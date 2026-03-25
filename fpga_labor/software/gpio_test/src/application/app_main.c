#include <stdint.h>

#define MEM32(addr) (*(volatile uint32_t *)(addr))

// The address you found in Libero Memory Map
#define MY_FABRIC_GPIO_BASE    0x40000000UL

// Offsets for 32-bit APB Data Width
#define GPIO_IN_REG         0x90
#define GPIO_OUT_REG        0xA0

void gpio_test(void){
    uint32_t data;
        // Read buttons (Bits 3:0)
        data=MEM32(MY_FABRIC_GPIO_BASE + GPIO_IN_REG);

        // Shift data so Button 0 (Bit 0) controls LED 0 (Bit 4)
        // Then write to the Output register
        MEM32(MY_FABRIC_GPIO_BASE + GPIO_OUT_REG) = (data << 4);
}
