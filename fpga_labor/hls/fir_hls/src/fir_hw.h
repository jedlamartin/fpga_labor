#ifndef FIR_HW_H_
#define FIR_HW_H_

#include "hls/streaming.hpp"
#include "hls/ap_int.hpp"
#include "hls/ap_fixpt.hpp"

typedef hls::ap_fixpt<24, 1, hls::AP_TRN, hls::AP_WRAP> din_t;
typedef hls::ap_fixpt<32, 1, hls::AP_TRN, hls::AP_WRAP> dout_t;
typedef hls::ap_fixpt<32, 1, hls::AP_TRN, hls::AP_WRAP> coeff_t;
typedef hls::ap_fixpt<48, 2, hls::AP_TRN, hls::AP_WRAP> acc_t;

struct axis_packet {
    dout_t data;
    bool last;
};
typedef hls::FIFO<axis_packet> stream_type;

void fir_hw(hls::ap_uint<16> tlast_dnum, hls::ap_uint<8> smpl_rd_num, hls::ap_uint<16> tap_num_m1,
coeff_t coeff_hw[512], hls::FIFO<din_t>& input_l, hls::FIFO<din_t>& input_r, stream_type& res);

#endif /* FIR_HW_H_ */
