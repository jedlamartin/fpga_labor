#include "app_main.h"
#include "mcc_tcpip_lite/udpv4.h"
#include "mcc_tcpip_lite/ip_database.h"
#include <string.h>

#define STREAMING_UDP_PORT 1234
#define AUDIO_PACKET_INTERVAL_MS 125
#define TEST_WAVE_BUFFER_SIZE 1024

static volatile bool is_streaming_active = false;
static uint32_t host_pc_ip_address = 0;
static uint16_t host_pc_udp_port = 0;
static uint64_t next_packet_transmission_time = 0;

static uint8_t test_wave_signal_buffer[TEST_WAVE_BUFFER_SIZE];
static uint8_t udp_streaming_tx_packet[TEST_WAVE_BUFFER_SIZE + 64] __attribute__((aligned(32)));

extern volatile uint64_t g_tick_counter;

void audio_stream_init(void) {
    uint32_t *sample_ptr = (uint32_t *)test_wave_signal_buffer;
        uint32_t sawtooth_accumulator = 0;

        /* Fill the buffer with our pristine sawtooth profile up front */
        for (size_t i = 0; i < (TEST_WAVE_BUFFER_SIZE / 4); i++) {
            sample_ptr[i] = sawtooth_accumulator;
            sawtooth_accumulator += 0x01000000;
        }
}

void audio_control_packet_callback(uint8_t *packet, int16_t length) {
    if (length > 0 && packet != NULL) {
        uint8_t runtime_command = packet[0];

        if (runtime_command == 0x00) {
            host_pc_ip_address = UDP_GetDestIP();
            host_pc_udp_port   = UDP_GetDestPort();
            is_streaming_active = true;
        }
        else if (runtime_command == 0x01) {
            is_streaming_active = false;
        }
    }
}

void audio_stream_service_pipeline(void)
{
    if (is_streaming_active && host_pc_ip_address != 0) {
        if (g_tick_counter >= next_packet_transmission_time) {
            uint8_t* pkt_ptr = udp_streaming_tx_packet;
            error_msg stack_status = UDP_Start(
                udp_streaming_tx_packet,
                &pkt_ptr,
                host_pc_ip_address,
                STREAMING_UDP_PORT,
                host_pc_udp_port
            );

            if (stack_status == NET_SUCCESS) {
                memcpy(pkt_ptr, test_wave_signal_buffer, TEST_WAVE_BUFFER_SIZE);
                pkt_ptr += TEST_WAVE_BUFFER_SIZE;
                __asm__ volatile("fence rw, rw" ::: "memory");
                UDP_Send(udp_streaming_tx_packet, (uint16_t)((pkt_ptr - udp_streaming_tx_packet) - OFFSET_UDP));
            }

            next_packet_transmission_time = g_tick_counter + AUDIO_PACKET_INTERVAL_MS;
        }
    }
}
