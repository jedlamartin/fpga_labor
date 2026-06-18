#include "fir_hw.h"

void fir_hw(hls::ap_uint<16> tlast_dnum, hls::ap_uint<8> smpl_rd_num, hls::ap_uint<16> tap_num_m1,
coeff_t coeff_hw[512], hls::FIFO<din_t>& input_l, hls::FIFO<din_t>& input_r, stream_type& res){
#pragma HLS function top
#pragma HLS interface argument(coeff_hw) type(axi_target)
#pragma HLS interface argument(tap_num_m1) type(axi_target)
#pragma HLS interface argument(smpl_rd_num) type(axi_target)
#pragma HLS interface argument(tlast_dnum) type(axi_target)
#pragma HLS interface argument(input_l) type(simple)
#pragma HLS interface argument(input_r) type(simple)
#pragma HLS interface argument(res) type(simple)

    static din_t buffer_left[512];
    static din_t buffer_right[512];
    static hls::ap_uint<9> write_idx = 0;

    static hls::ap_uint<16> cnt = 0;
    static hls::ap_uint<3> dec_cnt = 0;
    axis_packet out_data;

    buffer_left[write_idx]=(din_t)input_l.read();
    buffer_right[write_idx]=(din_t)input_r.read();

    dec_cnt++;
    if(dec_cnt >= smpl_rd_num){
        dec_cnt = 0;

        acc_t acc_l = 0;
        acc_t acc_r = 0;


		#pragma HLS loop pipeline II(2)
		#pragma HLS loop bounds lower(128) upper(512)
        for(int i = 0;i <= tap_num_m1;++i){
            hls::ap_uint<9> read_idx = write_idx - (hls::ap_uint<9>)i;
            din_t sample_l = buffer_left[read_idx];
            din_t sample_r = buffer_right[read_idx];

            acc_l += acc_t((acc_t)sample_l * coeff_hw[i]);
            acc_r += acc_t((acc_t)sample_r * coeff_hw[i]);
        }

        // Left channel
        cnt++;
        out_data.data = acc_l;
        out_data.last = (cnt == tlast_dnum);
        out_data.keep = -1;
        res.write(out_data);

        if(cnt == tlast_dnum){
            cnt = 0;
        }

        // Right channel
        cnt++;
        out_data.data = acc_r;
        out_data.last = (cnt == tlast_dnum);
        out_data.keep = -1;
        res.write(out_data);

        if(cnt == tlast_dnum){
            cnt = 0;
        }
    }

    ++write_idx;
}
