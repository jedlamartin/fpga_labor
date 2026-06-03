// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#ifdef SDT
#include "xparameters.h"
#endif
#include "xbypass_hw.h"

extern XBypass_hw_Config XBypass_hw_ConfigTable[];

#ifdef SDT
XBypass_hw_Config *XBypass_hw_LookupConfig(UINTPTR BaseAddress) {
	XBypass_hw_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XBypass_hw_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XBypass_hw_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XBypass_hw_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XBypass_hw_Initialize(XBypass_hw *InstancePtr, UINTPTR BaseAddress) {
	XBypass_hw_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XBypass_hw_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XBypass_hw_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XBypass_hw_Config *XBypass_hw_LookupConfig(u16 DeviceId) {
	XBypass_hw_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XBYPASS_HW_NUM_INSTANCES; Index++) {
		if (XBypass_hw_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XBypass_hw_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XBypass_hw_Initialize(XBypass_hw *InstancePtr, u16 DeviceId) {
	XBypass_hw_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XBypass_hw_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XBypass_hw_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

