#include <stdint.h>
#include <stdio.h>
#include "xparameters.h"
#include "xil_cache.h"
#include "xaxidma_hw.h"
#include "xfir_hw.h"
#include "xfir_hw_hw.h"
#define MEM32(addr) (*(volatile uint32_t *)(addr))

#define DMA_BUFFER_SIZE         (1024 * 1024)

#define BLOCK_SIZE 256
#define DATA_LENGTH 4 //bytes


uint32_t dma_rx_buf[DMA_BUFFER_SIZE] __attribute__((aligned(128)));

#define DMA_BASE_ADDR XPAR_AXI_DMA_0_BASEADDR
#define FIR_BASE_ADDR XPAR_FIR_HW_0_BASEADDR

void dma_init();
void dma_snd(void* src, uint32_t length);
void dma_rcv(void* dst, uint32_t length);
void dma_snd_wait();
void dma_rcv_wait();
void mem_cmp(void *buf1, void *buf2, uint32_t length);

XFir_hw fir_hw;

int main(){
    
    dma_init();

    int status = XFir_hw_Initialize(&fir_hw, FIR_BASE_ADDR);
    if(status != XST_SUCCESS){
        xil_printf("Error: FIR Initialization failed!\r\n");
        return -1;
    }

    XFir_hw_Set_tlast_dnum(&fir_hw, BLOCK_SIZE);

    int offs = 0;
    xil_printf("Starting continuous reception...\r\n");
    
    while(1){
        dma_rcv(dma_rx_buf + offs, BLOCK_SIZE * DATA_LENGTH);
        dma_rcv_wait();

        xil_printf("--- New Block at Offset %d ---\r\n", offs);
        for(int i = 0; i < BLOCK_SIZE; i++) {
            xil_printf("  Sample[%d]: 0x%08x\r\n", i, dma_rx_buf[offs + i]);
        }
        
        offs += BLOCK_SIZE;
        if (offs + BLOCK_SIZE >= DMA_BUFFER_SIZE) {
            offs = 0;
            xil_printf("--- Buffer Wrapped ---\r\n");
        }
    }

}


void dma_init(){
    MEM32(DMA_BASE_ADDR + XAXIDMA_TX_OFFSET + XAXIDMA_CR_OFFSET) = XAXIDMA_CR_RUNSTOP_MASK;
    MEM32(DMA_BASE_ADDR + XAXIDMA_RX_OFFSET + XAXIDMA_CR_OFFSET) = XAXIDMA_CR_RUNSTOP_MASK;
}
void dma_snd(void* src, uint32_t length){
    Xil_DCacheFlushRange((INTPTR)src, length);
    MEM32(DMA_BASE_ADDR + XAXIDMA_TX_OFFSET + XAXIDMA_SRCADDR_OFFSET) = (uint32_t)src;
    MEM32(DMA_BASE_ADDR + XAXIDMA_TX_OFFSET + XAXIDMA_SRCADDR_MSB_OFFSET) = (uint32_t)((uintptr_t)src >> 32);
    MEM32(DMA_BASE_ADDR + XAXIDMA_TX_OFFSET + XAXIDMA_BUFFLEN_OFFSET) = length;
}
void dma_rcv(void* dst, uint32_t length){
    Xil_DCacheInvalidateRange((INTPTR)dst, (INTPTR)length);
    MEM32(DMA_BASE_ADDR + XAXIDMA_RX_OFFSET + XAXIDMA_SRCADDR_OFFSET) = (uint32_t)dst;
    MEM32(DMA_BASE_ADDR + XAXIDMA_RX_OFFSET + XAXIDMA_SRCADDR_MSB_OFFSET) = (uint32_t)((uintptr_t)dst >> 32);
    MEM32(DMA_BASE_ADDR + XAXIDMA_RX_OFFSET + XAXIDMA_BUFFLEN_OFFSET) = length;
}
void dma_snd_wait(){
    for(;;){
        if(MEM32(DMA_BASE_ADDR + XAXIDMA_TX_OFFSET + XAXIDMA_SR_OFFSET) & XAXIDMA_IDLE_MASK){
            break;
        }
    }
}
void dma_rcv_wait(){
    for(;;){
        if(MEM32(DMA_BASE_ADDR + XAXIDMA_RX_OFFSET + XAXIDMA_SR_OFFSET) & XAXIDMA_IDLE_MASK){
            break;
        }
    }
}
void mem_cmp(void *buf1, void *buf2, uint32_t length){
	uint8_t *ptr1 = (uint8_t *)buf1;
	uint8_t *ptr2 = (uint8_t *)buf2;
	uint32_t i;

	for (i = 0; i < length; i++)
	{
		if (ptr1[i] != ptr2[i])
		{
			xil_printf(
				"mem_cmp(): Compare error! buf1[%d]=0x%02x, buf2[%d]=0x%02x\r\n",
				i,
				ptr1[i],
				i,
				ptr2[i]
			);
			return;
		}
	}

	xil_printf("mem_cmp(): Content of the buffers is the same.\r\n");
}
