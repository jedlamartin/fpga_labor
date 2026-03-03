// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 40736 $
// SVN $Date: 2022-06-08 20:01:19 +0530 (Wed, 08 Jun 2022) $
// 
// IP Core : CoreAXI4SInterconnect
//
// Module  : COREFIFO_AXI4S_MASTER_IF
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 1ns
module COREFIFO_AXI4S_MASTER_IF
   (     
      M_AXIS_ACLK_i,
      M_AXIS_ARESETN_i,
      //Master Port Interface Signals
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
      parameter                           TDATA_WIDTH   = 512;
      parameter                           TID_WIDTH     = 32;
      parameter                           TDEST_WIDTH   = 32;
      parameter                           TUSER_WIDTH   = 4096;
      parameter                           WWIDTH_CORE   = 9281;

      parameter                           ENABLE_TSTRB     = 1;
      parameter                           ENABLE_TKEEP     = 1;
      parameter                           ENABLE_TLAST     = 1;
      parameter                           ENABLE_TUSER     = 1;
      parameter                           ENABLE_TDEST     = 1;
      parameter                           ENABLE_TID       = 1;

      input                               M_AXIS_ACLK_i;
      input                               M_AXIS_ARESETN_i;
      //Master Port Interface Signals
      output                              M_AXIS_TVALID_o;
      input                               M_AXIS_TREADY_i;
      output [(8*TDATA_WIDTH)-1:0]        M_AXIS_TDATA_o;
      output [TDATA_WIDTH-1:0]            M_AXIS_TSTRB_o;
      output [TDATA_WIDTH-1:0]            M_AXIS_TKEEP_o;
      output [TID_WIDTH-1:0]              M_AXIS_TID_o;
      output [TDEST_WIDTH-1:0]            M_AXIS_TDEST_o;
      output [TUSER_WIDTH-1:0]            M_AXIS_TUSER_o;
      output                              M_AXIS_TLAST_o;

      input  [WWIDTH_CORE-1:0]            FIFO_RD_DATA_AXIS_i;
      input                               TLAST_EN_i;
      input                               FIFO_EMPTY_i;
      output                              FIFO_RD_EN_AXIS_o;
      output                              CUR_RD_TRANS_DONE_o;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////

   localparam TSTRB_OFFSET  = TDATA_WIDTH*8;                                                    
   localparam TKEEP_OFFSET  = TSTRB_OFFSET  + (ENABLE_TSTRB ? TDATA_WIDTH  : 0);
   localparam TLAST_OFFSET  = TKEEP_OFFSET  + (ENABLE_TKEEP ? TDATA_WIDTH  : 0);
   localparam TID_OFFSET    = TLAST_OFFSET  + (ENABLE_TLAST ? 1            : 0);
   localparam TDEST_OFFSET  = TID_OFFSET    + (ENABLE_TID   ? TID_WIDTH    : 0);
   localparam TUSER_OFFSET  = TDEST_OFFSET  + (ENABLE_TDEST ? TDEST_WIDTH  : 0);
   localparam TWIDTH        = TUSER_OFFSET  + (ENABLE_TUSER ? TUSER_WIDTH  : 0);



   wire              aresetn;
   wire              sresetn;
   wire              rd_en;
   wire              m_axi4s_tlast;

   
   wire              fifo_rd_en;
   
   wire [TWIDTH-1:0] m_axi4s_data;


   assign aresetn = (RESET_TYPE == 1) ? 1'b1 : M_AXIS_ARESETN_i;
   assign sresetn = (RESET_TYPE == 1) ? M_AXIS_ARESETN_i : 1'b1;
   
   assign M_AXIS_TDATA_o  = m_axi4s_data[(8*TDATA_WIDTH)-1:0];
   assign M_AXIS_TSTRB_o  = ENABLE_TSTRB ? m_axi4s_data[TSTRB_OFFSET +: TDATA_WIDTH] : {TDATA_WIDTH{1'b1}};
   assign M_AXIS_TKEEP_o  = ENABLE_TKEEP ? m_axi4s_data[TKEEP_OFFSET +: TDATA_WIDTH] : {TDATA_WIDTH{1'b1}};
   assign m_axi4s_tlast   = ENABLE_TLAST ? m_axi4s_data[TLAST_OFFSET]               : 1'b1;
   assign M_AXIS_TID_o    = ENABLE_TID   ? m_axi4s_data[TID_OFFSET   +: TID_WIDTH]   : {TID_WIDTH{1'b0}};
   assign M_AXIS_TDEST_o  = ENABLE_TDEST ? m_axi4s_data[TDEST_OFFSET +: TDEST_WIDTH] : {TDEST_WIDTH{1'b0}};
   assign M_AXIS_TUSER_o  = ENABLE_TUSER ? m_axi4s_data[TUSER_OFFSET +: TUSER_WIDTH] : {TUSER_WIDTH{1'b0}};
   assign M_AXIS_TLAST_o  = m_axi4s_tlast;



generate  if  ( READ_MODE == 0) begin
   //Used FWFT logic from CoreFIFO. 
   wire                      update_middle;
   wire                      update_dout;
   reg                       fifo_valid;
   reg                       middle_valid;
   reg                       dout_valid;  
   reg    [WWIDTH_CORE-1:0]  dout /*synthesis syn_preserve = 1*/;   
   reg    [WWIDTH_CORE-1:0]  middle_dout;   
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


generate  if  ( READ_MODE == 1) begin
   //Used FWFT logic from CoreFIFO. 
   wire                      update_middle;
   wire                      update_dout;
   reg                       fifo_valid;
   reg                       middle_valid;
   reg                       dout_valid;  
   reg    [WWIDTH_CORE-1:0]  dout;   
   reg    [WWIDTH_CORE-1:0]  middle_dout;   
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
   //For packet mode, fifo_rd_en condition is changed. fifo_rd_en is de-asserted when the master tlast and tvalid is asserted and fifo_rd_en remains de-asserted 
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
           dout[TLAST_OFFSET] <= 0; 
		   
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
	   
   //dout_valid_ctrl controls the master tvalid. This signal is required to control master tvalid when the last transaction in the packet is completed. 
   //In FWFT, fifo is read in advance so that when last transaction is completed, there may be a chance that next location FIFO is already read. However this 
   //data shouldn't be passed to AXI4 Stream i/f as in the packet mode, data shouldn't be passed to axi4 stream i/f until tlast is detected. After reset, 
   //master tvalid is delayed by two clock cycle of fifo read enable however after the packet is transmitted and if one data is already read in advance then master 
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
