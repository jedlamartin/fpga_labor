#include <stdint.h>
#include <stdio.h>
#include <sleep.h>
#include <xil_printf.h>
#include <xparameters.h>
#include <cmath>
#include <iostream>
#include <fstream>
#include <string>
#include <array>
#include <sstream>
#include "xil_cache.h"
#include "xaxidma_hw.h"
#include "xfir_hw.h"
#include "xfir_hw_hw.h"
#include "types.h"
#include "filter_coeffs.h"

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

constexpr uint32_t I2C_BASE_ADDR = XPAR_AXI_IIC_0_BASEADDR;
constexpr uint8_t I2C_DEV_ADDR = 0x4E;

// Fixed Offsets (Standard AXI IIC Map)
constexpr uint32_t I2C_SOFTR_OFFSET         = 0x040; // Soft Reset
constexpr uint32_t I2C_CR_OFFSET            = 0x100; // Control Register
constexpr uint32_t I2C_SR_OFFSET            = 0x104; // Status Register
constexpr uint32_t I2C_TX_FIFO_OFFSET       = 0x108; // Transmit FIFO (DTR)
constexpr uint32_t I2C_RX_FIFO_OFFSET       = 0x10C; // Receive FIFO (DRR)
constexpr uint32_t I2C_GPO_OFFSET           = 0x124; // GPO Register

// Bit Masks
constexpr uint32_t RKEY             = 0x0000000A;
constexpr uint32_t TX_RESET_MASK    = (1 << 1);
constexpr uint32_t EN_MASK          = (1 << 0);
constexpr uint32_t BB_MASK          = (1 << 2); // Bus Busy
constexpr uint32_t TX_EMPTY_MASK    = (1 << 7);
constexpr uint32_t RX_EMPTY_MASK    = (1 << 6);
constexpr uint32_t START_MASK       = (1 << 8);
constexpr uint32_t STOP_MASK        = (1 << 9);

constexpr uint32_t GPIO_BASE_ADDR = XPAR_AXI_GPIO_0_BASEADDR;
constexpr uint32_t EN_OFFSET = 0x00;

void i2c_init();
void i2c_write(uint8_t slv_addr, uint8_t reg_addr, uint8_t data);
uint8_t i2c_read(uint8_t slv_addr, uint8_t reg_addr);
void codec_init();

constexpr unsigned int smpl_rd_num = 3;
constexpr unsigned int coeff_size = (1 << (smpl_rd_num - 1)) * 128;

XFir_hw fir_ip;

int main() {
    i2c_init();
    sleep(1);

    if(XFir_hw_Initialize(&fir_ip, FIR_BASE_ADDR) != XST_SUCCESS) {
        xil_printf("FIR Init Failed\r\n");
        return -1;
    }

    const coeff_t* source_ptr;
    if constexpr (coeff_size == 128) {
        source_ptr = filter_128_data;
    } else if constexpr (coeff_size == 256) {
        source_ptr = filter_256_data;
    } else {
        source_ptr = filter_512_data;
    }


    word_type raw_coeffs[512];
    for (int i = 0; i < 512; i++) {
        // Extract the exact 32-bit integer representation of the fixed-point number
        raw_coeffs[i] = (word_type)source_ptr[i].range(31, 0).to_uint(); 
    }

    //word_type raw_coeffs[512] = {0};
    //raw_coeffs[0] = 0x7FFFFFFF;
    
    XFir_hw_Write_coeff_hw_Words(&fir_ip, 0, raw_coeffs, 512);    
    XFir_hw_Set_tap_num_m1(&fir_ip, coeff_size - 1);
    XFir_hw_Set_smpl_rd_num(&fir_ip, smpl_rd_num);
    XFir_hw_Set_tlast_dnum(&fir_ip, BLOCK_SIZE);

    xil_printf("Loaded 512 coeffs (Length: %d). System Ready.\r\n", coeff_size);

    codec_init();
    dma_init();

    int offs = 0;
    xil_printf("System Ready. Monitoring incoming audio blocks...\r\n");
    while(1) {
        dma_rcv(dma_rx_buf + offs, BLOCK_SIZE * DATA_LENGTH);
        dma_rcv_wait();
        Xil_DCacheInvalidateRange((INTPTR)(dma_rx_buf + offs), BLOCK_SIZE * DATA_LENGTH);

        offs += BLOCK_SIZE;
        if (offs + BLOCK_SIZE >= DMA_BUFFER_SIZE) {
            offs = 0;
            //xil_printf("--- Buffer Circular Wrap ---\r\n");
        }
    }
    return 0;
}


