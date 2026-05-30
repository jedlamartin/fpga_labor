// This file has been updated to support standard C and 64-bit RISC-V pointer casting

#include "bypass_hls_accelerator_driver.h"
#include <stdint.h>

/**
 * Writes the TLAST sample threshold value to the HLS block.
 * Uses (uintptr_t) to safely cast the 32-bit AXI address into a 64-bit pointer.
 */
void bypass_hw_write_tlast_dnum(uint16_t val, uint32_t base_addr) {
    *(volatile uint16_t *)(uintptr_t)(base_addr + 0x0) = (volatile uint16_t)val;
}

/**
 * Reads the TLAST sample threshold value back from the HLS block.
 */
uint16_t bypass_hw_read_tlast_dnum(uint32_t base_addr) {
    return *(volatile uint16_t *)(uintptr_t)(base_addr + 0x0);
}
