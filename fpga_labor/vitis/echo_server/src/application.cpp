/*
 * Copyright (C) 2009 - 2019 Xilinx, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 */

#include <stdio.h>
#include <string.h>
#include "xil_cache.h"

extern "C" {
#include "lwip/err.h"
#include "lwip/tcp.h"
#include "lwip/udp.h"
#include "xil_printf.h"
}

#include "init.h"

#define DMA_BUFF_SIZE (1024 * 16)
static uint8_t dma_buffer[DMA_BUFF_SIZE] __attribute__((aligned(64)));

static struct udp_pcb* active_pcb = NULL;  // The "pointer to the UDP PCB structure"
static ip_addr_t remote_ip;                // The source IP address from the PC
static u16_t remote_port = 0;              // The source UDP port from the PC
static int audio_transfer_enabled = 0;     // The flag to enable audio transfer
//static uint8_t audio_send_buffer[1024] __attribute__((aligned(32)));

static int new_data_available = 0;

extern "C" void set_transfer_flag() {
    new_data_available = true;
}

int transfer_data() {
	if(audio_transfer_enabled && active_pcb && dma_data_available){

//		static uint32_t sawtooth_counter = 0;
//        uint32_t *samples = (uint32_t *)audio_send_buffer;
//
//        for (int i = 0; i < 256; i++) {
//            samples[i] = sawtooth_counter;
//            sawtooth_counter += 0x01000000; 
//        }

		Xil_DCacheInvalidateRange((UINTPTR)dma_ptr_eth, 1024);

		struct pbuf *p = pbuf_alloc(PBUF_TRANSPORT, 1024, PBUF_REF);
		if(p){
			p->payload = dma_ptr_eth;
			err_t err = udp_sendto(active_pcb, p, &remote_ip, remote_port);
			if (err != ERR_OK) {
                xil_printf("UDP Send Error: %d\n\r", err);
            }
			pbuf_free(p);
		}else {
            xil_printf("Could not allocate pbuf for transmission\n\r");
        }
		dma_data_available = 0;
		new_data_available = 0;
	}
	return 0;
}

void print_app_header()
{
    xil_printf("\n\r----- lwIP UDP Echo Server (C++) -----\n\r");
    xil_printf("UDP packets sent to port 1234 will be echoed back\n\r");
}

extern "C" void recv_callback(void *arg, struct udp_pcb *pcb, struct pbuf *p, const ip_addr_t *addr, u16_t port){
	if(p != nullptr){
		uint8_t command = *((uint8_t *)p->payload);
		if(command == 0x00){
			active_pcb = pcb;
			ip_addr_copy(remote_ip, *addr);
			remote_port = port;
			audio_transfer_enabled = 1;
			
		}else if(command == 0x01){
			audio_transfer_enabled = 0;
		}
		pbuf_free(p);
	}
}

XFir_hw fir_ip;
int start_application()
{
	struct udp_pcb* pcb = udp_new();
	if (!pcb) return -1;
	err_t err;
	unsigned port = 1234;

	/* bind to specified @port */
	err = udp_bind(pcb, IP_ADDR_ANY, port);
	if (err != ERR_OK) {
		xil_printf("Unable to bind to port %d: err = %d\n\r", port, err);
		return -2;
	}

	udp_recv(pcb, (udp_recv_fn)recv_callback, NULL);

	codec_init();
	FIR_init(&fir_ip);
	dma_it_init(dma_buffer, DMA_BUFF_SIZE, 1024);

	xil_printf("UDP echo server started @ port %d\n\r", port);

	return 0;
}
