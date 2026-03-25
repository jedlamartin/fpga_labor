//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Wed Mar 25 14:38:09 2026
// Version: 2025.1 2025.1.0.14
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of COREAXI4DMACONTROLLER_C0 to TCL
# Family: PolarFireSoC
# Part Number: MPFS095T-1FCSG325E
# Create and Configure the core component COREAXI4DMACONTROLLER_C0
create_and_configure_core -core_vlnv {Actel:DirectCore:COREAXI4DMACONTROLLER:2.2.107} -component_name {COREAXI4DMACONTROLLER_C0} -params {\
"AXI4_STREAM_IF:true"  \
"AXI_DMA_DWIDTH:32"  \
"DSCRPTR_0_INT_ASSOC:0"  \
"DSCRPTR_0_PRI_LVL:0"  \
"DSCRPTR_1_INT_ASSOC:0"  \
"DSCRPTR_1_PRI_LVL:0"  \
"DSCRPTR_2_INT_ASSOC:0"  \
"DSCRPTR_2_PRI_LVL:0"  \
"DSCRPTR_3_INT_ASSOC:0"  \
"DSCRPTR_3_PRI_LVL:0"  \
"DSCRPTR_4_INT_ASSOC:0"  \
"DSCRPTR_4_PRI_LVL:0"  \
"DSCRPTR_5_INT_ASSOC:0"  \
"DSCRPTR_5_PRI_LVL:0"  \
"DSCRPTR_6_INT_ASSOC:0"  \
"DSCRPTR_6_PRI_LVL:0"  \
"DSCRPTR_7_INT_ASSOC:0"  \
"DSCRPTR_7_PRI_LVL:0"  \
"DSCRPTR_8_INT_ASSOC:0"  \
"DSCRPTR_8_PRI_LVL:0"  \
"DSCRPTR_9_INT_ASSOC:0"  \
"DSCRPTR_9_PRI_LVL:0"  \
"DSCRPTR_10_INT_ASSOC:0"  \
"DSCRPTR_10_PRI_LVL:0"  \
"DSCRPTR_11_INT_ASSOC:0"  \
"DSCRPTR_11_PRI_LVL:0"  \
"DSCRPTR_12_INT_ASSOC:0"  \
"DSCRPTR_12_PRI_LVL:0"  \
"DSCRPTR_13_INT_ASSOC:0"  \
"DSCRPTR_13_PRI_LVL:0"  \
"DSCRPTR_14_INT_ASSOC:0"  \
"DSCRPTR_14_PRI_LVL:0"  \
"DSCRPTR_15_INT_ASSOC:0"  \
"DSCRPTR_15_PRI_LVL:0"  \
"DSCRPTR_16_INT_ASSOC:0"  \
"DSCRPTR_16_PRI_LVL:0"  \
"DSCRPTR_17_INT_ASSOC:0"  \
"DSCRPTR_17_PRI_LVL:0"  \
"DSCRPTR_18_INT_ASSOC:0"  \
"DSCRPTR_18_PRI_LVL:0"  \
"DSCRPTR_19_INT_ASSOC:0"  \
"DSCRPTR_19_PRI_LVL:0"  \
"DSCRPTR_20_INT_ASSOC:0"  \
"DSCRPTR_20_PRI_LVL:0"  \
"DSCRPTR_21_INT_ASSOC:0"  \
"DSCRPTR_21_PRI_LVL:0"  \
"DSCRPTR_22_INT_ASSOC:0"  \
"DSCRPTR_22_PRI_LVL:0"  \
"DSCRPTR_23_INT_ASSOC:0"  \
"DSCRPTR_23_PRI_LVL:0"  \
"DSCRPTR_24_INT_ASSOC:0"  \
"DSCRPTR_24_PRI_LVL:0"  \
"DSCRPTR_25_INT_ASSOC:0"  \
"DSCRPTR_25_PRI_LVL:0"  \
"DSCRPTR_26_INT_ASSOC:0"  \
"DSCRPTR_26_PRI_LVL:0"  \
"DSCRPTR_27_INT_ASSOC:0"  \
"DSCRPTR_27_PRI_LVL:0"  \
"DSCRPTR_28_INT_ASSOC:0"  \
"DSCRPTR_28_PRI_LVL:0"  \
"DSCRPTR_29_INT_ASSOC:0"  \
"DSCRPTR_29_PRI_LVL:0"  \
"DSCRPTR_30_INT_ASSOC:0"  \
"DSCRPTR_30_PRI_LVL:0"  \
"DSCRPTR_31_INT_ASSOC:0"  \
"DSCRPTR_31_PRI_LVL:0"  \
"ECC:false"  \
"ID_WIDTH:1"  \
"INT_0_QUEUE_DEPTH:1"  \
"INT_1_QUEUE_DEPTH:1"  \
"INT_2_QUEUE_DEPTH:1"  \
"INT_3_QUEUE_DEPTH:1"  \
"NUM_INT_BDS:4"  \
"NUM_OF_INTS:1"  \
"NUM_PRI_LVLS:1"  \
"PRI_0_NUM_OF_BEATS:256"  \
"PRI_1_NUM_OF_BEATS:128"  \
"PRI_2_NUM_OF_BEATS:64"  \
"PRI_3_NUM_OF_BEATS:32"  \
"PRI_4_NUM_OF_BEATS:16"  \
"PRI_5_NUM_OF_BEATS:8"  \
"PRI_6_NUM_OF_BEATS:4"  \
"PRI_7_NUM_OF_BEATS:1"   }
# Exporting Component Description of COREAXI4DMACONTROLLER_C0 to TCL done
*/

