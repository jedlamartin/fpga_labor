// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XFIR_HW_H
#define XFIR_HW_H

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
#include "xfir_hw_hw.h"

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
} XFir_hw_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XFir_hw;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XFir_hw_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XFir_hw_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XFir_hw_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XFir_hw_ReadReg(BaseAddress, RegOffset) \
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
int XFir_hw_Initialize(XFir_hw *InstancePtr, UINTPTR BaseAddress);
XFir_hw_Config* XFir_hw_LookupConfig(UINTPTR BaseAddress);
#else
int XFir_hw_Initialize(XFir_hw *InstancePtr, u16 DeviceId);
XFir_hw_Config* XFir_hw_LookupConfig(u16 DeviceId);
#endif
int XFir_hw_CfgInitialize(XFir_hw *InstancePtr, XFir_hw_Config *ConfigPtr);
#else
int XFir_hw_Initialize(XFir_hw *InstancePtr, const char* InstanceName);
int XFir_hw_Release(XFir_hw *InstancePtr);
#endif


void XFir_hw_Set_tlast_dnum(XFir_hw *InstancePtr, u32 Data);
u32 XFir_hw_Get_tlast_dnum(XFir_hw *InstancePtr);
void XFir_hw_Set_smpl_rd_num(XFir_hw *InstancePtr, u32 Data);
u32 XFir_hw_Get_smpl_rd_num(XFir_hw *InstancePtr);
void XFir_hw_Set_tap_num_m1(XFir_hw *InstancePtr, u32 Data);
u32 XFir_hw_Get_tap_num_m1(XFir_hw *InstancePtr);
u32 XFir_hw_Get_coeff_hw_BaseAddress(XFir_hw *InstancePtr);
u32 XFir_hw_Get_coeff_hw_HighAddress(XFir_hw *InstancePtr);
u32 XFir_hw_Get_coeff_hw_TotalBytes(XFir_hw *InstancePtr);
u32 XFir_hw_Get_coeff_hw_BitWidth(XFir_hw *InstancePtr);
u32 XFir_hw_Get_coeff_hw_Depth(XFir_hw *InstancePtr);
u32 XFir_hw_Write_coeff_hw_Words(XFir_hw *InstancePtr, int offset, word_type *data, int length);
u32 XFir_hw_Read_coeff_hw_Words(XFir_hw *InstancePtr, int offset, word_type *data, int length);
u32 XFir_hw_Write_coeff_hw_Bytes(XFir_hw *InstancePtr, int offset, char *data, int length);
u32 XFir_hw_Read_coeff_hw_Bytes(XFir_hw *InstancePtr, int offset, char *data, int length);

#ifdef __cplusplus
}
#endif

#endif
