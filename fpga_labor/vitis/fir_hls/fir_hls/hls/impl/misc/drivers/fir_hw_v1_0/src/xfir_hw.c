// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xfir_hw.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XFir_hw_CfgInitialize(XFir_hw *InstancePtr, XFir_hw_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XFir_hw_Set_tlast_dnum(XFir_hw *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_hw_WriteReg(InstancePtr->Control_BaseAddress, XFIR_HW_CONTROL_ADDR_TLAST_DNUM_DATA, Data);
}

u32 XFir_hw_Get_tlast_dnum(XFir_hw *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFir_hw_ReadReg(InstancePtr->Control_BaseAddress, XFIR_HW_CONTROL_ADDR_TLAST_DNUM_DATA);
    return Data;
}

void XFir_hw_Set_smpl_rd_num(XFir_hw *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_hw_WriteReg(InstancePtr->Control_BaseAddress, XFIR_HW_CONTROL_ADDR_SMPL_RD_NUM_DATA, Data);
}

u32 XFir_hw_Get_smpl_rd_num(XFir_hw *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFir_hw_ReadReg(InstancePtr->Control_BaseAddress, XFIR_HW_CONTROL_ADDR_SMPL_RD_NUM_DATA);
    return Data;
}

void XFir_hw_Set_tap_num_m1(XFir_hw *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFir_hw_WriteReg(InstancePtr->Control_BaseAddress, XFIR_HW_CONTROL_ADDR_TAP_NUM_M1_DATA, Data);
}

u32 XFir_hw_Get_tap_num_m1(XFir_hw *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFir_hw_ReadReg(InstancePtr->Control_BaseAddress, XFIR_HW_CONTROL_ADDR_TAP_NUM_M1_DATA);
    return Data;
}

u32 XFir_hw_Get_coeff_hw_BaseAddress(XFir_hw *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (InstancePtr->Control_BaseAddress + XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE);
}

u32 XFir_hw_Get_coeff_hw_HighAddress(XFir_hw *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (InstancePtr->Control_BaseAddress + XFIR_HW_CONTROL_ADDR_COEFF_HW_HIGH);
}

u32 XFir_hw_Get_coeff_hw_TotalBytes(XFir_hw *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return (XFIR_HW_CONTROL_ADDR_COEFF_HW_HIGH - XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE + 1);
}

u32 XFir_hw_Get_coeff_hw_BitWidth(XFir_hw *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFIR_HW_CONTROL_WIDTH_COEFF_HW;
}

u32 XFir_hw_Get_coeff_hw_Depth(XFir_hw *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFIR_HW_CONTROL_DEPTH_COEFF_HW;
}

u32 XFir_hw_Write_coeff_hw_Words(XFir_hw *InstancePtr, int offset, word_type *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length)*4 > (XFIR_HW_CONTROL_ADDR_COEFF_HW_HIGH - XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(int *)(InstancePtr->Control_BaseAddress + XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE + (offset + i)*4) = *(data + i);
    }
    return length;
}

u32 XFir_hw_Read_coeff_hw_Words(XFir_hw *InstancePtr, int offset, word_type *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length)*4 > (XFIR_HW_CONTROL_ADDR_COEFF_HW_HIGH - XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(data + i) = *(int *)(InstancePtr->Control_BaseAddress + XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE + (offset + i)*4);
    }
    return length;
}

u32 XFir_hw_Write_coeff_hw_Bytes(XFir_hw *InstancePtr, int offset, char *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length) > (XFIR_HW_CONTROL_ADDR_COEFF_HW_HIGH - XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(char *)(InstancePtr->Control_BaseAddress + XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE + offset + i) = *(data + i);
    }
    return length;
}

u32 XFir_hw_Read_coeff_hw_Bytes(XFir_hw *InstancePtr, int offset, char *data, int length) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr -> IsReady == XIL_COMPONENT_IS_READY);

    int i;

    if ((offset + length) > (XFIR_HW_CONTROL_ADDR_COEFF_HW_HIGH - XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE + 1))
        return 0;

    for (i = 0; i < length; i++) {
        *(data + i) = *(char *)(InstancePtr->Control_BaseAddress + XFIR_HW_CONTROL_ADDR_COEFF_HW_BASE + offset + i);
    }
    return length;
}

