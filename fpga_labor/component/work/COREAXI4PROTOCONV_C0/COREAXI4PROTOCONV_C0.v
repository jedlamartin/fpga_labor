//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Tue Mar 24 22:48:53 2026
// Version: 2025.1 2025.1.0.14
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of COREAXI4PROTOCONV_C0 to TCL
# Family: PolarFireSoC
# Part Number: MPFS095T-1FCSG325E
# Create and Configure the core component COREAXI4PROTOCONV_C0
create_and_configure_core -core_vlnv {Actel:DirectCore:COREAXI4PROTOCONV:3.0.125} -component_name {COREAXI4PROTOCONV_C0} -params {\
"MM2S_ADDR_WIDTH:32"  \
"MM2S_CMDSTS_FIFO_DEPTH:16"  \
"MM2S_CMDSTS_FIFO_ENABLE:true"  \
"MM2S_CMDSTS_RAM_TYPE:3"  \
"MM2S_DATA_FIFO_DEPTH:64"  \
"MM2S_DATA_FIFO_ENABLE:true"  \
"MM2S_DATA_RAM_TYPE:2"  \
"MM2S_DATA_WIDTH:32"  \
"MM2S_ENABLE:true"  \
"MM2S_ENDIAN_CONV:false"  \
"MM2S_PKT_FIFO_ENABLE:0"  \
"MM2S_USER_ENABLE:false"  \
"MM2S_USER_WIDTH:1"  \
"RESET_TYPE:0"  \
"S2MM_ADDR_WIDTH:32"  \
"S2MM_BURST_LENGTH:16"  \
"S2MM_CMDSTS_FIFO_DEPTH:16"  \
"S2MM_CMDSTS_FIFO_ENABLE:true"  \
"S2MM_CMDSTS_RAM_TYPE:3"  \
"S2MM_DATA_FIFO_DEPTH:64"  \
"S2MM_DATA_FIFO_ENABLE:true"  \
"S2MM_DATA_RAM_TYPE:2"  \
"S2MM_DATA_WIDTH:32"  \
"S2MM_ENABLE:true"  \
"S2MM_ENDIAN_CONV:false"  \
"S2MM_PKT_DROP_ERR:false"  \
"S2MM_PKT_DROP_OVF:false"  \
"S2MM_PKT_FIFO_ENABLE:0"  \
"S2MM_UNDEF_BSTLEN:true"  \
"S2MM_USER_ENABLE:false"  \
"S2MM_USER_WIDTH:1"   }
# Exporting Component Description of COREAXI4PROTOCONV_C0 to TCL done
*/

