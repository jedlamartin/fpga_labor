/*******************************************************************************
 * Copyright 2025 Microchip FPGA Embedded Systems Solutions.
 *
 * SPDX-License-Identifier: MIT
 *
 * Application code running on e51
 *
 */

#include <stdio.h>
#include <string.h>
#include "mpfs_hal/mss_hal.h"
#include "drivers/mss/mss_mmuart/mss_uart.h"
#include "inc/uart_mapping.h"
#include "inc/common.h"

struct mss_uart_instance* g_uart = &g_mss_uart1_lo;

volatile uint32_t count_sw_ints_h0 = 0U;

char info_string[100];
uint32_t uart0_mutex;

/* Main function for the hart0(e51 processor).
 * Application code running on hart0 is placed here
 */

void e51(void)
{
    volatile uint32_t icount = 0U;

    (void)mss_config_clk_rst(MSS_PERIPH_MMUART_E51,
            (uint8_t) MPFS_HAL_FIRST_HART,
            PERIPHERAL_ON);

    HLS_DATA* hls = (HLS_DATA*)(uintptr_t)get_tp_reg();
    HART_SHARED_DATA * hart_share = (HART_SHARED_DATA *)hls->shared_mem;

    MSS_UART_init(g_uart,
            MSS_UART_115200_BAUD,
            MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT);

    hart_share->g_mss_uart1_lo = &g_mss_uart1_lo;
    hart_share->mutex_uart1 = 0U; /* Init spinlock mutex */
    sprintf(info_string,
            "\r\nHart %u, HLS mem address 0x%lx, Shared mem 0x%lx\r\n",
             hls->my_hart_id, (uint64_t)hls, (uint64_t)hls->shared_mem);
    spinlock(&hart_share->mutex_uart1);
    MSS_UART_polled_tx(g_uart, (const uint8_t*)info_string,
            (uint32_t)strlen(info_string));
    spinunlock(&hart_share->mutex_uart1);

    SysTick_Config();
    sprintf(info_string,"MPFS HAL Version Major %d, Minor %d patch %d\r\n",
             MPFS_HAL_VERSION_MAJOR,MPFS_HAL_VERSION_MINOR,
             MPFS_HAL_VERSION_PATCH);
    MSS_UART_polled_tx(g_uart, (const uint8_t*)info_string,(uint32_t)
                       strlen(info_string));

    /* ---------------------------------- */
    uint8_t rx_char;
    size_t rx_size = 0;

    sprintf(info_string, "Press any key to start the transaction...\r\n");
    MSS_UART_polled_tx(g_uart, (const uint8_t*)info_string, (uint32_t)strlen(info_string));

    while (rx_size == 0) {
        rx_size = MSS_UART_get_rx(g_uart, &rx_char, 1);
    }

    sprintf(info_string, "Key '%c' received. Waking up Hart 1...\r\n", rx_char);
    MSS_UART_polled_tx(g_uart, (const uint8_t*)info_string, (uint32_t)strlen(info_string));
    /* ---------------------------------- */

#if (IMAGE_LOADED_BY_BOOTLOADER == 0)

    /* Clear pending software interrupt in case there was any. */
    clear_soft_interrupt();
    set_csr(mie, MIP_MSIP);

    /* Raise software interrupt to wake hart 1 */
    raise_soft_interrupt(1U);

    __enable_irq();
#endif



    /* Start the other harts with appropriate UART input from user */
    raise_soft_interrupt(1u);
    while (1){
        __asm("wfi");
    }
    /* never return */
}

/* hart0 software interrupt handler */
void Software_h0_IRQHandler(void)
{
    count_sw_ints_h0++;
}
