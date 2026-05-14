#include <stdint.h>
#include <stdio.h>
#include "mpfs_hal/mss_hal.h"
#include "mpfs_hal/common/mss_l2_cache.h"
#include "mpfs_hal/common/mss_sysreg.h"

#define MEM32(addr) (*(volatile uint32_t *)(addr))

// The address you found in Libero Memory Map
#define MY_FABRIC_GPIO_BASE    0x40000000UL

// Offsets for 32-bit APB Data Width
#define GPIO_IN_REG         0x90
#define GPIO_OUT_REG        0xA0

#define DMA_BUFFER_SIZE         (1024 * 1024)

//uint8_t dma_tx_buf[DMA_BUFFER_SIZE] __attribute__((aligned(128), section(".ddr_non_cached_32bit")));
//uint8_t dma_rx_buf[DMA_BUFFER_SIZE] __attribute__((aligned(128), section(".ddr_non_cached_32bit")));

#define TX_BUF_ADDR  0xC0000000UL
#define RX_BUF_ADDR  0xC0100000UL
#define TX_BUF_PHYS_ADDR  0x80000000UL
#define RX_BUF_PHYS_ADDR  0x80100000UL

#define PROTOCONV_BASE_ADDR   0xE0000000UL

// --- S2MM (RX - Stream to Memory Mapped) Offsets ---
#define PROTOCONV_S2MM_CTRL_OFFSET   0x0010
#define PROTOCONV_S2MM_STS_OFFSET    0x0014
#define PROTOCONV_S2MM_LEN_OFFSET    0x0018
#define PROTOCONV_S2MM_ADDR0_OFFSET  0x001C
#define PROTOCONV_S2MM_ADDR1_OFFSET  0x0020

// --- MM2S (TX - Memory Mapped to Stream) Offsets ---
#define PROTOCONV_MM2S_CTRL_OFFSET   0x0410
#define PROTOCONV_MM2S_STS_OFFSET    0x0414
#define PROTOCONV_MM2S_LEN_OFFSET    0x0418
#define PROTOCONV_MM2S_ADDR0_OFFSET  0x041C
#define PROTOCONV_MM2S_ADDR1_OFFSET  0x0420

#define PROTOCONV_START_BIT          0x00000001
#define PROTOCONV_INCR_BURST         0x00000002
#define PROTOCONV_DONE_BIT           0x00000001

void dma_snd(void* src, uint32_t length);
void dma_rcv(void* dst, uint32_t length);
void dma_snd_wait(void);
void dma_rcv_wait(void* dst, uint32_t length);
void mem_cmp(void *buf1, void *buf2, uint32_t length);
void cache_flush(uintptr_t addr, uint32_t length);
void cache_invalidate(uintptr_t addr, uint32_t length);

void dma_test(void){

    uint32_t gpio_val;
    char msg[64];

    //gpio_val = MEM32(MY_FABRIC_GPIO_BASE + GPIO_IN_REG);
    //sprintf(msg, "DEBUG: GPIO Initial Value = 0x%08X\r\n", gpio_val);
    //MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg);

    //MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)"GATE: Press and HOLD Button 0 to continue...\r\n");

    //while( MEM32(MY_FABRIC_GPIO_BASE + GPIO_IN_REG) == gpio_val ) {}

    MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)"Started DMA test!\r\n");


    uint8_t* p_tx = (uint8_t *)TX_BUF_PHYS_ADDR;
    uint8_t* p_rx = (uint8_t *)RX_BUF_PHYS_ADDR;

    for(int i = 0; i < DMA_BUFFER_SIZE; ++i){
        p_tx[i] = (unsigned char)(i & 0xff);
        p_rx[i] = 0x00;
    }

    mem_cmp(p_tx, p_rx, DMA_BUFFER_SIZE);

    dma_rcv(p_rx, 128);

    // Remove ------------------
    uint32_t s2mm_sts = MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_STS_OFFSET);

    sprintf(msg, "S2MM Status: 0x%08X\r\n", s2mm_sts);
    MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg);

    uint32_t axi_err = (s2mm_sts >> 2) & 0x03;
    if (axi_err == 2){ sprintf(msg, "Hardware Error: SLVERR (Slave Error)\r\n"); MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg); }
    else if (axi_err == 3){ sprintf(msg, "Hardware Error: DECERR (Decode Error - Routing blocked!)\r\n"); MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg); }
    //----------------------------

    dma_snd(p_tx, 128);
    dma_rcv_wait(p_rx, 128);
    dma_snd_wait();

    mem_cmp(p_tx, p_rx, 128);

    for(int i=0; i<1024/128; ++i){
        dma_rcv(p_rx + i * 128, 128);
        dma_snd(p_tx + i * 128, 128);
        dma_rcv_wait(p_rx + i * 128, 128);
        dma_snd_wait();
    }

    mem_cmp(p_tx, p_rx, 1024);

    dma_rcv(p_rx, 1024);
    dma_snd(p_tx, 1024);
    dma_rcv_wait(p_rx, 1024);
    dma_snd_wait();

    mem_cmp(p_tx, p_rx, 1024);

}


