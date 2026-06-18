#include "app_main.h"

#define MEM32(addr) (*(volatile uint32_t *)(addr))
#define MEM8(addr) (*(volatile uint8_t *)(addr))

constexpr uint32_t I2C_BASE_ADDR = 0x41000000;
constexpr uint8_t I2C_DEV_ADDR = 0x4E;

// Fixed Offsets (Standard AXI IIC Map)
constexpr uint32_t I2C_CTRL_OFFSET  = 0x00;
constexpr uint32_t I2C_STAT_OFFSET  = 0x04;
constexpr uint32_t I2C_DATA_OFFSET  = 0x08;
constexpr uint32_t I2C_ADDR0_OFFSET = 0x0C;

// Control Register Bit Masks (CTRL)
constexpr uint8_t CTRL_CR2   = (1 << 7); // Clock Rate 2
constexpr uint8_t CTRL_ENS1  = (1 << 6); // Enable I2C Serial System
constexpr uint8_t CTRL_STA   = (1 << 5); // Start Flag
constexpr uint8_t CTRL_STO   = (1 << 4); // Stop Flag
constexpr uint8_t CTRL_SI    = (1 << 3); // Serial Interrupt (Clear to proceed)
constexpr uint8_t CTRL_AA    = (1 << 2); // Assert Acknowledge
constexpr uint8_t CTRL_CR1   = (1 << 1); // Clock Rate 1
constexpr uint8_t CTRL_CR0   = (1 << 0); // Clock Rate 0

// Common Status Codes (STAT)
constexpr uint8_t STAT_START_SENT    = 0x08;
constexpr uint8_t STAT_REP_START_SENT = 0x10;
constexpr uint8_t STAT_SLAW_ACK      = 0x18; // Slave Address Write Acked
constexpr uint8_t STAT_SLAW_NACK      = 0x20; // Slave Address Write NAcked
constexpr uint8_t STAT_DATAW_ACK     = 0x28; // Data Write Acked
constexpr uint8_t STAT_SLAR_ACK      = 0x40; // Slave Address Read Acked
constexpr uint8_t STAT_DATAR_ACK     = 0x50; // Data Read Acked
constexpr uint8_t STAT_DATAR_NACK    = 0x58; // Data Read NACK (End of read)
constexpr uint8_t STAT_IDLE          = 0xF8;

constexpr uint32_t GPIO_BASE_ADDR = 0x40000000;
constexpr uint32_t GPO_CFG_OFFSET = 0x00;
constexpr uint32_t EN_CFG_OFFSET = 0x04;
constexpr uint32_t OUT_OFFSET = 0xA0;
constexpr uint8_t GPO_MASK = (1 << 0);
constexpr uint8_t EN_MASK = (1 << 1);


//constexpr uint32_t DMA_BUFFER_SIZE = (1024 * 1024);

//uint8_t dma_tx_buf[DMA_BUFFER_SIZE] __attribute__((aligned(128), section(".ddr_non_cached_32bit")));
//uint8_t dma_rx_buf[DMA_BUFFER_SIZE] __attribute__((aligned(128), section(".ddr_non_cached_32bit")));

constexpr uint32_t TX_BUF_ADDR = 0xC0000000UL;
constexpr uint32_t RX_BUF_ADDR = 0xC0100000UL;

constexpr uint32_t PROTOCONV_BASE_ADDR = 0xE0000000UL;

// --- S2MM (RX - Stream to Memory Mapped) Offsets ---
constexpr uint32_t PROTOCONV_S2MM_CTRL_OFFSET = 0x0010;
constexpr uint32_t PROTOCONV_S2MM_STS_OFFSET =  0x0014;
constexpr uint32_t PROTOCONV_S2MM_LEN_OFFSET =  0x0018;
constexpr uint32_t PROTOCONV_S2MM_ADDR0_OFFSET = 0x001C;
constexpr uint32_t PROTOCONV_S2MM_ADDR1_OFFSET = 0x0020;

// --- MM2S (TX - Memory Mapped to Stream) Offsets ---
constexpr uint32_t PROTOCONV_MM2S_CTRL_OFFSET = 0x0410;
constexpr uint32_t PROTOCONV_MM2S_STS_OFFSET =  0x0414;
constexpr uint32_t PROTOCONV_MM2S_LEN_OFFSET =  0x0418;
constexpr uint32_t PROTOCONV_MM2S_ADDR0_OFFSET = 0x041C;
constexpr uint32_t PROTOCONV_MM2S_ADDR1_OFFSET = 0x0420;

