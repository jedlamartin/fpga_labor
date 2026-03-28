//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Sat Mar 28 21:30:34 2026
// Version: 2025.1 2025.1.0.14
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of CoreAXI4SInterconnect_C0 to TCL
# Family: PolarFireSoC
# Part Number: MPFS095T-1FCSG325E
# Create and Configure the core component CoreAXI4SInterconnect_C0
create_and_configure_core -core_vlnv {Actel:DirectCore:CoreAXI4SInterconnect:2.0.111} -component_name {CoreAXI4SInterconnect_C0} -params {\
"ARB_TYPE:0"  \
"AXI4S_I0RS:false"  \
"AXI4S_I0TDATA_BYTES:4"  \
"AXI4S_I1RS:false"  \
"AXI4S_I1TDATA_BYTES:4"  \
"AXI4S_I2RS:false"  \
"AXI4S_I2TDATA_BYTES:4"  \
"AXI4S_I3RS:false"  \
"AXI4S_I3TDATA_BYTES:4"  \
"AXI4S_I4RS:false"  \
"AXI4S_I4TDATA_BYTES:4"  \
"AXI4S_I5RS:false"  \
"AXI4S_I5TDATA_BYTES:4"  \
"AXI4S_I6RS:false"  \
"AXI4S_I6TDATA_BYTES:4"  \
"AXI4S_I7RS:false"  \
"AXI4S_I7TDATA_BYTES:4"  \
"AXI4S_IDWC_I0RS:false"  \
"AXI4S_IDWC_I1RS:false"  \
"AXI4S_IDWC_I2RS:false"  \
"AXI4S_IDWC_I3RS:false"  \
"AXI4S_IDWC_I4RS:false"  \
"AXI4S_IDWC_I5RS:false"  \
"AXI4S_IDWC_I6RS:false"  \
"AXI4S_IDWC_I7RS:false"  \
"AXI4S_IDWC_T0RS:false"  \
"AXI4S_IDWC_T1RS:false"  \
"AXI4S_IDWC_T2RS:false"  \
"AXI4S_IDWC_T3RS:false"  \
"AXI4S_IDWC_T4RS:false"  \
"AXI4S_IDWC_T5RS:false"  \
"AXI4S_IDWC_T6RS:false"  \
"AXI4S_IDWC_T7RS:false"  \
"AXI4S_T0RS:false"  \
"AXI4S_T0TDATA_BYTES:4"  \
"AXI4S_T1RS:false"  \
"AXI4S_T1TDATA_BYTES:4"  \
"AXI4S_T2RS:false"  \
"AXI4S_T2TDATA_BYTES:4"  \
"AXI4S_T3RS:false"  \
"AXI4S_T3TDATA_BYTES:4"  \
"AXI4S_T4RS:false"  \
"AXI4S_T4TDATA_BYTES:4"  \
"AXI4S_T5RS:false"  \
"AXI4S_T5TDATA_BYTES:4"  \
"AXI4S_T6RS:false"  \
"AXI4S_T6TDATA_BYTES:4"  \
"AXI4S_T7RS:false"  \
"AXI4S_T7TDATA_BYTES:4"  \
"AXI4S_TDWC_I0RS:false"  \
"AXI4S_TDWC_I1RS:false"  \
"AXI4S_TDWC_I2RS:false"  \
"AXI4S_TDWC_I3RS:false"  \
"AXI4S_TDWC_I4RS:false"  \
"AXI4S_TDWC_I5RS:false"  \
"AXI4S_TDWC_I6RS:false"  \
"AXI4S_TDWC_I7RS:false"  \
"AXI4S_TDWC_T0RS:false"  \
"AXI4S_TDWC_T1RS:false"  \
"AXI4S_TDWC_T2RS:false"  \
"AXI4S_TDWC_T3RS:false"  \
"AXI4S_TDWC_T4RS:false"  \
"AXI4S_TDWC_T5RS:false"  \
"AXI4S_TDWC_T6RS:false"  \
"AXI4S_TDWC_T7RS:false"  \
"ENABLE_IR0_FIFO:false"  \
"ENABLE_IR1_FIFO:false"  \
"ENABLE_IR2_FIFO:false"  \
"ENABLE_IR3_FIFO:false"  \
"ENABLE_IR4_FIFO:false"  \
"ENABLE_IR5_FIFO:false"  \
"ENABLE_IR6_FIFO:false"  \
"ENABLE_IR7_FIFO:false"  \
"ENABLE_TDATA:true"  \
"ENABLE_TDEST:true"  \
"ENABLE_TID:true"  \
"ENABLE_TIMEOUT:false"  \
"ENABLE_TKEEP:true"  \
"ENABLE_TLAST:true"  \
"ENABLE_TR0_FIFO:true"  \
"ENABLE_TR1_FIFO:false"  \
"ENABLE_TR2_FIFO:false"  \
"ENABLE_TR3_FIFO:false"  \
"ENABLE_TR4_FIFO:false"  \
"ENABLE_TR5_FIFO:false"  \
"ENABLE_TR6_FIFO:false"  \
"ENABLE_TR7_FIFO:false"  \
"ENABLE_TREADY:true"  \
"ENABLE_TSTRB:false"  \
"ENABLE_TUSER:true"  \
"IR0_ASYNC_FIFO:0"  \
"IR0_ENABLE_ARB:0"  \
"IR0_FIFO_DEPTH:16"  \
"IR0_FIFO_ECC:false"  \
"IR0_LCM_TDATA_BYTES:4"  \
"IR0_PACKET_MODE:false"  \
"IR0_RAM_TYPE:1"  \
"IR0_TDEST_BASE:0x0"  \
"IR0_TDEST_HIGH:0x0"  \
"IR0_TUSER_WIDTH:4"  \
"IR1_ASYNC_FIFO:0"  \
"IR1_ENABLE_ARB:0"  \
"IR1_FIFO_DEPTH:16"  \
"IR1_FIFO_ECC:false"  \
"IR1_LCM_TDATA_BYTES:4"  \
"IR1_PACKET_MODE:false"  \
"IR1_RAM_TYPE:1"  \
"IR1_TDEST_BASE:0x1"  \
"IR1_TDEST_HIGH:0x1"  \
"IR1_TUSER_WIDTH:4"  \
"IR2_ASYNC_FIFO:0"  \
"IR2_ENABLE_ARB:0"  \
"IR2_FIFO_DEPTH:16"  \
"IR2_FIFO_ECC:false"  \
"IR2_LCM_TDATA_BYTES:4"  \
"IR2_PACKET_MODE:false"  \
"IR2_RAM_TYPE:1"  \
"IR2_TDEST_BASE:0x2"  \
"IR2_TDEST_HIGH:0x2"  \
"IR2_TUSER_WIDTH:4"  \
"IR3_ASYNC_FIFO:0"  \
"IR3_ENABLE_ARB:0"  \
"IR3_FIFO_DEPTH:16"  \
"IR3_FIFO_ECC:false"  \
"IR3_LCM_TDATA_BYTES:4"  \
"IR3_PACKET_MODE:false"  \
"IR3_RAM_TYPE:1"  \
"IR3_TDEST_BASE:0x3"  \
"IR3_TDEST_HIGH:0x3"  \
"IR3_TUSER_WIDTH:4"  \
"IR4_ASYNC_FIFO:0"  \
"IR4_ENABLE_ARB:0"  \
"IR4_FIFO_DEPTH:16"  \
"IR4_FIFO_ECC:false"  \
"IR4_LCM_TDATA_BYTES:4"  \
"IR4_PACKET_MODE:false"  \
"IR4_RAM_TYPE:1"  \
"IR4_TDEST_BASE:0x4"  \
"IR4_TDEST_HIGH:0x4"  \
"IR4_TUSER_WIDTH:4"  \
"IR5_ASYNC_FIFO:0"  \
"IR5_ENABLE_ARB:0"  \
"IR5_FIFO_DEPTH:16"  \
"IR5_FIFO_ECC:false"  \
"IR5_LCM_TDATA_BYTES:4"  \
"IR5_PACKET_MODE:false"  \
"IR5_RAM_TYPE:1"  \
"IR5_TDEST_BASE:0x5"  \
"IR5_TDEST_HIGH:0x5"  \
"IR5_TUSER_WIDTH:4"  \
"IR6_ASYNC_FIFO:0"  \
"IR6_ENABLE_ARB:0"  \
"IR6_FIFO_DEPTH:16"  \
"IR6_FIFO_ECC:false"  \
"IR6_LCM_TDATA_BYTES:4"  \
"IR6_PACKET_MODE:false"  \
"IR6_RAM_TYPE:1"  \
"IR6_TDEST_BASE:0x6"  \
"IR6_TDEST_HIGH:0x6"  \
"IR6_TUSER_WIDTH:4"  \
"IR7_ASYNC_FIFO:0"  \
"IR7_ENABLE_ARB:0"  \
"IR7_FIFO_DEPTH:16"  \
"IR7_FIFO_ECC:false"  \
"IR7_LCM_TDATA_BYTES:4"  \
"IR7_PACKET_MODE:false"  \
"IR7_RAM_TYPE:1"  \
"IR7_TDEST_BASE:0x7"  \
"IR7_TDEST_HIGH:0x7"  \
"IR7_TUSER_WIDTH:4"  \
"NUM_ARB_TRANS:1"  \
"NUM_INITIATORS:1"  \
"NUM_STAGES:2"  \
"NUM_TARGETS:1"  \
"NUM_TARGETS_WIDTH:1"  \
"TDATA_BYTES:4"  \
"TDEST_WIDTH:32"  \
"TID_WIDTH:1"  \
"TIMEOUT_CYCLES:64"  \
"TR0_ASYNC_FIFO:1"  \
"TR0_FIFO_DEPTH:512"  \
"TR0_FIFO_ECC:false"  \
"TR0_IR0_LINK:true"  \
"TR0_IR1_LINK:true"  \
"TR0_IR2_LINK:true"  \
"TR0_IR3_LINK:true"  \
"TR0_IR4_LINK:true"  \
"TR0_IR5_LINK:true"  \
"TR0_IR6_LINK:true"  \
"TR0_IR7_LINK:true"  \
"TR0_LCM_TDATA_BYTES:4"  \
"TR0_PACKET_MODE:true"  \
"TR0_RAM_TYPE:1"  \
"TR0_TUSER_WIDTH:4"  \
"TR1_ASYNC_FIFO:0"  \
"TR1_FIFO_DEPTH:16"  \
"TR1_FIFO_ECC:false"  \
"TR1_IR0_LINK:true"  \
"TR1_IR1_LINK:true"  \
"TR1_IR2_LINK:true"  \
"TR1_IR3_LINK:true"  \
"TR1_IR4_LINK:true"  \
"TR1_IR5_LINK:true"  \
"TR1_IR6_LINK:true"  \
"TR1_IR7_LINK:true"  \
"TR1_LCM_TDATA_BYTES:4"  \
"TR1_PACKET_MODE:false"  \
"TR1_RAM_TYPE:1"  \
"TR1_TUSER_WIDTH:4"  \
"TR2_ASYNC_FIFO:0"  \
"TR2_FIFO_DEPTH:16"  \
"TR2_FIFO_ECC:false"  \
"TR2_IR0_LINK:true"  \
"TR2_IR1_LINK:true"  \
"TR2_IR2_LINK:true"  \
"TR2_IR3_LINK:true"  \
"TR2_IR4_LINK:true"  \
"TR2_IR5_LINK:true"  \
"TR2_IR6_LINK:true"  \
"TR2_IR7_LINK:true"  \
"TR2_LCM_TDATA_BYTES:4"  \
"TR2_PACKET_MODE:false"  \
"TR2_RAM_TYPE:1"  \
"TR2_TUSER_WIDTH:4"  \
"TR3_ASYNC_FIFO:0"  \
"TR3_FIFO_DEPTH:16"  \
"TR3_FIFO_ECC:false"  \
"TR3_IR0_LINK:true"  \
"TR3_IR1_LINK:true"  \
"TR3_IR2_LINK:true"  \
"TR3_IR3_LINK:true"  \
"TR3_IR4_LINK:true"  \
"TR3_IR5_LINK:true"  \
"TR3_IR6_LINK:true"  \
"TR3_IR7_LINK:true"  \
"TR3_LCM_TDATA_BYTES:4"  \
"TR3_PACKET_MODE:false"  \
"TR3_RAM_TYPE:1"  \
"TR3_TUSER_WIDTH:4"  \
"TR4_ASYNC_FIFO:0"  \
"TR4_FIFO_DEPTH:16"  \
"TR4_FIFO_ECC:false"  \
"TR4_IR0_LINK:true"  \
"TR4_IR1_LINK:true"  \
"TR4_IR2_LINK:true"  \
"TR4_IR3_LINK:true"  \
"TR4_IR4_LINK:true"  \
"TR4_IR5_LINK:true"  \
"TR4_IR6_LINK:true"  \
"TR4_IR7_LINK:true"  \
"TR4_LCM_TDATA_BYTES:4"  \
"TR4_PACKET_MODE:false"  \
"TR4_RAM_TYPE:1"  \
"TR4_TUSER_WIDTH:4"  \
"TR5_ASYNC_FIFO:0"  \
"TR5_FIFO_DEPTH:16"  \
"TR5_FIFO_ECC:false"  \
"TR5_IR0_LINK:true"  \
"TR5_IR1_LINK:true"  \
"TR5_IR2_LINK:true"  \
"TR5_IR3_LINK:true"  \
"TR5_IR4_LINK:true"  \
"TR5_IR5_LINK:true"  \
"TR5_IR6_LINK:true"  \
"TR5_IR7_LINK:true"  \
"TR5_LCM_TDATA_BYTES:4"  \
"TR5_PACKET_MODE:false"  \
"TR5_RAM_TYPE:1"  \
"TR5_TUSER_WIDTH:4"  \
"TR6_ASYNC_FIFO:0"  \
"TR6_FIFO_DEPTH:16"  \
"TR6_FIFO_ECC:false"  \
"TR6_IR0_LINK:true"  \
"TR6_IR1_LINK:true"  \
"TR6_IR2_LINK:true"  \
"TR6_IR3_LINK:true"  \
"TR6_IR4_LINK:true"  \
"TR6_IR5_LINK:true"  \
"TR6_IR6_LINK:true"  \
"TR6_IR7_LINK:true"  \
"TR6_LCM_TDATA_BYTES:4"  \
"TR6_PACKET_MODE:false"  \
"TR6_RAM_TYPE:1"  \
"TR6_TUSER_WIDTH:4"  \
"TR7_ASYNC_FIFO:0"  \
"TR7_FIFO_DEPTH:16"  \
"TR7_FIFO_ECC:false"  \
"TR7_IR0_LINK:true"  \
"TR7_IR1_LINK:true"  \
"TR7_IR2_LINK:true"  \
"TR7_IR3_LINK:true"  \
"TR7_IR4_LINK:true"  \
"TR7_IR5_LINK:true"  \
"TR7_IR6_LINK:true"  \
"TR7_IR7_LINK:true"  \
"TR7_LCM_TDATA_BYTES:4"  \
"TR7_PACKET_MODE:false"  \
"TR7_RAM_TYPE:1"  \
"TR7_TUSER_WIDTH:4"  \
"TUSER_BITS_P_BYTE:1"  \
"TUSER_WIDTH:4"   }
# Exporting Component Description of CoreAXI4SInterconnect_C0 to TCL done
*/

