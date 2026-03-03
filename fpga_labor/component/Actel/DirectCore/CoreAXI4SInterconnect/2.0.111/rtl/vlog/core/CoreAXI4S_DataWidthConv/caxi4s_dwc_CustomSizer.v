// *********************************************************************/
// Copyright (c) 2015 Microsemi Corporation.  All rights reserved.
//
// Any use or redistribution in part or in whole must be handled in
// accordance with the Actel license agreement and must be approved
// in advance in writing.
//
// File: caxi4s_dwc_CustomSizer.v
//
// SVN Revision Information:
// SVN $Revision: 40494 $
// SVN $Date: 2022-04-22 20:31:25 +0530 (Fri, 22 Apr 2022) $
//
// Description: Submodule to AXI4 Stream Switch top, perform Upsizing
// and Downsizing
//
// Notes:
// *********************************************************************/
`timescale 1ns / 1ns

module caxi4s_dwc_CustomSizer
#(
    parameter integer SYNC_RESET               = 0,

    parameter integer BYTE_SIZE                = 8,

    parameter integer SRC_TDATA_BYTES          = 3,                   // Defines Source TDATA port width        (1 to 512 Bytes)
    parameter integer DST_TDATA_BYTES          = 4,                   // Defines Destination TDATA port width   (1 to 512 Bytes)
    parameter integer LCM_TDATA_BYTES          = 12,                  // Defines LCM TDATA width                (1 to 261632 Bytes)

    parameter integer SRC_TDATA_WIDTH          = 24,                  // Defines Source TDATA port width        (8 to 4096)
    parameter integer DST_TDATA_WIDTH          = 32,                  // Defines Destination TDATA port width   (8 to 4096)

    parameter integer TUSER_BITS_P_BYTE        = 1,                   // Defines TUSER port bits per TDATA byte (1 to 2048)
    parameter integer SRC_TUSER_WIDTH          = 3,                   // Defines Source TUSER port width        (1 to 512 Bytes)
    parameter integer DST_TUSER_WIDTH          = 4,                   // Defines Destination TUSER port width   (1 to 512 Bytes)

    parameter integer TID_WIDTH                = 1,                   // Defines TID port width                 (1 to 32)
    parameter integer TDEST_WIDTH              = 1,                   // Defines TDEST port width               (1 to 32)

    parameter integer ENABLE_PACKING           = 0                    // Enable Packing (Null Byte Filtering)   (0 , 1)
    )
    (
    //============================================== Global Signals  ===============================================//
    input  wire                                aclk,
    input  wire                                resetn,                // active high reset - async assert and sync to aclk deassert

    //============================================== Input Source Bus ==============================================//
    input  wire                                src_tvalid,
    output                                     src_tready,
    input  wire [SRC_TDATA_WIDTH-1:0]          src_tdata,
    input  wire [SRC_TDATA_WIDTH/8-1:0]        src_tstrb,
    input  wire [SRC_TDATA_WIDTH/8-1:0]        src_tkeep,
    input  wire                                src_tlast,
    input  wire [TID_WIDTH-1:0]                src_tid,
    input  wire [TDEST_WIDTH-1:0]              src_tdest,
    input  wire [SRC_TUSER_WIDTH-1:0]          src_tuser,

    //============================================= Output Destination Bus =========================================//
    output reg                                 dst_tvalid,
    input  wire                                dst_tready,
    output      [DST_TDATA_WIDTH-1:0]          dst_tdata,
    output      [DST_TDATA_WIDTH/8-1:0]        dst_tstrb,
    output      [DST_TDATA_WIDTH/8-1:0]        dst_tkeep,
    output                                     dst_tlast,
    output      [TID_WIDTH-1:0]                dst_tid,
    output      [TDEST_WIDTH-1:0]              dst_tdest,
    output      [DST_TUSER_WIDTH-1:0]          dst_tuser
);
localparam LCM_COUNT_WIDTH  = $clog2(LCM_TDATA_BYTES)+1;
localparam SRC_NUM_TXRS     = LCM_TDATA_BYTES/SRC_TDATA_BYTES;
localparam DST_NUM_TXRS     = LCM_TDATA_BYTES/DST_TDATA_BYTES;
localparam SRC_COUNT_WIDTH  = SRC_NUM_TXRS==1 ? 1 : $clog2(SRC_NUM_TXRS);
localparam DST_COUNT_WIDTH  = DST_NUM_TXRS==1 ? 1 : $clog2(DST_NUM_TXRS);

wire aresetn = (SYNC_RESET==1) ? 1'b1   : resetn;
wire sresetn = (SYNC_RESET==1) ? resetn : 1'b1;

wire src_txr_flag       = src_tvalid & src_tready;
wire dst_txr_flag       = dst_tvalid & dst_tready;
wire dst_last_txr;
wire dst_txr_done;
reg  dst_txr_done_reg;
wire tid_change_flag;
reg  tid_change_reg;
wire add_null_byte;

wire [(LCM_TDATA_BYTES)*BYTE_SIZE                       -1:0] src_tdata_wire;
wire [(LCM_TDATA_BYTES)                                 -1:0] src_tstrb_wire;
wire [(LCM_TDATA_BYTES)                                 -1:0] src_tkeep_wire;
wire [(LCM_TDATA_BYTES)*TUSER_BITS_P_BYTE               -1:0] src_tuser_wire;
wire [(TID_WIDTH)                                       -1:0] src_tid_wire;
wire [(TDEST_WIDTH)                                     -1:0] src_tdest_wire;
                                                        
reg [DST_COUNT_WIDTH                                    -1:0] dst_txr_count;
reg                                                           tlast_in_mid;


reg [(LCM_TDATA_BYTES-SRC_TDATA_BYTES)*BYTE_SIZE        -1:0] src_tdata_reg;
reg [(LCM_TDATA_BYTES-SRC_TDATA_BYTES)                  -1:0] src_tstrb_reg;
reg [(LCM_TDATA_BYTES-SRC_TDATA_BYTES)                  -1:0] src_tkeep_reg;
reg [(LCM_TDATA_BYTES-SRC_TDATA_BYTES)*TUSER_BITS_P_BYTE-1:0] src_tuser_reg;
reg [(TID_WIDTH)                                        -1:0] src_tid_reg;
reg [(TDEST_WIDTH)                                      -1:0] src_tdest_reg;

generate
    if (SRC_NUM_TXRS != 1)
    begin
	    wire src_first_txr;
        wire src_last_txr;
		reg [SRC_COUNT_WIDTH                                    -1:0] src_txr_count;

        always@(posedge aclk or negedge aresetn)
        begin
            if (~aresetn | ~sresetn)
            begin
                tlast_in_mid        <= 1'b0;
                src_txr_count       <= {(SRC_COUNT_WIDTH){1'b0}};
                src_tdata_reg       <= {((LCM_TDATA_BYTES-SRC_TDATA_BYTES)*BYTE_SIZE){1'b0}};
                src_tstrb_reg       <= {(LCM_TDATA_BYTES -SRC_TDATA_BYTES){1'b0}};
                src_tkeep_reg       <= {(LCM_TDATA_BYTES -SRC_TDATA_BYTES){1'b0}};
                src_tuser_reg       <= {((LCM_TDATA_BYTES-SRC_TDATA_BYTES)*TUSER_BITS_P_BYTE){1'b0}};
                src_tid_reg         <= {(TID_WIDTH){1'b0}};
                src_tdest_reg       <= {(TDEST_WIDTH){1'b0}};
            end
            else if (dst_txr_done_reg)
            begin
                tlast_in_mid        <= 1'b0;
                src_txr_count       <= {(SRC_COUNT_WIDTH){1'b0}};
                src_tdata_reg       <= {((LCM_TDATA_BYTES-SRC_TDATA_BYTES)*BYTE_SIZE){1'b0}};
                src_tstrb_reg       <= {(LCM_TDATA_BYTES -SRC_TDATA_BYTES){1'b0}};
                src_tkeep_reg       <= {(LCM_TDATA_BYTES -SRC_TDATA_BYTES){1'b0}};
                src_tuser_reg       <= {((LCM_TDATA_BYTES-SRC_TDATA_BYTES)*TUSER_BITS_P_BYTE){1'b0}};
                src_tid_reg         <= {(TID_WIDTH){1'b0}};
                src_tdest_reg       <= {(TDEST_WIDTH){1'b0}};
            end
            else if (src_txr_flag & ~src_last_txr)
            begin
                src_tdata_reg[src_txr_count*SRC_TDATA_WIDTH  +:SRC_TDATA_WIDTH]     <= src_tdata;
                src_tstrb_reg[src_txr_count*SRC_TDATA_WIDTH/8+:SRC_TDATA_WIDTH/8]   <= src_tstrb;
                src_tkeep_reg[src_txr_count*SRC_TDATA_WIDTH/8+:SRC_TDATA_WIDTH/8]   <= src_tkeep;
                src_tuser_reg[src_txr_count*SRC_TUSER_WIDTH  +:SRC_TUSER_WIDTH]     <= src_tuser;
                src_tid_reg         <= src_tid;
                src_tdest_reg       <= src_tdest;
                tlast_in_mid        <= src_tlast;
                src_txr_count       <= src_tlast ? (SRC_NUM_TXRS - 1'b1) : (src_txr_count + 1'b1);
            end
            else if (tid_change_flag) begin
                src_txr_count       <= (SRC_NUM_TXRS - 1'b1);
            end
            else begin
                tlast_in_mid        <= tlast_in_mid;
                src_txr_count       <= src_txr_count;
                src_tdata_reg       <= src_tdata_reg;
                src_tstrb_reg       <= src_tstrb_reg;
                src_tkeep_reg       <= src_tkeep_reg;
                src_tuser_reg       <= src_tuser_reg;
                src_tid_reg         <= src_tid_reg;
                src_tdest_reg       <= src_tdest_reg;
            end
        end

        assign src_tdata_wire        = {((add_null_byte) ? {SRC_TDATA_BYTES{1'b0}} : (src_tdata)), src_tdata_reg};
        assign src_tstrb_wire        = {((add_null_byte) ? {SRC_TDATA_BYTES{1'b0}} : (src_tstrb)), src_tstrb_reg};
        assign src_tkeep_wire        = {((add_null_byte) ? {SRC_TDATA_BYTES{1'b0}} : (src_tkeep)), src_tkeep_reg};
        assign src_tuser_wire        = {((add_null_byte) ? {SRC_TDATA_BYTES{1'b0}} : (src_tuser)), src_tuser_reg};
        assign src_tid_wire          =   (add_null_byte) ? src_tid_reg             :  src_tid;
        assign src_tdest_wire        =   (add_null_byte) ? src_tdest_reg           :  src_tdest;

        assign src_tready            =   src_first_txr   ? 1'b1    :
                                         src_last_txr    ? (~tlast_in_mid & ~tid_change_reg & dst_txr_done_reg) : ~tid_change_flag;
        assign dst_tlast             =  dst_last_txr & dst_tvalid & (src_tlast | tlast_in_mid);
        assign tid_change_flag       =  (~src_first_txr && src_tvalid && (src_tid != src_tid_reg)) ? 1'b1 : 1'b0;
        assign add_null_byte         =  (tid_change_reg | tlast_in_mid);

        always@(posedge aclk or negedge aresetn)
        begin
            if (~aresetn | ~sresetn) begin
                tid_change_reg   <= 1'b0;
            end
            else if (dst_txr_done_reg) begin
                tid_change_reg   <= 1'b0;
            end
            else if (tid_change_flag) begin
                tid_change_reg   <= 1'b1;
            end
            else begin
                tid_change_reg   <= tid_change_reg;
            end
        end

        always@(posedge aclk or negedge aresetn)
        begin
            if (~aresetn | ~sresetn) begin
                dst_tvalid   <= 1'b0;
            end
            else if (dst_txr_done) begin
                dst_tvalid   <= 1'b0;
            end
            else if (src_tvalid & ((~src_last_txr & src_tlast) | (src_last_txr & ~dst_txr_done_reg))) begin
                dst_tvalid   <= 1'b1;
            end
            else begin
                dst_tvalid   <= dst_tvalid;
            end
        end

        assign src_first_txr = ~(|src_txr_count);
        assign src_last_txr  = (src_txr_count  == (SRC_NUM_TXRS - 1));		

    end
    else
    begin
        assign src_tdata_wire        = src_tdata;
        assign src_tstrb_wire        = src_tstrb;
        assign src_tkeep_wire        = src_tkeep;
        assign src_tuser_wire        = src_tuser;
        assign src_tid_wire          = src_tid;
        assign src_tdest_wire        = src_tdest;

        assign src_tready            = dst_txr_done_reg;
        assign dst_tlast             = dst_last_txr & dst_tvalid & src_tlast;

        always@(*)
        begin
            dst_tvalid               = src_tvalid & ~dst_txr_done_reg;
        end
    end
endgenerate

always@(posedge aclk or negedge aresetn)
begin
    if (~aresetn | ~sresetn) begin
        dst_txr_count   <= {(DST_COUNT_WIDTH){1'b0}};
    end
    else if (dst_txr_done) begin
        dst_txr_count   <= {(DST_COUNT_WIDTH){1'b0}};
    end
    else if (dst_txr_flag) begin
        dst_txr_count   <= dst_txr_count + 1'b1;
    end
    else begin
        dst_txr_count   <= dst_txr_count;
    end
end


assign dst_last_txr  = (dst_txr_count  == (DST_NUM_TXRS - 1));
assign dst_txr_done  = (dst_last_txr)  &  (dst_txr_flag);

always@(posedge aclk or negedge aresetn)
begin
    if (~aresetn | ~sresetn) begin
        dst_txr_done_reg   <= 1'b0;
    end
    else begin
        dst_txr_done_reg   <= dst_txr_done;
    end
end

assign dst_tdata     = dst_tvalid    ? src_tdata_wire[dst_txr_count*DST_TDATA_WIDTH  +:DST_TDATA_WIDTH  ] : {DST_TDATA_WIDTH{1'b0}};
assign dst_tstrb     = dst_tvalid    ? src_tstrb_wire[dst_txr_count*DST_TDATA_WIDTH/8+:DST_TDATA_WIDTH/8] : {DST_TDATA_WIDTH/8{1'b0}};
assign dst_tkeep     = dst_tvalid    ? src_tkeep_wire[dst_txr_count*DST_TDATA_WIDTH/8+:DST_TDATA_WIDTH/8] : {DST_TDATA_WIDTH/8{1'b0}};
assign dst_tuser     = dst_tvalid    ? src_tuser_wire[dst_txr_count*DST_TUSER_WIDTH  +:DST_TUSER_WIDTH  ] : {DST_TUSER_WIDTH{1'b0}};
assign dst_tid       = dst_tvalid    ? src_tid_wire   : {TID_WIDTH  {1'b0}};
assign dst_tdest     = dst_tvalid    ? src_tdest_wire : {TDEST_WIDTH{1'b0}};

endmodule  //caxi4s_dwc_CustomSizer
