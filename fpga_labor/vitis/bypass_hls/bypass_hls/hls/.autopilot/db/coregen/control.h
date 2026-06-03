// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of tlast_dnum
//        bit 15~0 - tlast_dnum[15:0] (Read/Write)
//        others   - reserved
// 0x14 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define CONTROL_ADDR_TLAST_DNUM_DATA 0x10
#define CONTROL_BITS_TLAST_DNUM_DATA 16
