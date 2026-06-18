/*******************************************************************************
 * Copyright 2025 Microchip FPGA Embedded Systems Solutions.
 *
 * SPDX-License-Identifier: MIT
 *
 * Application code running on U54_1
 *
 */

#include <stdio.h>
#include <string.h>
#include "mpfs_hal/mss_hal.h"
#include "app_main.h"

volatile uint32_t count_sw_ints_h1 = 0U;


/* Main function for the hart1(U54_1 processor).
 * Application code running on hart1 is placed here
 */

void u54_1(void)
{
    volatile uint32_t icount = 0U;

    /* Clear pending software interrupt in case there was any.
       Enable only the software interrupt so that the E51 core can bring this
       core out of WFI by raising a software interrupt. */

    clear_soft_interrupt();
    set_csr(mie, MIP_MSIP);

    /* Put this hart in WFI */

    do
    {
        __asm("wfi");
    }while(0 == (read_csr(mip) & MIP_MSIP));

    /* The hart is out of WFI, clear the SW interrupt. Here onwards application
     * can enable and use any interrupts as required */

    clear_soft_interrupt();

    __enable_irq();

    uint8_t* p_tx = (uint8_t *)TX_BUF_PHYS_ADDR;
    uint8_t* p_rx = (uint8_t *)RX_BUF_PHYS_ADDR;

    init();

    int offs = 0;
    while (1U){
        // Prepare the DMA to receive data into the buffer at the current offset
        dma_rcv(p_rx + offs, BLOCK_SIZE * DATA_LENGTH);

        // This loop will block until the FIR sends exactly BLOCK_SIZE samples
        // and asserts the TLAST wire to the DMA S2MM port.
        dma_rcv_wait(p_rx + offs, BLOCK_SIZE * DATA_LENGTH);

        offs += BLOCK_SIZE;
        if (offs + BLOCK_SIZE >= DMA_BUFFER_SIZE) {
            offs = 0;
        }
    }

    /* never return */
}

/* hart1 Software interrupt handler */

void Software_h1_IRQHandler(void)
{
    count_sw_ints_h1++;
}
