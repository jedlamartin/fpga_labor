// *********************************************************************/
// Copyright (c) 2015 Microsemi Corporation.  All rights reserved.
//
// Any use or redistribution in part or in whole must be handled in
// accordance with the Actel license agreement and must be approved
// in advance in writing.
//
// File: caxi4s_Sw_RegisterSlice.v
//
// SVN Revision Information:
// SVN $Revision: 40502 $
// SVN $Date: 2022-04-26 20:36:05 +0530 (Tue, 26 Apr 2022) $
// SVN $URL: svn://owl/IP/soft/DirectCores/CoreAXI4S_Switch/trunk/rtl/vlog/core/caxi4s_Sw_RegisterSlice.v $
//
// Description: This file provides an RegisterSlice for an AXI4 stream Port.
//
// Notes:
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4s_Sw_RegisterSlice #
(
    parameter integer SYNC_RESET       = 0,
    parameter integer ENABLE_RS        = 1,            // 0 means no slice on channel - 1 means full slice on channel

    parameter integer TID_WIDTH        = 1,            // Defines TID port width                 (1 to 32)
    parameter integer TDEST_WIDTH      = 1,            // Defines TDEST port width               (1 to 32)
    parameter integer TDATA_WIDTH      = 32,           // Defines TDATA port width               (8 to 4096)
    parameter integer TUSER_WIDTH      = 1             // Defines TUSER port width               (1 to 512 Bytes)
)
(

    //=====================================  Global Signals   ========================================================================
    input  wire                               aclk,
    input  wire                               resetn,

    //================================================= Source Port ==================================================//
    // AXI4 Stream interface
    input  wire                               src_tvalid,
    output wire                               src_tready,
    input  wire [TDATA_WIDTH-1:0]             src_tdata,
    input  wire [TDATA_WIDTH/8-1:0]           src_tstrb,
    input  wire [TDATA_WIDTH/8-1:0]           src_tkeep,
    input  wire                               src_tlast,
    input  wire [TID_WIDTH-1:0]               src_tid,
    input  wire [TDEST_WIDTH-1:0]             src_tdest,
    input  wire [TUSER_WIDTH-1:0]             src_tuser,

    //============================================== Destination Port ===============================================//
    // AXI4 Stream interface 
    output wire                               dst_tvalid,
    input  wire                               dst_tready,
    output wire [TDATA_WIDTH-1:0]             dst_tdata,
    output wire [TDATA_WIDTH/8-1:0]           dst_tstrb,
    output wire [TDATA_WIDTH/8-1:0]           dst_tkeep,
    output wire                               dst_tlast,
    output wire [TID_WIDTH-1:0]               dst_tid,
    output wire [TDEST_WIDTH-1:0]             dst_tdest,
    output wire [TUSER_WIDTH-1:0]             dst_tuser
);

//===================================================================================================================

generate
    if ( ENABLE_RS == 0 )          // Channel - direct connection, no Register Slice
    begin           
        assign src_tready  = dst_tready;
        assign dst_tvalid  = src_tvalid;
        assign dst_tdata   = src_tdata;
        assign dst_tstrb   = src_tstrb;
        assign dst_tkeep   = src_tkeep;
        assign dst_tlast   = src_tlast;
        assign dst_tid     = src_tid;
        assign dst_tdest   = src_tdest;
        assign dst_tuser   = src_tuser;
    end
    else if ( ENABLE_RS == 1 )     // Channel - Register Slice
    begin
        //=====================================================================================
        // Channel signal bus
        //=====================================================================================
        localparam CHANNEL_WIDTH = TDATA_WIDTH+(TDATA_WIDTH/8)+(TDATA_WIDTH/8)+1+TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH; //  the number of channel signals to register (outside of Valid & Ready)
    
        wire [CHANNEL_WIDTH-1:0] src_channel, dst_channel;
    
        assign src_channel = {    src_tdata, src_tstrb, src_tkeep, src_tlast, src_tid, src_tdest, src_tuser};
    
        caxi4s_Sw_RegSliceFull 
        #(
            .SYNC_RESET     (SYNC_RESET     ),
            .CHANNEL_WIDTH  (CHANNEL_WIDTH  )
         )
        caxi4s_Sw_RegSliceFull_inst
        (
            .aclk           (aclk           ),
            .resetn         (resetn         ),                      
            .mDat           (src_channel    ),      // channel data signals to register from "master" or "source"
            .mValid         (src_tvalid     ),      // indicates when mDat is valid
            .mReady         (src_tready     ),      // indicates when taking data from "master" or "source"
            .sDat           (dst_channel    ),      // channel data signals registered to "slave" or "sink"
            .sValid         (dst_tvalid     ),      // indicates when sDat is valid
            .sReady         (dst_tready     )       // indicates when slave/sink taking sDat
        );

        assign dst_tdata  = dst_channel[TDATA_WIDTH+(TDATA_WIDTH/8)+(TDATA_WIDTH/8)+1+TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH-1:(TDATA_WIDTH/8)+(TDATA_WIDTH/8)+1+TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH];
        assign dst_tstrb  = dst_channel[            (TDATA_WIDTH/8)+(TDATA_WIDTH/8)+1+TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH-1:                (TDATA_WIDTH/8)+1+TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH];
        assign dst_tkeep  = dst_channel[                            (TDATA_WIDTH/8)+1+TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH-1:                                1+TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH];
        assign dst_tlast  = dst_channel[                                            1+TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH-1:                                  TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH];
        assign dst_tid    = dst_channel[                                              TID_WIDTH+TDEST_WIDTH+TUSER_WIDTH-1:                                            TDEST_WIDTH+TUSER_WIDTH];
        assign dst_tdest  = dst_channel[                                                        TDEST_WIDTH+TUSER_WIDTH-1:                                                        TUSER_WIDTH];
        assign dst_tuser  = dst_channel[                                                                    TUSER_WIDTH-1:                                                                  0];
    end 
endgenerate
endmodule       // caxi4s_Sw_RegisterSlice.v