constexpr uint32_t PROTOCONV_START_BIT = 0x00000001;
constexpr uint32_t PROTOCONV_INCR_BURST = 0x00000002;
constexpr uint32_t PROTOCONV_DONE_BIT = 0x00000001;

constexpr uint32_t FIR_HLS_BASE_ADDR = 0xE0010000UL;

//constexpr uint32_t BLOCK_SIZE = 256;
//constexpr uint32_t DATA_LENGTH = 4; //bytes

constexpr unsigned int smpl_rd_num = 3;
constexpr unsigned int coeff_size = (1 << (smpl_rd_num - 1)) * 128;

void cache_invalidate(uintptr_t addr, uint32_t length);
void cache_flush(uintptr_t addr, uint32_t length);

void init(){
    i2c_init();
    sleep_ms(1000);
    const double* source_ptr = filter_512_data;

    if constexpr (coeff_size == 128) {
        source_ptr = filter_128_data;
    } else if constexpr (coeff_size == 256) {
        source_ptr = filter_256_data;
    } else {
        source_ptr = filter_512_data;
    }

    const int FRACTIONAL_BITS = 30;
    const double SCALING_FACTOR = (double)(1ULL << FRACTIONAL_BITS);

    int32_t raw_coeffs[512];
    for (int i = 0; i < coeff_size; i++) {
        raw_coeffs[i] = (int32_t)(source_ptr[i] * SCALING_FACTOR);
    }

    fir_hw_memcpy_write_coeff_hw(raw_coeffs, 512 * sizeof(int32_t), FIR_HLS_BASE_ADDR);
    fir_hw_write_tap_num_m1(coeff_size - 1, FIR_HLS_BASE_ADDR);
    fir_hw_write_smpl_rd_num(smpl_rd_num, FIR_HLS_BASE_ADDR);
    fir_hw_write_tlast_dnum(BLOCK_SIZE, FIR_HLS_BASE_ADDR);

    codec_init();
    volatile uint8_t read_val = i2c_read(I2C_DEV_ADDR, 0x04);
}

void i2c_init() {
    /* * Target: ~100kHz SCL
       * Divider: 960 (CR2=1, CR1=0, CR0=0)
       * ENS1: Enable (bit 6) */
    volatile uint8_t stat = MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET);
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_ENS1 | CTRL_CR2;
}

constexpr uint8_t CTRL_BASE = CTRL_ENS1 | CTRL_CR2;
void i2c_write(uint8_t slv_addr, uint8_t reg_addr, uint8_t data) {
    // 1. Send START
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STA;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    if (MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET) != STAT_START_SENT) {
        MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
        while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO); // Wait for hardware STOP
        sleep_cycles(100000);
        return;
    }

    // 2. Send Slave Address + W
    MEM8(I2C_BASE_ADDR + I2C_DATA_OFFSET) = (slv_addr << 1);
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    if (MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET) != STAT_SLAW_ACK) {
        MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
        while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
        sleep_cycles(100000);
        return;
    }

    // 3. Send Register Address
    MEM8(I2C_BASE_ADDR + I2C_DATA_OFFSET) = reg_addr;
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    if (MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET) != STAT_DATAW_ACK) {
        MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
        while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
        sleep_cycles(100000);
        return;
    }

    // 4. Send Data
    MEM8(I2C_BASE_ADDR + I2C_DATA_OFFSET) = data;
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    if (MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET) != STAT_DATAW_ACK) {
        MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
        while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
        sleep_cycles(100000);
        return;
    }

    // 5. STOP
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
    while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
    sleep_cycles(100000); // 1ms delay for copper wires to physically pull up
}


