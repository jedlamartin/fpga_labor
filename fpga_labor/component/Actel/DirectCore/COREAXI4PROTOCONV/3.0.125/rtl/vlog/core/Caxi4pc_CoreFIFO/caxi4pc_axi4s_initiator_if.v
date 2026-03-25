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
// Module  : COREFIFO_AXI4S_INITIATOR_IF
//
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP.
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 100ps

module caxi4pc_axi4s_initiator_if
   (
      M_AXIS_ACLK_i,
      M_AXIS_ARESETN_i,
      //Initiator Port Interface Signals
      M_AXIS_TVALID_o,
      M_AXIS_TREADY_i,
      M_AXIS_TDATA_o,
      M_AXIS_TSTRB_o,
      M_AXIS_TKEEP_o,
      M_AXIS_TID_o,
      M_AXIS_TDEST_o,
      M_AXIS_TUSER_o,
      M_AXIS_TLAST_o,

      FIFO_RD_DATA_AXIS_i,
      FIFO_RD_EN_AXIS_o,
      CUR_RD_TRANS_DONE_o,
      TLAST_EN_i,
      FIFO_EMPTY_i
   );

      parameter                           RESET_TYPE    = 0;
      parameter                           NUM_STAGES    = 2;
      parameter                           READ_MODE     = 1;
      parameter                           PIPE          = 1;
      parameter                           ECC           = 0;

      parameter                           TTDATA_WIDTH   = 512;
      parameter                           TTID_WIDTH     = 32;
      parameter                           TTDEST_WIDTH   = 32;
      parameter                           TTUSER_WIDTH   = 4096;

      parameter                           ITDATA_WIDTH   = 512;
      parameter                           ITID_WIDTH     = 32;
      parameter                           ITDEST_WIDTH   = 32;
      parameter                           ITUSER_WIDTH   = 4096;

      parameter                           WIDTH_CORE   = 9281;

      parameter                           ENABLE_TSTRB     = 1;
      parameter                           ENABLE_TKEEP     = 1;
      parameter                           ENABLE_TLAST     = 1;
      parameter                           ENABLE_TUSER     = 1;
      parameter                           ENABLE_TDEST     = 1;
      parameter                           ENABLE_TID       = 1;

      parameter   [0:0]                   UPDN_CNV         = 0;
      parameter   [7:0]                   DNCNV_RATIO      = 2;
      parameter   [7:0]                   UPCNV_RATIO      = 2;
	  
      parameter   [7:0]                   EOP_OFFSET       = 8;

      input                               M_AXIS_ACLK_i;
      input                               M_AXIS_ARESETN_i;
      //Initiator Port Interface Signals
      output                              M_AXIS_TVALID_o;
      input                               M_AXIS_TREADY_i;
      output [ITDATA_WIDTH-1:0]           M_AXIS_TDATA_o;
      output [(ITDATA_WIDTH/8)-1:0]       M_AXIS_TSTRB_o;
      output [(ITDATA_WIDTH/8)-1:0]       M_AXIS_TKEEP_o;
      output [ITID_WIDTH-1:0]             M_AXIS_TID_o;
      output [ITDEST_WIDTH-1:0]           M_AXIS_TDEST_o;
      output [ITUSER_WIDTH-1:0]           M_AXIS_TUSER_o;
      output                              M_AXIS_TLAST_o;

      input  [WIDTH_CORE-1:0]             FIFO_RD_DATA_AXIS_i;
      input                               TLAST_EN_i;
      input                               FIFO_EMPTY_i;
      output                              FIFO_RD_EN_AXIS_o;
      output                              CUR_RD_TRANS_DONE_o;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////

   localparam TTSTRB_OFFSET  = TTDATA_WIDTH;
   localparam TTKEEP_OFFSET  = TTSTRB_OFFSET  + (ENABLE_TSTRB ? (TTDATA_WIDTH/8)  : 0);
   localparam TTLAST_OFFSET  = TTKEEP_OFFSET  + (ENABLE_TKEEP ? (TTDATA_WIDTH/8)  : 0);
   localparam TTID_OFFSET    = TTLAST_OFFSET  + (ENABLE_TLAST ? 1                 : 0);
   localparam TTDEST_OFFSET  = TTID_OFFSET    + (ENABLE_TID   ? TTID_WIDTH        : 0);
   localparam TTUSER_OFFSET  = TTDEST_OFFSET  + (ENABLE_TDEST ? TTDEST_WIDTH      : 0);
   localparam TTWIDTH        = TTUSER_OFFSET  + (ENABLE_TUSER ? TTUSER_WIDTH      : 0);

   localparam ITSTRB_OFFSET  = ITDATA_WIDTH;
   localparam ITKEEP_OFFSET  = ITSTRB_OFFSET  + (ENABLE_TSTRB ? (ITDATA_WIDTH/8)  : 0);
   localparam ITLAST_OFFSET  = ITKEEP_OFFSET  + (ENABLE_TKEEP ? (ITDATA_WIDTH/8)  : 0);
   localparam ITID_OFFSET    = ITLAST_OFFSET  + (ENABLE_TLAST ? 1                 : 0);
   localparam ITDEST_OFFSET  = ITID_OFFSET    + (ENABLE_TID   ? ITID_WIDTH        : 0);
   localparam ITUSER_OFFSET  = ITDEST_OFFSET  + (ENABLE_TDEST ? ITDEST_WIDTH      : 0);
   localparam ITWIDTH        = ITUSER_OFFSET  + (ENABLE_TUSER ? ITUSER_WIDTH      : 0);


   wire               aresetn;
   wire               sresetn;
   wire               rd_en;
   wire               m_axi4s_tlast;


   wire               fifo_rd_en;

   wire [WIDTH_CORE-1:0]  m_axi4s_data;
   wire [UPCNV_RATIO-1:0] M_AXIS_TLAST;

   assign aresetn = (RESET_TYPE == 1) ? 1'b1 : M_AXIS_ARESETN_i;
   assign sresetn = (RESET_TYPE == 1) ? M_AXIS_ARESETN_i : 1'b1;

  genvar i;
  generate
    if (UPDN_CNV) begin : gen_axi4s_mst_up_cnv
      for (i = 0; i < UPCNV_RATIO; i=i+1) begin
        assign M_AXIS_TDATA_o[(i*TTDATA_WIDTH) +: TTDATA_WIDTH]                 = m_axi4s_data[(i*TTWIDTH) +: TTDATA_WIDTH];
        //if (ENABLE_TSTRB)
        //  assign M_AXIS_TSTRB_o[(i*(TTDATA_WIDTH/8)) +: (TTDATA_WIDTH/8)]     = m_axi4s_data[(i*TTWIDTH)+TTSTRB_OFFSET +: (TTDATA_WIDTH/8)];
        if (ENABLE_TKEEP)
          assign M_AXIS_TKEEP_o[(i*(TTDATA_WIDTH/8)) +: (TTDATA_WIDTH/8)]       = m_axi4s_data[(i*TTWIDTH)+TTKEEP_OFFSET +: (TTDATA_WIDTH/8)];
        if (ENABLE_TLAST)  
          assign M_AXIS_TLAST[i]                                                = (i == (UPCNV_RATIO - 1)) & m_axi4s_data[(i*TTWIDTH)+TTLAST_OFFSET +: 1];

        //if (ENABLE_TID)
        //  assign M_AXIS_TID_o[(i*TTID_WIDTH) +: TTID_WIDTH]                   = m_axi4s_data[(i*TTWIDTH)+TTID_OFFSET +: TTID_WIDTH)];
        //if (ENABLE_TDEST)
        //  assign M_AXIS_TDEST_o[(i*TTDEST_OFFSET) +: TTDEST_WIDTH]            = m_axi4s_data[(i*TTWIDTH)+TTDEST_OFFSET +: TTDEST_WIDTH];
        if (ENABLE_TUSER)
          assign M_AXIS_TUSER_o[(i*TTUSER_WIDTH) +: TTUSER_WIDTH]               =  m_axi4s_data[(i*TTWIDTH)+TTUSER_OFFSET +: TTUSER_WIDTH];
      end
	  
	assign M_AXIS_TLAST_o = (| M_AXIS_TLAST);
    end else begin : gen_axi4s_mst_eq_width
      assign M_AXIS_TDATA_o  = m_axi4s_data[ITDATA_WIDTH-1:0];
      assign M_AXIS_TSTRB_o  = ENABLE_TSTRB ? m_axi4s_data[ITSTRB_OFFSET +: (ITDATA_WIDTH/8)] : {(ITDATA_WIDTH/8){1'b1}};
      assign M_AXIS_TKEEP_o  = ENABLE_TKEEP ? m_axi4s_data[ITKEEP_OFFSET +: (ITDATA_WIDTH/8)] : {(ITDATA_WIDTH/8){1'b1}};
      assign m_axi4s_tlast   = ENABLE_TLAST ? m_axi4s_data[ITLAST_OFFSET] : 1'b1;
      assign M_AXIS_TID_o    = ENABLE_TID ? m_axi4s_data[ITID_OFFSET+:ITID_WIDTH] : {ITID_WIDTH{1'b0}};
      assign M_AXIS_TDEST_o  = ENABLE_TDEST ? m_axi4s_data[ITDEST_OFFSET +: ITDEST_WIDTH]     : {ITDEST_WIDTH{1'b0}};
      assign M_AXIS_TUSER_o  = ENABLE_TUSER ? m_axi4s_data[ITUSER_OFFSET +: ITUSER_WIDTH]     : {ITUSER_WIDTH{1'b0}};
	  assign M_AXIS_TLAST_o  = m_axi4s_tlast;
//      assign M_AXIS_TLAST_o  = m_axi4s_tlast;
    end
  endgenerate



generate  if  ( (READ_MODE == 0) && (PIPE == 2)&&(ECC == 1)) begin : gen_axi4s_initr_cut_through_mode_pipelined_ecc
   //Used FWFT logic from CoreFIFO.
   wire                      update_middle, update_middle1, update_middle2;
   wire                      update_dout;
   reg                       fifo_valid;
   reg                       middle_valid, middle1_valid, middle2_valid, fifo_rd_en_r, fifo_rd_en_r1;
   reg                       dout_valid;
   reg    [WIDTH_CORE-1:0]  dout /*synthesis syn_preserve = 1*/;
   reg    [WIDTH_CORE-1:0]  middle_dout, middle1_dout, middle2_dout;
   reg                       empty;

   reg                       pkt_read_en;

   assign update_middle = fifo_valid & ((update_dout & !(middle2_valid || middle1_valid || middle_valid)) ||
                                        (!update_dout & (middle2_valid & middle1_valid & middle_valid)) );

   assign update_dout   = (((fifo_valid && !middle1_valid && !middle_valid && !middle2_valid) ||
	                   (middle_valid && !middle1_valid && !middle2_valid) || 
			   (middle1_valid && !middle2_valid) || middle2_valid) && M_AXIS_TREADY_i) || (fifo_valid && !dout_valid);
   assign update_middle1 = middle_valid & (!(middle2_valid == middle1_dout) || !(middle1_valid ^ middle2_valid ^ update_dout));
   assign update_middle2 = middle1_valid & middle_valid && (middle2_valid == update_dout);

   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   assign fifo_rd_en = !(FIFO_EMPTY_i) && !(middle_valid /*&& dout_valid*/ && (fifo_valid || (!fifo_valid && (fifo_rd_en_r || fifo_rd_en_r1))));

   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if(!aresetn | !sresetn) begin
         fifo_valid   <= 1'b0;
         middle_valid <= 1'b0;
         dout_valid   <= 1'b0;
         dout         <= 0;
         middle_dout  <= 0;
         middle1_valid <= 1'b0;
         middle1_dout  <= 0;
         fifo_rd_en_r  <= 0;
         fifo_rd_en_r1  <= 0;
      end
      else begin
         fifo_rd_en_r  <= fifo_rd_en;
         fifo_rd_en_r1  <= fifo_rd_en_r;
         if(update_middle) begin
            middle_dout  <= FIFO_RD_DATA_AXIS_i;
         end
         if(update_middle1) begin
            middle1_dout  <= middle_dout;
         end
         if(update_middle2) begin
            middle2_dout  <= middle1_dout;
         end
         if(update_dout) begin
            dout  <= middle2_valid ? middle2_dout :middle1_valid ? middle1_dout : middle_valid ? middle_dout : FIFO_RD_DATA_AXIS_i;
         end

         if(fifo_rd_en_r1) begin
            fifo_valid  <= 1'b1;
         end
         else if(update_middle || update_dout) begin
            fifo_valid  <= 1'b0;
         end

         if(update_middle) begin
            middle_valid  <= 1'b1;
         end
         else if(update_middle1 || update_dout) begin
            middle_valid  <= 1'b0;
         end
         if(update_middle1) begin
            middle1_valid  <= 1'b1;
         end
         else if(update_middle2 || update_dout) begin
            middle1_valid  <= 1'b0;
         end
         if(update_middle2) begin
            middle2_valid  <= 1'b1;
         end
         else if(update_dout) begin
            middle2_valid  <= 1'b0;
         end

         if(update_dout) begin
            dout_valid  <= 1'b1;
         end
         else if(M_AXIS_TREADY_i) begin
            dout_valid  <= 1'b0;
         end

      end
   end

   assign  m_axi4s_data = dout;

   assign  CUR_RD_TRANS_DONE_o  = 0;
   assign  FIFO_RD_EN_AXIS_o    = fifo_rd_en;

   assign  M_AXIS_TVALID_o      = dout_valid;

end
endgenerate
generate  if  ( (READ_MODE == 0) && (((PIPE == 2) && (ECC != 1)) ||
                                     ((PIPE == 1) && (ECC == 2)))) begin : gen_axi4s_initr_cut_through_mode_pipelined_noecc
   //Used FWFT logic from CoreFIFO.
   wire                      update_middle, update_middle1;
   wire                      update_dout;
   reg                       fifo_valid;
   reg                       middle_valid, middle1_valid, fifo_rd_en_r;
   reg                       dout_valid;
   reg    [WIDTH_CORE-1:0]  dout /*synthesis syn_preserve = 1*/;
   reg    [WIDTH_CORE-1:0]  middle_dout, middle1_dout;
   reg                       empty;

   reg                       pkt_read_en;

   assign update_middle = fifo_valid & ((!middle1_valid && !update_dout) || (middle_valid && update_dout) || (middle1_valid && !middle_valid));
   assign update_dout   = (((fifo_valid && !middle1_valid && !middle_valid) ||( middle_valid && !middle1_valid) || middle1_valid) && M_AXIS_TREADY_i) || (fifo_valid && !dout_valid);
   assign update_middle1 = middle_valid & (middle1_valid == update_dout) && (fifo_valid || M_AXIS_TREADY_i);

   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   assign fifo_rd_en = !(FIFO_EMPTY_i) && !(middle_valid /*&& dout_valid*/ && (fifo_valid || (!fifo_valid && fifo_rd_en_r)));

   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if(!aresetn | !sresetn) begin
         fifo_valid   <= 1'b0;
         middle_valid <= 1'b0;
         dout_valid   <= 1'b0;
         dout         <= 0;
         middle_dout  <= 0;
         middle1_valid <= 1'b0;
         middle1_dout  <= 0;
         fifo_rd_en_r  <= 0;
      end
      else begin
         fifo_rd_en_r  <= fifo_rd_en;
         if(update_middle) begin
            middle_dout  <= FIFO_RD_DATA_AXIS_i;
         end
         if(update_middle1) begin
            middle1_dout  <= middle_dout;
         end
         if(update_dout) begin
            dout  <= middle1_valid ? middle1_dout : middle_valid ? middle_dout : FIFO_RD_DATA_AXIS_i;
         end

         if(fifo_rd_en_r) begin
            fifo_valid  <= 1'b1;
         end
         else if(update_middle || update_dout) begin
            fifo_valid  <= 1'b0;
         end

         if(update_middle) begin
            middle_valid  <= 1'b1;
         end
         else if(update_middle1 || update_dout) begin
            middle_valid  <= 1'b0;
         end
         if(update_middle1) begin
            middle1_valid  <= 1'b1;
         end
         else if(update_dout) begin
            middle1_valid  <= 1'b0;
         end

         if(update_dout) begin
            dout_valid  <= 1'b1;
         end
         else if(M_AXIS_TREADY_i) begin
            dout_valid  <= 1'b0;
         end

      end
   end

   assign  m_axi4s_data = dout;

   assign  CUR_RD_TRANS_DONE_o  = 0;
   assign  FIFO_RD_EN_AXIS_o    = fifo_rd_en;

   assign  M_AXIS_TVALID_o      = dout_valid;

end
endgenerate
generate  if  ( (READ_MODE == 0) && (PIPE == 1) && (ECC != 1)) begin : gen_axi4s_initr_cut_through_mode_nonpipelined
   //Used FWFT logic from CoreFIFO.
   wire                      update_middle;
   wire                      update_dout;
   reg                       fifo_valid;
   reg                       middle_valid;
   reg                       dout_valid;
   reg    [WIDTH_CORE-1:0]  dout /*synthesis syn_preserve = 1*/;
   reg    [WIDTH_CORE-1:0]  middle_dout;
   reg                       empty;

   reg                       pkt_read_en;

   assign update_middle = fifo_valid & (middle_valid == update_dout);
   assign update_dout   = (fifo_valid || middle_valid) && (M_AXIS_TREADY_i || !dout_valid);

   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   assign fifo_rd_en = !(FIFO_EMPTY_i) && !(middle_valid && dout_valid && fifo_valid);

   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if(!aresetn | !sresetn) begin
         fifo_valid   <= 1'b0;
         middle_valid <= 1'b0;
         dout_valid   <= 1'b0;
         dout         <= 0;
         middle_dout  <= 0;
      end
      else begin
         if(update_middle) begin
            middle_dout  <= FIFO_RD_DATA_AXIS_i;
         end
         if(update_dout) begin
            dout  <= middle_valid ? middle_dout : FIFO_RD_DATA_AXIS_i;
         end

         if(fifo_rd_en) begin
            fifo_valid  <= 1'b1;
         end
         else if(update_middle || update_dout) begin
            fifo_valid  <= 1'b0;
         end

         if(update_middle) begin
            middle_valid  <= 1'b1;
         end
         else if(update_dout) begin
            middle_valid  <= 1'b0;
         end

         if(update_dout) begin
            dout_valid  <= 1'b1;
         end
         else if(M_AXIS_TREADY_i) begin
            dout_valid  <= 1'b0;
         end

      end
   end

   assign  m_axi4s_data = dout;

   assign  CUR_RD_TRANS_DONE_o  = 0;
   assign  FIFO_RD_EN_AXIS_o    = fifo_rd_en;

   assign  M_AXIS_TVALID_o      = dout_valid;

end
endgenerate


generate  if  ( READ_MODE == 1) begin :  gen_axi4s_initr_strfrwrd_mode
   //Used FWFT logic from CoreFIFO.
   wire                      update_middle;
   wire                      update_dout;
   reg                       fifo_valid;
   reg                       middle_valid;
   reg                       dout_valid;
   reg    [WIDTH_CORE-1:0]  dout;
   reg    [WIDTH_CORE-1:0]  middle_dout;
   reg                       empty;

   reg                       cur_transfer_done;
   reg                       pkt_read_en;
   reg                       dout_valid_ctrl;
   wire                      m_xfer_done;
   reg                       tlast_en_reg;

   assign m_xfer_done   = (M_AXIS_TVALID_o == 1'b1 && M_AXIS_TREADY_i ==1'b1 && m_axi4s_tlast ==1'b1);
   assign update_middle = fifo_valid & (middle_valid == update_dout);
   assign update_dout   = (fifo_valid || middle_valid) && (M_AXIS_TREADY_i || !dout_valid);

   // --------------------------------------------------------------------------
   // Generates the read enable to be given to the FIFO controller
   // fifo_rd_en: It is different from the top-level read enable
   // --------------------------------------------------------------------------
   //For packet mode, fifo_rd_en condition is changed. fifo_rd_en is de-asserted when the Initiator tlast and tvalid is asserted and fifo_rd_en remains de-asserted
   //until next complete packet is received. pkt_read_en indicates that new packet is stored into the fifo and it can be read.

   assign fifo_rd_en = !(FIFO_EMPTY_i) && !(middle_valid && dout_valid && fifo_valid) && pkt_read_en && ~(M_AXIS_TVALID_o & m_axi4s_tlast);

   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if(!aresetn | !sresetn) begin
         fifo_valid   <= 1'b0;
         middle_valid <= 1'b0;
         dout_valid   <= 1'b0;
         dout         <= 0;
         middle_dout  <= 0;
      end
      else begin
         if(update_middle) begin
            middle_dout  <= FIFO_RD_DATA_AXIS_i;
         end
         if(update_dout)
           dout               <= middle_valid ? middle_dout : FIFO_RD_DATA_AXIS_i;
  	     else if(m_xfer_done)
           dout[TTLAST_OFFSET] <= 0;

         if(fifo_rd_en) begin
            fifo_valid  <= 1'b1;
         end
         else if(update_middle || update_dout) begin
            fifo_valid  <= 1'b0;
         end

         if(update_middle) begin
            middle_valid  <= 1'b1;
         end
         else if(update_dout) begin
            middle_valid  <= 1'b0;
         end

         if(m_xfer_done | ~pkt_read_en) begin //de-assert tvalid after the last transaction in the packet is transmitted.
            dout_valid  <= 1'b0;
         end
         //assert tvalid in the next clock cycle after fifo_rd_en is asserted if in the previous packet data is read in advance from the fifo.
         //or else assert tvalid after two clock cycle of fifo_rd_en is asserted which is the normal fwft condition or assert tvalid if FIFO goes empty during
         //last packet transfer and one data is still pending in the intermediate registers. In the last condition fifo_rd_en will not be asserted as fifo is empty
         //TLAST_EN_i is delayed by one clock cycle to assert tvalid
         else if(update_dout | (dout_valid_ctrl & (fifo_rd_en | tlast_en_reg))) begin
            dout_valid  <= 1'b1;
         end
         else if(M_AXIS_TREADY_i) begin
            dout_valid  <= 1'b0;
         end

      end
   end

   assign  m_axi4s_data = dout;

   assign  CUR_RD_TRANS_DONE_o  = cur_transfer_done;
   assign  FIFO_RD_EN_AXIS_o    = fifo_rd_en;

   assign  M_AXIS_TVALID_o      = dout_valid;

   always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         cur_transfer_done    <= 1'b0;
      end else begin
          if(m_xfer_done) begin
            cur_transfer_done  <= 1'b1;
          end else begin
            cur_transfer_done  <= 1'b0;
         end
      end
   end

   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if ((!aresetn) || (!sresetn))
	   pkt_read_en <= 1'b0;
	 else if(m_xfer_done)
	   pkt_read_en <= 1'b0;
	 else if(TLAST_EN_i)
	   pkt_read_en <= 1'b1;

   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if ((!aresetn) || (!sresetn))
	   tlast_en_reg <= 1'b0;
	 else
	   tlast_en_reg <= TLAST_EN_i;

   //dout_valid_ctrl controls the Initiator tvalid. This signal is required to control Initiator tvalid when the last transaction in the packet is completed.
   //In FWFT, fifo is read in advance so that when last transaction is completed, there may be a chance that next location FIFO is already read. However this
   //data shouldn't be passed to AXI4 Stream i/f as in the packet mode, data shouldn't be passed to axi4 stream i/f until tlast is detected. After reset,
   //Initiator tvalid is delayed by two clock cycle of fifo read enable however after the packet is transmitted and if one data is already read in advance then Initiator
   //tvalid should be delayed by only one clock cycle of fifo read en. update_dout indicates whether data is read in advance or not when last transaction in packet is
   //transmitted.

   always @(posedge M_AXIS_ACLK_i or negedge aresetn)
     if ((!aresetn) || (!sresetn))
	   dout_valid_ctrl <= 1'b0;
	 else if(m_xfer_done)
	   dout_valid_ctrl <= update_dout;


end
endgenerate



endmodule
