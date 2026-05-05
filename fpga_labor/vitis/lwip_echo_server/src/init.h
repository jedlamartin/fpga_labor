/* init.h */
#ifndef __INIT_H_
#define __INIT_H_

#include <stdint.h>
#include <stdio.h>
#include <sleep.h>

#ifdef __cplusplus
extern "C" {
#endif

// Shared function prototypes for main.c
void codec_init();
void dma_init();
void dma_snd(void* src, uint32_t length);
void dma_rcv(void* dst, uint32_t length);
void dma_snd_wait();
void dma_rcv_wait();
int start_application();
void print_app_header();
int transfer_data();
void set_transfer_flag();

// Use void* to hide C++ classes/structs (like XFir_hw) from main.c
void FIR_init(void* fir_ip_ptr);

// Standardize types for C/C++ linking
extern volatile uint8_t dma_data_available; 
extern unsigned char* dma_ptr_eth;
int dma_it_init(unsigned char *buff, unsigned long buff_size, unsigned long transfer_size);

#ifdef __cplusplus
}
#endif

#endif /* __INIT_H_ */