uint8_t i2c_read(uint8_t slv_addr, uint8_t reg_addr) {
    uint8_t received_data = 0;

    // 1. Send START
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STA;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    if (MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET) != STAT_START_SENT) {
        MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
        while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
        sleep_cycles(100000);
        return 0;
    }

    // 2. Send Slave Address + W
    MEM8(I2C_BASE_ADDR + I2C_DATA_OFFSET) = (slv_addr << 1);
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    if (MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET) != STAT_SLAW_ACK) {
        MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
        while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
        sleep_cycles(100000);
        return 0;
    }

    // 3. Send Register Address
    MEM8(I2C_BASE_ADDR + I2C_DATA_OFFSET) = reg_addr;
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    if (MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET) != STAT_DATAW_ACK) {
        MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
        while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
        sleep_cycles(100000);
        return 0;
    }

    // 4. Repeated START
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STA;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    if (MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET) != STAT_REP_START_SENT) {
        MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
        while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
        sleep_cycles(100000);
        return 0;
    }

    // 5. Send Slave Address + R
    MEM8(I2C_BASE_ADDR + I2C_DATA_OFFSET) = (slv_addr << 1) | 0x01;
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    if (MEM8(I2C_BASE_ADDR + I2C_STAT_OFFSET) != STAT_SLAR_ACK) {
        MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
        while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
        sleep_cycles(100000);
        return 0;
    }

    // 6. Receive Data Byte (Omitting CTRL_AA forces a NACK to tell slave to stop)
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE;
    while (!(MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_SI));

    // Save the data before sending STOP!
    received_data = MEM8(I2C_BASE_ADDR + I2C_DATA_OFFSET);

    // 7. STOP
    MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) = CTRL_BASE | CTRL_STO;
    while (MEM8(I2C_BASE_ADDR + I2C_CTRL_OFFSET) & CTRL_STO);
    sleep_cycles(100000);

    return received_data;
}

void codec_init() {
    // 1. Reset pulse: Pull GPO bit 0 low (Reset active)
    MEM32(GPIO_BASE_ADDR + OUT_OFFSET) &= ~GPO_MASK;
    sleep_ms(1000);  // ~1ms

    // 2. Release reset: Pull GPO bit 0 high (Reset inactive)
    MEM32(GPIO_BASE_ADDR + OUT_OFFSET) |= GPO_MASK;
    sleep_ms(1000);  // ~1ms

    // 3. Write registers in the order specified in the table
    // i2c_write(slave_addr, reg_addr, data)

    // Set DAC control 1 register to 0x00
    i2c_write(I2C_DEV_ADDR, 0x03, 0x00);

    // Set ADC control: Mode, data format, and operating speed
    i2c_write(I2C_DEV_ADDR, 0x04, 0x41);

    // Set MCLK frequency: Configure MCLK input division
    i2c_write(I2C_DEV_ADDR, 0x05, 0x10);

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

    // Power control: Disable unused functions to saven power
    i2c_write(I2C_DEV_ADDR, 0x02, 0x08);

    // Enable with GPIO
    MEM32(GPIO_BASE_ADDR + OUT_OFFSET) |= EN_MASK;
}

void dma_test(void){

    uint32_t gpio_val;
    char msg[64];

    //gpio_val = MEM32(MY_FABRIC_GPIO_BASE + GPIO_IN_REG);
    //sprintf(msg, "DEBUG: GPIO Initial Value = 0x%08X\r\n", gpio_val);
    //MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg);

    //MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)"GATE: Press and HOLD Button 0 to continue...\r\n");

    //while( MEM32(MY_FABRIC_GPIO_BASE + GPIO_IN_REG) == gpio_val ) {}

    uint8_t* p_tx = (uint8_t *)TX_BUF_PHYS_ADDR;
    uint8_t* p_rx = (uint8_t *)RX_BUF_PHYS_ADDR;

    for(int i = 0; i < DMA_BUFFER_SIZE; ++i){
        p_tx[i] = (unsigned char)(i & 0xff);
        p_rx[i] = 0x00;
    }

    mem_cmp(p_tx, p_rx, DMA_BUFFER_SIZE);

    dma_rcv(p_rx, 128);

    // Remove ------------------
    uint32_t s2mm_sts = MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_STS_OFFSET);

    //sprintf(msg, "S2MM Status: 0x%08X\r\n", s2mm_sts);
    //MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg);

    uint32_t axi_err = (s2mm_sts >> 2) & 0x03;
    //if (axi_err == 2){ sprintf(msg, "Hardware Error: SLVERR (Slave Error)\r\n"); MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg); }
    //else if (axi_err == 3){ sprintf(msg, "Hardware Error: DECERR (Decode Error - Routing blocked!)\r\n"); MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg); }
    //----------------------------

    dma_snd(p_tx, 128);
    dma_rcv_wait(p_rx, 128);
    dma_snd_wait();

    mem_cmp(p_tx, p_rx, 128);

    for(int i=0; i<1024/128; ++i){
        dma_rcv(p_rx + i * 128, 128);
        dma_snd(p_tx + i * 128, 128);
        dma_rcv_wait(p_rx + i * 128, 128);
        dma_snd_wait();
    }

    mem_cmp(p_tx, p_rx, 1024);

    dma_rcv(p_rx, 1024);
    dma_snd(p_tx, 1024);
    dma_rcv_wait(p_rx, 1024);
    dma_snd_wait();

    mem_cmp(p_tx, p_rx, 1024);

}