// COREAXI4DMACONTROLLER_C0
module COREAXI4DMACONTROLLER_C0(
    // Inputs
    CLOCK,
    CTRL_ARADDR,
    CTRL_ARVALID,
    CTRL_AWADDR,
    CTRL_AWVALID,
    CTRL_BREADY,
    CTRL_RREADY,
    CTRL_WDATA,
    CTRL_WSTRB,
    CTRL_WVALID,
    DMA_ARREADY,
    DMA_AWREADY,
    DMA_BID,
    DMA_BRESP,
    DMA_BVALID,
    DMA_RDATA,
    DMA_RID,
    DMA_RLAST,
    DMA_RRESP,
    DMA_RVALID,
    DMA_WREADY,
    RESETN,
    STRTDMAOP,
    TDATA,
    TDEST,
    TID,
    TKEEP,
    TLAST,
    TSTRB,
    TVALID,
    // Outputs
    CTRL_ARREADY,
    CTRL_AWREADY,
    CTRL_BRESP,
    CTRL_BVALID,
    CTRL_RDATA,
    CTRL_RRESP,
    CTRL_RVALID,
    CTRL_WREADY,
    DMA_ARADDR,
    DMA_ARBURST,
    DMA_ARID,
    DMA_ARLEN,
    DMA_ARSIZE,
    DMA_ARVALID,
    DMA_AWADDR,
    DMA_AWBURST,
    DMA_AWID,
    DMA_AWLEN,
    DMA_AWSIZE,
    DMA_AWVALID,
    DMA_BREADY,
    DMA_RREADY,
    DMA_WDATA,
    DMA_WLAST,
    DMA_WSTRB,
    DMA_WVALID,
    INTERRUPT,
    TREADY
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         CLOCK;
input  [10:0] CTRL_ARADDR;
input         CTRL_ARVALID;
input  [10:0] CTRL_AWADDR;
input         CTRL_AWVALID;
input         CTRL_BREADY;
input         CTRL_RREADY;
input  [31:0] CTRL_WDATA;
input  [3:0]  CTRL_WSTRB;
input         CTRL_WVALID;
input         DMA_ARREADY;
input         DMA_AWREADY;
input  [0:0]  DMA_BID;
input  [1:0]  DMA_BRESP;
input         DMA_BVALID;
input  [31:0] DMA_RDATA;
input  [0:0]  DMA_RID;
input         DMA_RLAST;
input  [1:0]  DMA_RRESP;
input         DMA_RVALID;
input         DMA_WREADY;
input         RESETN;
input  [3:0]  STRTDMAOP;
input  [31:0] TDATA;
input  [1:0]  TDEST;
input  [0:0]  TID;
input  [3:0]  TKEEP;
input         TLAST;
input  [3:0]  TSTRB;
input         TVALID;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output        CTRL_ARREADY;
output        CTRL_AWREADY;
output [1:0]  CTRL_BRESP;
output        CTRL_BVALID;
output [31:0] CTRL_RDATA;
output [1:0]  CTRL_RRESP;
output        CTRL_RVALID;
output        CTRL_WREADY;
output [31:0] DMA_ARADDR;
output [1:0]  DMA_ARBURST;
output [0:0]  DMA_ARID;
output [7:0]  DMA_ARLEN;
output [2:0]  DMA_ARSIZE;
output        DMA_ARVALID;
output [31:0] DMA_AWADDR;
output [1:0]  DMA_AWBURST;
output [0:0]  DMA_AWID;
output [7:0]  DMA_AWLEN;
output [2:0]  DMA_AWSIZE;
output        DMA_AWVALID;
output        DMA_BREADY;
output        DMA_RREADY;
output [31:0] DMA_WDATA;
output        DMA_WLAST;
output [3:0]  DMA_WSTRB;
output        DMA_WVALID;
output [0:0]  INTERRUPT;
output        TREADY;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [31:0] AXI4InitiatorDMA_IF_ARADDR;
wire   [1:0]  AXI4InitiatorDMA_IF_ARBURST;
wire   [0:0]  AXI4InitiatorDMA_IF_ARID;
wire   [7:0]  AXI4InitiatorDMA_IF_ARLEN;
wire          DMA_ARREADY;
wire   [2:0]  AXI4InitiatorDMA_IF_ARSIZE;
wire          AXI4InitiatorDMA_IF_ARVALID;
wire   [31:0] AXI4InitiatorDMA_IF_AWADDR;
wire   [1:0]  AXI4InitiatorDMA_IF_AWBURST;
wire   [0:0]  AXI4InitiatorDMA_IF_AWID;
wire   [7:0]  AXI4InitiatorDMA_IF_AWLEN;
wire          DMA_AWREADY;
wire   [2:0]  AXI4InitiatorDMA_IF_AWSIZE;
wire          AXI4InitiatorDMA_IF_AWVALID;
wire   [0:0]  DMA_BID;
wire          AXI4InitiatorDMA_IF_BREADY;
wire   [1:0]  DMA_BRESP;
wire          DMA_BVALID;
wire   [31:0] DMA_RDATA;
wire   [0:0]  DMA_RID;
wire          DMA_RLAST;
wire          AXI4InitiatorDMA_IF_RREADY;
wire   [1:0]  DMA_RRESP;
wire          DMA_RVALID;
wire   [31:0] AXI4InitiatorDMA_IF_WDATA;
wire          AXI4InitiatorDMA_IF_WLAST;
wire          DMA_WREADY;
wire   [3:0]  AXI4InitiatorDMA_IF_WSTRB;
wire          AXI4InitiatorDMA_IF_WVALID;
wire   [10:0] CTRL_ARADDR;
wire          AXI4TargetCtrl_IF_ARREADY;
wire          CTRL_ARVALID;
wire   [10:0] CTRL_AWADDR;
wire          AXI4TargetCtrl_IF_AWREADY;
wire          CTRL_AWVALID;
wire          CTRL_BREADY;
wire   [1:0]  AXI4TargetCtrl_IF_BRESP;
wire          AXI4TargetCtrl_IF_BVALID;
wire   [31:0] AXI4TargetCtrl_IF_RDATA;
wire          CTRL_RREADY;
wire   [1:0]  AXI4TargetCtrl_IF_RRESP;
wire          AXI4TargetCtrl_IF_RVALID;
wire   [31:0] CTRL_WDATA;
wire          AXI4TargetCtrl_IF_WREADY;
wire   [3:0]  CTRL_WSTRB;
wire          CTRL_WVALID;
wire          CLOCK;
wire   [0:0]  INTERRUPT_net_0;
wire          RESETN;
wire   [3:0]  STRTDMAOP;
wire   [31:0] TDATA;
wire   [1:0]  TDEST;
wire   [0:0]  TID;
wire   [3:0]  TKEEP;
wire          TLAST;
wire          TREADY_net_0;
wire   [3:0]  TSTRB;
wire          TVALID;
wire   [0:0]  INTERRUPT_net_1;
wire   [0:0]  AXI4InitiatorDMA_IF_AWID_net_0;
wire   [31:0] AXI4InitiatorDMA_IF_AWADDR_net_0;
wire   [7:0]  AXI4InitiatorDMA_IF_AWLEN_net_0;
wire   [2:0]  AXI4InitiatorDMA_IF_AWSIZE_net_0;
wire   [1:0]  AXI4InitiatorDMA_IF_AWBURST_net_0;
wire          AXI4InitiatorDMA_IF_AWVALID_net_0;
wire   [31:0] AXI4InitiatorDMA_IF_WDATA_net_0;
wire   [3:0]  AXI4InitiatorDMA_IF_WSTRB_net_0;
wire          AXI4InitiatorDMA_IF_WLAST_net_0;
wire          AXI4InitiatorDMA_IF_WVALID_net_0;
wire          AXI4InitiatorDMA_IF_BREADY_net_0;
wire   [0:0]  AXI4InitiatorDMA_IF_ARID_net_0;
wire   [31:0] AXI4InitiatorDMA_IF_ARADDR_net_0;
wire   [7:0]  AXI4InitiatorDMA_IF_ARLEN_net_0;
wire   [2:0]  AXI4InitiatorDMA_IF_ARSIZE_net_0;
wire   [1:0]  AXI4InitiatorDMA_IF_ARBURST_net_0;
wire          AXI4InitiatorDMA_IF_ARVALID_net_0;
wire          AXI4InitiatorDMA_IF_RREADY_net_0;
wire          AXI4TargetCtrl_IF_AWREADY_net_0;
wire          AXI4TargetCtrl_IF_WREADY_net_0;
wire   [1:0]  AXI4TargetCtrl_IF_BRESP_net_0;
wire          AXI4TargetCtrl_IF_BVALID_net_0;
wire          AXI4TargetCtrl_IF_ARREADY_net_0;
wire   [31:0] AXI4TargetCtrl_IF_RDATA_net_0;
wire   [1:0]  AXI4TargetCtrl_IF_RRESP_net_0;
wire          AXI4TargetCtrl_IF_RVALID_net_0;
wire          TREADY_net_1;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign INTERRUPT_net_1[0]                = INTERRUPT_net_0[0];
assign INTERRUPT[0:0]                    = INTERRUPT_net_1[0];
assign AXI4InitiatorDMA_IF_AWID_net_0[0] = AXI4InitiatorDMA_IF_AWID[0];
assign DMA_AWID[0:0]                     = AXI4InitiatorDMA_IF_AWID_net_0[0];
assign AXI4InitiatorDMA_IF_AWADDR_net_0  = AXI4InitiatorDMA_IF_AWADDR;
assign DMA_AWADDR[31:0]                  = AXI4InitiatorDMA_IF_AWADDR_net_0;
assign AXI4InitiatorDMA_IF_AWLEN_net_0   = AXI4InitiatorDMA_IF_AWLEN;
assign DMA_AWLEN[7:0]                    = AXI4InitiatorDMA_IF_AWLEN_net_0;
assign AXI4InitiatorDMA_IF_AWSIZE_net_0  = AXI4InitiatorDMA_IF_AWSIZE;
assign DMA_AWSIZE[2:0]                   = AXI4InitiatorDMA_IF_AWSIZE_net_0;
assign AXI4InitiatorDMA_IF_AWBURST_net_0 = AXI4InitiatorDMA_IF_AWBURST;
assign DMA_AWBURST[1:0]                  = AXI4InitiatorDMA_IF_AWBURST_net_0;
assign AXI4InitiatorDMA_IF_AWVALID_net_0 = AXI4InitiatorDMA_IF_AWVALID;
assign DMA_AWVALID                       = AXI4InitiatorDMA_IF_AWVALID_net_0;
assign AXI4InitiatorDMA_IF_WDATA_net_0   = AXI4InitiatorDMA_IF_WDATA;
assign DMA_WDATA[31:0]                   = AXI4InitiatorDMA_IF_WDATA_net_0;
assign AXI4InitiatorDMA_IF_WSTRB_net_0   = AXI4InitiatorDMA_IF_WSTRB;
assign DMA_WSTRB[3:0]                    = AXI4InitiatorDMA_IF_WSTRB_net_0;
assign AXI4InitiatorDMA_IF_WLAST_net_0   = AXI4InitiatorDMA_IF_WLAST;
assign DMA_WLAST                         = AXI4InitiatorDMA_IF_WLAST_net_0;
assign AXI4InitiatorDMA_IF_WVALID_net_0  = AXI4InitiatorDMA_IF_WVALID;
assign DMA_WVALID                        = AXI4InitiatorDMA_IF_WVALID_net_0;
assign AXI4InitiatorDMA_IF_BREADY_net_0  = AXI4InitiatorDMA_IF_BREADY;
assign DMA_BREADY                        = AXI4InitiatorDMA_IF_BREADY_net_0;
assign AXI4InitiatorDMA_IF_ARID_net_0[0] = AXI4InitiatorDMA_IF_ARID[0];
assign DMA_ARID[0:0]                     = AXI4InitiatorDMA_IF_ARID_net_0[0];
assign AXI4InitiatorDMA_IF_ARADDR_net_0  = AXI4InitiatorDMA_IF_ARADDR;
assign DMA_ARADDR[31:0]                  = AXI4InitiatorDMA_IF_ARADDR_net_0;
assign AXI4InitiatorDMA_IF_ARLEN_net_0   = AXI4InitiatorDMA_IF_ARLEN;
assign DMA_ARLEN[7:0]                    = AXI4InitiatorDMA_IF_ARLEN_net_0;
assign AXI4InitiatorDMA_IF_ARSIZE_net_0  = AXI4InitiatorDMA_IF_ARSIZE;
assign DMA_ARSIZE[2:0]                   = AXI4InitiatorDMA_IF_ARSIZE_net_0;
assign AXI4InitiatorDMA_IF_ARBURST_net_0 = AXI4InitiatorDMA_IF_ARBURST;
assign DMA_ARBURST[1:0]                  = AXI4InitiatorDMA_IF_ARBURST_net_0;
assign AXI4InitiatorDMA_IF_ARVALID_net_0 = AXI4InitiatorDMA_IF_ARVALID;
assign DMA_ARVALID                       = AXI4InitiatorDMA_IF_ARVALID_net_0;
assign AXI4InitiatorDMA_IF_RREADY_net_0  = AXI4InitiatorDMA_IF_RREADY;
assign DMA_RREADY                        = AXI4InitiatorDMA_IF_RREADY_net_0;
assign AXI4TargetCtrl_IF_AWREADY_net_0   = AXI4TargetCtrl_IF_AWREADY;
assign CTRL_AWREADY                      = AXI4TargetCtrl_IF_AWREADY_net_0;
assign AXI4TargetCtrl_IF_WREADY_net_0    = AXI4TargetCtrl_IF_WREADY;
assign CTRL_WREADY                       = AXI4TargetCtrl_IF_WREADY_net_0;
assign AXI4TargetCtrl_IF_BRESP_net_0     = AXI4TargetCtrl_IF_BRESP;
assign CTRL_BRESP[1:0]                   = AXI4TargetCtrl_IF_BRESP_net_0;
assign AXI4TargetCtrl_IF_BVALID_net_0    = AXI4TargetCtrl_IF_BVALID;
assign CTRL_BVALID                       = AXI4TargetCtrl_IF_BVALID_net_0;
assign AXI4TargetCtrl_IF_ARREADY_net_0   = AXI4TargetCtrl_IF_ARREADY;
assign CTRL_ARREADY                      = AXI4TargetCtrl_IF_ARREADY_net_0;
assign AXI4TargetCtrl_IF_RDATA_net_0     = AXI4TargetCtrl_IF_RDATA;
assign CTRL_RDATA[31:0]                  = AXI4TargetCtrl_IF_RDATA_net_0;
assign AXI4TargetCtrl_IF_RRESP_net_0     = AXI4TargetCtrl_IF_RRESP;
assign CTRL_RRESP[1:0]                   = AXI4TargetCtrl_IF_RRESP_net_0;
assign AXI4TargetCtrl_IF_RVALID_net_0    = AXI4TargetCtrl_IF_RVALID;
assign CTRL_RVALID                       = AXI4TargetCtrl_IF_RVALID_net_0;
assign TREADY_net_1                      = TREADY_net_0;
assign TREADY                            = TREADY_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_COREAXI4DMACONTROLLER   -   Actel:DirectCore:COREAXI4DMACONTROLLER:2.2.107
COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_COREAXI4DMACONTROLLER #( 
        .AXI4_STREAM_IF       ( 1 ),
        .AXI_DMA_DWIDTH       ( 32 ),
        .DSCRPTR_0_INT_ASSOC  ( 0 ),
        .DSCRPTR_0_PRI_LVL    ( 0 ),
        .DSCRPTR_1_INT_ASSOC  ( 0 ),
        .DSCRPTR_1_PRI_LVL    ( 0 ),
        .DSCRPTR_2_INT_ASSOC  ( 0 ),
        .DSCRPTR_2_PRI_LVL    ( 0 ),
        .DSCRPTR_3_INT_ASSOC  ( 0 ),
        .DSCRPTR_3_PRI_LVL    ( 0 ),
        .DSCRPTR_4_INT_ASSOC  ( 0 ),
        .DSCRPTR_4_PRI_LVL    ( 0 ),
        .DSCRPTR_5_INT_ASSOC  ( 0 ),
        .DSCRPTR_5_PRI_LVL    ( 0 ),
        .DSCRPTR_6_INT_ASSOC  ( 0 ),
        .DSCRPTR_6_PRI_LVL    ( 0 ),
        .DSCRPTR_7_INT_ASSOC  ( 0 ),
        .DSCRPTR_7_PRI_LVL    ( 0 ),
        .DSCRPTR_8_INT_ASSOC  ( 0 ),
        .DSCRPTR_8_PRI_LVL    ( 0 ),
        .DSCRPTR_9_INT_ASSOC  ( 0 ),
        .DSCRPTR_9_PRI_LVL    ( 0 ),
        .DSCRPTR_10_INT_ASSOC ( 0 ),
        .DSCRPTR_10_PRI_LVL   ( 0 ),
        .DSCRPTR_11_INT_ASSOC ( 0 ),
        .DSCRPTR_11_PRI_LVL   ( 0 ),
        .DSCRPTR_12_INT_ASSOC ( 0 ),
        .DSCRPTR_12_PRI_LVL   ( 0 ),
        .DSCRPTR_13_INT_ASSOC ( 0 ),
        .DSCRPTR_13_PRI_LVL   ( 0 ),
        .DSCRPTR_14_INT_ASSOC ( 0 ),
        .DSCRPTR_14_PRI_LVL   ( 0 ),
        .DSCRPTR_15_INT_ASSOC ( 0 ),
        .DSCRPTR_15_PRI_LVL   ( 0 ),
        .DSCRPTR_16_INT_ASSOC ( 0 ),
        .DSCRPTR_16_PRI_LVL   ( 0 ),
        .DSCRPTR_17_INT_ASSOC ( 0 ),
        .DSCRPTR_17_PRI_LVL   ( 0 ),
        .DSCRPTR_18_INT_ASSOC ( 0 ),
        .DSCRPTR_18_PRI_LVL   ( 0 ),
        .DSCRPTR_19_INT_ASSOC ( 0 ),
        .DSCRPTR_19_PRI_LVL   ( 0 ),
        .DSCRPTR_20_INT_ASSOC ( 0 ),
        .DSCRPTR_20_PRI_LVL   ( 0 ),
        .DSCRPTR_21_INT_ASSOC ( 0 ),
        .DSCRPTR_21_PRI_LVL   ( 0 ),
        .DSCRPTR_22_INT_ASSOC ( 0 ),
        .DSCRPTR_22_PRI_LVL   ( 0 ),
        .DSCRPTR_23_INT_ASSOC ( 0 ),
        .DSCRPTR_23_PRI_LVL   ( 0 ),
        .DSCRPTR_24_INT_ASSOC ( 0 ),
        .DSCRPTR_24_PRI_LVL   ( 0 ),
        .DSCRPTR_25_INT_ASSOC ( 0 ),
        .DSCRPTR_25_PRI_LVL   ( 0 ),
        .DSCRPTR_26_INT_ASSOC ( 0 ),
        .DSCRPTR_26_PRI_LVL   ( 0 ),
        .DSCRPTR_27_INT_ASSOC ( 0 ),
        .DSCRPTR_27_PRI_LVL   ( 0 ),
        .DSCRPTR_28_INT_ASSOC ( 0 ),
        .DSCRPTR_28_PRI_LVL   ( 0 ),
        .DSCRPTR_29_INT_ASSOC ( 0 ),
        .DSCRPTR_29_PRI_LVL   ( 0 ),
        .DSCRPTR_30_INT_ASSOC ( 0 ),
        .DSCRPTR_30_PRI_LVL   ( 0 ),
        .DSCRPTR_31_INT_ASSOC ( 0 ),
        .DSCRPTR_31_PRI_LVL   ( 0 ),
        .ECC                  ( 0 ),
        .FAMILY               ( 27 ),
        .ID_WIDTH             ( 1 ),
        .INT_0_QUEUE_DEPTH    ( 1 ),
        .INT_1_QUEUE_DEPTH    ( 1 ),
        .INT_2_QUEUE_DEPTH    ( 1 ),
        .INT_3_QUEUE_DEPTH    ( 1 ),
        .NUM_INT_BDS          ( 4 ),
        .NUM_OF_INTS          ( 1 ),
        .NUM_PRI_LVLS         ( 1 ),
        .PRI_0_NUM_OF_BEATS   ( 256 ),
        .PRI_1_NUM_OF_BEATS   ( 128 ),
        .PRI_2_NUM_OF_BEATS   ( 64 ),
        .PRI_3_NUM_OF_BEATS   ( 32 ),
        .PRI_4_NUM_OF_BEATS   ( 16 ),
        .PRI_5_NUM_OF_BEATS   ( 8 ),
        .PRI_6_NUM_OF_BEATS   ( 4 ),
        .PRI_7_NUM_OF_BEATS   ( 1 ) )