void dma_init(){
    MEM32(DMA_BASE_ADDR + XAXIDMA_TX_OFFSET + XAXIDMA_CR_OFFSET) = XAXIDMA_CR_RUNSTOP_MASK;
    MEM32(DMA_BASE_ADDR + XAXIDMA_RX_OFFSET + XAXIDMA_CR_OFFSET) = XAXIDMA_CR_RUNSTOP_MASK;
}
void dma_snd(void* src, uint32_t length){
    Xil_DCacheFlushRange((INTPTR)src, length);
    MEM32(DMA_BASE_ADDR + XAXIDMA_TX_OFFSET + XAXIDMA_SRCADDR_OFFSET) = (uint32_t)(uintptr_t)src;
    MEM32(DMA_BASE_ADDR + XAXIDMA_TX_OFFSET + XAXIDMA_SRCADDR_MSB_OFFSET) = (uint32_t)((uintptr_t)src >> 32);
    MEM32(DMA_BASE_ADDR + XAXIDMA_TX_OFFSET + XAXIDMA_BUFFLEN_OFFSET) = length;
}
void dma_rcv(void* dst, uint32_t length){
    Xil_DCacheInvalidateRange((INTPTR)dst, (INTPTR)length);
    MEM32(DMA_BASE_ADDR + XAXIDMA_RX_OFFSET + XAXIDMA_SRCADDR_OFFSET) = (uint32_t)(uintptr_t)dst;
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

void i2c_init() {
    // Reset the controller
    MEM32(I2C_BASE_ADDR + I2C_SOFTR_OFFSET) = RKEY;
    
    // Enable device, Reset TX FIFO
    MEM32(I2C_BASE_ADDR + I2C_CR_OFFSET) = EN_MASK | TX_RESET_MASK;
    
    // Release TX FIFO reset
    MEM32(I2C_BASE_ADDR + I2C_CR_OFFSET) &= ~TX_RESET_MASK;
}

void i2c_write(uint8_t slv_addr, uint8_t reg_addr, uint8_t data) {
    uint32_t status;
    
    // Wait for idle bus and empty TX FIFO
    do {
        status = MEM32(I2C_BASE_ADDR + I2C_SR_OFFSET);
    } while ((status & BB_MASK) || !(status & TX_EMPTY_MASK));
    
    // Sequence: [START + ADDR+W] -> [REG_ADDR] -> [STOP + DATA]
    MEM32(I2C_BASE_ADDR + I2C_TX_FIFO_OFFSET) = (START_MASK | (slv_addr << 1));
    MEM32(I2C_BASE_ADDR + I2C_TX_FIFO_OFFSET) = reg_addr;
    MEM32(I2C_BASE_ADDR + I2C_TX_FIFO_OFFSET) = (STOP_MASK | data);
    
    // Final wait to ensure it actually left the FIFO
    do {
        status = MEM32(I2C_BASE_ADDR + I2C_SR_OFFSET);
    } while (!(status & TX_EMPTY_MASK) || (status & BB_MASK));
}

uint8_t i2c_read(uint8_t slv_addr, uint8_t reg_addr) {
    uint32_t status;
    
    // Wait for idle bus
    do {
        status = MEM32(I2C_BASE_ADDR + I2C_SR_OFFSET);
    } while ((status & BB_MASK) || !(status & TX_EMPTY_MASK));

    // 1. Write register address (Start + Addr + W)
    MEM32(I2C_BASE_ADDR + I2C_TX_FIFO_OFFSET) = (START_MASK | (slv_addr << 1));
    MEM32(I2C_BASE_ADDR + I2C_TX_FIFO_OFFSET) = reg_addr; 
    
    // 2. Switch to Read (Repeated Start + Addr + R)
    MEM32(I2C_BASE_ADDR + I2C_TX_FIFO_OFFSET) = (START_MASK | (slv_addr << 1) | 0x01);
    
    // 3. Command 1 byte read with STOP
    MEM32(I2C_BASE_ADDR + I2C_TX_FIFO_OFFSET) = (STOP_MASK | 0x01);

    // 4. Wait until RX FIFO has data (RX_EMPTY_MASK goes to 0)
    do {
        status = MEM32(I2C_BASE_ADDR + I2C_SR_OFFSET);
    } while ((status & RX_EMPTY_MASK) ); 

    return (uint8_t)MEM32(I2C_BASE_ADDR + I2C_RX_FIFO_OFFSET); 
}

void codec_init() {
    // 1. Reset pulse: Pull GPO bit 0 low (Reset active)
    MEM32(I2C_BASE_ADDR + I2C_GPO_OFFSET) = 0x0000;
    usleep(1000); // 1 ms wait

    // 2. Release reset: Pull GPO bit 0 high (Reset inactive)
    MEM32(I2C_BASE_ADDR + I2C_GPO_OFFSET) = 0x0001;
    usleep(1000); // 1 ms wait for stabilization

    // 3. Write registers in the order specified in the table
    // i2c_write(slave_addr, reg_addr, data)

    // Set DAC control 1 register to 0x00
    i2c_write(I2C_DEV_ADDR, 0x03, 0x00); 
    
    // Set ADC control: Mode, data format, and operating speed
    i2c_write(I2C_DEV_ADDR, 0x04, 0x41); 
    
    // Set MCLK frequency: Configure MCLK input division
    i2c_write(I2C_DEV_ADDR, 0x05, 0x20); 
    
    // Signal selection: Set to use SDIN1 serial data input
    i2c_write(I2C_DEV_ADDR, 0x06, 0x00); 
    
    // Set PGA B gain: Adjust gain to -6.0 dB - 110100
    i2c_write(I2C_DEV_ADDR, 0x07, 0x34); 
    
    // Set PGA A gain: Adjust gain to -6.0 dB
    i2c_write(I2C_DEV_ADDR, 0x08, 0x34); 
    
    // ADC input control: Connect Line Input to the ADC
    i2c_write(I2C_DEV_ADDR, 0x09, 0x01); 
    
    // Set DAC A volume control to 0x00
    i2c_write(I2C_DEV_ADDR, 0x0a, 0x00); 
    
    // Set DAC B volume control to 0x00
    i2c_write(I2C_DEV_ADDR, 0x0b, 0x00); 
    
    // Set DAC control 2 register to 0x00
    i2c_write(I2C_DEV_ADDR, 0x0c, 0x00); 
    
    // Power control: Disable unused functions to save power
    i2c_write(I2C_DEV_ADDR, 0x02, 0x08); 

    // Enable with GPIO
    MEM32(GPIO_BASE_ADDR + EN_OFFSET) = 1;
}