void dma_snd(void* src, uint32_t length){
    uintptr_t addr = (uintptr_t)src;

    // FLUSH CACHE BEFORE SENDING
    cache_flush(addr, length);

    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_CTRL_OFFSET) = 0;

    // MM2S = Transmit (Send)
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_ADDR0_OFFSET) = (uint32_t)addr;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_ADDR1_OFFSET) = (uint32_t)(addr >> 32);
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_LEN_OFFSET) = length;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_CTRL_OFFSET) = PROTOCONV_INCR_BURST | PROTOCONV_START_BIT;
}

void dma_rcv(void* dst, uint32_t length){
    uintptr_t addr = (uintptr_t)dst;

    // S2MM = Receive
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_ADDR0_OFFSET) = (uint32_t)addr;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_ADDR1_OFFSET) = (uint32_t)(addr >> 32); // Likely 0
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_LEN_OFFSET) = length;
    MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_CTRL_OFFSET) = PROTOCONV_INCR_BURST | PROTOCONV_START_BIT;
}

void dma_snd_wait(void){
    // Wait WHILE the done bit is 0
    while((MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_MM2S_STS_OFFSET) & PROTOCONV_DONE_BIT) == 0){}
    __asm volatile ("fence iorw, iorw" ::: "memory");
}

void dma_rcv_wait(void* dst, uint32_t length){
    // Wait WHILE the done bit is 0
    while((MEM32(PROTOCONV_BASE_ADDR + PROTOCONV_S2MM_STS_OFFSET) & PROTOCONV_DONE_BIT) == 0){}
    // INVALIDATE CACHE BEFORE RECEIVING
    cache_invalidate((uintptr_t)dst, length);
    __asm volatile ("fence iorw, iorw" ::: "memory");
}

void mem_cmp(void *buf1, void *buf2, uint32_t length){
    uint8_t *ptr1 = (uint8_t *)buf1;
    uint8_t *ptr2 = (uint8_t *)buf2;
    char msg[128];

    for (uint32_t i = 0; i < length; i++){
        if (ptr1[i] != ptr2[i]) {
                    //sprintf(msg, "FAIL: index %u, expected 0x%02x, got 0x%02x\r\n", i, ptr1[i], ptr2[i]);
                    //sprintf(msg, "FAIL: index %u, expected 0x%02x, got 0x%02x\r\n", i, ptr1[i], ptr2[i]);
                    //MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)msg);
                    return;
                }
    }

    //MSS_UART_polled_tx_string(&g_mss_uart1_lo, (uint8_t*)"SUCCESS: Buffers match!\r\n");
}

/* FLUSH: Use before DMA Transmit (CPU -> DDR) */
void cache_flush(uintptr_t addr, uint32_t length) {
    // Force physical address (0x8...) for the L2 Cache Controller
    uintptr_t phys_addr = addr & ~0x40000000ULL;
    uintptr_t start = phys_addr & ~(64ULL - 1);
    uintptr_t end = phys_addr + length;

    for (uintptr_t curr = start; curr < end; curr += 64) {
        CACHE_CTRL->FLUSH64 = curr;
    }
    // "fence iorw, iorw" ensures all previous writes to DDR are finished
    __asm volatile ("fence iorw, iorw" ::: "memory");
}

/* INVALIDATE: Use after DMA Receive (DDR -> CPU) */
void cache_invalidate(uintptr_t addr, uint32_t length) {
    // Force physical address (0x8...) for the L2 Cache Controller
    uintptr_t phys_addr = addr & ~0x40000000ULL;
    uintptr_t start = phys_addr & ~(64ULL - 1);
    uintptr_t end = phys_addr + length;

    for (uintptr_t curr = start; curr < end; curr += 64) {
        CACHE_CTRL->FLUSH64 = curr;
    }
    // "fence r, r" ensures the CPU re-fetches from DDR for the next read
    __asm volatile ("fence r, r" ::: "memory");
}
