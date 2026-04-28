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
#include "xfir_hw.h"

extern XFir_hw_Config XFir_hw_ConfigTable[];

#ifdef SDT
XFir_hw_Config *XFir_hw_LookupConfig(UINTPTR BaseAddress) {
	XFir_hw_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XFir_hw_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XFir_hw_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XFir_hw_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFir_hw_Initialize(XFir_hw *InstancePtr, UINTPTR BaseAddress) {
	XFir_hw_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFir_hw_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFir_hw_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XFir_hw_Config *XFir_hw_LookupConfig(u16 DeviceId) {
	XFir_hw_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XFIR_HW_NUM_INSTANCES; Index++) {
		if (XFir_hw_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XFir_hw_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFir_hw_Initialize(XFir_hw *InstancePtr, u16 DeviceId) {
	XFir_hw_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFir_hw_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFir_hw_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