// COREAXI4PROTOCONV_C0
module COREAXI4PROTOCONV_C0(
    // Inputs
    ACLK,
    I_AXI4S_TREADY,
    I_MM2SAXI4_ARREADY,
    I_MM2SAXI4_RDATA,
    I_MM2SAXI4_RID,
    I_MM2SAXI4_RLAST,
    I_MM2SAXI4_RRESP,
    I_MM2SAXI4_RUSER,
    I_MM2SAXI4_RVALID,
    I_S2MMAXI4_AWREADY,
    I_S2MMAXI4_BID,
    I_S2MMAXI4_BRESP,
    I_S2MMAXI4_BVALID,
    I_S2MMAXI4_WREADY,
    RESETN,
    T_AXI4L_ARADDR,
    T_AXI4L_ARVALID,
    T_AXI4L_AWADDR,
    T_AXI4L_AWVALID,
    T_AXI4L_BREADY,
    T_AXI4L_RREADY,
    T_AXI4L_WDATA,
    T_AXI4L_WSTRB,
    T_AXI4L_WVALID,
    T_AXI4S_TDATA,
    T_AXI4S_TDEST,
    T_AXI4S_TID,
    T_AXI4S_TKEEP,
    T_AXI4S_TLAST,
    T_AXI4S_TUSER,
    T_AXI4S_TVALID,
    // Outputs
    I_AXI4S_TDATA,
    I_AXI4S_TDEST,
    I_AXI4S_TID,
    I_AXI4S_TKEEP,
    I_AXI4S_TLAST,
    I_AXI4S_TUSER,
    I_AXI4S_TVALID,
    I_MM2SAXI4_ARADDR,
    I_MM2SAXI4_ARBURST,
    I_MM2SAXI4_ARID,
    I_MM2SAXI4_ARLEN,
    I_MM2SAXI4_ARSIZE,
    I_MM2SAXI4_ARVALID,
    I_MM2SAXI4_RREADY,
    I_S2MMAXI4_AWADDR,
    I_S2MMAXI4_AWBURST,
    I_S2MMAXI4_AWID,
    I_S2MMAXI4_AWLEN,
    I_S2MMAXI4_AWSIZE,
    I_S2MMAXI4_AWVALID,
    I_S2MMAXI4_BREADY,
    I_S2MMAXI4_WDATA,
    I_S2MMAXI4_WLAST,
    I_S2MMAXI4_WSTRB,
    I_S2MMAXI4_WUSER,
    I_S2MMAXI4_WVALID,
    MM2S_ERR_INT,
    MM2S_INT,
    S2MM_ERR_INT,
    S2MM_INT,
    T_AXI4L_ARREADY,
    T_AXI4L_AWREADY,
    T_AXI4L_BRESP,
    T_AXI4L_BVALID,
    T_AXI4L_RDATA,
    T_AXI4L_RRESP,
    T_AXI4L_RVALID,
    T_AXI4L_WREADY,
    T_AXI4S_TREADY
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         ACLK;
input         I_AXI4S_TREADY;
input         I_MM2SAXI4_ARREADY;
input  [31:0] I_MM2SAXI4_RDATA;
input         I_MM2SAXI4_RID;
input         I_MM2SAXI4_RLAST;
input  [1:0]  I_MM2SAXI4_RRESP;
input  [0:0]  I_MM2SAXI4_RUSER;
input         I_MM2SAXI4_RVALID;
input         I_S2MMAXI4_AWREADY;
input         I_S2MMAXI4_BID;
input  [1:0]  I_S2MMAXI4_BRESP;
input         I_S2MMAXI4_BVALID;
input         I_S2MMAXI4_WREADY;
input         RESETN;
input  [10:0] T_AXI4L_ARADDR;
input         T_AXI4L_ARVALID;
input  [10:0] T_AXI4L_AWADDR;
input         T_AXI4L_AWVALID;
input         T_AXI4L_BREADY;
input         T_AXI4L_RREADY;
input  [31:0] T_AXI4L_WDATA;
input  [3:0]  T_AXI4L_WSTRB;
input         T_AXI4L_WVALID;
input  [31:0] T_AXI4S_TDATA;
input  [31:0] T_AXI4S_TDEST;
input         T_AXI4S_TID;
input  [3:0]  T_AXI4S_TKEEP;
input         T_AXI4S_TLAST;
input  [0:0]  T_AXI4S_TUSER;
input         T_AXI4S_TVALID;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [31:0] I_AXI4S_TDATA;
output [31:0] I_AXI4S_TDEST;
output        I_AXI4S_TID;
output [3:0]  I_AXI4S_TKEEP;
output        I_AXI4S_TLAST;
output [0:0]  I_AXI4S_TUSER;
output        I_AXI4S_TVALID;
output [31:0] I_MM2SAXI4_ARADDR;
output [1:0]  I_MM2SAXI4_ARBURST;
output        I_MM2SAXI4_ARID;
output [7:0]  I_MM2SAXI4_ARLEN;
output [2:0]  I_MM2SAXI4_ARSIZE;
output        I_MM2SAXI4_ARVALID;
output        I_MM2SAXI4_RREADY;
output [31:0] I_S2MMAXI4_AWADDR;
output [1:0]  I_S2MMAXI4_AWBURST;
output        I_S2MMAXI4_AWID;
output [7:0]  I_S2MMAXI4_AWLEN;
output [2:0]  I_S2MMAXI4_AWSIZE;
output        I_S2MMAXI4_AWVALID;
output        I_S2MMAXI4_BREADY;
output [31:0] I_S2MMAXI4_WDATA;
output        I_S2MMAXI4_WLAST;
output [3:0]  I_S2MMAXI4_WSTRB;
output [0:0]  I_S2MMAXI4_WUSER;
output        I_S2MMAXI4_WVALID;
output        MM2S_ERR_INT;
output        MM2S_INT;
output        S2MM_ERR_INT;
output        S2MM_INT;
output        T_AXI4L_ARREADY;
output        T_AXI4L_AWREADY;
output [1:0]  T_AXI4L_BRESP;
output        T_AXI4L_BVALID;
output [31:0] T_AXI4L_RDATA;
output [1:0]  T_AXI4L_RRESP;
output        T_AXI4L_RVALID;
output        T_AXI4L_WREADY;
output        T_AXI4S_TREADY;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          ACLK;
wire   [10:0] T_AXI4L_ARADDR;
wire          AXI4L_TRGT_ARREADY;
wire          T_AXI4L_ARVALID;
wire   [10:0] T_AXI4L_AWADDR;
wire          AXI4L_TRGT_AWREADY;
wire          T_AXI4L_AWVALID;
wire          T_AXI4L_BREADY;
wire   [1:0]  AXI4L_TRGT_BRESP;
wire          AXI4L_TRGT_BVALID;
wire   [31:0] AXI4L_TRGT_RDATA;
wire          T_AXI4L_RREADY;
wire   [1:0]  AXI4L_TRGT_RRESP;
wire          AXI4L_TRGT_RVALID;
wire   [31:0] T_AXI4L_WDATA;
wire          AXI4L_TRGT_WREADY;
wire   [3:0]  T_AXI4L_WSTRB;
wire          T_AXI4L_WVALID;
wire   [31:0] MM2S_AXI4MM_INITR_ARADDR;
wire   [1:0]  MM2S_AXI4MM_INITR_ARBURST;
wire          MM2S_AXI4MM_INITR_ARID;
wire   [7:0]  MM2S_AXI4MM_INITR_ARLEN;
wire          I_MM2SAXI4_ARREADY;
wire   [2:0]  MM2S_AXI4MM_INITR_ARSIZE;
wire          MM2S_AXI4MM_INITR_ARVALID;
wire   [31:0] I_MM2SAXI4_RDATA;
wire          I_MM2SAXI4_RID;
wire          I_MM2SAXI4_RLAST;
wire          MM2S_AXI4MM_INITR_RREADY;
wire   [1:0]  I_MM2SAXI4_RRESP;
wire   [0:0]  I_MM2SAXI4_RUSER;
wire          I_MM2SAXI4_RVALID;
wire   [31:0] MM2S_AXI4S_INITR_TDATA;
wire   [31:0] MM2S_AXI4S_INITR_TDEST;
wire          MM2S_AXI4S_INITR_TID;
wire   [3:0]  MM2S_AXI4S_INITR_TKEEP;
wire          MM2S_AXI4S_INITR_TLAST;
wire          I_AXI4S_TREADY;
wire   [0:0]  MM2S_AXI4S_INITR_TUSER;
wire          MM2S_AXI4S_INITR_TVALID;
wire          MM2S_ERR_INT_net_0;
wire          MM2S_INT_net_0;
wire          RESETN;
wire   [31:0] S2MM_AXI4MM_INITR_AWADDR;
wire   [1:0]  S2MM_AXI4MM_INITR_AWBURST;
wire          S2MM_AXI4MM_INITR_AWID;
wire   [7:0]  S2MM_AXI4MM_INITR_AWLEN;
wire          I_S2MMAXI4_AWREADY;
wire   [2:0]  S2MM_AXI4MM_INITR_AWSIZE;
wire          S2MM_AXI4MM_INITR_AWVALID;
wire          I_S2MMAXI4_BID;
wire          S2MM_AXI4MM_INITR_BREADY;
wire   [1:0]  I_S2MMAXI4_BRESP;
wire          I_S2MMAXI4_BVALID;
wire   [31:0] S2MM_AXI4MM_INITR_WDATA;
wire          S2MM_AXI4MM_INITR_WLAST;
wire          I_S2MMAXI4_WREADY;
wire   [3:0]  S2MM_AXI4MM_INITR_WSTRB;
wire   [0:0]  S2MM_AXI4MM_INITR_WUSER;
wire          S2MM_AXI4MM_INITR_WVALID;
wire   [31:0] T_AXI4S_TDATA;
wire   [31:0] T_AXI4S_TDEST;
wire          T_AXI4S_TID;
wire   [3:0]  T_AXI4S_TKEEP;
wire          T_AXI4S_TLAST;
wire          S2MM_AXI4S_TRGT_TREADY;
wire   [0:0]  T_AXI4S_TUSER;
wire          T_AXI4S_TVALID;
wire          S2MM_ERR_INT_net_0;
wire          S2MM_INT_net_0;
wire          S2MM_INT_net_1;
wire          S2MM_ERR_INT_net_1;
wire          MM2S_INT_net_1;
wire          MM2S_ERR_INT_net_1;
wire          AXI4L_TRGT_AWREADY_net_0;
wire          AXI4L_TRGT_WREADY_net_0;
wire          AXI4L_TRGT_BVALID_net_0;
wire          AXI4L_TRGT_ARREADY_net_0;
wire          AXI4L_TRGT_RVALID_net_0;
wire          S2MM_AXI4S_TRGT_TREADY_net_0;
wire          S2MM_AXI4MM_INITR_AWID_net_0;
wire          S2MM_AXI4MM_INITR_AWVALID_net_0;
wire          S2MM_AXI4MM_INITR_WVALID_net_0;
wire          S2MM_AXI4MM_INITR_WLAST_net_0;
wire          S2MM_AXI4MM_INITR_BREADY_net_0;
wire          MM2S_AXI4S_INITR_TVALID_net_0;
wire          MM2S_AXI4S_INITR_TID_net_0;
wire          MM2S_AXI4S_INITR_TLAST_net_0;
wire          MM2S_AXI4MM_INITR_ARID_net_0;
wire          MM2S_AXI4MM_INITR_ARVALID_net_0;
wire          MM2S_AXI4MM_INITR_RREADY_net_0;
wire   [1:0]  AXI4L_TRGT_BRESP_net_0;
wire   [31:0] AXI4L_TRGT_RDATA_net_0;
wire   [1:0]  AXI4L_TRGT_RRESP_net_0;
wire   [31:0] S2MM_AXI4MM_INITR_AWADDR_net_0;
wire   [7:0]  S2MM_AXI4MM_INITR_AWLEN_net_0;
wire   [2:0]  S2MM_AXI4MM_INITR_AWSIZE_net_0;
wire   [1:0]  S2MM_AXI4MM_INITR_AWBURST_net_0;
wire   [31:0] S2MM_AXI4MM_INITR_WDATA_net_0;
wire   [3:0]  S2MM_AXI4MM_INITR_WSTRB_net_0;
wire   [0:0]  S2MM_AXI4MM_INITR_WUSER_net_0;
wire   [31:0] MM2S_AXI4S_INITR_TDEST_net_0;
wire   [31:0] MM2S_AXI4S_INITR_TDATA_net_0;
wire   [3:0]  MM2S_AXI4S_INITR_TKEEP_net_0;
wire   [0:0]  MM2S_AXI4S_INITR_TUSER_net_0;
wire   [31:0] MM2S_AXI4MM_INITR_ARADDR_net_0;
wire   [7:0]  MM2S_AXI4MM_INITR_ARLEN_net_0;
wire   [2:0]  MM2S_AXI4MM_INITR_ARSIZE_net_0;
wire   [1:0]  MM2S_AXI4MM_INITR_ARBURST_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          GND_net;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net = 1'b0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign S2MM_INT_net_1                   = S2MM_INT_net_0;
assign S2MM_INT                         = S2MM_INT_net_1;
assign S2MM_ERR_INT_net_1               = S2MM_ERR_INT_net_0;
assign S2MM_ERR_INT                     = S2MM_ERR_INT_net_1;
assign MM2S_INT_net_1                   = MM2S_INT_net_0;
assign MM2S_INT                         = MM2S_INT_net_1;
assign MM2S_ERR_INT_net_1               = MM2S_ERR_INT_net_0;
assign MM2S_ERR_INT                     = MM2S_ERR_INT_net_1;
assign AXI4L_TRGT_AWREADY_net_0         = AXI4L_TRGT_AWREADY;
assign T_AXI4L_AWREADY                  = AXI4L_TRGT_AWREADY_net_0;
assign AXI4L_TRGT_WREADY_net_0          = AXI4L_TRGT_WREADY;
assign T_AXI4L_WREADY                   = AXI4L_TRGT_WREADY_net_0;
assign AXI4L_TRGT_BVALID_net_0          = AXI4L_TRGT_BVALID;
assign T_AXI4L_BVALID                   = AXI4L_TRGT_BVALID_net_0;
assign AXI4L_TRGT_ARREADY_net_0         = AXI4L_TRGT_ARREADY;
assign T_AXI4L_ARREADY                  = AXI4L_TRGT_ARREADY_net_0;
assign AXI4L_TRGT_RVALID_net_0          = AXI4L_TRGT_RVALID;
assign T_AXI4L_RVALID                   = AXI4L_TRGT_RVALID_net_0;
assign S2MM_AXI4S_TRGT_TREADY_net_0     = S2MM_AXI4S_TRGT_TREADY;
assign T_AXI4S_TREADY                   = S2MM_AXI4S_TRGT_TREADY_net_0;
assign S2MM_AXI4MM_INITR_AWID_net_0     = S2MM_AXI4MM_INITR_AWID;
assign I_S2MMAXI4_AWID                  = S2MM_AXI4MM_INITR_AWID_net_0;
assign S2MM_AXI4MM_INITR_AWVALID_net_0  = S2MM_AXI4MM_INITR_AWVALID;
assign I_S2MMAXI4_AWVALID               = S2MM_AXI4MM_INITR_AWVALID_net_0;
assign S2MM_AXI4MM_INITR_WVALID_net_0   = S2MM_AXI4MM_INITR_WVALID;
assign I_S2MMAXI4_WVALID                = S2MM_AXI4MM_INITR_WVALID_net_0;
assign S2MM_AXI4MM_INITR_WLAST_net_0    = S2MM_AXI4MM_INITR_WLAST;
assign I_S2MMAXI4_WLAST                 = S2MM_AXI4MM_INITR_WLAST_net_0;
assign S2MM_AXI4MM_INITR_BREADY_net_0   = S2MM_AXI4MM_INITR_BREADY;
assign I_S2MMAXI4_BREADY                = S2MM_AXI4MM_INITR_BREADY_net_0;
assign MM2S_AXI4S_INITR_TVALID_net_0    = MM2S_AXI4S_INITR_TVALID;
assign I_AXI4S_TVALID                   = MM2S_AXI4S_INITR_TVALID_net_0;
assign MM2S_AXI4S_INITR_TID_net_0       = MM2S_AXI4S_INITR_TID;
assign I_AXI4S_TID                      = MM2S_AXI4S_INITR_TID_net_0;
assign MM2S_AXI4S_INITR_TLAST_net_0     = MM2S_AXI4S_INITR_TLAST;
assign I_AXI4S_TLAST                    = MM2S_AXI4S_INITR_TLAST_net_0;
assign MM2S_AXI4MM_INITR_ARID_net_0     = MM2S_AXI4MM_INITR_ARID;
assign I_MM2SAXI4_ARID                  = MM2S_AXI4MM_INITR_ARID_net_0;
assign MM2S_AXI4MM_INITR_ARVALID_net_0  = MM2S_AXI4MM_INITR_ARVALID;
assign I_MM2SAXI4_ARVALID               = MM2S_AXI4MM_INITR_ARVALID_net_0;
assign MM2S_AXI4MM_INITR_RREADY_net_0   = MM2S_AXI4MM_INITR_RREADY;
assign I_MM2SAXI4_RREADY                = MM2S_AXI4MM_INITR_RREADY_net_0;
assign AXI4L_TRGT_BRESP_net_0           = AXI4L_TRGT_BRESP;
assign T_AXI4L_BRESP[1:0]               = AXI4L_TRGT_BRESP_net_0;
assign AXI4L_TRGT_RDATA_net_0           = AXI4L_TRGT_RDATA;
assign T_AXI4L_RDATA[31:0]              = AXI4L_TRGT_RDATA_net_0;
assign AXI4L_TRGT_RRESP_net_0           = AXI4L_TRGT_RRESP;
assign T_AXI4L_RRESP[1:0]               = AXI4L_TRGT_RRESP_net_0;
assign S2MM_AXI4MM_INITR_AWADDR_net_0   = S2MM_AXI4MM_INITR_AWADDR;
assign I_S2MMAXI4_AWADDR[31:0]          = S2MM_AXI4MM_INITR_AWADDR_net_0;
assign S2MM_AXI4MM_INITR_AWLEN_net_0    = S2MM_AXI4MM_INITR_AWLEN;
assign I_S2MMAXI4_AWLEN[7:0]            = S2MM_AXI4MM_INITR_AWLEN_net_0;
assign S2MM_AXI4MM_INITR_AWSIZE_net_0   = S2MM_AXI4MM_INITR_AWSIZE;
assign I_S2MMAXI4_AWSIZE[2:0]           = S2MM_AXI4MM_INITR_AWSIZE_net_0;
assign S2MM_AXI4MM_INITR_AWBURST_net_0  = S2MM_AXI4MM_INITR_AWBURST;
assign I_S2MMAXI4_AWBURST[1:0]          = S2MM_AXI4MM_INITR_AWBURST_net_0;
assign S2MM_AXI4MM_INITR_WDATA_net_0    = S2MM_AXI4MM_INITR_WDATA;
assign I_S2MMAXI4_WDATA[31:0]           = S2MM_AXI4MM_INITR_WDATA_net_0;
assign S2MM_AXI4MM_INITR_WSTRB_net_0    = S2MM_AXI4MM_INITR_WSTRB;
assign I_S2MMAXI4_WSTRB[3:0]            = S2MM_AXI4MM_INITR_WSTRB_net_0;
assign S2MM_AXI4MM_INITR_WUSER_net_0[0] = S2MM_AXI4MM_INITR_WUSER[0];
assign I_S2MMAXI4_WUSER[0:0]            = S2MM_AXI4MM_INITR_WUSER_net_0[0];
assign MM2S_AXI4S_INITR_TDEST_net_0     = MM2S_AXI4S_INITR_TDEST;
assign I_AXI4S_TDEST[31:0]              = MM2S_AXI4S_INITR_TDEST_net_0;
assign MM2S_AXI4S_INITR_TDATA_net_0     = MM2S_AXI4S_INITR_TDATA;
assign I_AXI4S_TDATA[31:0]              = MM2S_AXI4S_INITR_TDATA_net_0;
assign MM2S_AXI4S_INITR_TKEEP_net_0     = MM2S_AXI4S_INITR_TKEEP;
assign I_AXI4S_TKEEP[3:0]               = MM2S_AXI4S_INITR_TKEEP_net_0;
assign MM2S_AXI4S_INITR_TUSER_net_0[0]  = MM2S_AXI4S_INITR_TUSER[0];
assign I_AXI4S_TUSER[0:0]               = MM2S_AXI4S_INITR_TUSER_net_0[0];
assign MM2S_AXI4MM_INITR_ARADDR_net_0   = MM2S_AXI4MM_INITR_ARADDR;
assign I_MM2SAXI4_ARADDR[31:0]          = MM2S_AXI4MM_INITR_ARADDR_net_0;
assign MM2S_AXI4MM_INITR_ARLEN_net_0    = MM2S_AXI4MM_INITR_ARLEN;
assign I_MM2SAXI4_ARLEN[7:0]            = MM2S_AXI4MM_INITR_ARLEN_net_0;
assign MM2S_AXI4MM_INITR_ARSIZE_net_0   = MM2S_AXI4MM_INITR_ARSIZE;
assign I_MM2SAXI4_ARSIZE[2:0]           = MM2S_AXI4MM_INITR_ARSIZE_net_0;
assign MM2S_AXI4MM_INITR_ARBURST_net_0  = MM2S_AXI4MM_INITR_ARBURST;
assign I_MM2SAXI4_ARBURST[1:0]          = MM2S_AXI4MM_INITR_ARBURST_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------COREAXI4PROTOCONV   -   Actel:DirectCore:COREAXI4PROTOCONV:3.0.125
COREAXI4PROTOCONV #( 
        .FAMILY                  ( 27 ),
        .MM2S_ADDR_WIDTH         ( 32 ),
        .MM2S_CMDSTS_FIFO_DEPTH  ( 16 ),
        .MM2S_CMDSTS_FIFO_ENABLE ( 1 ),
        .MM2S_CMDSTS_RAM_TYPE    ( 3 ),
        .MM2S_DATA_FIFO_DEPTH    ( 64 ),
        .MM2S_DATA_FIFO_ENABLE   ( 1 ),
        .MM2S_DATA_RAM_TYPE      ( 2 ),
        .MM2S_DATA_WIDTH         ( 32 ),
        .MM2S_ENABLE             ( 1 ),
        .MM2S_ENDIAN_CONV        ( 0 ),
        .MM2S_PKT_FIFO_ENABLE    ( 0 ),
        .MM2S_USER_ENABLE        ( 0 ),
        .MM2S_USER_WIDTH         ( 1 ),
        .RESET_TYPE              ( 0 ),
        .S2MM_ADDR_WIDTH         ( 32 ),
        .S2MM_BURST_LENGTH       ( 16 ),
        .S2MM_CMDSTS_FIFO_DEPTH  ( 16 ),
        .S2MM_CMDSTS_FIFO_ENABLE ( 1 ),
        .S2MM_CMDSTS_RAM_TYPE    ( 3 ),
        .S2MM_DATA_FIFO_DEPTH    ( 64 ),
        .S2MM_DATA_FIFO_ENABLE   ( 1 ),
        .S2MM_DATA_RAM_TYPE      ( 2 ),
        .S2MM_DATA_WIDTH         ( 32 ),
        .S2MM_ENABLE             ( 1 ),
        .S2MM_ENDIAN_CONV        ( 0 ),
        .S2MM_PKT_DROP_ERR       ( 0 ),
        .S2MM_PKT_DROP_OVF       ( 0 ),
        .S2MM_PKT_FIFO_ENABLE    ( 0 ),
        .S2MM_UNDEF_BSTLEN       ( 1 ),
        .S2MM_USER_ENABLE        ( 0 ),
        .S2MM_USER_WIDTH         ( 1 ),
        .TGIGEN_DISPLAY_SYMBOL   ( 1 ) )
