#ifndef TYPES_H
#define TYPES_H

#include <ap_int.h>
#include <ap_fixed.h>

typedef ap_fixed<24, 1, AP_TRN, AP_WRAP> din_t;
typedef ap_fixed<32, 1, AP_TRN, AP_WRAP> dout_t;
typedef ap_fixed<32, 1, AP_TRN, AP_WRAP> coeff_t;
typedef ap_fixed<48, 2, AP_TRN, AP_WRAP> acc_t;

#endif