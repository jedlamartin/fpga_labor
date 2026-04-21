#include "ap_int.h"
#include "ap_fixed.h"
#include "ap_axi_sdata.h"
#include "hls_stream.h"

typedef ap_fixed<24, 1, AP_TRN, AP_WRAP> din_t;

typedef ap_fixed<32, 1, AP_TRN, AP_WRAP> dout_t;
typedef hls::axis<dout_t, 0, 0, 0> axis_type;
typedef hls::stream<axis_type> stream_type;

typedef ap_fixed<32, 1, AP_TRN, AP_WRAP> coeff_t;
typedef ap_fixed<48, 2, AP_TRN, AP_WRAP> acc_t;

void fir_hw(ap_uint<16> tlast_dnum, ap_uint<3> smpl_rd_num, ap_uint<9> tap_num_m1,
coeff_t coeff_hw[512], din_t *input_l, din_t *input_r, stream_type &res);