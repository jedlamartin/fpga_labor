/*******************************************************************************
 * Copyright 2019 Microchip FPGA Embedded Systems Solution.
 *
 * SPDX-License-Identifier: MIT
 *
 * MPFS HAL Embedded Software example
 *
 */
/*******************************************************************************
 *
 * Code running on U54 first hart
 *
 */
#include <stdio.h>
#include <string.h>
#include "mpfs_hal/mss_hal.h"
#include "inc/common.h"

extern uint64_t hart_jump_ddr;
extern uint64_t ddr_test;
extern mss_uart_instance_t *g_uart;
extern char info_string[];

volatile uint32_t count_sw_ints_h1 = 0U;

#define NO_OF_ITERATIONS    2
#define DDR_BASE            0x80000000u
#define DDR_SIZE            0x40000000u

#define MIN_OFFSET          1U
#define MAX_OFFSET          16U
#define START_OFFSET        12U

extern void dma_test(void);

/* Main function for the HART1(U54_1 processor).
 * Application code running on HART1 is placed here
 *
 * The HART1 goes into WFI. HART0 brings it out of WFI when it raises the first
 * Software interrupt to this HART
 */
void u54_1(void)
{
    HLS_DATA* hls = (HLS_DATA*)(uintptr_t)get_tp_reg();

    /* Clear pending software interrupt in case there was any.
       Enable only the software interrupt so that the E51 core can bring this
       core out of WFI by raising a software interrupt. */
    clear_soft_interrupt();
    set_csr(mie, MIP_MSIP);

    /*Put this hart into WFI.*/
    do
    {
        __asm("wfi");
    }while(0 == (read_csr(mip) & MIP_MSIP));

    /* The hart is out of WFI, clear the SW interrupt. Hear onwards Application
     * can enable and use any interrupts as required */
    clear_soft_interrupt();

    __enable_irq();

    dma_test();

    while (1){
        __asm("wfi");
    }
    /* never return */
}

/* HART1 Software interrupt handler */
void Software_h1_IRQHandler(void)
{
    count_sw_ints_h1++;
}
