#include "bypass_hw.h"

void bypass_hw(hls::ap_uint<16> tlast_dnum, hls::FIFO<din_t>& input_l, hls::FIFO<din_t> &input_r, stream_type& res){
#pragma HLS function top
#pragma HLS function pipeline
#pragma HLS interface argument(tlast_dnum) type(axi_target)
#pragma HLS interface argument(input_l) type(simple)
#pragma HLS interface argument(input_r) type(simple)
#pragma HLS interface argument(res) type(simple)

    static hls::ap_uint<16> cnt = 0;
    axis_packet out_data;

    // Left channel
    cnt++;
    out_data.data = (dout_t)input_l.read();
    out_data.last = (cnt == tlast_dnum);
    res.write(out_data);

    if(cnt == tlast_dnum){
        cnt = 0;
    }

    // Right channel
    cnt++;
    out_data.data = (dout_t)input_r.read();
    out_data.last = (cnt == tlast_dnum);
    res.write(out_data);

    if(cnt == tlast_dnum){
        cnt = 0;
    }
}