void dma_snd(void* src, uint32_t length){
    uintptr_t addr = (uintptr_t)src;

    // FLUSH CACHE BEFORE SENDING
    cache_flush(addr, length);

    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_CTRL_OFFSET) = 0;

    // MM2S = Transmit (Send)
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_ADDR0_OFFSET) = (uint32_t)addr;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_ADDR1_OFFSET) = (uint32_t)(addr >> 32);
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_LEN_OFFSET) = length;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_CTRL_OFFSET) = PROTOCONV_INCR_BURST | PROTOCONV_START_BIT;
}

void dma_rcv(void* dst, uint32_t length){
    uintptr_t addr = (uintptr_t)dst;

    // S2MM = Receive
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_ADDR0_OFFSET) = (uint32_t)addr;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_ADDR1_OFFSET) = (uint32_t)(addr >> 32); // Likely 0
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_LEN_OFFSET) = length;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_CTRL_OFFSET) = PROTOCONV_INCR_BURST | PROTOCONV_START_BIT;
}

void dma_snd_wait(void){
    // Wait WHILE the done bit is 0
    while((MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_STS_OFFSET) & PROTOCONV_DONE_BIT) == 0){}
    __asm volatile ("fence iorw, iorw" ::: "memory");
}

void dma_rcv_wait(void* dst, uint32_t length){
    // Wait WHILE the done bit is 0
    while((MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_STS_OFFSET) & PROTOCONV_DONE_BIT) == 0){}
    // INVALIDATE CACHE BEFORE RECEIVING
    cache_invalidate((uintptr_t)dst, length);
    __asm volatile ("fence iorw, iorw" ::: "memory");
}

void mem_cmp(void *buf1, void *buf2, uint32_t length){
    uint8_t *ptr1 = (uint8_t *)buf1;
    uint8_t *ptr2 = (uint8_t *)buf2;
    char msg[128];

    for (uint32_t i = 0; i < length; i++){
        if (ptr1[i] != ptr2[i]) {
                    sprintf(msg, "FAIL: index %u, expected 0x%02x, got 0x%02x\r\n", i, ptr1[i], ptr2[i]);
                    MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg);
                    return;
                }
    }

    MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)"SUCCESS: Buffers match!\r\n");
}

/* FLUSH: Use before DMA Transmit (CPU -> DDR) */
void cache_flush(uintptr_t addr, uint32_t length) {
    // Force physical address (0x8...) for the L2 Cache Controller
    uintptr_t phys_addr = addr & ~0x40000000ULL;
    uintptr_t start = phys_addr & ~(64ULL - 1);
    uintptr_t end = phys_addr + length;

    for (uintptr_t curr = start; curr < end; curr += 64) {
        CACHE_CTRL->FLUSH64 = curr;
    }
    // "fence iorw, iorw" ensures all previous writes to DDR are finished
    __asm volatile ("fence iorw, iorw" ::: "memory");
}

/* INVALIDATE: Use after DMA Receive (DDR -> CPU) */
void cache_invalidate(uintptr_t addr, uint32_t length) {
    // Force physical address (0x8...) for the L2 Cache Controller
    uintptr_t phys_addr = addr & ~0x40000000ULL;
    uintptr_t start = phys_addr & ~(64ULL - 1);
    uintptr_t end = phys_addr + length;

    for (uintptr_t curr = start; curr < end; curr += 64) {
        CACHE_CTRL->FLUSH64 = curr;
    }
    // "fence r, r" ensures the CPU re-fetches from DDR for the next read
    __asm volatile ("fence r, r" ::: "memory");
}