// CoreAXI4SInterconnect_C0
module CoreAXI4SInterconnect_C0(
    // Inputs
    AXI4S_I0CLK,
    AXI4S_I0RESETN,
    AXI4S_I0TREADY,
    AXI4S_T0TDATA,
    AXI4S_T0TDEST,
    AXI4S_T0TID,
    AXI4S_T0TKEEP,
    AXI4S_T0TLAST,
    AXI4S_T0TSTRB,
    AXI4S_T0TUSER,
    AXI4S_T0TVALID,
    // Outputs
    AXI4S_I0TDATA,
    AXI4S_I0TDEST,
    AXI4S_I0TID,
    AXI4S_I0TKEEP,
    AXI4S_I0TLAST,
    AXI4S_I0TSTRB,
    AXI4S_I0TUSER,
    AXI4S_I0TVALID,
    AXI4S_T0TREADY
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         AXI4S_I0CLK;
input         AXI4S_I0RESETN;
input         AXI4S_I0TREADY;
input  [31:0] AXI4S_T0TDATA;
input  [31:0] AXI4S_T0TDEST;
input  [0:0]  AXI4S_T0TID;
input  [3:0]  AXI4S_T0TKEEP;
input         AXI4S_T0TLAST;
input  [3:0]  AXI4S_T0TSTRB;
input  [3:0]  AXI4S_T0TUSER;
input         AXI4S_T0TVALID;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [31:0] AXI4S_I0TDATA;
output [31:0] AXI4S_I0TDEST;
output [1:0]  AXI4S_I0TID;
output [3:0]  AXI4S_I0TKEEP;
output        AXI4S_I0TLAST;
output [3:0]  AXI4S_I0TSTRB;
output [3:0]  AXI4S_I0TUSER;
output        AXI4S_I0TVALID;
output        AXI4S_T0TREADY;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          AXI4S_I0CLK;
wire          AXI4S_I0RESETN;
wire   [31:0] AXI4S_INITIATOR0_TDATA;
wire   [31:0] AXI4S_INITIATOR0_TDEST;
wire   [1:0]  AXI4S_INITIATOR0_TID;
wire   [3:0]  AXI4S_INITIATOR0_TKEEP;
wire          AXI4S_INITIATOR0_TLAST;
wire          AXI4S_I0TREADY;
wire   [3:0]  AXI4S_INITIATOR0_TSTRB;
wire   [3:0]  AXI4S_INITIATOR0_TUSER;
wire          AXI4S_INITIATOR0_TVALID;
wire   [31:0] AXI4S_T0TDATA;
wire   [31:0] AXI4S_T0TDEST;
wire   [0:0]  AXI4S_T0TID;
wire   [3:0]  AXI4S_T0TKEEP;
wire          AXI4S_T0TLAST;
wire          AXI4S_TARGET0_TREADY;
wire   [3:0]  AXI4S_T0TSTRB;
wire   [3:0]  AXI4S_T0TUSER;
wire          AXI4S_T0TVALID;
wire          AXI4S_TARGET0_TREADY_net_0;
wire          AXI4S_INITIATOR0_TVALID_net_0;
wire   [31:0] AXI4S_INITIATOR0_TDATA_net_0;
wire   [3:0]  AXI4S_INITIATOR0_TSTRB_net_0;
wire   [3:0]  AXI4S_INITIATOR0_TKEEP_net_0;
wire          AXI4S_INITIATOR0_TLAST_net_0;
wire   [1:0]  AXI4S_INITIATOR0_TID_net_0;
wire   [31:0] AXI4S_INITIATOR0_TDEST_net_0;
wire   [3:0]  AXI4S_INITIATOR0_TUSER_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          GND_net;
wire   [31:0] AXI4S_T1TDATA_const_net_0;
wire   [3:0]  AXI4S_T1TSTRB_const_net_0;
wire   [3:0]  AXI4S_T1TKEEP_const_net_0;
wire   [31:0] AXI4S_T1TDEST_const_net_0;
wire   [3:0]  AXI4S_T1TUSER_const_net_0;
wire   [31:0] AXI4S_T2TDATA_const_net_0;
wire   [3:0]  AXI4S_T2TSTRB_const_net_0;
wire   [3:0]  AXI4S_T2TKEEP_const_net_0;
wire   [31:0] AXI4S_T2TDEST_const_net_0;
wire   [3:0]  AXI4S_T2TUSER_const_net_0;
wire   [31:0] AXI4S_T3TDATA_const_net_0;
wire   [3:0]  AXI4S_T3TSTRB_const_net_0;
wire   [3:0]  AXI4S_T3TKEEP_const_net_0;
wire   [31:0] AXI4S_T3TDEST_const_net_0;
wire   [3:0]  AXI4S_T3TUSER_const_net_0;
wire   [31:0] AXI4S_T4TDATA_const_net_0;
wire   [3:0]  AXI4S_T4TSTRB_const_net_0;
wire   [3:0]  AXI4S_T4TKEEP_const_net_0;
wire   [31:0] AXI4S_T4TDEST_const_net_0;
wire   [3:0]  AXI4S_T4TUSER_const_net_0;
wire   [31:0] AXI4S_T5TDATA_const_net_0;
wire   [3:0]  AXI4S_T5TSTRB_const_net_0;
wire   [3:0]  AXI4S_T5TKEEP_const_net_0;
wire   [31:0] AXI4S_T5TDEST_const_net_0;
wire   [3:0]  AXI4S_T5TUSER_const_net_0;
wire   [31:0] AXI4S_T6TDATA_const_net_0;
wire   [3:0]  AXI4S_T6TSTRB_const_net_0;
wire   [3:0]  AXI4S_T6TKEEP_const_net_0;
wire   [31:0] AXI4S_T6TDEST_const_net_0;
wire   [3:0]  AXI4S_T6TUSER_const_net_0;
wire   [31:0] AXI4S_T7TDATA_const_net_0;
wire   [3:0]  AXI4S_T7TSTRB_const_net_0;
wire   [3:0]  AXI4S_T7TKEEP_const_net_0;
wire   [31:0] AXI4S_T7TDEST_const_net_0;
wire   [3:0]  AXI4S_T7TUSER_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net                   = 1'b0;
assign AXI4S_T1TDATA_const_net_0 = 32'h00000000;
assign AXI4S_T1TSTRB_const_net_0 = 4'h0;
assign AXI4S_T1TKEEP_const_net_0 = 4'h0;
assign AXI4S_T1TDEST_const_net_0 = 32'h00000000;
assign AXI4S_T1TUSER_const_net_0 = 4'h0;
assign AXI4S_T2TDATA_const_net_0 = 32'h00000000;
assign AXI4S_T2TSTRB_const_net_0 = 4'h0;
assign AXI4S_T2TKEEP_const_net_0 = 4'h0;
assign AXI4S_T2TDEST_const_net_0 = 32'h00000000;
assign AXI4S_T2TUSER_const_net_0 = 4'h0;
assign AXI4S_T3TDATA_const_net_0 = 32'h00000000;
assign AXI4S_T3TSTRB_const_net_0 = 4'h0;
assign AXI4S_T3TKEEP_const_net_0 = 4'h0;
assign AXI4S_T3TDEST_const_net_0 = 32'h00000000;
assign AXI4S_T3TUSER_const_net_0 = 4'h0;
assign AXI4S_T4TDATA_const_net_0 = 32'h00000000;
assign AXI4S_T4TSTRB_const_net_0 = 4'h0;
assign AXI4S_T4TKEEP_const_net_0 = 4'h0;
assign AXI4S_T4TDEST_const_net_0 = 32'h00000000;
assign AXI4S_T4TUSER_const_net_0 = 4'h0;
assign AXI4S_T5TDATA_const_net_0 = 32'h00000000;
assign AXI4S_T5TSTRB_const_net_0 = 4'h0;
assign AXI4S_T5TKEEP_const_net_0 = 4'h0;
assign AXI4S_T5TDEST_const_net_0 = 32'h00000000;
assign AXI4S_T5TUSER_const_net_0 = 4'h0;
assign AXI4S_T6TDATA_const_net_0 = 32'h00000000;
assign AXI4S_T6TSTRB_const_net_0 = 4'h0;
assign AXI4S_T6TKEEP_const_net_0 = 4'h0;
assign AXI4S_T6TDEST_const_net_0 = 32'h00000000;
assign AXI4S_T6TUSER_const_net_0 = 4'h0;
assign AXI4S_T7TDATA_const_net_0 = 32'h00000000;
assign AXI4S_T7TSTRB_const_net_0 = 4'h0;
assign AXI4S_T7TKEEP_const_net_0 = 4'h0;
assign AXI4S_T7TDEST_const_net_0 = 32'h00000000;
assign AXI4S_T7TUSER_const_net_0 = 4'h0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign AXI4S_TARGET0_TREADY_net_0    = AXI4S_TARGET0_TREADY;
assign AXI4S_T0TREADY                = AXI4S_TARGET0_TREADY_net_0;
assign AXI4S_INITIATOR0_TVALID_net_0 = AXI4S_INITIATOR0_TVALID;
assign AXI4S_I0TVALID                = AXI4S_INITIATOR0_TVALID_net_0;
assign AXI4S_INITIATOR0_TDATA_net_0  = AXI4S_INITIATOR0_TDATA;
assign AXI4S_I0TDATA[31:0]           = AXI4S_INITIATOR0_TDATA_net_0;
assign AXI4S_INITIATOR0_TSTRB_net_0  = AXI4S_INITIATOR0_TSTRB;
assign AXI4S_I0TSTRB[3:0]            = AXI4S_INITIATOR0_TSTRB_net_0;
assign AXI4S_INITIATOR0_TKEEP_net_0  = AXI4S_INITIATOR0_TKEEP;
assign AXI4S_I0TKEEP[3:0]            = AXI4S_INITIATOR0_TKEEP_net_0;
assign AXI4S_INITIATOR0_TLAST_net_0  = AXI4S_INITIATOR0_TLAST;
assign AXI4S_I0TLAST                 = AXI4S_INITIATOR0_TLAST_net_0;
assign AXI4S_INITIATOR0_TID_net_0    = AXI4S_INITIATOR0_TID;
assign AXI4S_I0TID[1:0]              = AXI4S_INITIATOR0_TID_net_0;
assign AXI4S_INITIATOR0_TDEST_net_0  = AXI4S_INITIATOR0_TDEST;
assign AXI4S_I0TDEST[31:0]           = AXI4S_INITIATOR0_TDEST_net_0;
assign AXI4S_INITIATOR0_TUSER_net_0  = AXI4S_INITIATOR0_TUSER;
assign AXI4S_I0TUSER[3:0]            = AXI4S_INITIATOR0_TUSER_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------CoreAXI4SInterconnect   -   Actel:DirectCore:CoreAXI4SInterconnect:2.0.111
CoreAXI4SInterconnect #( 
        .ARB_TYPE              ( 0 ),
        .AXI4S_I0RS            ( 0 ),
        .AXI4S_I0TDATA_BYTES   ( 4 ),
        .AXI4S_I1RS            ( 0 ),
        .AXI4S_I1TDATA_BYTES   ( 4 ),
        .AXI4S_I2RS            ( 0 ),
        .AXI4S_I2TDATA_BYTES   ( 4 ),
        .AXI4S_I3RS            ( 0 ),
        .AXI4S_I3TDATA_BYTES   ( 4 ),
        .AXI4S_I4RS            ( 0 ),
        .AXI4S_I4TDATA_BYTES   ( 4 ),
        .AXI4S_I5RS            ( 0 ),
        .AXI4S_I5TDATA_BYTES   ( 4 ),
        .AXI4S_I6RS            ( 0 ),
        .AXI4S_I6TDATA_BYTES   ( 4 ),
        .AXI4S_I7RS            ( 0 ),
        .AXI4S_I7TDATA_BYTES   ( 4 ),
        .AXI4S_IDWC_I0RS       ( 0 ),
        .AXI4S_IDWC_I1RS       ( 0 ),
        .AXI4S_IDWC_I2RS       ( 0 ),
        .AXI4S_IDWC_I3RS       ( 0 ),
        .AXI4S_IDWC_I4RS       ( 0 ),
        .AXI4S_IDWC_I5RS       ( 0 ),
        .AXI4S_IDWC_I6RS       ( 0 ),
        .AXI4S_IDWC_I7RS       ( 0 ),
        .AXI4S_IDWC_T0RS       ( 0 ),
        .AXI4S_IDWC_T1RS       ( 0 ),
        .AXI4S_IDWC_T2RS       ( 0 ),
        .AXI4S_IDWC_T3RS       ( 0 ),
        .AXI4S_IDWC_T4RS       ( 0 ),
        .AXI4S_IDWC_T5RS       ( 0 ),
        .AXI4S_IDWC_T6RS       ( 0 ),
        .AXI4S_IDWC_T7RS       ( 0 ),
        .AXI4S_T0RS            ( 0 ),
        .AXI4S_T0TDATA_BYTES   ( 4 ),
        .AXI4S_T1RS            ( 0 ),
        .AXI4S_T1TDATA_BYTES   ( 4 ),
        .AXI4S_T2RS            ( 0 ),
        .AXI4S_T2TDATA_BYTES   ( 4 ),
        .AXI4S_T3RS            ( 0 ),
        .AXI4S_T3TDATA_BYTES   ( 4 ),
        .AXI4S_T4RS            ( 0 ),
        .AXI4S_T4TDATA_BYTES   ( 4 ),
        .AXI4S_T5RS            ( 0 ),
        .AXI4S_T5TDATA_BYTES   ( 4 ),
        .AXI4S_T6RS            ( 0 ),
        .AXI4S_T6TDATA_BYTES   ( 4 ),
        .AXI4S_T7RS            ( 0 ),
        .AXI4S_T7TDATA_BYTES   ( 4 ),
        .AXI4S_TDWC_I0RS       ( 0 ),
        .AXI4S_TDWC_I1RS       ( 0 ),
        .AXI4S_TDWC_I2RS       ( 0 ),
        .AXI4S_TDWC_I3RS       ( 0 ),
        .AXI4S_TDWC_I4RS       ( 0 ),
        .AXI4S_TDWC_I5RS       ( 0 ),
        .AXI4S_TDWC_I6RS       ( 0 ),
        .AXI4S_TDWC_I7RS       ( 0 ),
        .AXI4S_TDWC_T0RS       ( 0 ),
        .AXI4S_TDWC_T1RS       ( 0 ),
        .AXI4S_TDWC_T2RS       ( 0 ),
        .AXI4S_TDWC_T3RS       ( 0 ),
        .AXI4S_TDWC_T4RS       ( 0 ),
        .AXI4S_TDWC_T5RS       ( 0 ),
        .AXI4S_TDWC_T6RS       ( 0 ),
        .AXI4S_TDWC_T7RS       ( 0 ),
        .ENABLE_IR0_FIFO       ( 0 ),
        .ENABLE_IR1_FIFO       ( 0 ),
        .ENABLE_IR2_FIFO       ( 0 ),
        .ENABLE_IR3_FIFO       ( 0 ),
        .ENABLE_IR4_FIFO       ( 0 ),
        .ENABLE_IR5_FIFO       ( 0 ),
        .ENABLE_IR6_FIFO       ( 0 ),
        .ENABLE_IR7_FIFO       ( 0 ),
        .ENABLE_TDATA          ( 1 ),
        .ENABLE_TDEST          ( 1 ),
        .ENABLE_TID            ( 1 ),
        .ENABLE_TIMEOUT        ( 0 ),
        .ENABLE_TKEEP          ( 1 ),
        .ENABLE_TLAST          ( 1 ),
        .ENABLE_TR0_FIFO       ( 1 ),
        .ENABLE_TR1_FIFO       ( 0 ),
        .ENABLE_TR2_FIFO       ( 0 ),
        .ENABLE_TR3_FIFO       ( 0 ),
        .ENABLE_TR4_FIFO       ( 0 ),
        .ENABLE_TR5_FIFO       ( 0 ),
        .ENABLE_TR6_FIFO       ( 0 ),
        .ENABLE_TR7_FIFO       ( 0 ),
        .ENABLE_TREADY         ( 1 ),
        .ENABLE_TSTRB          ( 0 ),
        .ENABLE_TUSER          ( 1 ),
        .FAMILY                ( 27 ),
        .IR0_ASYNC_FIFO        ( 0 ),
        .IR0_ENABLE_ARB        ( 0 ),
        .IR0_FIFO_DEPTH        ( 16 ),
        .IR0_FIFO_ECC          ( 0 ),
        .IR0_LCM_TDATA_BYTES   ( 4 ),
        .IR0_PACKET_MODE       ( 0 ),
        .IR0_RAM_TYPE          ( 1 ),
        .IR0_TDEST_BASE        ( 'h0 ),
        .IR0_TDEST_HIGH        ( 'h0 ),
        .IR0_TUSER_WIDTH       ( 4 ),
        .IR1_ASYNC_FIFO        ( 0 ),
        .IR1_ENABLE_ARB        ( 0 ),
        .IR1_FIFO_DEPTH        ( 16 ),
        .IR1_FIFO_ECC          ( 0 ),
        .IR1_LCM_TDATA_BYTES   ( 4 ),
        .IR1_PACKET_MODE       ( 0 ),
        .IR1_RAM_TYPE          ( 1 ),
        .IR1_TDEST_BASE        ( 'h1 ),
        .IR1_TDEST_HIGH        ( 'h1 ),
        .IR1_TUSER_WIDTH       ( 4 ),
        .IR2_ASYNC_FIFO        ( 0 ),
        .IR2_ENABLE_ARB        ( 0 ),
        .IR2_FIFO_DEPTH        ( 16 ),
        .IR2_FIFO_ECC          ( 0 ),
        .IR2_LCM_TDATA_BYTES   ( 4 ),
        .IR2_PACKET_MODE       ( 0 ),
        .IR2_RAM_TYPE          ( 1 ),
        .IR2_TDEST_BASE        ( 'h2 ),
        .IR2_TDEST_HIGH        ( 'h2 ),
        .IR2_TUSER_WIDTH       ( 4 ),
        .IR3_ASYNC_FIFO        ( 0 ),
        .IR3_ENABLE_ARB        ( 0 ),
        .IR3_FIFO_DEPTH        ( 16 ),
        .IR3_FIFO_ECC          ( 0 ),
        .IR3_LCM_TDATA_BYTES   ( 4 ),
        .IR3_PACKET_MODE       ( 0 ),
        .IR3_RAM_TYPE          ( 1 ),
        .IR3_TDEST_BASE        ( 'h3 ),
        .IR3_TDEST_HIGH        ( 'h3 ),
        .IR3_TUSER_WIDTH       ( 4 ),
        .IR4_ASYNC_FIFO        ( 0 ),
        .IR4_ENABLE_ARB        ( 0 ),
        .IR4_FIFO_DEPTH        ( 16 ),
        .IR4_FIFO_ECC          ( 0 ),
        .IR4_LCM_TDATA_BYTES   ( 4 ),
        .IR4_PACKET_MODE       ( 0 ),
        .IR4_RAM_TYPE          ( 1 ),
        .IR4_TDEST_BASE        ( 'h4 ),
        .IR4_TDEST_HIGH        ( 'h4 ),
        .IR4_TUSER_WIDTH       ( 4 ),
        .IR5_ASYNC_FIFO        ( 0 ),
        .IR5_ENABLE_ARB        ( 0 ),
        .IR5_FIFO_DEPTH        ( 16 ),
        .IR5_FIFO_ECC          ( 0 ),
        .IR5_LCM_TDATA_BYTES   ( 4 ),
        .IR5_PACKET_MODE       ( 0 ),
        .IR5_RAM_TYPE          ( 1 ),
        .IR5_TDEST_BASE        ( 'h5 ),
        .IR5_TDEST_HIGH        ( 'h5 ),
        .IR5_TUSER_WIDTH       ( 4 ),
        .IR6_ASYNC_FIFO        ( 0 ),
        .IR6_ENABLE_ARB        ( 0 ),
        .IR6_FIFO_DEPTH        ( 16 ),
        .IR6_FIFO_ECC          ( 0 ),
        .IR6_LCM_TDATA_BYTES   ( 4 ),
        .IR6_PACKET_MODE       ( 0 ),
        .IR6_RAM_TYPE          ( 1 ),
        .IR6_TDEST_BASE        ( 'h6 ),
        .IR6_TDEST_HIGH        ( 'h6 ),
        .IR6_TUSER_WIDTH       ( 4 ),
        .IR7_ASYNC_FIFO        ( 0 ),
        .IR7_ENABLE_ARB        ( 0 ),
        .IR7_FIFO_DEPTH        ( 16 ),
        .IR7_FIFO_ECC          ( 0 ),
        .IR7_LCM_TDATA_BYTES   ( 4 ),
        .IR7_PACKET_MODE       ( 0 ),
        .IR7_RAM_TYPE          ( 1 ),
        .IR7_TDEST_BASE        ( 'h7 ),
        .IR7_TDEST_HIGH        ( 'h7 ),
        .IR7_TUSER_WIDTH       ( 4 ),
        .NUM_ARB_TRANS         ( 1 ),
        .NUM_INITIATORS        ( 1 ),
        .NUM_STAGES            ( 2 ),
        .NUM_TARGETS           ( 1 ),
        .NUM_TARGETS_WIDTH     ( 1 ),
        .TDATA_BYTES           ( 4 ),
        .TDEST_WIDTH           ( 32 ),
        .TGIGEN_DISPLAY_SYMBOL ( 1 ),
        .TID_WIDTH             ( 1 ),
        .TIMEOUT_CYCLES        ( 64 ),
        .TR0_ASYNC_FIFO        ( 1 ),
        .TR0_FIFO_DEPTH        ( 512 ),
        .TR0_FIFO_ECC          ( 0 ),
        .TR0_IR0_LINK          ( 1 ),
        .TR0_IR1_LINK          ( 1 ),
        .TR0_IR2_LINK          ( 1 ),
        .TR0_IR3_LINK          ( 1 ),
        .TR0_IR4_LINK          ( 1 ),
        .TR0_IR5_LINK          ( 1 ),
        .TR0_IR6_LINK          ( 1 ),
        .TR0_IR7_LINK          ( 1 ),
        .TR0_LCM_TDATA_BYTES   ( 4 ),
        .TR0_PACKET_MODE       ( 1 ),
        .TR0_RAM_TYPE          ( 1 ),
        .TR0_TUSER_WIDTH       ( 4 ),
        .TR1_ASYNC_FIFO        ( 0 ),
        .TR1_FIFO_DEPTH        ( 16 ),
        .TR1_FIFO_ECC          ( 0 ),
        .TR1_IR0_LINK          ( 1 ),
        .TR1_IR1_LINK          ( 1 ),
        .TR1_IR2_LINK          ( 1 ),
        .TR1_IR3_LINK          ( 1 ),
        .TR1_IR4_LINK          ( 1 ),
        .TR1_IR5_LINK          ( 1 ),
        .TR1_IR6_LINK          ( 1 ),
        .TR1_IR7_LINK          ( 1 ),
        .TR1_LCM_TDATA_BYTES   ( 4 ),
        .TR1_PACKET_MODE       ( 0 ),
        .TR1_RAM_TYPE          ( 1 ),
        .TR1_TUSER_WIDTH       ( 4 ),
        .TR2_ASYNC_FIFO        ( 0 ),
        .TR2_FIFO_DEPTH        ( 16 ),
        .TR2_FIFO_ECC          ( 0 ),
        .TR2_IR0_LINK          ( 1 ),
        .TR2_IR1_LINK          ( 1 ),
        .TR2_IR2_LINK          ( 1 ),
        .TR2_IR3_LINK          ( 1 ),
        .TR2_IR4_LINK          ( 1 ),
        .TR2_IR5_LINK          ( 1 ),
        .TR2_IR6_LINK          ( 1 ),
        .TR2_IR7_LINK          ( 1 ),
        .TR2_LCM_TDATA_BYTES   ( 4 ),
        .TR2_PACKET_MODE       ( 0 ),
        .TR2_RAM_TYPE          ( 1 ),
        .TR2_TUSER_WIDTH       ( 4 ),
        .TR3_ASYNC_FIFO        ( 0 ),
        .TR3_FIFO_DEPTH        ( 16 ),
        .TR3_FIFO_ECC          ( 0 ),
        .TR3_IR0_LINK          ( 1 ),
        .TR3_IR1_LINK          ( 1 ),
        .TR3_IR2_LINK          ( 1 ),
        .TR3_IR3_LINK          ( 1 ),
        .TR3_IR4_LINK          ( 1 ),
        .TR3_IR5_LINK          ( 1 ),
        .TR3_IR6_LINK          ( 1 ),
        .TR3_IR7_LINK          ( 1 ),
        .TR3_LCM_TDATA_BYTES   ( 4 ),
        .TR3_PACKET_MODE       ( 0 ),
        .TR3_RAM_TYPE          ( 1 ),
        .TR3_TUSER_WIDTH       ( 4 ),
        .TR4_ASYNC_FIFO        ( 0 ),
        .TR4_FIFO_DEPTH        ( 16 ),
        .TR4_FIFO_ECC          ( 0 ),
        .TR4_IR0_LINK          ( 1 ),
        .TR4_IR1_LINK          ( 1 ),
        .TR4_IR2_LINK          ( 1 ),
        .TR4_IR3_LINK          ( 1 ),
        .TR4_IR4_LINK          ( 1 ),
        .TR4_IR5_LINK          ( 1 ),
        .TR4_IR6_LINK          ( 1 ),
        .TR4_IR7_LINK          ( 1 ),
        .TR4_LCM_TDATA_BYTES   ( 4 ),
        .TR4_PACKET_MODE       ( 0 ),
        .TR4_RAM_TYPE          ( 1 ),
        .TR4_TUSER_WIDTH       ( 4 ),
        .TR5_ASYNC_FIFO        ( 0 ),
        .TR5_FIFO_DEPTH        ( 16 ),
        .TR5_FIFO_ECC          ( 0 ),
        .TR5_IR0_LINK          ( 1 ),
        .TR5_IR1_LINK          ( 1 ),
        .TR5_IR2_LINK          ( 1 ),
        .TR5_IR3_LINK          ( 1 ),
        .TR5_IR4_LINK          ( 1 ),
        .TR5_IR5_LINK          ( 1 ),
        .TR5_IR6_LINK          ( 1 ),
        .TR5_IR7_LINK          ( 1 ),
        .TR5_LCM_TDATA_BYTES   ( 4 ),
        .TR5_PACKET_MODE       ( 0 ),
        .TR5_RAM_TYPE          ( 1 ),
        .TR5_TUSER_WIDTH       ( 4 ),
        .TR6_ASYNC_FIFO        ( 0 ),
        .TR6_FIFO_DEPTH        ( 16 ),
        .TR6_FIFO_ECC          ( 0 ),
        .TR6_IR0_LINK          ( 1 ),
        .TR6_IR1_LINK          ( 1 ),
        .TR6_IR2_LINK          ( 1 ),
        .TR6_IR3_LINK          ( 1 ),
        .TR6_IR4_LINK          ( 1 ),
        .TR6_IR5_LINK          ( 1 ),
        .TR6_IR6_LINK          ( 1 ),
        .TR6_IR7_LINK          ( 1 ),
        .TR6_LCM_TDATA_BYTES   ( 4 ),
        .TR6_PACKET_MODE       ( 0 ),
        .TR6_RAM_TYPE          ( 1 ),
        .TR6_TUSER_WIDTH       ( 4 ),
        .TR7_ASYNC_FIFO        ( 0 ),
        .TR7_FIFO_DEPTH        ( 16 ),
        .TR7_FIFO_ECC          ( 0 ),
        .TR7_IR0_LINK          ( 1 ),
        .TR7_IR1_LINK          ( 1 ),
        .TR7_IR2_LINK          ( 1 ),
        .TR7_IR3_LINK          ( 1 ),
        .TR7_IR4_LINK          ( 1 ),
        .TR7_IR5_LINK          ( 1 ),
        .TR7_IR6_LINK          ( 1 ),
        .TR7_IR7_LINK          ( 1 ),
        .TR7_LCM_TDATA_BYTES   ( 4 ),
        .TR7_PACKET_MODE       ( 0 ),
        .TR7_RAM_TYPE          ( 1 ),
        .TR7_TUSER_WIDTH       ( 4 ),
        .TUSER_BITS_P_BYTE     ( 1 ),
        .TUSER_WIDTH           ( 4 ) )
CoreAXI4SInterconnect_C0_0(
        // Inputs
        .ACLK           ( GND_net ), // tied to 1'b0 from definition
        .RESETN         ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I0CLK    ( AXI4S_I0CLK ),
        .AXI4S_I0RESETN ( AXI4S_I0RESETN ),
        .AXI4S_I1CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I1RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I2CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I2RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I3CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I3RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I4CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I4RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I5CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I5RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I6CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I6RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I7CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I7RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T0CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T0RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T1CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T1RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T2CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T2RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T3CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T3RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T4CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T4RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T5CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T5RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T6CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T6RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T7CLK    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T7RESETN ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T0TVALID ( AXI4S_T0TVALID ),
        .AXI4S_T0TLAST  ( AXI4S_T0TLAST ),
        .AXI4S_T1TVALID ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T1TLAST  ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T2TVALID ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T2TLAST  ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T3TVALID ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T3TLAST  ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T4TVALID ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T4TLAST  ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T5TVALID ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T5TLAST  ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T6TVALID ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T6TLAST  ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T7TVALID ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T7TLAST  ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I0TREADY ( AXI4S_I0TREADY ),
        .AXI4S_I1TREADY ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I2TREADY ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I3TREADY ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I4TREADY ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I5TREADY ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I6TREADY ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_I7TREADY ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T0TDATA  ( AXI4S_T0TDATA ),
        .AXI4S_T0TSTRB  ( AXI4S_T0TSTRB ),
        .AXI4S_T0TKEEP  ( AXI4S_T0TKEEP ),
        .AXI4S_T0TID    ( AXI4S_T0TID ),
        .AXI4S_T0TDEST  ( AXI4S_T0TDEST ),
        .AXI4S_T0TUSER  ( AXI4S_T0TUSER ),
        .AXI4S_T1TDATA  ( AXI4S_T1TDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T1TSTRB  ( AXI4S_T1TSTRB_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T1TKEEP  ( AXI4S_T1TKEEP_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T1TID    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T1TDEST  ( AXI4S_T1TDEST_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T1TUSER  ( AXI4S_T1TUSER_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T2TDATA  ( AXI4S_T2TDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T2TSTRB  ( AXI4S_T2TSTRB_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T2TKEEP  ( AXI4S_T2TKEEP_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T2TID    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T2TDEST  ( AXI4S_T2TDEST_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T2TUSER  ( AXI4S_T2TUSER_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T3TDATA  ( AXI4S_T3TDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T3TSTRB  ( AXI4S_T3TSTRB_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T3TKEEP  ( AXI4S_T3TKEEP_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T3TID    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T3TDEST  ( AXI4S_T3TDEST_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T3TUSER  ( AXI4S_T3TUSER_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T4TDATA  ( AXI4S_T4TDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T4TSTRB  ( AXI4S_T4TSTRB_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T4TKEEP  ( AXI4S_T4TKEEP_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T4TID    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T4TDEST  ( AXI4S_T4TDEST_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T4TUSER  ( AXI4S_T4TUSER_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T5TDATA  ( AXI4S_T5TDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T5TSTRB  ( AXI4S_T5TSTRB_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T5TKEEP  ( AXI4S_T5TKEEP_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T5TID    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T5TDEST  ( AXI4S_T5TDEST_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T5TUSER  ( AXI4S_T5TUSER_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T6TDATA  ( AXI4S_T6TDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T6TSTRB  ( AXI4S_T6TSTRB_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T6TKEEP  ( AXI4S_T6TKEEP_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T6TID    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T6TDEST  ( AXI4S_T6TDEST_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T6TUSER  ( AXI4S_T6TUSER_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T7TDATA  ( AXI4S_T7TDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T7TSTRB  ( AXI4S_T7TSTRB_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T7TKEEP  ( AXI4S_T7TKEEP_const_net_0 ), // tied to 4'h0 from definition
        .AXI4S_T7TID    ( GND_net ), // tied to 1'b0 from definition
        .AXI4S_T7TDEST  ( AXI4S_T7TDEST_const_net_0 ), // tied to 32'h00000000 from definition
        .AXI4S_T7TUSER  ( AXI4S_T7TUSER_const_net_0 ), // tied to 4'h0 from definition
        // Outputs
        .AXI4S_T0TREADY ( AXI4S_TARGET0_TREADY ),
        .AXI4S_T1TREADY (  ),
        .AXI4S_T2TREADY (  ),
        .AXI4S_T3TREADY (  ),
        .AXI4S_T4TREADY (  ),
        .AXI4S_T5TREADY (  ),
        .AXI4S_T6TREADY (  ),
        .AXI4S_T7TREADY (  ),
        .AXI4S_I0TVALID ( AXI4S_INITIATOR0_TVALID ),
        .AXI4S_I0TLAST  ( AXI4S_INITIATOR0_TLAST ),
        .AXI4S_I1TVALID (  ),
        .AXI4S_I1TLAST  (  ),
        .AXI4S_I2TVALID (  ),
        .AXI4S_I2TLAST  (  ),
        .AXI4S_I3TVALID (  ),
        .AXI4S_I3TLAST  (  ),
        .AXI4S_I4TVALID (  ),
        .AXI4S_I4TLAST  (  ),
        .AXI4S_I5TVALID (  ),
        .AXI4S_I5TLAST  (  ),
        .AXI4S_I6TVALID (  ),
        .AXI4S_I6TLAST  (  ),
        .AXI4S_I7TVALID (  ),
        .AXI4S_I7TLAST  (  ),
        .AXI4S_I0TDATA  ( AXI4S_INITIATOR0_TDATA ),
        .AXI4S_I0TSTRB  ( AXI4S_INITIATOR0_TSTRB ),
        .AXI4S_I0TKEEP  ( AXI4S_INITIATOR0_TKEEP ),
        .AXI4S_I0TID    ( AXI4S_INITIATOR0_TID ),
        .AXI4S_I0TDEST  ( AXI4S_INITIATOR0_TDEST ),
        .AXI4S_I0TUSER  ( AXI4S_INITIATOR0_TUSER ),
        .AXI4S_I1TDATA  (  ),
        .AXI4S_I1TSTRB  (  ),
        .AXI4S_I1TKEEP  (  ),
        .AXI4S_I1TID    (  ),
        .AXI4S_I1TDEST  (  ),
        .AXI4S_I1TUSER  (  ),
        .AXI4S_I2TDATA  (  ),
        .AXI4S_I2TSTRB  (  ),
        .AXI4S_I2TKEEP  (  ),
        .AXI4S_I2TID    (  ),
        .AXI4S_I2TDEST  (  ),
        .AXI4S_I2TUSER  (  ),
        .AXI4S_I3TDATA  (  ),
        .AXI4S_I3TSTRB  (  ),
        .AXI4S_I3TKEEP  (  ),
        .AXI4S_I3TID    (  ),
        .AXI4S_I3TDEST  (  ),
        .AXI4S_I3TUSER  (  ),
        .AXI4S_I4TDATA  (  ),
        .AXI4S_I4TSTRB  (  ),
        .AXI4S_I4TKEEP  (  ),
        .AXI4S_I4TID    (  ),
        .AXI4S_I4TDEST  (  ),
        .AXI4S_I4TUSER  (  ),
        .AXI4S_I5TDATA  (  ),
        .AXI4S_I5TSTRB  (  ),
        .AXI4S_I5TKEEP  (  ),
        .AXI4S_I5TID    (  ),
        .AXI4S_I5TDEST  (  ),
        .AXI4S_I5TUSER  (  ),
        .AXI4S_I6TDATA  (  ),
        .AXI4S_I6TSTRB  (  ),
        .AXI4S_I6TKEEP  (  ),
        .AXI4S_I6TID    (  ),
        .AXI4S_I6TDEST  (  ),
        .AXI4S_I6TUSER  (  ),
        .AXI4S_I7TDATA  (  ),
        .AXI4S_I7TSTRB  (  ),
        .AXI4S_I7TKEEP  (  ),
        .AXI4S_I7TID    (  ),
        .AXI4S_I7TDEST  (  ),
        .AXI4S_I7TUSER  (  ),
        .DECODE_ERR     (  ) 
        );


endmodule
