#ifndef BYPASS_HW_H_
#define BYPASS_HW_H_

#include "hls/streaming.hpp"
#include "hls/ap_int.hpp"
#include "hls/ap_fixpt.hpp"

typedef hls::ap_fixpt<24, 1, hls::AP_TRN, hls::AP_WRAP> din_t;
typedef hls::ap_fixpt<32, 1, hls::AP_TRN, hls::AP_WRAP> dout_t;

struct axis_packet {
    dout_t data;
    bool last;
};
typedef hls::FIFO<axis_packet> stream_type;

void bypass_hw(hls::ap_uint<16> tlast_dnum, hls::FIFO<din_t>& input_l, hls::FIFO<din_t> &input_r, stream_type& res);

#endif /* BYPASS_HW_H_ */
