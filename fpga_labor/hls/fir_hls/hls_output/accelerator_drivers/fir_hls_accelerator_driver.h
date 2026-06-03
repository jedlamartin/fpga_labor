#ifndef _FIR_HLS_ACCELERATOR_DRIVER_H
#define _FIR_HLS_ACCELERATOR_DRIVER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "fir_hls_memory_map.h"


void fir_hw_write_tlast_dnum(uint16_t val,  uint32_t base_addr = FIR_HW_BASE_ADDR);
uint16_t fir_hw_read_tlast_dnum(uint32_t base_addr = FIR_HW_BASE_ADDR);

void fir_hw_write_smpl_rd_num(uint8_t val,  uint32_t base_addr = FIR_HW_BASE_ADDR);
uint8_t fir_hw_read_smpl_rd_num(uint32_t base_addr = FIR_HW_BASE_ADDR);

void fir_hw_write_tap_num_m1(uint16_t val,  uint32_t base_addr = FIR_HW_BASE_ADDR);
uint16_t fir_hw_read_tap_num_m1(uint32_t base_addr = FIR_HW_BASE_ADDR);

void fir_hw_memcpy_write_coeff_hw(void* coeff_hw, uint64_t byte_size, uint32_t base_addr = FIR_HW_BASE_ADDR);
void fir_hw_memcpy_read_coeff_hw(void* coeff_hw, uint64_t byte_size, uint32_t base_addr = FIR_HW_BASE_ADDR);
void fir_hw_dma_write_coeff_hw(void* coeff_hw, uint64_t byte_size, uint32_t base_addr = FIR_HW_BASE_ADDR);
void fir_hw_dma_read_coeff_hw(void* coeff_hw, uint64_t byte_size, uint32_t base_addr = FIR_HW_BASE_ADDR);
#ifdef __cplusplus
}
#endif

#endif
