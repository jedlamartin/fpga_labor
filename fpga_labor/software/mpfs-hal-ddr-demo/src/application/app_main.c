#include <stdint.h>
#include <stdio.h>
#include "mpfs_hal/mss_hal.h"
#include "mpfs_hal/common/mss_l2_cache.h"

#define MEM32(addr) (*(volatile uint32_t *)(addr))

#define DMA_BUFFER_SIZE         (1024 * 1024)

uint8_t dma_tx_buf[DMA_BUFFER_SIZE] __attribute__((aligned(128), section(".ddr_cached_32bit")));
uint8_t dma_rx_buf[DMA_BUFFER_SIZE] __attribute__((aligned(128), section(".ddr_cached_32bit")));

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
#define PROTOCONV_DONE_BIT           0x00000001

void dma_snd(void* src, uint32_t length);
void dma_rcv(void* dst, uint32_t length);
void dma_snd_wait(void);
void dma_rcv_wait(void* dst, uint32_t length);
void mem_cmp(void *buf1, void *buf2, uint32_t length);
void cache_flush(uintptr_t addr, uint32_t length);
void cache_invalidate(uintptr_t addr, uint32_t length);

void dma_test(void){
    for(int i = 0; i < DMA_BUFFER_SIZE; ++i){
        dma_tx_buf[i] = (unsigned char)(i & 0xff);
        dma_rx_buf[i] = 0x00;
    }

    mem_cmp(dma_tx_buf, dma_rx_buf, DMA_BUFFER_SIZE);

    dma_rcv(dma_rx_buf, 128);
    dma_snd(dma_tx_buf, 128);
    dma_rcv_wait(dma_rx_buf, 128);
    dma_snd_wait();

    mem_cmp(dma_tx_buf, dma_rx_buf, 128);

    for(int i=0; i<1024/128; ++i){
        dma_rcv(dma_rx_buf + i * 128, 128);
        dma_snd(dma_tx_buf + i * 128, 128);
        dma_rcv_wait(dma_rx_buf + i * 128, 128);
        dma_snd_wait();
    }

    mem_cmp(dma_tx_buf, dma_rx_buf, 1024);

    dma_rcv(dma_rx_buf, 1024);
    dma_snd(dma_tx_buf, 1024);
    dma_rcv_wait(dma_rx_buf, 1024);
    dma_snd_wait();

    mem_cmp(dma_tx_buf, dma_rx_buf, 1024);

}


void dma_snd(void* src, uint32_t length){
    // FLUSH CACHE BEFORE SENDING
    cache_flush((uintptr_t)src, length);

    // MM2S = Transmit (Send)
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_ADDR0_OFFSET) = (uint32_t)(uintptr_t)src;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_ADDR1_OFFSET) = (uint32_t)((uintptr_t)src >> 32);
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_LEN_OFFSET) = length;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_CTRL_OFFSET) = PROTOCONV_START_BIT;
}

void dma_rcv(void* dst, uint32_t length){
    // S2MM = Receive
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_ADDR0_OFFSET) = (uint32_t)(uintptr_t)dst;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_ADDR1_OFFSET) = (uint32_t)((uintptr_t)dst >> 32);
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_LEN_OFFSET) = length;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_CTRL_OFFSET) = PROTOCONV_START_BIT;
}

void dma_snd_wait(void){
    // Wait WHILE the done bit is 0
    while((MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_STS_OFFSET) & PROTOCONV_DONE_BIT) == 0){}
}

void dma_rcv_wait(void* dst, uint32_t length){
    // Wait WHILE the done bit is 0
    while((MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_STS_OFFSET) & PROTOCONV_DONE_BIT) == 0){}
    // INVALIDATE CACHE BEFORE RECEIVING
    cache_invalidate((uintptr_t)dst, length);
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
    uintptr_t start = addr & ~(64ULL - 1);
    uintptr_t end = addr + length;

    for (uintptr_t curr = start; curr < end; curr += 64) {
        CACHE_CTRL->FLUSH64 = curr;
    }
    // "fence iorw, iorw" ensures all previous writes to DDR are finished
    __asm volatile ("fence iorw, iorw" ::: "memory");
}

/* INVALIDATE: Use after DMA Receive (DDR -> CPU) */
void cache_invalidate(uintptr_t addr, uint32_t length) {
    uintptr_t start = addr & ~(64ULL - 1);
    uintptr_t end = addr + length;

    for (uintptr_t curr = start; curr < end; curr += 64) {
        CACHE_CTRL->FLUSH64 = curr;
    }
    // "fence r, r" ensures the CPU re-fetches from DDR for the next read
    __asm volatile ("fence r, r" ::: "memory");
}