COREAXI4DMACONTROLLER_C0_0(
        // Inputs
        .RESETN       ( RESETN ),
        .CLOCK        ( CLOCK ),
        .CTRL_AWVALID ( CTRL_AWVALID ),
        .CTRL_WVALID  ( CTRL_WVALID ),
        .CTRL_BREADY  ( CTRL_BREADY ),
        .CTRL_ARVALID ( CTRL_ARVALID ),
        .CTRL_RREADY  ( CTRL_RREADY ),
        .DMA_AWREADY  ( DMA_AWREADY ),
        .DMA_WREADY   ( DMA_WREADY ),
        .DMA_BVALID   ( DMA_BVALID ),
        .DMA_ARREADY  ( DMA_ARREADY ),
        .DMA_RVALID   ( DMA_RVALID ),
        .DMA_RLAST    ( DMA_RLAST ),
        .TVALID       ( TVALID ),
        .TLAST        ( TLAST ),
        .CTRL_AWADDR  ( CTRL_AWADDR ),
        .CTRL_WSTRB   ( CTRL_WSTRB ),
        .CTRL_WDATA   ( CTRL_WDATA ),
        .CTRL_ARADDR  ( CTRL_ARADDR ),
        .STRTDMAOP    ( STRTDMAOP ),
        .DMA_BRESP    ( DMA_BRESP ),
        .DMA_BID      ( DMA_BID ),
        .DMA_RDATA    ( DMA_RDATA ),
        .DMA_RID      ( DMA_RID ),
        .DMA_RRESP    ( DMA_RRESP ),
        .TDATA        ( TDATA ),
        .TSTRB        ( TSTRB ),
        .TKEEP        ( TKEEP ),
        .TID          ( TID ),
        .TDEST        ( TDEST ),
        // Outputs
        .CTRL_AWREADY ( AXI4TargetCtrl_IF_AWREADY ),
        .CTRL_WREADY  ( AXI4TargetCtrl_IF_WREADY ),
        .CTRL_BVALID  ( AXI4TargetCtrl_IF_BVALID ),
        .CTRL_ARREADY ( AXI4TargetCtrl_IF_ARREADY ),
        .CTRL_RVALID  ( AXI4TargetCtrl_IF_RVALID ),
        .DMA_AWVALID  ( AXI4InitiatorDMA_IF_AWVALID ),
        .DMA_WVALID   ( AXI4InitiatorDMA_IF_WVALID ),
        .DMA_WLAST    ( AXI4InitiatorDMA_IF_WLAST ),
        .DMA_BREADY   ( AXI4InitiatorDMA_IF_BREADY ),
        .DMA_ARVALID  ( AXI4InitiatorDMA_IF_ARVALID ),
        .DMA_RREADY   ( AXI4InitiatorDMA_IF_RREADY ),
        .TREADY       ( TREADY_net_0 ),
        .INTERRUPT    ( INTERRUPT_net_0 ),
        .CTRL_BRESP   ( AXI4TargetCtrl_IF_BRESP ),
        .CTRL_RDATA   ( AXI4TargetCtrl_IF_RDATA ),
        .CTRL_RRESP   ( AXI4TargetCtrl_IF_RRESP ),
        .DMA_AWADDR   ( AXI4InitiatorDMA_IF_AWADDR ),
        .DMA_AWID     ( AXI4InitiatorDMA_IF_AWID ),
        .DMA_AWLEN    ( AXI4InitiatorDMA_IF_AWLEN ),
        .DMA_AWSIZE   ( AXI4InitiatorDMA_IF_AWSIZE ),
        .DMA_AWBURST  ( AXI4InitiatorDMA_IF_AWBURST ),
        .DMA_WSTRB    ( AXI4InitiatorDMA_IF_WSTRB ),
        .DMA_WDATA    ( AXI4InitiatorDMA_IF_WDATA ),
        .DMA_ARADDR   ( AXI4InitiatorDMA_IF_ARADDR ),
        .DMA_ARID     ( AXI4InitiatorDMA_IF_ARID ),
        .DMA_ARLEN    ( AXI4InitiatorDMA_IF_ARLEN ),
        .DMA_ARSIZE   ( AXI4InitiatorDMA_IF_ARSIZE ),
        .DMA_ARBURST  ( AXI4InitiatorDMA_IF_ARBURST ) 
        );


endmodule
