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

void init(){
    i2c_init();
    sleep_ms(10000000);
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
