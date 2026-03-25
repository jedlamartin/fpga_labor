// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2024 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 
// SVN $Date: 
//
// IP Core : CoreAXI4SInterconnect
//
// Module  : COREFIFO_AXI4S_TARGET_IF
//
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP.
// Notes    :
// ******************************************************************************************************/

`timescale 1ns / 100ps

module caxi4pc_axi4s_target_if (
    S_AXIS_ACLK_i,
    S_AXIS_ARESETN_i,
    //Target Port Interface Signals
    S_AXIS_TVALID_i,
    S_AXIS_TREADY_o,
    S_AXIS_TDATA_i,
    S_AXIS_TSTRB_i,
    S_AXIS_TKEEP_i,
    S_AXIS_TID_i,
    S_AXIS_TDEST_i,
    S_AXIS_TUSER_i,
    S_AXIS_TLAST_i,

    FIFO_WR_DATA_AXIS_o,
    FIFO_WE_EN_AXIS_o,
    S_AXIS_TLAST_o,
    CUR_RD_TRANS_DONE_i,
    FIFO_FULL_i,
	sop,
	eop,
	tlast_dis
);

  parameter RESET_TYPE = 0;
  parameter NUM_STAGES = 2;
  parameter READ_MODE = 0;

  parameter TTDATA_WIDTH = 512;
  parameter TTID_WIDTH = 32;
  parameter TTDEST_WIDTH = 32;
  parameter TTUSER_WIDTH = 4096;

  parameter ITDATA_WIDTH = 512;
  parameter ITID_WIDTH = 32;
  parameter ITDEST_WIDTH = 32;
  parameter ITUSER_WIDTH = 4096;

  parameter WIDTH_CORE = 9281;

  parameter ENABLE_TSTRB = 1;
  parameter ENABLE_TKEEP = 1;
  parameter ENABLE_TLAST = 1;
  parameter ENABLE_TUSER = 1;
  parameter ENABLE_TDEST = 1;
  parameter ENABLE_TID = 1;
  parameter PKT_DROP_OVF = 0;

  parameter [0:0] UPDN_CNV = 0;
  parameter [7:0] DNCNV_RATIO = 2;
  parameter [7:0] UPCNV_RATIO = 2;

  input S_AXIS_ACLK_i;
  input S_AXIS_ARESETN_i;
  //Target Port Interface Signals
  input S_AXIS_TVALID_i;
  output S_AXIS_TREADY_o;
  input [TTDATA_WIDTH-1:0] S_AXIS_TDATA_i;
  input [(TTDATA_WIDTH/8)-1:0] S_AXIS_TSTRB_i;
  input [(TTDATA_WIDTH/8)-1:0] S_AXIS_TKEEP_i;
  input [TTID_WIDTH-1:0] S_AXIS_TID_i;
  input [TTDEST_WIDTH-1:0] S_AXIS_TDEST_i;
  input [TTUSER_WIDTH-1:0] S_AXIS_TUSER_i;
  input S_AXIS_TLAST_i;


  output [WIDTH_CORE-1:0] FIFO_WR_DATA_AXIS_o;
  output FIFO_WE_EN_AXIS_o;
  output S_AXIS_TLAST_o;
  input CUR_RD_TRANS_DONE_i;
  input FIFO_FULL_i;

  output sop;
  output eop;
  input  tlast_dis;

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  localparam TTSTRB_OFFSET = TTDATA_WIDTH;
  localparam TTKEEP_OFFSET = TTSTRB_OFFSET + (ENABLE_TSTRB ? (TTDATA_WIDTH / 8) : 0);
  localparam TTLAST_OFFSET = TTKEEP_OFFSET + (ENABLE_TKEEP ? (TTDATA_WIDTH / 8) : 0);
  localparam TTID_OFFSET   = TTLAST_OFFSET + (ENABLE_TLAST ? 1 : 0);
  localparam TTDEST_OFFSET = TTID_OFFSET + (ENABLE_TID ? TTID_WIDTH : 0);
  localparam TTUSER_OFFSET = TTDEST_OFFSET + (ENABLE_TDEST ? TTDEST_WIDTH : 0);
  localparam TTWIDTH       = TTUSER_OFFSET + (ENABLE_TUSER ? TTUSER_WIDTH : 0);

  localparam ITSTRB_OFFSET = ITDATA_WIDTH;
  localparam ITKEEP_OFFSET = ITSTRB_OFFSET + (ENABLE_TSTRB ? (ITDATA_WIDTH / 8) : 0);
  localparam ITLAST_OFFSET = ITKEEP_OFFSET + (ENABLE_TKEEP ? (ITDATA_WIDTH / 8) : 0);
  localparam ITID_OFFSET   = ITLAST_OFFSET + (ENABLE_TLAST ? 1 : 0);
  localparam ITDEST_OFFSET = ITID_OFFSET + (ENABLE_TID ? ITID_WIDTH : 0);
  localparam ITUSER_OFFSET = ITDEST_OFFSET + (ENABLE_TDEST ? ITDEST_WIDTH : 0);
  localparam ITWIDTH       = ITUSER_OFFSET + (ENABLE_TUSER ? ITUSER_WIDTH : 0);

  wire                    S_AXIS_TREADY_s;
  wire [WIDTH_CORE-1:0]   s_axi4s_data;
  reg                     s_up_cnv_cnt;
  reg                     dummy_fifo_wrreq;
  reg  [TTUSER_WIDTH-1:0] s_axis_tuser_reg;


  wire                   aresetn;
  wire                   sresetn;

  genvar i;
  generate
    if (~UPDN_CNV) begin : gen_axi4s_target_dn_cnv
      for (i = 0; i < DNCNV_RATIO; i=i+1) begin
        assign s_axi4s_data[(i*ITWIDTH) +: ITDATA_WIDTH]                      = S_AXIS_TDATA_i[(i*ITDATA_WIDTH) +: ITDATA_WIDTH];
        //if (ENABLE_TSTRB) assign s_axi4s_data[(i*ITWIDTH)+ITSTRB_OFFSET +: (ITDATA_WIDTH/8)]  = S_AXIS_TSTRB_i[(i*(ITDATA_WIDTH/8)) +: (ITDATA_WIDTH/8)];
        if (ENABLE_TKEEP)
          assign s_axi4s_data[(i*ITWIDTH)+ITKEEP_OFFSET +: (ITDATA_WIDTH/8)]  = S_AXIS_TKEEP_i[(i*(ITDATA_WIDTH/8)) +: (ITDATA_WIDTH/8)];
        if (ENABLE_TLAST)
          assign s_axi4s_data[(i*ITWIDTH)+ITLAST_OFFSET +: 1]                 = (i == DNCNV_RATIO-1) ? S_AXIS_TLAST_i : 1'b0;
        //if (ENABLE_TID)
        //  assign s_axi4s_data[(i*ITWIDTH)+ITID_OFFSET   +: ITID_WIDTH]        = S_AXIS_TID_i[(i*ITID_WIDTH) +: ITID_WIDTH];
        //if (ENABLE_TDEST)
        //  assign s_axi4s_data[(i*ITWIDTH)+ITDEST_OFFSET +: ITDEST_WIDTH]      = S_AXIS_TDEST_i[(i*ITDEST_WIDTH) +: ITDEST_WIDTH];
        if (ENABLE_TUSER)
          assign s_axi4s_data[(i*ITWIDTH)+ITUSER_OFFSET +: ITUSER_WIDTH]      =  S_AXIS_TUSER_i[(i*ITUSER_WIDTH) +: ITUSER_WIDTH];
      end
    end else if (UPDN_CNV) begin : gen_axi4s_target_up_cnv
      assign s_axi4s_data[TTDATA_WIDTH-1:0]                    = ~dummy_fifo_wrreq ? S_AXIS_TDATA_i : {TTDATA_WIDTH{1'b0}};
      //if (ENABLE_TSTRB)
      //  assign s_axi4s_data[TTSTRB_OFFSET +: (TTDATA_WIDTH/8)]  = ~dummy_fifo_wrreq ? S_AXIS_TSTRB_i : {TTDATA_WIDTH/8{1'b0}};
      if (ENABLE_TKEEP)
        assign s_axi4s_data[TTKEEP_OFFSET +: (TTDATA_WIDTH/8)]  = ~dummy_fifo_wrreq ? S_AXIS_TKEEP_i : {TTDATA_WIDTH/8{1'b0}};
      if (ENABLE_TLAST)
        assign s_axi4s_data[TTLAST_OFFSET]                     = ~dummy_fifo_wrreq ? S_AXIS_TLAST_i & s_up_cnv_cnt : 1'b1;
      //if (ENABLE_TID)
      //  assign s_axi4s_data[TTID_OFFSET   +: TTID_WIDTH]        = ~dummy_fifo_wrreq ? S_AXIS_TID_i;
      //if (ENABLE_TDEST)
      //  assign s_axi4s_data[TTDEST_OFFSET +: TTDEST_WIDTH]      = ~dummy_fifo_wrreq ? S_AXIS_TDEST_i;
      if (ENABLE_TUSER)
        assign s_axi4s_data[TTUSER_OFFSET +: TTUSER_WIDTH]      = ~dummy_fifo_wrreq ? S_AXIS_TUSER_i : s_axis_tuser_reg;
    end else begin : gen_axi4s_target_eq_width
      assign s_axi4s_data[TTDATA_WIDTH-1:0] = S_AXIS_TDATA_i;
      if (ENABLE_TSTRB) assign s_axi4s_data[TTSTRB_OFFSET+:(TTDATA_WIDTH/8)] = S_AXIS_TSTRB_i;
      if (ENABLE_TKEEP) assign s_axi4s_data[TTKEEP_OFFSET+:(TTDATA_WIDTH/8)] = S_AXIS_TKEEP_i;
      if (ENABLE_TLAST) assign s_axi4s_data[TTLAST_OFFSET]                   = S_AXIS_TLAST_i;
      if (ENABLE_TID)   assign s_axi4s_data[TTID_OFFSET+:TTID_WIDTH]         = S_AXIS_TID_i;
      if (ENABLE_TDEST) assign s_axi4s_data[TTDEST_OFFSET+:TTDEST_WIDTH]     = S_AXIS_TDEST_i;
      if (ENABLE_TUSER) assign s_axi4s_data[TTUSER_OFFSET+:TTUSER_WIDTH]     = S_AXIS_TUSER_i;
    end
  endgenerate

  assign aresetn             = (RESET_TYPE == 1) ? 1'b1 : S_AXIS_ARESETN_i;
  assign sresetn             = (RESET_TYPE == 1) ? S_AXIS_ARESETN_i : 1'b1;


  assign S_AXIS_TREADY_s     = PKT_DROP_OVF ? 1'b1: ~FIFO_FULL_i;
  assign S_AXIS_TREADY_o     = S_AXIS_TREADY_s;
  assign FIFO_WR_DATA_AXIS_o = s_axi4s_data;
  assign FIFO_WE_EN_AXIS_o   = (S_AXIS_TREADY_s & (S_AXIS_TVALID_i | dummy_fifo_wrreq));

  always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
    if ((!aresetn) || (!sresetn)) s_up_cnv_cnt <= 1'b0;
    else if(UPDN_CNV) begin
      if ((FIFO_WE_EN_AXIS_o & S_AXIS_TLAST_i) | dummy_fifo_wrreq) s_up_cnv_cnt <= 1'b0;
      else if (FIFO_WE_EN_AXIS_o) s_up_cnv_cnt <= ~s_up_cnv_cnt;
    end else
      s_up_cnv_cnt <= 1'b0;
  end

  always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
    if ((!aresetn) || (!sresetn)) dummy_fifo_wrreq <= 1'b0;
    else if(UPDN_CNV) begin
      if (FIFO_WE_EN_AXIS_o & S_AXIS_TLAST_i & ~s_up_cnv_cnt) dummy_fifo_wrreq <= 1'b1;
      else if (S_AXIS_TREADY_s) dummy_fifo_wrreq <= 1'b0;
    end
    else
      dummy_fifo_wrreq <= 1'b0;
    end

  always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
    if ((!aresetn) || (!sresetn)) s_axis_tuser_reg <= {TTUSER_WIDTH{1'b0}};
    else if (FIFO_WE_EN_AXIS_o & S_AXIS_TLAST_i & ~s_up_cnv_cnt & UPDN_CNV)
      s_axis_tuser_reg <= S_AXIS_TUSER_i;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  generate
    if (READ_MODE == 1) begin
      reg  [11:0] tlast_count;
      reg         first_tlast;
      reg         first_tlast_s;
      reg         tlast_en;
      reg         CUR_RD_TRANS_DONE_d;
      wire        S_AXIS_TLAST_s;
      reg         tlast_en_ctrl;

      assign S_AXIS_TLAST_s     = (S_AXIS_TREADY_s==1'b1 && S_AXIS_TVALID_i == 1'b1 && S_AXIS_TLAST_i ==1'b1 && ~tlast_dis) ? 1'b1 : 1'b0 ;

      always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
        if ((!aresetn) || (!sresetn)) tlast_en_ctrl <= 1'd0;
        else if (tlast_count < 1) tlast_en_ctrl <= S_AXIS_TLAST_s & CUR_RD_TRANS_DONE_d;
        else tlast_en_ctrl <= 1'd0;
      end

      always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
        if ((!aresetn) || (!sresetn)) begin
          tlast_count <= 12'd0;
        end else begin
          if (S_AXIS_TLAST_s == 1'b1 && CUR_RD_TRANS_DONE_i == 1'b1) begin
            tlast_count <= tlast_count;
          end else if (S_AXIS_TLAST_s == 1'b1 && CUR_RD_TRANS_DONE_i == 1'b0) begin
            tlast_count <= tlast_count + 1'b1;
          end else if (S_AXIS_TLAST_s == 1'b0 && CUR_RD_TRANS_DONE_i == 1'b1) begin
            tlast_count <= tlast_count - 1'b1;
          end else begin
            tlast_count <= tlast_count;
          end
        end
      end

      always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
        if ((!aresetn) || (!sresetn)) begin
          first_tlast   <= 1'b0;
          first_tlast_s <= 1'b0;
        end else begin
          if (S_AXIS_TLAST_s == 1'b1 && first_tlast == 1'b0) begin
            first_tlast   <= 1'b1;
            first_tlast_s <= 1'b1;
          end else if ((tlast_count == 0) & ~S_AXIS_TLAST_s) begin
            first_tlast <= 1'b0;
          end else begin
            first_tlast_s <= 1'b0;
          end
        end
      end


      always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
        if ((!aresetn) || (!sresetn)) begin
          tlast_en <= 1'b0;
          CUR_RD_TRANS_DONE_d <= 1'b0;
        end else begin
          CUR_RD_TRANS_DONE_d <= CUR_RD_TRANS_DONE_i;
          if (first_tlast_s == 1'b1) begin
            tlast_en <= 1'b1;
          end else if (tlast_count > 'd0 && (CUR_RD_TRANS_DONE_d == 1'b1 || tlast_en_ctrl)) begin
            tlast_en <= 1'b1;
          end else if (tlast_count > 'd0 && CUR_RD_TRANS_DONE_d == 1'b0) begin
            tlast_en <= 1'b0;
          end else begin
            tlast_en <= 1'b0;
          end
        end
      end
      assign S_AXIS_TLAST_o = tlast_en;
    end else begin
      assign S_AXIS_TLAST_o = 0;
    end
  endgenerate

// Generation of Start of packet and end of packet
  generate
    if (READ_MODE == 1) begin
      reg 	sop_ctrl;
	
	  assign eop 		= S_AXIS_TVALID_i & S_AXIS_TREADY_o & S_AXIS_TLAST_i ;
	  assign sop  		= sop_ctrl & S_AXIS_TVALID_i;
	
	  always@(posedge S_AXIS_ACLK_i or negedge aresetn) begin
       if(~aresetn | ~sresetn) 						sop_ctrl    <= 1'b1;
	   else if(S_AXIS_TLAST_i & S_AXIS_TREADY_o)	sop_ctrl    <= 1'b1;
	   else if(sop & S_AXIS_TREADY_o)				sop_ctrl    <= 1'b0;
	  end
    end
  endgenerate
endmodule
