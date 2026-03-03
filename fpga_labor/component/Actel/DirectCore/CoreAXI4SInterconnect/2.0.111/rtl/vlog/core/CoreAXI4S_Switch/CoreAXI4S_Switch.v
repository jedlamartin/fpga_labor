// *********************************************************************/
// Copyright (c) 2015 Microsemi Corporation.  All rights reserved.
//
// Any use or redistribution in part or in whole must be handled in
// accordance with the Actel license agreement and must be approved
// in advance in writing.
//
// File: COREAXI4S_SWITCH.v
//
// SVN Revision Information:
// SVN $Revision: 40502 $
// SVN $Date: 2022-04-26 20:36:05 +0530 (Tue, 26 Apr 2022) $

//
// Description: AXI4 Stream Switch module route multiple initiator streams to
// multiple target streams
//
// Notes:
// *********************************************************************/
`timescale 1ns / 1ns

module COREAXI4S_SWITCH
    #(
    // -------------------------------------------
    // PARAMETER Declaration
    // -------------------------------------------
    parameter integer FAMILY                   = 19,

    parameter integer NUM_INITIATORS           = 2,                   // Defines number of Initiator Ports      (1 to 8)
    parameter integer NUM_TARGETS              = 2,                   // Defines number of Target Ports         (1 to 8)

    parameter integer MAX_TARGETS              = 8,
    parameter integer MAX_INITIATORS           = 8,
    parameter integer NUM_INITIATORS_WIDTH     = 1,                   // Defines width for number of Initiator Ports(1 to 3)
    parameter integer NUM_TARGETS_WIDTH        = 1,                   // Defines width for number of Target Ports (1 to 3)

    parameter integer TID_WIDTH                = 1,                   // Defines TID port width                 (1 to 32)
    parameter integer TDEST_WIDTH              = 1,                   // Defines TDEST port width               (1 to 32)
    parameter integer TDATA_BYTES              = 4,                   // Defines TDATA port width               (1 to 512 Bytes)
    parameter integer TDATA_WIDTH              = 32,                  // Defines TDATA port width               (8 to 4096)
    parameter integer TUSER_WIDTH              = 1,                   // Defines TUSER port width               (1 to 512 Bytes)

    parameter integer ENABLE_TDATA             = 1,                   // Enable TDATA                           (0 , 1)
    parameter integer ENABLE_TUSER             = 1,                   // Enable TUSER                           (0 , 1)
    parameter integer ENABLE_TID               = 1,                   // Enable TID                             (0 , 1)
    parameter integer ENABLE_TREADY            = 1,                   // Enable TREADY                          (0 , 1)
    parameter integer ENABLE_TLAST             = 1,                   // Enable TLAST                           (0 , 1)
    parameter integer ENABLE_TSTRB             = 1,                   // Enable TSTRB                           (0 , 1)
    parameter integer ENABLE_TKEEP             = 1,                   // Enable TKEEP                           (0 , 1)

    parameter integer ARB_TYPE                 = 0,                   // Arbitration Type                       (0 , 1) 0 -> TLAST, 1 -> Number of Transfers
    parameter integer NUM_ARB_TRANS            = 1,                   // Number of Arbitration Transfers        (1 to 1024)
    parameter integer ENABLE_TIMEOUT           = 0,                   // Enable Timeout                         (0 , 1)
    parameter integer TIMEOUT_CYCLES           = 64,                  // Number of Timeout cycles for tready    (16 to 1024)

    parameter [0:0]   IR0_ENABLE_ARB           = 1,                   // Enable Arbitration                     (0 , 1)
    parameter [0:0]   IR1_ENABLE_ARB           = 1,                   // Enable Arbitration                     (0 , 1)
    parameter [0:0]   IR2_ENABLE_ARB           = 1,                   // Enable Arbitration                     (0 , 1)
    parameter [0:0]   IR3_ENABLE_ARB           = 1,                   // Enable Arbitration                     (0 , 1)
    parameter [0:0]   IR4_ENABLE_ARB           = 1,                   // Enable Arbitration                     (0 , 1)
    parameter [0:0]   IR5_ENABLE_ARB           = 1,                   // Enable Arbitration                     (0 , 1)
    parameter [0:0]   IR6_ENABLE_ARB           = 1,                   // Enable Arbitration                     (0 , 1)
    parameter [0:0]   IR7_ENABLE_ARB           = 1,                   // Enable Arbitration                     (0 , 1)

    parameter [0:0]   TR0_IR0_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR0_IR1_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR0_IR2_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR0_IR3_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR0_IR4_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR0_IR5_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR0_IR6_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR0_IR7_LINK             = 1,                   // Connectivity                           (0 , 1)

    parameter [0:0]   TR1_IR0_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR1_IR1_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR1_IR2_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR1_IR3_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR1_IR4_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR1_IR5_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR1_IR6_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR1_IR7_LINK             = 1,                   // Connectivity                           (0 , 1)

    parameter [0:0]   TR2_IR0_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR2_IR1_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR2_IR2_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR2_IR3_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR2_IR4_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR2_IR5_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR2_IR6_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR2_IR7_LINK             = 1,                   // Connectivity                           (0 , 1)

    parameter [0:0]   TR3_IR0_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR3_IR1_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR3_IR2_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR3_IR3_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR3_IR4_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR3_IR5_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR3_IR6_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR3_IR7_LINK             = 1,                   // Connectivity                           (0 , 1)

    parameter [0:0]   TR4_IR0_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR4_IR1_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR4_IR2_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR4_IR3_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR4_IR4_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR4_IR5_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR4_IR6_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR4_IR7_LINK             = 1,                   // Connectivity                           (0 , 1)

    parameter [0:0]   TR5_IR0_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR5_IR1_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR5_IR2_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR5_IR3_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR5_IR4_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR5_IR5_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR5_IR6_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR5_IR7_LINK             = 1,                   // Connectivity                           (0 , 1)

    parameter [0:0]   TR6_IR0_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR6_IR1_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR6_IR2_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR6_IR3_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR6_IR4_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR6_IR5_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR6_IR6_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR6_IR7_LINK             = 1,                   // Connectivity                           (0 , 1)

    parameter [0:0]   TR7_IR0_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR7_IR1_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR7_IR2_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR7_IR3_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR7_IR4_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR7_IR5_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR7_IR6_LINK             = 1,                   // Connectivity                           (0 , 1)
    parameter [0:0]   TR7_IR7_LINK             = 1,                   // Connectivity                           (0 , 1)

    parameter integer IR0_TDEST_BASE           = 'h00000000,          // Initiator port TDEST Base              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR1_TDEST_BASE           = 'h00000001,          // Initiator port TDEST Base              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR2_TDEST_BASE           = 'h00000002,          // Initiator port TDEST Base              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR3_TDEST_BASE           = 'h00000003,          // Initiator port TDEST Base              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR4_TDEST_BASE           = 'h00000004,          // Initiator port TDEST Base              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR5_TDEST_BASE           = 'h00000005,          // Initiator port TDEST Base              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR6_TDEST_BASE           = 'h00000006,          // Initiator port TDEST Base              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR7_TDEST_BASE           = 'h00000007,          // Initiator port TDEST Base              ('h00000000 , 'hFFFFFFFF)
                                                                                                             
    parameter integer IR0_TDEST_HIGH           = 'h00000000,          // Initiator port TDEST High              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR1_TDEST_HIGH           = 'h00000001,          // Initiator port TDEST High              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR2_TDEST_HIGH           = 'h00000002,          // Initiator port TDEST High              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR3_TDEST_HIGH           = 'h00000003,          // Initiator port TDEST High              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR4_TDEST_HIGH           = 'h00000004,          // Initiator port TDEST High              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR5_TDEST_HIGH           = 'h00000005,          // Initiator port TDEST High              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR6_TDEST_HIGH           = 'h00000006,          // Initiator port TDEST High              ('h00000000 , 'hFFFFFFFF)
    parameter integer IR7_TDEST_HIGH           = 'h00000007,          // Initiator port TDEST High              ('h00000000 , 'hFFFFFFFF)

    parameter [0:0]   AXI4S_T0RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_T1RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_T2RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_T3RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_T4RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_T5RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_T6RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_T7RS               = 0,                   // Register Slice                         (0 , 1)

    parameter [0:0]   AXI4S_I0RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_I1RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_I2RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_I3RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_I4RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_I5RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_I6RS               = 0,                   // Register Slice                         (0 , 1)
    parameter [0:0]   AXI4S_I7RS               = 0                    // Register Slice                         (0 , 1)
    )
    (
    //================================================= Global Signals  ==============================================//
    input  wire                                                        ACLK,
    input  wire                                                        RESETN,      // active low reset

    //================================================= Target Port ==================================================//
    // AXI4 Stream interface 0
    input  wire                                                        AXI4S_T0TVALID,
    output wire                                                        AXI4S_T0TREADY,
    input  wire [TDATA_WIDTH-1:0]                                      AXI4S_T0TDATA,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T0TSTRB,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T0TKEEP,
    input  wire                                                        AXI4S_T0TLAST,
    input  wire [TID_WIDTH-1:0]                                        AXI4S_T0TID,
    input  wire [TDEST_WIDTH-1:0]                                      AXI4S_T0TDEST,
    input  wire [TUSER_WIDTH-1:0]                                      AXI4S_T0TUSER,

    // AXI4 Stream interface 1
    input  wire                                                        AXI4S_T1TVALID,
    output wire                                                        AXI4S_T1TREADY,
    input  wire [TDATA_WIDTH-1:0]                                      AXI4S_T1TDATA,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T1TSTRB,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T1TKEEP,
    input  wire                                                        AXI4S_T1TLAST,
    input  wire [TID_WIDTH-1:0]                                        AXI4S_T1TID,
    input  wire [TDEST_WIDTH-1:0]                                      AXI4S_T1TDEST,
    input  wire [TUSER_WIDTH-1:0]                                      AXI4S_T1TUSER,

    // AXI4 Stream interface 2
    input  wire                                                        AXI4S_T2TVALID,
    output wire                                                        AXI4S_T2TREADY,
    input  wire [TDATA_WIDTH-1:0]                                      AXI4S_T2TDATA,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T2TSTRB,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T2TKEEP,
    input  wire                                                        AXI4S_T2TLAST,
    input  wire [TID_WIDTH-1:0]                                        AXI4S_T2TID,
    input  wire [TDEST_WIDTH-1:0]                                      AXI4S_T2TDEST,
    input  wire [TUSER_WIDTH-1:0]                                      AXI4S_T2TUSER,

    // AXI4 Stream interface 3
    input  wire                                                        AXI4S_T3TVALID,
    output wire                                                        AXI4S_T3TREADY,
    input  wire [TDATA_WIDTH-1:0]                                      AXI4S_T3TDATA,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T3TSTRB,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T3TKEEP,
    input  wire                                                        AXI4S_T3TLAST,
    input  wire [TID_WIDTH-1:0]                                        AXI4S_T3TID,
    input  wire [TDEST_WIDTH-1:0]                                      AXI4S_T3TDEST,
    input  wire [TUSER_WIDTH-1:0]                                      AXI4S_T3TUSER,

    // AXI4 Stream interface 4
    input  wire                                                        AXI4S_T4TVALID,
    output wire                                                        AXI4S_T4TREADY,
    input  wire [TDATA_WIDTH-1:0]                                      AXI4S_T4TDATA,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T4TSTRB,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T4TKEEP,
    input  wire                                                        AXI4S_T4TLAST,
    input  wire [TID_WIDTH-1:0]                                        AXI4S_T4TID,
    input  wire [TDEST_WIDTH-1:0]                                      AXI4S_T4TDEST,
    input  wire [TUSER_WIDTH-1:0]                                      AXI4S_T4TUSER,

    // AXI4 Stream interface 5
    input  wire                                                        AXI4S_T5TVALID,
    output wire                                                        AXI4S_T5TREADY,
    input  wire [TDATA_WIDTH-1:0]                                      AXI4S_T5TDATA,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T5TSTRB,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T5TKEEP,
    input  wire                                                        AXI4S_T5TLAST,
    input  wire [TID_WIDTH-1:0]                                        AXI4S_T5TID,
    input  wire [TDEST_WIDTH-1:0]                                      AXI4S_T5TDEST,
    input  wire [TUSER_WIDTH-1:0]                                      AXI4S_T5TUSER,

    // AXI4 Stream interface 6
    input  wire                                                        AXI4S_T6TVALID,
    output wire                                                        AXI4S_T6TREADY,
    input  wire [TDATA_WIDTH-1:0]                                      AXI4S_T6TDATA,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T6TSTRB,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T6TKEEP,
    input  wire                                                        AXI4S_T6TLAST,
    input  wire [TID_WIDTH-1:0]                                        AXI4S_T6TID,
    input  wire [TDEST_WIDTH-1:0]                                      AXI4S_T6TDEST,
    input  wire [TUSER_WIDTH-1:0]                                      AXI4S_T6TUSER,

    // AXI4 Stream interface 7
    input  wire                                                        AXI4S_T7TVALID,
    output wire                                                        AXI4S_T7TREADY,
    input  wire [TDATA_WIDTH-1:0]                                      AXI4S_T7TDATA,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T7TSTRB,
    input  wire [TDATA_WIDTH/8-1:0]                                    AXI4S_T7TKEEP,
    input  wire                                                        AXI4S_T7TLAST,
    input  wire [TID_WIDTH-1:0]                                        AXI4S_T7TID,
    input  wire [TDEST_WIDTH-1:0]                                      AXI4S_T7TDEST,
    input  wire [TUSER_WIDTH-1:0]                                      AXI4S_T7TUSER,

    //================================================= Initiator Port ==================================================//
    // AXI4 Stream interface 0
    output wire                                                        AXI4S_I0TVALID,
    input  wire                                                        AXI4S_I0TREADY,
    output wire [TDATA_WIDTH-1:0]                                      AXI4S_I0TDATA,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I0TSTRB,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I0TKEEP,
    output wire                                                        AXI4S_I0TLAST,
    output wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]                      AXI4S_I0TID,
    output wire [TDEST_WIDTH-1:0]                                      AXI4S_I0TDEST,
    output wire [TUSER_WIDTH-1:0]                                      AXI4S_I0TUSER,

    // AXI4 Stream interface 1
    output wire                                                        AXI4S_I1TVALID,
    input  wire                                                        AXI4S_I1TREADY,
    output wire [TDATA_WIDTH-1:0]                                      AXI4S_I1TDATA,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I1TSTRB,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I1TKEEP,
    output wire                                                        AXI4S_I1TLAST,
    output wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]                      AXI4S_I1TID,
    output wire [TDEST_WIDTH-1:0]                                      AXI4S_I1TDEST,
    output wire [TUSER_WIDTH-1:0]                                      AXI4S_I1TUSER,

    // AXI4 Stream interface 2
    output wire                                                        AXI4S_I2TVALID,
    input  wire                                                        AXI4S_I2TREADY,
    output wire [TDATA_WIDTH-1:0]                                      AXI4S_I2TDATA,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I2TSTRB,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I2TKEEP,
    output wire                                                        AXI4S_I2TLAST,
    output wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]                      AXI4S_I2TID,
    output wire [TDEST_WIDTH-1:0]                                      AXI4S_I2TDEST,
    output wire [TUSER_WIDTH-1:0]                                      AXI4S_I2TUSER,

    // AXI4 Stream interface 3
    output wire                                                        AXI4S_I3TVALID,
    input  wire                                                        AXI4S_I3TREADY,
    output wire [TDATA_WIDTH-1:0]                                      AXI4S_I3TDATA,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I3TSTRB,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I3TKEEP,
    output wire                                                        AXI4S_I3TLAST,
    output wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]                      AXI4S_I3TID,
    output wire [TDEST_WIDTH-1:0]                                      AXI4S_I3TDEST,
    output wire [TUSER_WIDTH-1:0]                                      AXI4S_I3TUSER,

    // AXI4 Stream interface 4
    output wire                                                        AXI4S_I4TVALID,
    input  wire                                                        AXI4S_I4TREADY,
    output wire [TDATA_WIDTH-1:0]                                      AXI4S_I4TDATA,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I4TSTRB,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I4TKEEP,
    output wire                                                        AXI4S_I4TLAST,
    output wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]                      AXI4S_I4TID,
    output wire [TDEST_WIDTH-1:0]                                      AXI4S_I4TDEST,
    output wire [TUSER_WIDTH-1:0]                                      AXI4S_I4TUSER,

    // AXI4 Stream interface 5
    output wire                                                        AXI4S_I5TVALID,
    input  wire                                                        AXI4S_I5TREADY,
    output wire [TDATA_WIDTH-1:0]                                      AXI4S_I5TDATA,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I5TSTRB,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I5TKEEP,
    output wire                                                        AXI4S_I5TLAST,
    output wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]                      AXI4S_I5TID,
    output wire [TDEST_WIDTH-1:0]                                      AXI4S_I5TDEST,
    output wire [TUSER_WIDTH-1:0]                                      AXI4S_I5TUSER,

    // AXI4 Stream interface 6
    output wire                                                        AXI4S_I6TVALID,
    input  wire                                                        AXI4S_I6TREADY,
    output wire [TDATA_WIDTH-1:0]                                      AXI4S_I6TDATA,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I6TSTRB,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I6TKEEP,
    output wire                                                        AXI4S_I6TLAST,
    output wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]                      AXI4S_I6TID,
    output wire [TDEST_WIDTH-1:0]                                      AXI4S_I6TDEST,
    output wire [TUSER_WIDTH-1:0]                                      AXI4S_I6TUSER,

    // AXI4 Stream interface 7
    output wire                                                        AXI4S_I7TVALID,
    input  wire                                                        AXI4S_I7TREADY,
    output wire [TDATA_WIDTH-1:0]                                      AXI4S_I7TDATA,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I7TSTRB,
    output wire [TDATA_WIDTH/8-1:0]                                    AXI4S_I7TKEEP,
    output wire                                                        AXI4S_I7TLAST,
    output wire [TID_WIDTH+NUM_TARGETS_WIDTH-1:0]                      AXI4S_I7TID,
    output wire [TDEST_WIDTH-1:0]                                      AXI4S_I7TDEST,
    output wire [TUSER_WIDTH-1:0]                                      AXI4S_I7TUSER,

    output wire [NUM_TARGETS-1:0]                                      DECODE_ERR
    );

localparam integer INTEGER_SIZE = 32;
localparam TREADY_DEFAULT_VALUE = 1'b1;
localparam TLAST_DEFAULT_VALUE  = 1'b1;
localparam M_TID_WIDTH          = TID_WIDTH + NUM_TARGETS_WIDTH;

localparam SYNC_RESET           = (FAMILY == 25) ? 1 : 0;

localparam [(MAX_TARGETS*MAX_INITIATORS)-1:0] TRx_IRy_LINK = {TR7_IR7_LINK,TR7_IR6_LINK,TR7_IR5_LINK,TR7_IR4_LINK,TR7_IR3_LINK,TR7_IR2_LINK,TR7_IR1_LINK,TR7_IR0_LINK,
                                                              TR6_IR7_LINK,TR6_IR6_LINK,TR6_IR5_LINK,TR6_IR4_LINK,TR6_IR3_LINK,TR6_IR2_LINK,TR6_IR1_LINK,TR6_IR0_LINK,
                                                              TR5_IR7_LINK,TR5_IR6_LINK,TR5_IR5_LINK,TR5_IR4_LINK,TR5_IR3_LINK,TR5_IR2_LINK,TR5_IR1_LINK,TR5_IR0_LINK,
                                                              TR4_IR7_LINK,TR4_IR6_LINK,TR4_IR5_LINK,TR4_IR4_LINK,TR4_IR3_LINK,TR4_IR2_LINK,TR4_IR1_LINK,TR4_IR0_LINK,
                                                              TR3_IR7_LINK,TR3_IR6_LINK,TR3_IR5_LINK,TR3_IR4_LINK,TR3_IR3_LINK,TR3_IR2_LINK,TR3_IR1_LINK,TR3_IR0_LINK,
                                                              TR2_IR7_LINK,TR2_IR6_LINK,TR2_IR5_LINK,TR2_IR4_LINK,TR2_IR3_LINK,TR2_IR2_LINK,TR2_IR1_LINK,TR2_IR0_LINK,
                                                              TR1_IR7_LINK,TR1_IR6_LINK,TR1_IR5_LINK,TR1_IR4_LINK,TR1_IR3_LINK,TR1_IR2_LINK,TR1_IR1_LINK,TR1_IR0_LINK,
                                                              TR0_IR7_LINK,TR0_IR6_LINK,TR0_IR5_LINK,TR0_IR4_LINK,TR0_IR3_LINK,TR0_IR2_LINK,TR0_IR1_LINK,TR0_IR0_LINK};

localparam [(NUM_INITIATORS*INTEGER_SIZE)-1:0] IRy_TDEST_BASE = {IR7_TDEST_BASE,IR6_TDEST_BASE,IR5_TDEST_BASE,IR4_TDEST_BASE,IR3_TDEST_BASE,IR2_TDEST_BASE,IR1_TDEST_BASE,IR0_TDEST_BASE};
localparam [(NUM_INITIATORS*INTEGER_SIZE)-1:0] IRy_TDEST_HIGH = {IR7_TDEST_HIGH,IR6_TDEST_HIGH,IR5_TDEST_HIGH,IR4_TDEST_HIGH,IR3_TDEST_HIGH,IR2_TDEST_HIGH,IR1_TDEST_HIGH,IR0_TDEST_HIGH};

localparam [ MAX_TARGETS   -1:0] AXI4S_TxRS                  = {AXI4S_T7RS,AXI4S_T6RS,AXI4S_T5RS,AXI4S_T4RS,AXI4S_T3RS,AXI4S_T2RS,AXI4S_T1RS,AXI4S_T0RS};
localparam [ MAX_INITIATORS-1:0] AXI4S_IyRS                  = {AXI4S_I7RS,AXI4S_I6RS,AXI4S_I5RS,AXI4S_I4RS,AXI4S_I3RS,AXI4S_I2RS,AXI4S_I1RS,AXI4S_I0RS};
localparam [ MAX_INITIATORS-1:0] ENABLE_ARB                  = {IR7_ENABLE_ARB,IR6_ENABLE_ARB,IR5_ENABLE_ARB,IR4_ENABLE_ARB,IR3_ENABLE_ARB,IR2_ENABLE_ARB,IR1_ENABLE_ARB,IR0_ENABLE_ARB};

wire [(NUM_TARGETS*NUM_INITIATORS)-1:0]         w_valid_req;
wire [(NUM_TARGETS*NUM_INITIATORS)-1:0]         w_valid_req_transpose;

wire aresetn = (SYNC_RESET==1) ? 1'b1   : RESETN;
wire sresetn = (SYNC_RESET==1) ? RESETN : 1'b1;

genvar i,j;
generate
    for (i=0; i<NUM_INITIATORS; i=i+1)
    begin : i_loop
        for (j=0; j<NUM_TARGETS; j=j+1)
        begin : j_loop
            assign w_valid_req_transpose[(i*NUM_TARGETS)+j] = w_valid_req[(j*NUM_INITIATORS)+i];
        end
    end
endgenerate

wire [(NUM_TARGETS*NUM_INITIATORS)-1:0]         w_trgt_sel;
wire [(NUM_INITIATORS)-1:0]                     w_arbValid;
wire [NUM_TARGETS-1:0]                          w_route_tready   [NUM_INITIATORS-1:0];
wire [(NUM_INITIATORS*NUM_TARGETS)-1:0]         w_route_tready_t;


genvar k,l;
generate
    if(NUM_INITIATORS == 1)
	  begin 
	    assign w_route_tready_t = w_route_tready[0];
      end	  
	else 
	  begin 
        for (k=0; k<NUM_TARGETS; k=k+1)        
        begin : k_loop
            for (l=0; l<NUM_INITIATORS; l=l+1)
            begin : l_loop
                assign w_route_tready_t[(k*NUM_INITIATORS)+l] = w_route_tready[l][k];
            end
        end
	  end
endgenerate


wire [(NUM_TARGETS)-1:0]                     w_axi4s_txtvalid   = {AXI4S_T7TVALID,AXI4S_T6TVALID,AXI4S_T5TVALID,AXI4S_T4TVALID,AXI4S_T3TVALID,AXI4S_T2TVALID,AXI4S_T1TVALID,AXI4S_T0TVALID};
wire [(NUM_TARGETS)-1:0]                     w_axi4s_txtready; 
wire [(NUM_TARGETS*TDATA_WIDTH)-1:0]         w_axi4s_txtdata;
wire [(NUM_TARGETS*TDATA_WIDTH/8)-1:0]       w_axi4s_txtstrb; 
wire [(NUM_TARGETS*TDATA_WIDTH/8)-1:0]       w_axi4s_txtkeep;
wire [(NUM_TARGETS)-1:0]                     w_axi4s_txtlast;
wire [(NUM_TARGETS*TID_WIDTH)-1:0]           w_axi4s_txtid;
wire [(NUM_TARGETS*TDEST_WIDTH)-1:0]         w_axi4s_txtdest    = {AXI4S_T7TDEST,AXI4S_T6TDEST,AXI4S_T5TDEST,AXI4S_T4TDEST,AXI4S_T3TDEST,AXI4S_T2TDEST,AXI4S_T1TDEST,AXI4S_T0TDEST};
wire [(NUM_TARGETS*TUSER_WIDTH)-1:0]         w_axi4s_txtuser;

wire [(NUM_TARGETS)-1:0]                     r_axi4s_txtvalid;
wire [(NUM_TARGETS)-1:0]                     r_axi4s_txtready; 
wire [(NUM_TARGETS*TDATA_WIDTH)-1:0]         r_axi4s_txtdata;
wire [(NUM_TARGETS*TDATA_WIDTH/8)-1:0]       r_axi4s_txtstrb; 
wire [(NUM_TARGETS*TDATA_WIDTH/8)-1:0]       r_axi4s_txtkeep;
wire [(NUM_TARGETS)-1:0]                     r_axi4s_txtlast;
wire [(NUM_TARGETS*TID_WIDTH)-1:0]           r_axi4s_txtid;
wire [(NUM_TARGETS*TDEST_WIDTH)-1:0]         r_axi4s_txtdest;
wire [(NUM_TARGETS*TUSER_WIDTH)-1:0]         r_axi4s_txtuser;

genvar ip_rs_count;
generate
    for (ip_rs_count=0; ip_rs_count<NUM_TARGETS; ip_rs_count=ip_rs_count+1)
    begin : ip_rs_inst_loop
        caxi4s_Sw_RegisterSlice
        #(
        .SYNC_RESET       (SYNC_RESET       ),
        .ENABLE_RS        (AXI4S_TxRS[ip_rs_count]),
        .TID_WIDTH        (TID_WIDTH        ),
        .TDEST_WIDTH      (TDEST_WIDTH      ),
        .TDATA_WIDTH      (TDATA_WIDTH      ),
        .TUSER_WIDTH      (TUSER_WIDTH      )
        )
        caxi4s_Sw_RegisterSlice_ip_inst
        (
        //==============================================  Global Signals  ===============================================//
        .aclk             (ACLK             ),
        .resetn           (RESETN           ),

        //================================================= Input Port ==================================================//
        .src_tvalid       (w_axi4s_txtvalid [ip_rs_count]),
        .src_tready       (w_axi4s_txtready [ip_rs_count]),
        .src_tdata        (w_axi4s_txtdata  [((ip_rs_count+1)*TDATA_WIDTH)-1:(ip_rs_count)*TDATA_WIDTH]),
        .src_tstrb        (w_axi4s_txtstrb  [((ip_rs_count+1)*TDATA_WIDTH/8)-1:(ip_rs_count)*TDATA_WIDTH/8]),
        .src_tkeep        (w_axi4s_txtkeep  [((ip_rs_count+1)*TDATA_WIDTH/8)-1:(ip_rs_count)*TDATA_WIDTH/8]),
        .src_tlast        (w_axi4s_txtlast  [ip_rs_count]),
        .src_tid          (w_axi4s_txtid    [((ip_rs_count+1)*TID_WIDTH)-1:(ip_rs_count)*TID_WIDTH]),
        .src_tdest        (w_axi4s_txtdest  [((ip_rs_count+1)*TDEST_WIDTH)-1:(ip_rs_count)*TDEST_WIDTH]),
        .src_tuser        (w_axi4s_txtuser  [((ip_rs_count+1)*TUSER_WIDTH)-1:(ip_rs_count)*TUSER_WIDTH]),

        //================================================= Output Port =================================================//
        .dst_tvalid       (r_axi4s_txtvalid [ip_rs_count]),
        .dst_tready       (r_axi4s_txtready [ip_rs_count]),
        .dst_tdata        (r_axi4s_txtdata  [((ip_rs_count+1)*TDATA_WIDTH)-1:(ip_rs_count)*TDATA_WIDTH]),
        .dst_tstrb        (r_axi4s_txtstrb  [((ip_rs_count+1)*TDATA_WIDTH/8)-1:(ip_rs_count)*TDATA_WIDTH/8]),
        .dst_tkeep        (r_axi4s_txtkeep  [((ip_rs_count+1)*TDATA_WIDTH/8)-1:(ip_rs_count)*TDATA_WIDTH/8]),
        .dst_tlast        (r_axi4s_txtlast  [ip_rs_count]),
        .dst_tid          (r_axi4s_txtid    [((ip_rs_count+1)*TID_WIDTH)-1:(ip_rs_count)*TID_WIDTH]),
        .dst_tdest        (r_axi4s_txtdest  [((ip_rs_count+1)*TDEST_WIDTH)-1:(ip_rs_count)*TDEST_WIDTH]),
        .dst_tuser        (r_axi4s_txtuser  [((ip_rs_count+1)*TUSER_WIDTH)-1:(ip_rs_count)*TUSER_WIDTH])
        );
    end // ip_rs_inst_loop
endgenerate

wire [(NUM_INITIATORS)-1:0]                    w_axi4s_iytvalid; 
wire [(NUM_INITIATORS)-1:0]                    w_axi4s_iytready; 
wire [(NUM_INITIATORS*TDATA_WIDTH)-1:0]        w_axi4s_iytdata;
wire [(NUM_INITIATORS*TDATA_WIDTH/8)-1:0]      w_axi4s_iytstrb;
wire [(NUM_INITIATORS*TDATA_WIDTH/8)-1:0]      w_axi4s_iytkeep;
wire [(NUM_INITIATORS)-1:0]                    w_axi4s_iytlast;
wire [(NUM_INITIATORS*M_TID_WIDTH)-1:0]        w_axi4s_iytid;
wire [(NUM_INITIATORS*TDEST_WIDTH)-1:0]        w_axi4s_iytdest;
wire [(NUM_INITIATORS*TUSER_WIDTH)-1:0]        w_axi4s_iytuser;

wire [(NUM_INITIATORS)-1:0]                    r_axi4s_iytvalid;
wire [(NUM_INITIATORS)-1:0]                    r_axi4s_iytready; 
wire [(NUM_INITIATORS*TDATA_WIDTH)-1:0]        r_axi4s_iytdata;
wire [(NUM_INITIATORS*TDATA_WIDTH/8)-1:0]      r_axi4s_iytstrb; 
wire [(NUM_INITIATORS*TDATA_WIDTH/8)-1:0]      r_axi4s_iytkeep;
wire [(NUM_INITIATORS)-1:0]                    r_axi4s_iytlast;
wire [(NUM_INITIATORS*M_TID_WIDTH)-1:0]        r_axi4s_iytid;
wire [(NUM_INITIATORS*TDEST_WIDTH)-1:0]        r_axi4s_iytdest;
wire [(NUM_INITIATORS*TUSER_WIDTH)-1:0]        r_axi4s_iytuser;

genvar op_rs_count;
generate
    for (op_rs_count=0; op_rs_count<NUM_INITIATORS; op_rs_count=op_rs_count+1)
    begin : op_rs_inst_loop
        caxi4s_Sw_RegisterSlice
        #(
        .SYNC_RESET       (SYNC_RESET       ),
        .ENABLE_RS        (AXI4S_IyRS[op_rs_count]),
        .TID_WIDTH        (M_TID_WIDTH      ),
        .TDEST_WIDTH      (TDEST_WIDTH      ),
        .TDATA_WIDTH      (TDATA_WIDTH      ),
        .TUSER_WIDTH      (TUSER_WIDTH      )
        )
        caxi4s_Sw_RegisterSlice_op_inst
        (
        //==============================================  Global Signals  ===============================================//
        .aclk             (ACLK             ),
        .resetn           (RESETN           ),

        //================================================= Input Port ==================================================//
        .src_tvalid       (w_axi4s_iytvalid [op_rs_count]),
        .src_tready       (w_axi4s_iytready [op_rs_count]),
        .src_tdata        (w_axi4s_iytdata  [((op_rs_count+1)*TDATA_WIDTH)-1:(op_rs_count)*TDATA_WIDTH]),
        .src_tstrb        (w_axi4s_iytstrb  [((op_rs_count+1)*TDATA_WIDTH/8)-1:(op_rs_count)*TDATA_WIDTH/8]),
        .src_tkeep        (w_axi4s_iytkeep  [((op_rs_count+1)*TDATA_WIDTH/8)-1:(op_rs_count)*TDATA_WIDTH/8]),
        .src_tlast        (w_axi4s_iytlast  [op_rs_count]),
        .src_tid          (w_axi4s_iytid    [((op_rs_count+1)*M_TID_WIDTH)-1:(op_rs_count)*M_TID_WIDTH]),
        .src_tdest        (w_axi4s_iytdest  [((op_rs_count+1)*TDEST_WIDTH)-1:(op_rs_count)*TDEST_WIDTH]),
        .src_tuser        (w_axi4s_iytuser  [((op_rs_count+1)*TUSER_WIDTH)-1:(op_rs_count)*TUSER_WIDTH]),

        //================================================= Output Port =================================================//
        .dst_tvalid       (r_axi4s_iytvalid [op_rs_count]),
        .dst_tready       (r_axi4s_iytready [op_rs_count]),
        .dst_tdata        (r_axi4s_iytdata  [((op_rs_count+1)*TDATA_WIDTH)-1:(op_rs_count)*TDATA_WIDTH]),
        .dst_tstrb        (r_axi4s_iytstrb  [((op_rs_count+1)*TDATA_WIDTH/8)-1:(op_rs_count)*TDATA_WIDTH/8]),
        .dst_tkeep        (r_axi4s_iytkeep  [((op_rs_count+1)*TDATA_WIDTH/8)-1:(op_rs_count)*TDATA_WIDTH/8]),
        .dst_tlast        (r_axi4s_iytlast  [op_rs_count]),
        .dst_tid          (r_axi4s_iytid    [((op_rs_count+1)*M_TID_WIDTH)-1:(op_rs_count)*M_TID_WIDTH]),
        .dst_tdest        (r_axi4s_iytdest  [((op_rs_count+1)*TDEST_WIDTH)-1:(op_rs_count)*TDEST_WIDTH]),
        .dst_tuser        (r_axi4s_iytuser  [((op_rs_count+1)*TUSER_WIDTH)-1:(op_rs_count)*TUSER_WIDTH])
        );
    end // op_rs_inst_loop
endgenerate

generate
  if (ENABLE_TDATA) begin
    assign w_axi4s_txtdata = {AXI4S_T7TDATA,AXI4S_T6TDATA,AXI4S_T5TDATA,AXI4S_T4TDATA,AXI4S_T3TDATA,AXI4S_T2TDATA,AXI4S_T1TDATA,AXI4S_T0TDATA};
  end
  else begin
    assign w_axi4s_txtdata = {(NUM_TARGETS*TDATA_WIDTH){1'b0}};
  end
endgenerate

generate
  if (ENABLE_TSTRB & ENABLE_TDATA) begin
    assign w_axi4s_txtstrb = {AXI4S_T7TSTRB,AXI4S_T6TSTRB,AXI4S_T5TSTRB,AXI4S_T4TSTRB,AXI4S_T3TSTRB,AXI4S_T2TSTRB,AXI4S_T1TSTRB,AXI4S_T0TSTRB};
  end
  else begin
    assign w_axi4s_txtstrb = {(NUM_TARGETS*TDATA_WIDTH/8){1'b1}};
  end
endgenerate

generate
  if (ENABLE_TKEEP) begin
    assign w_axi4s_txtkeep = {AXI4S_T7TKEEP,AXI4S_T6TKEEP,AXI4S_T5TKEEP,AXI4S_T4TKEEP,AXI4S_T3TKEEP,AXI4S_T2TKEEP,AXI4S_T1TKEEP,AXI4S_T0TKEEP};
  end
  else begin
    assign w_axi4s_txtkeep = {(NUM_TARGETS*TDATA_WIDTH/8){1'b1}};
  end
endgenerate

generate
  if (ENABLE_TUSER) begin
    assign w_axi4s_txtuser = {AXI4S_T7TUSER,AXI4S_T6TUSER,AXI4S_T5TUSER,AXI4S_T4TUSER,AXI4S_T3TUSER,AXI4S_T2TUSER,AXI4S_T1TUSER,AXI4S_T0TUSER};
  end
  else begin
    assign w_axi4s_txtuser = {(NUM_TARGETS*TUSER_WIDTH){1'b0}};
  end
endgenerate

generate
  if (ENABLE_TLAST) begin
    assign w_axi4s_txtlast = {AXI4S_T7TLAST,AXI4S_T6TLAST,AXI4S_T5TLAST,AXI4S_T4TLAST,AXI4S_T3TLAST,AXI4S_T2TLAST,AXI4S_T1TLAST,AXI4S_T0TLAST};
  end
  else begin
    assign w_axi4s_txtlast = {(NUM_TARGETS){TLAST_DEFAULT_VALUE}};;
  end
endgenerate

generate
  if (ENABLE_TID) begin
    assign w_axi4s_txtid = {AXI4S_T7TID,AXI4S_T6TID,AXI4S_T5TID,AXI4S_T4TID,AXI4S_T3TID,AXI4S_T2TID,AXI4S_T1TID,AXI4S_T0TID};
  end
  else begin
    assign w_axi4s_txtid = {(NUM_TARGETS*TID_WIDTH){1'b0}};
  end
endgenerate

generate
  if (ENABLE_TREADY) begin
    assign r_axi4s_iytready = {AXI4S_I7TREADY,AXI4S_I6TREADY,AXI4S_I5TREADY,AXI4S_I4TREADY,AXI4S_I3TREADY,AXI4S_I2TREADY,AXI4S_I1TREADY,AXI4S_I0TREADY};
  end
  else begin
    assign r_axi4s_iytready = {(NUM_INITIATORS){TREADY_DEFAULT_VALUE}};
  end
endgenerate

assign AXI4S_T0TREADY = w_axi4s_txtready[0];

generate
if ( NUM_TARGETS > 1 )
    begin
        assign AXI4S_T1TREADY = w_axi4s_txtready[1];
    end

if ( NUM_TARGETS > 2 )
    begin
        assign AXI4S_T2TREADY = w_axi4s_txtready[2];
    end

if ( NUM_TARGETS > 3 )
    begin
        assign AXI4S_T3TREADY = w_axi4s_txtready[3];
    end

if ( NUM_TARGETS > 4 )
    begin
        assign AXI4S_T4TREADY = w_axi4s_txtready[4];
    end

if ( NUM_TARGETS > 5 )
    begin
        assign AXI4S_T5TREADY = w_axi4s_txtready[5];
    end

if ( NUM_TARGETS > 6 )
    begin
        assign AXI4S_T6TREADY = w_axi4s_txtready[6];
    end

if ( NUM_TARGETS > 7 )
    begin
        assign AXI4S_T7TREADY = w_axi4s_txtready[7];
    end
endgenerate

assign AXI4S_I0TVALID = r_axi4s_iytvalid[0];
assign AXI4S_I0TDATA  = r_axi4s_iytdata[(0+1)*TDATA_WIDTH  -1:0*TDATA_WIDTH];
assign AXI4S_I0TSTRB  = r_axi4s_iytstrb[(0+1)*TDATA_WIDTH/8-1:0*TDATA_WIDTH/8];
assign AXI4S_I0TKEEP  = r_axi4s_iytkeep[(0+1)*TDATA_WIDTH/8-1:0*TDATA_WIDTH/8];
assign AXI4S_I0TLAST  = r_axi4s_iytlast [0];
assign AXI4S_I0TID    = r_axi4s_iytid  [(0+1)*M_TID_WIDTH  -1:0*M_TID_WIDTH];
assign AXI4S_I0TDEST  = r_axi4s_iytdest[(0+1)*TDEST_WIDTH  -1:0*TDEST_WIDTH];
assign AXI4S_I0TUSER  = r_axi4s_iytuser[(0+1)*TUSER_WIDTH  -1:0*TUSER_WIDTH];

generate
if ( NUM_INITIATORS > 1 )
    begin
        assign AXI4S_I1TVALID = r_axi4s_iytvalid[1];
        assign AXI4S_I1TDATA  = r_axi4s_iytdata[(1+1)*TDATA_WIDTH  -1:1*TDATA_WIDTH];
        assign AXI4S_I1TSTRB  = r_axi4s_iytstrb[(1+1)*TDATA_WIDTH/8-1:1*TDATA_WIDTH/8];
        assign AXI4S_I1TKEEP  = r_axi4s_iytkeep[(1+1)*TDATA_WIDTH/8-1:1*TDATA_WIDTH/8];
        assign AXI4S_I1TLAST  = r_axi4s_iytlast [1];
        assign AXI4S_I1TID    = r_axi4s_iytid  [(1+1)*M_TID_WIDTH  -1:1*M_TID_WIDTH];
        assign AXI4S_I1TDEST  = r_axi4s_iytdest[(1+1)*TDEST_WIDTH  -1:1*TDEST_WIDTH];
        assign AXI4S_I1TUSER  = r_axi4s_iytuser[(1+1)*TUSER_WIDTH  -1:1*TUSER_WIDTH];
    end

if ( NUM_INITIATORS > 2 )
    begin
        assign AXI4S_I2TVALID = r_axi4s_iytvalid[2];
        assign AXI4S_I2TDATA  = r_axi4s_iytdata[(2+1)*TDATA_WIDTH  -1:2*TDATA_WIDTH];
        assign AXI4S_I2TSTRB  = r_axi4s_iytstrb[(2+1)*TDATA_WIDTH/8-1:2*TDATA_WIDTH/8];
        assign AXI4S_I2TKEEP  = r_axi4s_iytkeep[(2+1)*TDATA_WIDTH/8-1:2*TDATA_WIDTH/8];
        assign AXI4S_I2TLAST  = r_axi4s_iytlast [2];
        assign AXI4S_I2TID    = r_axi4s_iytid  [(2+1)*M_TID_WIDTH  -1:2*M_TID_WIDTH];
        assign AXI4S_I2TDEST  = r_axi4s_iytdest[(2+1)*TDEST_WIDTH  -1:2*TDEST_WIDTH];
        assign AXI4S_I2TUSER  = r_axi4s_iytuser[(2+1)*TUSER_WIDTH  -1:2*TUSER_WIDTH];
    end

if ( NUM_INITIATORS > 3 )
    begin
        assign AXI4S_I3TVALID = r_axi4s_iytvalid[3];
        assign AXI4S_I3TDATA  = r_axi4s_iytdata[(3+1)*TDATA_WIDTH  -1:3*TDATA_WIDTH];
        assign AXI4S_I3TSTRB  = r_axi4s_iytstrb[(3+1)*TDATA_WIDTH/8-1:3*TDATA_WIDTH/8];
        assign AXI4S_I3TKEEP  = r_axi4s_iytkeep[(3+1)*TDATA_WIDTH/8-1:3*TDATA_WIDTH/8];
        assign AXI4S_I3TLAST  = r_axi4s_iytlast [3];
        assign AXI4S_I3TID    = r_axi4s_iytid  [(3+1)*M_TID_WIDTH  -1:3*M_TID_WIDTH];
        assign AXI4S_I3TDEST  = r_axi4s_iytdest[(3+1)*TDEST_WIDTH  -1:3*TDEST_WIDTH];
        assign AXI4S_I3TUSER  = r_axi4s_iytuser[(3+1)*TUSER_WIDTH  -1:3*TUSER_WIDTH];
    end

if ( NUM_INITIATORS > 4 )
    begin
        assign AXI4S_I4TVALID = r_axi4s_iytvalid[4];
        assign AXI4S_I4TDATA  = r_axi4s_iytdata[(4+1)*TDATA_WIDTH  -1:4*TDATA_WIDTH];
        assign AXI4S_I4TSTRB  = r_axi4s_iytstrb[(4+1)*TDATA_WIDTH/8-1:4*TDATA_WIDTH/8];
        assign AXI4S_I4TKEEP  = r_axi4s_iytkeep[(4+1)*TDATA_WIDTH/8-1:4*TDATA_WIDTH/8];
        assign AXI4S_I4TLAST  = r_axi4s_iytlast [4];
        assign AXI4S_I4TID    = r_axi4s_iytid  [(4+1)*M_TID_WIDTH  -1:4*M_TID_WIDTH];
        assign AXI4S_I4TDEST  = r_axi4s_iytdest[(4+1)*TDEST_WIDTH  -1:4*TDEST_WIDTH];
        assign AXI4S_I4TUSER  = r_axi4s_iytuser[(4+1)*TUSER_WIDTH  -1:4*TUSER_WIDTH];
    end

if ( NUM_INITIATORS > 5 )
    begin
        assign AXI4S_I5TVALID = r_axi4s_iytvalid[5];
        assign AXI4S_I5TDATA  = r_axi4s_iytdata[(5+1)*TDATA_WIDTH  -1:5*TDATA_WIDTH];
        assign AXI4S_I5TSTRB  = r_axi4s_iytstrb[(5+1)*TDATA_WIDTH/8-1:5*TDATA_WIDTH/8];
        assign AXI4S_I5TKEEP  = r_axi4s_iytkeep[(5+1)*TDATA_WIDTH/8-1:5*TDATA_WIDTH/8];
        assign AXI4S_I5TLAST  = r_axi4s_iytlast [5];
        assign AXI4S_I5TID    = r_axi4s_iytid  [(5+1)*M_TID_WIDTH  -1:5*M_TID_WIDTH];
        assign AXI4S_I5TDEST  = r_axi4s_iytdest[(5+1)*TDEST_WIDTH  -1:5*TDEST_WIDTH];
        assign AXI4S_I5TUSER  = r_axi4s_iytuser[(5+1)*TUSER_WIDTH  -1:5*TUSER_WIDTH];
    end

if ( NUM_INITIATORS > 6 )
    begin
        assign AXI4S_I6TVALID = r_axi4s_iytvalid[6];
        assign AXI4S_I6TDATA  = r_axi4s_iytdata[(6+1)*TDATA_WIDTH  -1:6*TDATA_WIDTH];
        assign AXI4S_I6TSTRB  = r_axi4s_iytstrb[(6+1)*TDATA_WIDTH/8-1:6*TDATA_WIDTH/8];
        assign AXI4S_I6TKEEP  = r_axi4s_iytkeep[(6+1)*TDATA_WIDTH/8-1:6*TDATA_WIDTH/8];
        assign AXI4S_I6TLAST  = r_axi4s_iytlast [6];
        assign AXI4S_I6TID    = r_axi4s_iytid  [(6+1)*M_TID_WIDTH  -1:6*M_TID_WIDTH];
        assign AXI4S_I6TDEST  = r_axi4s_iytdest[(6+1)*TDEST_WIDTH  -1:6*TDEST_WIDTH];
        assign AXI4S_I6TUSER  = r_axi4s_iytuser[(6+1)*TUSER_WIDTH  -1:6*TUSER_WIDTH];
    end

if ( NUM_INITIATORS > 7 )
    begin
        assign AXI4S_I7TVALID = r_axi4s_iytvalid[7];
        assign AXI4S_I7TDATA  = r_axi4s_iytdata[(7+1)*TDATA_WIDTH  -1:7*TDATA_WIDTH];
        assign AXI4S_I7TSTRB  = r_axi4s_iytstrb[(7+1)*TDATA_WIDTH/8-1:7*TDATA_WIDTH/8];
        assign AXI4S_I7TKEEP  = r_axi4s_iytkeep[(7+1)*TDATA_WIDTH/8-1:7*TDATA_WIDTH/8];
        assign AXI4S_I7TLAST  = r_axi4s_iytlast [7];
        assign AXI4S_I7TID    = r_axi4s_iytid  [(7+1)*M_TID_WIDTH  -1:7*M_TID_WIDTH];
        assign AXI4S_I7TDEST  = r_axi4s_iytdest[(7+1)*TDEST_WIDTH  -1:7*TDEST_WIDTH];
        assign AXI4S_I7TUSER  = r_axi4s_iytuser[(7+1)*TUSER_WIDTH  -1:7*TUSER_WIDTH];
    end
endgenerate

genvar ins_count;
generate
    for (ins_count=0; ins_count<NUM_TARGETS; ins_count=ins_count+1)
    begin : Decoder_inst_loop
        caxi4s_Sw_Decoder
        #(
        .INTEGER_SIZE           (INTEGER_SIZE           ),
        .NUM_INITIATORS         (NUM_INITIATORS         ),
        .NUM_INITIATORS_WIDTH   (NUM_INITIATORS_WIDTH   ),
        .MAX_INITIATORS         (MAX_INITIATORS         ),
        .TDEST_WIDTH            (TDEST_WIDTH            ),

        .TRx_IRy_LINK           (TRx_IRy_LINK  [((ins_count+1)*MAX_INITIATORS)-1:(ins_count)*MAX_INITIATORS]),

        .IRy_TDEST_BASE         (IRy_TDEST_BASE         ),
        .IRy_TDEST_HIGH         (IRy_TDEST_HIGH         )
        )
        caxi4s_Sw_Decoder_inst
        (
        //================================================= Input Port ==================================================//
        .trgt_tvalid            (r_axi4s_txtvalid[ins_count]),
        .trgt_tdest             (r_axi4s_txtdest[((ins_count+1)*TDEST_WIDTH)-1:(ins_count)*TDEST_WIDTH]),

        //================================================= Output Port =================================================//
        .valid_req              (w_valid_req[((ins_count+1)*NUM_INITIATORS)-1:(ins_count)*NUM_INITIATORS]),
        //.req_itor_index         (),
        .decode_err             (DECODE_ERR[ins_count]  )
        );
    end // Decoder_inst_loop
endgenerate

genvar arb_count;
generate
    for (arb_count=0; arb_count<NUM_INITIATORS; arb_count=arb_count+1)
    begin : Arb_inst_loop
        if (ENABLE_ARB[arb_count])
        begin
            caxi4s_Sw_Arbitration
            #(
            .SYNC_RESET       (SYNC_RESET           ),
            .INTEGER_SIZE     (INTEGER_SIZE         ),
            .NUM_REQSTS       (NUM_TARGETS          ),
            .NUM_REQSTS_WIDTH (NUM_TARGETS_WIDTH    ),
            .ARB_TYPE         (ARB_TYPE             ),
            .NUM_ARB_TRANS    (NUM_ARB_TRANS        ),
            .ENABLE_TIMEOUT   (ENABLE_TIMEOUT       ),
            .TIMEOUT_CYCLES   (TIMEOUT_CYCLES       )
            )
            caxi4s_Sw_Arbitration_inst
            (
            //================================================= Global Signals  ==============================================//
            .aclk             (ACLK),
            .resetn           (RESETN),
    
            //================================================= Input Port ==================================================//
            .requestors       (w_valid_req_transpose[((arb_count+1)*NUM_TARGETS)-1:(arb_count)*NUM_TARGETS]),
            .extr_tlast       (r_axi4s_txtlast      ),
            .extr_tready      (w_axi4s_iytready[arb_count]),
    
            //================================================= Output Port =================================================//
            .grant            (w_trgt_sel[((arb_count+1)*NUM_TARGETS)-1:(arb_count)*NUM_TARGETS]),
//            .grantEnc         (),
            .arbValid         (w_arbValid[arb_count])
            );
        end
        else
        begin		
		    reg  [(NUM_TARGETS*NUM_INITIATORS)-1:0]         w_trgt_sel_pre;
			
            always@(posedge ACLK or negedge aresetn)
            begin
                if (~aresetn | ~sresetn)
                begin
                    w_trgt_sel_pre[((arb_count+1)*NUM_TARGETS)-1:(arb_count)*NUM_TARGETS]   <= {NUM_TARGETS{1'b0}};
                end
                else
                begin
                    w_trgt_sel_pre[((arb_count+1)*NUM_TARGETS)-1:(arb_count)*NUM_TARGETS]   <= w_valid_req_transpose[((arb_count+1)*NUM_TARGETS)-1:(arb_count)*NUM_TARGETS];
                end
            end
            assign w_trgt_sel[((arb_count+1)*NUM_TARGETS)-1:(arb_count)*NUM_TARGETS] = w_trgt_sel_pre[((arb_count+1)*NUM_TARGETS)-1:(arb_count)*NUM_TARGETS];
            assign w_arbValid[arb_count]    = (| w_trgt_sel[((arb_count+1)*NUM_TARGETS)-1:(arb_count)*NUM_TARGETS]);
        end
    end // Arb_inst_loop
endgenerate

genvar router_count;
generate
    for (router_count=0; router_count<NUM_INITIATORS; router_count=router_count+1)
    begin : Router_inst_loop
        caxi4s_Sw_Bus_Router
        #(
        .INTEGER_SIZE       (INTEGER_SIZE           ),
        .NUM_TARGETS        (NUM_TARGETS            ),
        .NUM_TARGETS_WIDTH  (NUM_TARGETS_WIDTH      ),
        .TDATA_WIDTH        (TDATA_WIDTH            ),
        .TID_WIDTH          (TID_WIDTH              ),
        .TDEST_WIDTH        (TDEST_WIDTH            ),
        .TUSER_WIDTH        (TUSER_WIDTH            ),
        .M_TID_WIDTH        (M_TID_WIDTH            )
        )
       caxi4s_Sw_Bus_Router_inst
        (
        //============================================== Input Control Port =============================================//
        .trgt_sel_valid     (w_arbValid[router_count]),
        .trgt_sel           (w_trgt_sel[((router_count+1)*NUM_TARGETS)-1:(router_count)*NUM_TARGETS]),

        //============================================== Input Target Bus ===============================================//
        .axi4s_txtvalid     (r_axi4s_txtvalid       ),
        .axi4s_txtready     (w_route_tready[router_count]),
        .axi4s_txtdata      (r_axi4s_txtdata        ),
        .axi4s_txtstrb      (r_axi4s_txtstrb        ),
        .axi4s_txtkeep      (r_axi4s_txtkeep        ),
        .axi4s_txtlast      (r_axi4s_txtlast        ),
        .axi4s_txtid        (r_axi4s_txtid          ),
        .axi4s_txtdest      (r_axi4s_txtdest        ),
        .axi4s_txtuser      (r_axi4s_txtuser        ),

        //============================================== Output Initiator Bus ============================================//
        .axi4s_iytvalid     (w_axi4s_iytvalid[router_count]),
        .axi4s_iytready     (w_axi4s_iytready[router_count]),
        .axi4s_iytdata      (w_axi4s_iytdata[((router_count+1)*TDATA_WIDTH)-1:(router_count)*TDATA_WIDTH]),
        .axi4s_iytstrb      (w_axi4s_iytstrb[((router_count+1)*TDATA_WIDTH/8)-1:(router_count)*TDATA_WIDTH/8]),
        .axi4s_iytkeep      (w_axi4s_iytkeep[((router_count+1)*TDATA_WIDTH/8)-1:(router_count)*TDATA_WIDTH/8]),
        .axi4s_iytlast      (w_axi4s_iytlast[router_count]),
        .axi4s_iytid        (w_axi4s_iytid[((router_count+1)*M_TID_WIDTH)-1:(router_count)*M_TID_WIDTH]),
        .axi4s_iytdest      (w_axi4s_iytdest[((router_count+1)*TDEST_WIDTH)-1:(router_count)*TDEST_WIDTH]),
        .axi4s_iytuser      (w_axi4s_iytuser[((router_count+1)*TUSER_WIDTH)-1:(router_count)*TUSER_WIDTH])
        );
    end // Router_inst_loop
endgenerate

genvar trgt_tready_count;
generate
    for (trgt_tready_count=0; trgt_tready_count<NUM_TARGETS; trgt_tready_count=trgt_tready_count+1)
    begin : trgt_tready_loop
        assign r_axi4s_txtready[trgt_tready_count] = ((|w_route_tready_t[((trgt_tready_count+1)*NUM_INITIATORS)-1:(trgt_tready_count)*NUM_INITIATORS]) & r_axi4s_txtvalid[trgt_tready_count]);
    end // trgt_tready_loop
endgenerate

endmodule  // COREAXI4S_SWITCH.v
