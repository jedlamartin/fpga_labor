// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XBYPASS_HW_H
#define XBYPASS_HW_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xbypass_hw_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
#ifdef SDT
    char *Name;
#else
    u16 DeviceId;
#endif
    u64 Control_BaseAddress;
} XBypass_hw_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XBypass_hw;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XBypass_hw_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XBypass_hw_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XBypass_hw_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XBypass_hw_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
#ifdef SDT
int XBypass_hw_Initialize(XBypass_hw *InstancePtr, UINTPTR BaseAddress);
XBypass_hw_Config* XBypass_hw_LookupConfig(UINTPTR BaseAddress);
#else
int XBypass_hw_Initialize(XBypass_hw *InstancePtr, u16 DeviceId);
XBypass_hw_Config* XBypass_hw_LookupConfig(u16 DeviceId);
#endif
int XBypass_hw_CfgInitialize(XBypass_hw *InstancePtr, XBypass_hw_Config *ConfigPtr);
#else
int XBypass_hw_Initialize(XBypass_hw *InstancePtr, const char* InstanceName);
int XBypass_hw_Release(XBypass_hw *InstancePtr);
#endif


void XBypass_hw_Set_tlast_dnum(XBypass_hw *InstancePtr, u32 Data);
u32 XBypass_hw_Get_tlast_dnum(XBypass_hw *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
