// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 40600 $
// SVN $Date: 2022-05-18 11:57:41 +0530 (Wed, 18 May 2022) $
// 
// IP Core : CoreAXI4SInterconnect
//
// Module  : COREFIFO_AXI4S_SLAVE_IF
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/

`timescale 1ns / 1ns
module COREFIFO_AXI4S_SLAVE_IF
   (     
      S_AXIS_ACLK_i,
      S_AXIS_ARESETN_i,
      //Slave Port Interface Signals
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
      FIFO_FULL_i
   );

      parameter                           RESET_TYPE       = 0;   
      parameter                           NUM_STAGES       = 2; // To select number of syn
      parameter                           READ_MODE        = 0;
      parameter                           TDATA_WIDTH      = 512;
      parameter                           TID_WIDTH        = 32;
      parameter                           TDEST_WIDTH      = 32;
      parameter                           TUSER_WIDTH      = 4096;
      parameter                           WWIDTH_CORE      = 9281;

      parameter                           ENABLE_TSTRB     = 1;
      parameter                           ENABLE_TKEEP     = 1;
      parameter                           ENABLE_TLAST     = 1;
      parameter                           ENABLE_TUSER     = 1;
      parameter                           ENABLE_TDEST      = 1;
      parameter                           ENABLE_TID       = 1;

      input                               S_AXIS_ACLK_i;
      input                               S_AXIS_ARESETN_i;
      //Slave Port Interface Signals
      input                               S_AXIS_TVALID_i;
      output                              S_AXIS_TREADY_o;
      input  [(8*TDATA_WIDTH)-1:0]        S_AXIS_TDATA_i;
      input  [TDATA_WIDTH-1:0]            S_AXIS_TSTRB_i;
      input  [TDATA_WIDTH-1:0]            S_AXIS_TKEEP_i;
      input  [TID_WIDTH-1:0]              S_AXIS_TID_i;
      input  [TDEST_WIDTH-1:0]            S_AXIS_TDEST_i;
      input  [TUSER_WIDTH-1:0]            S_AXIS_TUSER_i;
      input                               S_AXIS_TLAST_i;


      output [WWIDTH_CORE-1:0]            FIFO_WR_DATA_AXIS_o;
      output                              FIFO_WE_EN_AXIS_o;
      output                              S_AXIS_TLAST_o;
      input                               CUR_RD_TRANS_DONE_i;
      input                               FIFO_FULL_i;

 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

   localparam TSTRB_OFFSET  = TDATA_WIDTH*8;
   localparam TKEEP_OFFSET  = TSTRB_OFFSET  + (ENABLE_TSTRB ? TDATA_WIDTH  : 0);
   localparam TLAST_OFFSET  = TKEEP_OFFSET  + (ENABLE_TKEEP ? TDATA_WIDTH  : 0);
   localparam TID_OFFSET    = TLAST_OFFSET  + (ENABLE_TLAST ? 1            : 0);
   localparam TDEST_OFFSET  = TID_OFFSET    + (ENABLE_TID   ? TID_WIDTH    : 0);
   localparam TUSER_OFFSET  = TDEST_OFFSET  + (ENABLE_TDEST  ? TDEST_WIDTH  : 0);
   localparam TWIDTH        = TUSER_OFFSET  + (ENABLE_TUSER ? TUSER_WIDTH  : 0);

   wire                S_AXIS_TREADY_s;
   wire [TWIDTH-1:0]   s_axi4s_data;
   //wire [TWIDTH-1:0]   s_axi4s_data_s;
   
   
   //reg                 fifo_wr_en;
   

   wire aresetn;
   wire sresetn;
 
   generate
      assign s_axi4s_data[(8*TDATA_WIDTH)-1:0] = S_AXIS_TDATA_i;
      if (ENABLE_TSTRB) assign s_axi4s_data[TSTRB_OFFSET +: TDATA_WIDTH] = S_AXIS_TSTRB_i;
      if (ENABLE_TKEEP) assign s_axi4s_data[TKEEP_OFFSET +: TDATA_WIDTH]  = S_AXIS_TKEEP_i;
      if (ENABLE_TLAST) assign s_axi4s_data[TLAST_OFFSET]                 = S_AXIS_TLAST_i;
      if (ENABLE_TID)   assign s_axi4s_data[TID_OFFSET   +: TID_WIDTH]    = S_AXIS_TID_i;
      if (ENABLE_TDEST) assign s_axi4s_data[TDEST_OFFSET +: TDEST_WIDTH]  = S_AXIS_TDEST_i;
      if (ENABLE_TUSER) assign s_axi4s_data[TUSER_OFFSET +: TUSER_WIDTH]  = S_AXIS_TUSER_i;
   endgenerate
   
   assign aresetn = (RESET_TYPE == 1) ? 1'b1 : S_AXIS_ARESETN_i;
   assign sresetn = (RESET_TYPE == 1) ? S_AXIS_ARESETN_i : 1'b1;


   assign S_AXIS_TREADY_s       = FIFO_FULL_i ? 1'b0 : 1'b1;
   assign S_AXIS_TREADY_o       = S_AXIS_TREADY_s;
   assign FIFO_WR_DATA_AXIS_o   = s_axi4s_data ;
   assign FIFO_WE_EN_AXIS_o     = (S_AXIS_TREADY_s==1'b1 && S_AXIS_TVALID_i == 1'b1) ? 1'b1 : 1'b0 ;
   
 

/////////////SEQ_LOGIC/////////////////////////////////////////////////////////////////////////////////////////////
/*
   always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
     if ((!aresetn) || (!sresetn)) begin
         fifo_wr_en     <= 1'b0;
         s_axi4s_data_s <= 'h0;
      end else begin
         s_axi4s_data_s <= s_axi4s_data;
         if (S_AXIS_TREADY_s && S_AXIS_TVALID_i) begin
            fifo_wr_en  <= 1'b1;
         end
      end
   end


   assign S_AXIS_TREADY_s       = FIFO_FULL_i ? 1'b0 : 1'b1;
   assign S_AXIS_TREADY_o       = S_AXIS_TREADY_s;
   assign FIFO_WR_DATA_AXIS_o   = s_axi4s_data_s ;
   assign FIFO_WE_EN_AXIS_o     = fifo_wr_en;
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   generate  if  (READ_MODE == 1) begin
      reg  [11:0]         tlast_count;
      reg                 first_tlast;
      reg                 first_tlast_s;
	  reg                 tlast_en;
      reg                 CUR_RD_TRANS_DONE_d;
	  wire                S_AXIS_TLAST_s;
	reg 		  tlast_en_ctrl;
	  
	  assign S_AXIS_TLAST_s     = (S_AXIS_TREADY_s==1'b1 && S_AXIS_TVALID_i == 1'b1 && S_AXIS_TLAST_i ==1'b1) ? 1'b1 : 1'b0 ;
	
	always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
         if ((!aresetn) || (!sresetn)) 
            tlast_en_ctrl    <= 1'd0;
	     else if (tlast_count < 1)
	        tlast_en_ctrl    <= S_AXIS_TLAST_s & CUR_RD_TRANS_DONE_d ;
		 else 
		    tlast_en_ctrl    <= 1'd0;		 
	end
	


      always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
         if ((!aresetn) || (!sresetn)) begin
            tlast_count    <= 12'd0;
         end else begin
            if (S_AXIS_TLAST_s== 1'b1 && CUR_RD_TRANS_DONE_i==1'b1) begin
               tlast_count    <= tlast_count;
            end else if (S_AXIS_TLAST_s== 1'b1 && CUR_RD_TRANS_DONE_i==1'b0) begin
               tlast_count    <= tlast_count+ 1'b1;
            end else if (S_AXIS_TLAST_s== 1'b0 && CUR_RD_TRANS_DONE_i==1'b1) begin
               tlast_count    <= tlast_count - 1'b1;
            end else begin
               tlast_count    <= tlast_count;
            end
         end
      end

      always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
         if ((!aresetn) || (!sresetn)) begin
            first_tlast    <= 1'b0;
            first_tlast_s  <= 1'b0;
         end else begin
            if (S_AXIS_TLAST_s== 1'b1 && first_tlast ==1'b0) begin
               first_tlast    <= 1'b1;
               first_tlast_s  <= 1'b1;
            end else if((tlast_count == 0) & ~S_AXIS_TLAST_s)  begin
               first_tlast    <= 1'b0;
            end else  begin
               first_tlast_s  <= 1'b0;
            end
         end
      end


      always @(posedge S_AXIS_ACLK_i or negedge aresetn) begin
         if ((!aresetn) || (!sresetn)) begin
            tlast_en <= 1'b0;
            CUR_RD_TRANS_DONE_d <= 1'b0;
         end else begin
            CUR_RD_TRANS_DONE_d <=CUR_RD_TRANS_DONE_i;
            if (first_tlast_s ==1'b1) begin
               tlast_en <= 1'b1;
            end else if (tlast_count > 'd0 && (CUR_RD_TRANS_DONE_d==1'b1 || tlast_en_ctrl) ) begin
               tlast_en <= 1'b1;
            end else if(tlast_count > 'd0  && CUR_RD_TRANS_DONE_d==1'b0) begin
               tlast_en <= 1'b0;
            end else begin
               tlast_en <= 1'b0;
            end
         end
      end
	  assign S_AXIS_TLAST_o =  tlast_en;
   end 
   else begin 
     assign S_AXIS_TLAST_o =  0;
   end 
   endgenerate

endmodule 
