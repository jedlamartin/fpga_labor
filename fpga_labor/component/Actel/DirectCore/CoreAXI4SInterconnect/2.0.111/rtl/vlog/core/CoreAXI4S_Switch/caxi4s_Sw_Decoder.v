// *********************************************************************/
// Copyright (c) 2015 Microsemi Corporation.  All rights reserved.
//
// Any use or redistribution in part or in whole must be handled in
// accordance with the Actel license agreement and must be approved
// in advance in writing.
//
// File: caxi4s_Sw_Decoder.v
//
// SVN Revision Information:
// SVN $Revision: 40502 $
// SVN $Date: 2022-04-26 20:36:05 +0530 (Tue, 26 Apr 2022) $
// SVN $URL: svn://owl/IP/soft/DirectCores/CoreAXI4S_Switch/trunk/rtl/vlog/core/caxi4s_Sw_Decoder.v $
//
// Description: Submodule to AXI4 Stream Switch top, it monitor TVALID and TDEST
// from all the Target Ports and validate to generate valid request output for arbitration
//
// Notes:
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4s_Sw_Decoder
#(
    parameter integer  INTEGER_SIZE               = 32,
    parameter integer  NUM_INITIATORS             = 8,                                           // Defines number of Initiator Ports      (1 to 8)
    parameter integer  NUM_INITIATORS_WIDTH       = 3,                         
    parameter integer  MAX_INITIATORS             = 8,                         
    parameter integer  TDEST_WIDTH                = 1,                                           // Defines Target TDEST port width        (1 to 32)

    parameter [MAX_INITIATORS-1:0]                TRx_IRy_LINK   = 8'b11111111,                  // Connectivity                           (0 , 1)
    parameter [NUM_INITIATORS*INTEGER_SIZE-1:0]   IRy_TDEST_BASE = 32'd0,                        // Initiator port TDEST Base
    parameter [NUM_INITIATORS*INTEGER_SIZE-1:0]   IRy_TDEST_HIGH = 32'd0                         // Initiator port TDEST High
    )
    (
    input  wire                                   trgt_tvalid,
    input  wire [TDEST_WIDTH               -1:0]  trgt_tdest,

    output wire [NUM_INITIATORS-1:0]              valid_req,
    //output wire [NUM_INITIATORS_WIDTH-1:0]        req_itor_index,
    output wire                                   decode_err
);

wire  [NUM_INITIATORS-1:0] req;


//assign req_itor_index = fnc_hot2enc(valid_req);
assign decode_err    = (~(|req)) && trgt_tvalid;

genvar count;
generate
    for (count = 0; count < NUM_INITIATORS; count = count + 1)
    begin : compare_count_loop
        assign req[count]       = (trgt_tdest >= IRy_TDEST_BASE[(count+1)*INTEGER_SIZE-1:count*INTEGER_SIZE]) && (trgt_tdest <= IRy_TDEST_HIGH[(count+1)*INTEGER_SIZE-1:count*INTEGER_SIZE]) ? 1'b1 : 1'b0;
        assign valid_req[count] = trgt_tvalid && req[count] && TRx_IRy_LINK[count];
    end
endgenerate
endmodule