#ifndef DMA_H
#define DMA_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// --- Hardware Address Map from Libero ---
#define HLS_BYPASS_BASE_ADDR    0xE0010000UL

// --- Application Constants ---
#define BLOCK_SIZE              256
#define DATA_LENGTH             4
#define DMA_BUFFER_SIZE         (1024 * 1024)
#define TX_BUF_PHYS_ADDR        0x80000000UL
#define RX_BUF_PHYS_ADDR        0x80100000UL

// --- System Lifecycle Prototypes ---
void init(void);
void i2c_init(void);
void i2c_write(uint8_t slv_addr, uint8_t reg_addr, uint8_t data);
uint8_t i2c_read(uint8_t slv_addr, uint8_t reg_addr);
void codec_init(void);

// --- DMA Pipeline Prototypes ---
void dma_snd(void* src, uint32_t length);
void dma_rcv(void* dst, uint32_t length);
void dma_snd_wait(void);
void dma_rcv_wait(void* dst, uint32_t length);
void mem_cmp(void *buf1, void *buf2, uint32_t length);
int dma_it_init(unsigned char *buff, unsigned long buff_size, unsigned long transfer_size);

#ifdef __cplusplus
}
#endif

#endif /* DMA_H */
