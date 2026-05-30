//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Fri May 29 18:11:51 2026
// Version: 2025.2 2025.2.0.14
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of COREFIFO_C1 to TCL
# Family: PolarFireSoC
# Part Number: MPFS095T-1FCSG325E
# Create and Configure the core component COREFIFO_C1
create_and_configure_core -core_vlnv {Actel:DirectCore:COREFIFO:3.1.101} -component_name {COREFIFO_C1} -params {\
"AE_STATIC_EN:false"  \
"AEVAL:4"  \
"AF_STATIC_EN:false"  \
"AFVAL:1020"  \
"CTRL_TYPE:2"  \
"DIE_SIZE:10"  \
"ECC:0"  \
"ESTOP:true"  \
"FSTOP:true"  \
"FWFT:true"  \
"NUM_STAGES:2"  \
"OVERFLOW_EN:false"  \
"PIPE:1"  \
"PREFETCH:false"  \
"RAM_OPT:0"  \
"RDCNT_EN:false"  \
"RDEPTH:512"  \
"RE_POLARITY:0"  \
"READ_DVALID:false"  \
"RWIDTH:24"  \
"SYNC:1"  \
"SYNC_RESET:1"  \
"UNDERFLOW_EN:false"  \
"WDEPTH:512"  \
"WE_POLARITY:0"  \
"WRCNT_EN:false"  \
"WRITE_ACK:false"  \
"WWIDTH:24"   }
# Exporting Component Description of COREFIFO_C1 to TCL done
*/

// COREFIFO_C1
module COREFIFO_C1(
    // Inputs
    CLK,
    DATA,
    RE,
    RESET_N,
    WE,
    // Outputs
    EMPTY,
    FULL,
    Q
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         CLK;
input  [23:0] DATA;
input         RE;
input         RESET_N;
input         WE;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output        EMPTY;
output        FULL;
output [23:0] Q;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          CLK;
wire   [23:0] DATA;
wire          EMPTY_net_0;
wire          FULL_net_0;
wire   [23:0] Q_net_0;
wire          RE;
wire          RESET_N;
wire          WE;
wire          FULL_net_1;
wire          EMPTY_net_1;
wire   [23:0] Q_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          GND_net;
wire   [23:0] MEMRD_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net           = 1'b0;
assign MEMRD_const_net_0 = 24'h000000;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign FULL_net_1  = FULL_net_0;
assign FULL        = FULL_net_1;
assign EMPTY_net_1 = EMPTY_net_0;
assign EMPTY       = EMPTY_net_1;
assign Q_net_1     = Q_net_0;
assign Q[23:0]     = Q_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------COREFIFO_C1_COREFIFO_C1_0_COREFIFO   -   Actel:DirectCore:COREFIFO:3.1.101
COREFIFO_C1_COREFIFO_C1_0_COREFIFO #( 
        .AE_STATIC_EN ( 0 ),
        .AEVAL        ( 4 ),
        .AF_STATIC_EN ( 0 ),
        .AFVAL        ( 1020 ),
        .CTRL_TYPE    ( 2 ),
        .DIE_SIZE     ( 10 ),
        .ECC          ( 0 ),
        .ESTOP        ( 1 ),
        .FAMILY       ( 27 ),
        .FSTOP        ( 1 ),
        .FWFT         ( 1 ),
        .NUM_STAGES   ( 2 ),
        .OVERFLOW_EN  ( 0 ),
        .PIPE         ( 1 ),
        .PREFETCH     ( 0 ),
        .RAM_OPT      ( 0 ),
        .RDCNT_EN     ( 0 ),
        .RDEPTH       ( 512 ),
        .RE_POLARITY  ( 0 ),
        .READ_DVALID  ( 0 ),
        .RWIDTH       ( 24 ),
        .SYNC         ( 1 ),
        .SYNC_RESET   ( 1 ),
        .UNDERFLOW_EN ( 0 ),
        .WDEPTH       ( 512 ),
        .WE_POLARITY  ( 0 ),
        .WRCNT_EN     ( 0 ),
        .WRITE_ACK    ( 0 ),
        .WWIDTH       ( 24 ) )
COREFIFO_C1_0(
        // Inputs
        .CLK        ( CLK ),
        .WCLOCK     ( GND_net ), // tied to 1'b0 from definition
        .RCLOCK     ( GND_net ), // tied to 1'b0 from definition
        .RESET_N    ( RESET_N ),
        .WRESET_N   ( GND_net ), // tied to 1'b0 from definition
        .RRESET_N   ( GND_net ), // tied to 1'b0 from definition
        .WE         ( WE ),
        .RE         ( RE ),
        .DATA       ( DATA ),
        .MEMRD      ( MEMRD_const_net_0 ), // tied to 24'h000000 from definition
        // Outputs
        .FULL       ( FULL_net_0 ),
        .EMPTY      ( EMPTY_net_0 ),
        .AFULL      (  ),
        .AEMPTY     (  ),
        .OVERFLOW   (  ),
        .UNDERFLOW  (  ),
        .WACK       (  ),
        .DVLD       (  ),
        .MEMWE      (  ),
        .MEMRE      (  ),
        .SB_CORRECT (  ),
        .DB_DETECT  (  ),
        .Q          ( Q_net_0 ),
        .WRCNT      (  ),
        .RDCNT      (  ),
        .MEMWADDR   (  ),
        .MEMRADDR   (  ),
        .MEMWD      (  ) 
        );


endmodule