COREAXI4PROTOCONV_C1_0(
        // Inputs
        .ACLK               ( ACLK ),
        .RESETN             ( RESETN ),
        .T_AXI4L_AWVALID    ( T_AXI4L_AWVALID ),
        .T_AXI4L_WVALID     ( T_AXI4L_WVALID ),
        .T_AXI4L_BREADY     ( T_AXI4L_BREADY ),
        .T_AXI4L_ARVALID    ( T_AXI4L_ARVALID ),
        .T_AXI4L_RREADY     ( T_AXI4L_RREADY ),
        .T_AXI4S_TVALID     ( T_AXI4S_TVALID ),
        .T_AXI4S_TID        ( T_AXI4S_TID ),
        .T_AXI4S_TLAST      ( T_AXI4S_TLAST ),
        .I_S2MMAXI4_AWREADY ( I_S2MMAXI4_AWREADY ),
        .I_S2MMAXI4_WREADY  ( I_S2MMAXI4_WREADY ),
        .I_S2MMAXI4_BID     ( I_S2MMAXI4_BID ),
        .I_S2MMAXI4_BVALID  ( I_S2MMAXI4_BVALID ),
        .S2MM_PKT_ERR       ( GND_net ), // tied to 1'b0 from definition
        .I_AXI4S_TREADY     ( I_AXI4S_TREADY ),
        .I_MM2SAXI4_ARREADY ( I_MM2SAXI4_ARREADY ),
        .I_MM2SAXI4_RID     ( I_MM2SAXI4_RID ),
        .I_MM2SAXI4_RVALID  ( I_MM2SAXI4_RVALID ),
        .I_MM2SAXI4_RLAST   ( I_MM2SAXI4_RLAST ),
        .T_AXI4L_AWADDR     ( T_AXI4L_AWADDR ),
        .T_AXI4L_WDATA      ( T_AXI4L_WDATA ),
        .T_AXI4L_WSTRB      ( T_AXI4L_WSTRB ),
        .T_AXI4L_ARADDR     ( T_AXI4L_ARADDR ),
        .T_AXI4S_TDEST      ( T_AXI4S_TDEST ),
        .T_AXI4S_TDATA      ( T_AXI4S_TDATA ),
        .T_AXI4S_TKEEP      ( T_AXI4S_TKEEP ),
        .T_AXI4S_TUSER      ( T_AXI4S_TUSER ),
        .I_S2MMAXI4_BRESP   ( I_S2MMAXI4_BRESP ),
        .I_MM2SAXI4_RDATA   ( I_MM2SAXI4_RDATA ),
        .I_MM2SAXI4_RRESP   ( I_MM2SAXI4_RRESP ),
        .I_MM2SAXI4_RUSER   ( I_MM2SAXI4_RUSER ),
        // Outputs
        .T_AXI4L_AWREADY    ( AXI4L_TRGT_AWREADY ),
        .T_AXI4L_WREADY     ( AXI4L_TRGT_WREADY ),
        .T_AXI4L_BVALID     ( AXI4L_TRGT_BVALID ),
        .T_AXI4L_ARREADY    ( AXI4L_TRGT_ARREADY ),
        .T_AXI4L_RVALID     ( AXI4L_TRGT_RVALID ),
        .T_AXI4S_TREADY     ( S2MM_AXI4S_TRGT_TREADY ),
        .I_S2MMAXI4_AWID    ( S2MM_AXI4MM_INITR_AWID ),
        .I_S2MMAXI4_AWVALID ( S2MM_AXI4MM_INITR_AWVALID ),
        .I_S2MMAXI4_WVALID  ( S2MM_AXI4MM_INITR_WVALID ),
        .I_S2MMAXI4_WLAST   ( S2MM_AXI4MM_INITR_WLAST ),
        .I_S2MMAXI4_BREADY  ( S2MM_AXI4MM_INITR_BREADY ),
        .S2MM_INT           ( S2MM_INT_net_0 ),
        .S2MM_ERR_INT       ( S2MM_ERR_INT_net_0 ),
        .I_AXI4S_TVALID     ( MM2S_AXI4S_INITR_TVALID ),
        .I_AXI4S_TID        ( MM2S_AXI4S_INITR_TID ),
        .I_AXI4S_TLAST      ( MM2S_AXI4S_INITR_TLAST ),
        .I_MM2SAXI4_ARID    ( MM2S_AXI4MM_INITR_ARID ),
        .I_MM2SAXI4_ARVALID ( MM2S_AXI4MM_INITR_ARVALID ),
        .I_MM2SAXI4_RREADY  ( MM2S_AXI4MM_INITR_RREADY ),
        .MM2S_INT           ( MM2S_INT_net_0 ),
        .MM2S_ERR_INT       ( MM2S_ERR_INT_net_0 ),
        .T_AXI4L_BRESP      ( AXI4L_TRGT_BRESP ),
        .T_AXI4L_RDATA      ( AXI4L_TRGT_RDATA ),
        .T_AXI4L_RRESP      ( AXI4L_TRGT_RRESP ),
        .I_S2MMAXI4_AWADDR  ( S2MM_AXI4MM_INITR_AWADDR ),
        .I_S2MMAXI4_AWLEN   ( S2MM_AXI4MM_INITR_AWLEN ),
        .I_S2MMAXI4_AWSIZE  ( S2MM_AXI4MM_INITR_AWSIZE ),
        .I_S2MMAXI4_AWBURST ( S2MM_AXI4MM_INITR_AWBURST ),
        .I_S2MMAXI4_WDATA   ( S2MM_AXI4MM_INITR_WDATA ),
        .I_S2MMAXI4_WSTRB   ( S2MM_AXI4MM_INITR_WSTRB ),
        .I_S2MMAXI4_WUSER   ( S2MM_AXI4MM_INITR_WUSER ),
        .I_AXI4S_TDEST      ( MM2S_AXI4S_INITR_TDEST ),
        .I_AXI4S_TDATA      ( MM2S_AXI4S_INITR_TDATA ),
        .I_AXI4S_TKEEP      ( MM2S_AXI4S_INITR_TKEEP ),
        .I_AXI4S_TUSER      ( MM2S_AXI4S_INITR_TUSER ),
        .I_MM2SAXI4_ARADDR  ( MM2S_AXI4MM_INITR_ARADDR ),
        .I_MM2SAXI4_ARLEN   ( MM2S_AXI4MM_INITR_ARLEN ),
        .I_MM2SAXI4_ARSIZE  ( MM2S_AXI4MM_INITR_ARSIZE ),
        .I_MM2SAXI4_ARBURST ( MM2S_AXI4MM_INITR_ARBURST ) 
        );


endmodule
