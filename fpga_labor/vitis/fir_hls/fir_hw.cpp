#include "types.h"

void fir_hw(ap_uint<16> tlast_dnum, ap_uint<3> smpl_rd_num, ap_uint<9> tap_num_m1,
coeff_t coeff_hw[512], din_t *input_l, din_t *input_r, stream_type &res){
#pragma HLS INTERFACE mode=s_axilite port=coeff_hw
#pragma HLS INTERFACE mode=s_axilite port=tap_num_m1
#pragma HLS INTERFACE mode=s_axilite port=smpl_rd_num
#pragma HLS INTERFACE mode=s_axilite port=tlast_dnum
#pragma HLS INTERFACE mode=ap_hs port=input_l
#pragma HLS INTERFACE mode=ap_hs port=input_r
#pragma HLS INTERFACE mode=axis port=res
#pragma HLS INTERFACE mode=ap_ctrl_none port=return
    
    static din_t buffer_left[512];
    static din_t buffer_right[512];
    static ap_uint<9> write_idx = 0;

    static ap_uint<16> cnt = 0;
    static ap_uint<3> dec_cnt = 0;
    axis_type out_data;
    
    buffer_left[write_idx]=(din_t)*input_l;
    buffer_right[write_idx]=(din_t)*input_r;

    dec_cnt++;
    if(dec_cnt >= smpl_rd_num){
        dec_cnt = 0;
        
        acc_t acc_l = 0;
        acc_t acc_r = 0;

        for(int i = 0;i <= tap_num_m1;++i){
        #pragma HLS PIPELINE II=2
        #pragma HLS LOOP_TRIPCOUNT max=512 min=128
            ap_uint<9> read_idx = write_idx - i;
            din_t sample_l = buffer_left[read_idx];
            din_t sample_r = buffer_right[read_idx];
            acc_l += (acc_t)sample_l * coeff_hw[i];
            acc_r += (acc_t)sample_r * coeff_hw[i];
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