#ifndef __INIT_H_
#define __INIT_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Standard C Interface main.c uses */
void print_app_header();
void codec_init();
void dma_init();
int start_application();
int transfer_data();
void set_transfer_flag();
void FIR_init(void* fir_ip_ptr); 

extern volatile uint8_t dma_data_available;
extern unsigned char* dma_ptr_eth;
int dma_it_init(unsigned char *buff, unsigned long buff_size, unsigned long transfer_size);

#ifdef __cplusplus
}
#endif

/* --- C++ ONLY Logic: main.c will ignore this block --- */
#if defined(__cplusplus) && !defined(_MAIN_C_)  
#include "xfir_hw.h"
#include "ap_int.h"    /* Only true C++ files see this now */
#include "types.h"
#include "filter_coeffs.h"

constexpr unsigned int smpl_rd_num = 3; 
constexpr unsigned int coeff_size = (1 << (smpl_rd_num - 1)) * 128;
#endif

#endif