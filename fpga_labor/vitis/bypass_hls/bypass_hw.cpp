#include "ap_int.h"
#include "ap_fixed.h"
#include "ap_axi_sdata.h"
#include "hls_stream.h"

typedef ap_fixed<24, 1, AP_TRN, AP_WRAP> din_t;
typedef ap_fixed<32, 1, AP_TRN, AP_WRAP> dout_t;
typedef hls::axis<dout_t, 0, 0, 0> axis_type;
typedef hls::stream<axis_type> stream_type;

void bypass_hw(ap_uint<16> tlast_dnum, din_t* input_l, din_t* input_r, stream_type& res){
#pragma HLS INTERFACE mode=s_axilite port=tlast_dnum
#pragma HLS INTERFACE mode=ap_hs port=input_l
#pragma HLS INTERFACE mode=ap_hs port=input_r
#pragma HLS INTERFACE mode=axis port=res
#pragma HLS INTERFACE mode=ap_ctrl_none port=return
    
    static ap_uint<16> cnt = 0;
    axis_type out_data;
    
    // Left channel
    cnt++;
    out_data.data = (dout_t)*input_l;
    out_data.last = (cnt == tlast_dnum);
    out_data.keep = -1;
    res.write(out_data);

    if(cnt == tlast_dnum){
        cnt = 0;
    }

    // Right channel
    cnt++;
    out_data.data = (dout_t)*input_r;
    out_data.last = (cnt == tlast_dnum);
    out_data.keep = -1;
    res.write(out_data);

    if(cnt == tlast_dnum){
        cnt = 0;
    }
}