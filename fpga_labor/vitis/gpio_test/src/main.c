#include <xparameters.h>
#include <stdint.h>

#define MEM32(addr) (*(volatile uint32_t *)(addr))

// AXI GPIO leirasbol
#define LED_OFFSET 0x00
#define BTN_OFFSET 0x08

int main(){
    uint32_t data;
    for(;;){
        data=MEM32(XPAR_AXI_GPIO_0_BASEADDR + BTN_OFFSET);
        MEM32(XPAR_AXI_GPIO_0_BASEADDR + LED_OFFSET) = data;
    }
}
