#include <xparameters.h>
#include <stdint.h>
#include <sleep.h>

#define MEM32(addr) (*(volatile uint32_t *)(addr))

constexpr uint32_t I2C_BASE_ADDR = XPAR_AXI_IIC_0_BASEADDR;
constexpr uint8_t I2C_DEV_ADDR = 0x4E;

// Fixed Offsets (Standard AXI IIC Map)
constexpr uint32_t I2C_SOFTR_OFFSET         = 0x040; // Soft Reset
constexpr uint32_t I2C_CR_OFFSET            = 0x100; // Control Register
constexpr uint32_t I2C_SR_OFFSET            = 0x104; // Status Register
constexpr uint32_t I2C_TX_FIFO_OFFSET       = 0x108; // Transmit FIFO (DTR)
constexpr uint32_t I2C_RX_FIFO_OFFSET       = 0x10C; // Receive FIFO (DRR)
constexpr uint32_t I2C_GPO_OFFSET           = 0x10C; // GPO Register

// Bit Masks
constexpr uint32_t RKEY             = 0x0000000A;
constexpr uint32_t TX_RESET_MASK    = (1 << 1);
constexpr uint32_t EN_MASK          = (1 << 0);
constexpr uint32_t BB_MASK          = (1 << 2); // Bus Busy
constexpr uint32_t TX_EMPTY_MASK    = (1 << 7);
constexpr uint32_t RX_EMPTY_MASK    = (1 << 6);
constexpr uint32_t START_MASK       = (1 << 8);
constexpr uint32_t STOP_MASK        = (1 << 9);

void i2c_init();
void i2c_write(uint8_t slv_addr, uint8_t reg_addr, uint8_t data);
uint8_t i2c_read(uint8_t slv_addr, uint8_t reg_addr);
void codec_init();

int main(){
    
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
}