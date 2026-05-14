#ifndef APP_MAIN_H
#define APP_MAIN_H

#include "mpfs_hal/mss_hal.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void init(void);
void i2c_init(void);
void i2c_write(uint8_t slv_addr, uint8_t reg_addr, uint8_t data);
uint8_t i2c_read(uint8_t slv_addr, uint8_t reg_addr);
void codec_init(void);

#ifdef __cplusplus
}
#endif

#endif /* APP_MAIN_H */
