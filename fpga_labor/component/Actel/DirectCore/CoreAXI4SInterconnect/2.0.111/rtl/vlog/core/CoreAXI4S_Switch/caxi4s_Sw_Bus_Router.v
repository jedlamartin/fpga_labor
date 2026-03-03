// *********************************************************************/
// Copyright (c) 2015 Microsemi Corporation.  All rights reserved.
//
// Any use or redistribution in part or in whole must be handled in
// accordance with the Actel license agreement and must be approved
// in advance in writing.
//
// File: caxi4s_Sw_Bus_Router.v
//
// SVN Revision Information:
// SVN $Revision: 39705 $
// SVN $Date: 2021-12-17 15:13:54 +0530 (Fri, 17 Dec 2021) $
//
// Description: Submodule to AXI4 Stream Switch top, it route Target Port bus signals 
// to Initiator port
//
// Notes:
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4s_Sw_Bus_Router
#(
    parameter integer  INTEGER_SIZE               = 32,
    parameter integer  NUM_TARGETS                = 8,                   // Defines number of Target Ports         (1 to 8)
    parameter integer  NUM_TARGETS_WIDTH          = 3,
    parameter integer  TDATA_WIDTH                = 32,                  // Defines TDATA port width               (8 to 4096)
    parameter integer  TID_WIDTH                  = 1,                   // Defines TID port width                 (1 to 32)
    parameter integer  TDEST_WIDTH                = 2,                   // Defines TDEST port width               (1 to 32)
    parameter integer  TUSER_WIDTH                = 1,                   // Defines TUSER port width               (1 to 512 Bytes)
    parameter integer  M_TID_WIDTH                = 2                    // Defines Initiator TID port width       (1 to 32)
    )
    (
    //============================================== Input Control Port =============================================//
    input  wire                                        trgt_sel_valid,
    input  wire [(NUM_TARGETS)-1:0]                    trgt_sel,

    //============================================== Input Target Bus ===============================================//
    input  wire [NUM_TARGETS-1:0]                      axi4s_txtvalid,
    output reg  [NUM_TARGETS-1:0]                      axi4s_txtready,
    input  wire [NUM_TARGETS*TDATA_WIDTH-1:0]          axi4s_txtdata,
    input  wire [NUM_TARGETS*TDATA_WIDTH/8-1:0]        axi4s_txtstrb,
    input  wire [NUM_TARGETS*TDATA_WIDTH/8-1:0]        axi4s_txtkeep,
    input  wire [NUM_TARGETS-1:0]                      axi4s_txtlast,
    input  wire [NUM_TARGETS*TID_WIDTH-1:0]            axi4s_txtid,
    input  wire [NUM_TARGETS*TDEST_WIDTH-1:0]          axi4s_txtdest,
    input  wire [NUM_TARGETS*TUSER_WIDTH-1:0]          axi4s_txtuser,

    //============================================= Output Initiator Bus =============================================//
    output reg                                         axi4s_iytvalid,
    input  wire                                        axi4s_iytready,
    output reg  [TDATA_WIDTH-1:0]                      axi4s_iytdata,
    output reg  [TDATA_WIDTH/8-1:0]                    axi4s_iytstrb,
    output reg  [TDATA_WIDTH/8-1:0]                    axi4s_iytkeep,
    output reg                                         axi4s_iytlast,
    output reg  [M_TID_WIDTH-1:0]                      axi4s_iytid,
    output reg  [TDEST_WIDTH-1:0]                      axi4s_iytdest,
    output reg  [TUSER_WIDTH-1:0]                      axi4s_iytuser
);

wire  [NUM_TARGETS_WIDTH-1:0] trgt_selEnc;

function [NUM_TARGETS_WIDTH-1:0] fnc_hot2enc (input [NUM_TARGETS-1:0]  one_hot);
    begin
        fnc_hot2enc[0] = |(one_hot & 8'b1010_1010);
        fnc_hot2enc[1] = |(one_hot & 8'b1100_1100);
        fnc_hot2enc[2] = |(one_hot & 8'b1111_0000);
        //fnc_hot2enc[3] = |(one_hot & 16'b1111_1111_0000_0000);
    end
endfunction

assign  trgt_selEnc    = fnc_hot2enc(trgt_sel);

always @(*)
begin
    if (trgt_sel_valid)
    begin
        axi4s_iytvalid = axi4s_txtvalid[trgt_selEnc];
        axi4s_iytdata  = axi4s_txtdata [(TDATA_WIDTH*trgt_selEnc)+:TDATA_WIDTH];
        axi4s_iytstrb  = axi4s_txtstrb [(TDATA_WIDTH/8*trgt_selEnc)+:TDATA_WIDTH/8];
        axi4s_iytkeep  = axi4s_txtkeep [(TDATA_WIDTH/8*trgt_selEnc)+:TDATA_WIDTH/8];
        axi4s_iytlast  = axi4s_txtlast [trgt_selEnc];
        axi4s_iytid    = {trgt_selEnc,axi4s_txtid[(TID_WIDTH*trgt_selEnc)+:TID_WIDTH]};
        axi4s_iytdest  = axi4s_txtdest [(TDEST_WIDTH*trgt_selEnc)+:TDEST_WIDTH];
        axi4s_iytuser  = axi4s_txtuser [(TUSER_WIDTH*trgt_selEnc)+:TUSER_WIDTH];
        
        axi4s_txtready              = {NUM_TARGETS{1'b0}};
        axi4s_txtready[trgt_selEnc] = axi4s_iytready;
    end
    else
    begin
        axi4s_iytvalid  = 1'b0;
        axi4s_iytdata   = {(TDATA_WIDTH){1'b0}};
        axi4s_iytstrb   = {(TDATA_WIDTH/8){1'b0}};
        axi4s_iytkeep   = {(TDATA_WIDTH/8){1'b0}};
        axi4s_iytlast   = 1'b0;
        axi4s_iytid     = {(M_TID_WIDTH){1'b0}};
        axi4s_iytdest   = {(TDEST_WIDTH){1'b0}};
        axi4s_iytuser   = {(TUSER_WIDTH){1'b0}};

        axi4s_txtready  = {(NUM_TARGETS){1'b0}};
    end
end
 endmodule