#ifndef _BYPASS_HLS_ACCELERATOR_DRIVER_H
#define _BYPASS_HLS_ACCELERATOR_DRIVER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "bypass_hls_memory_map.h"


void bypass_hw_write_tlast_dnum(uint16_t val,  uint32_t base_addr = BYPASS_HW_BASE_ADDR);
uint16_t bypass_hw_read_tlast_dnum(uint32_t base_addr = BYPASS_HW_BASE_ADDR);
#ifdef __cplusplus
}
#endif

#endif
