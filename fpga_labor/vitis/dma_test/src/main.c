#include <xparameters.h>
#include <stdint.h>
#include <xil_cache.h>
#include <xaxidma_hw.h>
#include <stdio.h>

#define MEM32(addr) (*(volatile uint32_t *)(addr))

#define DMA_BUFFER_SIZE         (1024 * 1024)

uint8_t dma_tx_buf[DMA_BUFFER_SIZE] __attribute__((aligned(128)));
uint8_t dma_rx_buf[DMA_BUFFER_SIZE] __attribute__((aligned(128)));

#define DMA_BASE_ADDR XPAR_AXI_DMA_0_BASEADDR

void dma_init();
void dma_snd(void* src, uint32_t length);
void dma_rcv(void* dst, uint32_t length);
void dma_snd_wait();
void dma_rcv_wait();
void mem_cmp(void *buf1, void *buf2, uint32_t length);

int main(){
    
    dma_init();

	for(int i = 0; i < DMA_BUFFER_SIZE; ++i){
		dma_tx_buf[i] = (unsigned char)(i & 0xff);
		dma_rx_buf[i] = 0x00;
	}

    mem_cmp(dma_tx_buf, dma_rx_buf, DMA_BUFFER_SIZE);

    dma_snd(dma_tx_buf, 128);
    dma_rcv(dma_rx_buf, 128);
    dma_snd_wait();
    dma_rcv_wait();

    mem_cmp(dma_tx_buf, dma_rx_buf, 128);
    
    Xil_DCacheFlushRange((INTPTR)dma_tx_buf, 1024);
    Xil_DCacheInvalidateRange((INTPTR)dma_rx_buf, 1024);    
    for(int i=0; i<1024/128;++i){
        dma_snd(dma_tx_buf + i * 128, 128);
        dma_rcv(dma_rx_buf + i * 128, 128);
        dma_snd_wait();
        dma_rcv_wait();
    }
    
    mem_cmp(dma_tx_buf, dma_rx_buf, 1024);

    dma_snd(dma_tx_buf, 1024);
    dma_rcv(dma_rx_buf, 1024);
    dma_snd_wait();
    dma_rcv_wait();
    
    mem_cmp(dma_tx_buf, dma_rx_buf, 1024);

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
