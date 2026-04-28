// 0x000 : reserved
// 0x004 : reserved
// 0x008 : reserved
// 0x00c : reserved
// 0x010 : Data signal of tlast_dnum
//         bit 15~0 - tlast_dnum[15:0] (Read/Write)
//         others   - reserved
// 0x014 : reserved
// 0x018 : Data signal of smpl_rd_num
//         bit 2~0 - smpl_rd_num[2:0] (Read/Write)
//         others  - reserved
// 0x01c : reserved
// 0x020 : Data signal of tap_num_m1
//         bit 8~0 - tap_num_m1[8:0] (Read/Write)
//         others  - reserved
// 0x024 : reserved
// 0x800 ~
// 0xfff : Memory 'coeff_hw' (512 * 32b)
//         Word n : bit [31:0] - coeff_hw[n]
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define CONTROL_ADDR_TLAST_DNUM_DATA  0x010
#define CONTROL_BITS_TLAST_DNUM_DATA  16
#define CONTROL_ADDR_SMPL_RD_NUM_DATA 0x018
#define CONTROL_BITS_SMPL_RD_NUM_DATA 3
#define CONTROL_ADDR_TAP_NUM_M1_DATA  0x020
#define CONTROL_BITS_TAP_NUM_M1_DATA  9
#define CONTROL_ADDR_COEFF_HW_BASE    0x800
#define CONTROL_ADDR_COEFF_HW_HIGH    0xfff
#define CONTROL_WIDTH_COEFF_HW        32
#define CONTROL_DEPTH_COEFF_HW        512
