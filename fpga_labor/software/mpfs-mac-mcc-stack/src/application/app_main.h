#ifndef APP_MAIN_H
#define APP_MAIN_H

#include <stdint.h>

void audio_stream_init(void);
void audio_stream_service_pipeline(void);
void audio_control_packet_callback(uint8_t *packet, int16_t length);

#endif /* APP_MAIN_H */
