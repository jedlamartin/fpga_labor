// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xbypass_hw.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XBypass_hw_CfgInitialize(XBypass_hw *InstancePtr, XBypass_hw_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XBypass_hw_Set_tlast_dnum(XBypass_hw *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XBypass_hw_WriteReg(InstancePtr->Control_BaseAddress, XBYPASS_HW_CONTROL_ADDR_TLAST_DNUM_DATA, Data);
}

u32 XBypass_hw_Get_tlast_dnum(XBypass_hw *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XBypass_hw_ReadReg(InstancePtr->Control_BaseAddress, XBYPASS_HW_CONTROL_ADDR_TLAST_DNUM_DATA);
    return Data;
}

