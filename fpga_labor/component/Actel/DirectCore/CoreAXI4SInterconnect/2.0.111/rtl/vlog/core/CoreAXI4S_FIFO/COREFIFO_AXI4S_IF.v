// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 40477 $
// SVN $Date: 2022-04-19 00:37:03 +0530 (Tue, 19 Apr 2022) $
// 
// IP Core : CoreAXI4SInterconnect
//
// Module  : COREFIFO_AXI4S_IF
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 1ns
module COREFIFO_AXI4S_IF
   (     
      M_AXIS_ACLK_i,
      S_AXIS_ACLK_i,
      M_AXIS_ARESETN_i,
      S_AXIS_ARESETN_i,
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

      FIFO_WR_DATA_AXI4_S_o,
      FIFO_RD_DATA_AXI4_S_i,
      FIFO_WE_EN_AXI4_S_o,
      FIFO_RE_EN_AXI4_S_o,
      FIFO_FULL_i,
      FIFO_EMPTY_i
   );

      parameter                           SYNC             = 0;   
      parameter                           RESET_TYPE       = 0;   
      parameter                           NUM_STAGES       = 2; 
      parameter                           READ_MODE        = 0;


      parameter                           AXIS_TDATA_WIDTH = 512;
      parameter                           AXIS_TID_WIDTH   = 32;
      parameter                           AXIS_TDEST_WIDTH = 32;
      parameter                           AXIS_TUSER_WIDTH = 4096;
      parameter                           WWIDTH_CORE      = 9281;

      parameter                           ENABLE_TSTRB     = 1;
      parameter                           ENABLE_TKEEP     = 1;
      parameter                           ENABLE_TLAST     = 1;
      parameter                           ENABLE_TUSER     = 1;
      parameter                           ENABLE_TDEST     = 1;
      parameter                           ENABLE_TID       = 1;

      input                               M_AXIS_ACLK_i;
      input                               S_AXIS_ACLK_i;
      input                               M_AXIS_ARESETN_i;
      input                               S_AXIS_ARESETN_i;
      //Master Port Interface Signals
      output                              M_AXIS_TVALID_o;
      input                               M_AXIS_TREADY_i;
      output [(8*AXIS_TDATA_WIDTH)-1:0]   M_AXIS_TDATA_o;
      output [AXIS_TDATA_WIDTH-1:0]       M_AXIS_TSTRB_o;
      output [AXIS_TDATA_WIDTH-1:0]       M_AXIS_TKEEP_o;
      output [AXIS_TID_WIDTH-1:0]         M_AXIS_TID_o;
      output [AXIS_TDEST_WIDTH-1:0]       M_AXIS_TDEST_o;
      output [AXIS_TUSER_WIDTH-1:0]       M_AXIS_TUSER_o;
      output                              M_AXIS_TLAST_o;

      //Slave Port Interface Signals
      input                               S_AXIS_TVALID_i;
      output                              S_AXIS_TREADY_o;
      input  [(8*AXIS_TDATA_WIDTH)-1:0]   S_AXIS_TDATA_i;
      input  [AXIS_TDATA_WIDTH-1:0]       S_AXIS_TSTRB_i;
      input  [AXIS_TDATA_WIDTH-1:0]       S_AXIS_TKEEP_i;
      input  [AXIS_TID_WIDTH-1:0]         S_AXIS_TID_i;
      input  [AXIS_TDEST_WIDTH-1:0]       S_AXIS_TDEST_i;
      input  [AXIS_TUSER_WIDTH-1:0]       S_AXIS_TUSER_i;
      input                               S_AXIS_TLAST_i;


      output [WWIDTH_CORE-1:0]            FIFO_WR_DATA_AXI4_S_o;
      input  [WWIDTH_CORE-1:0]            FIFO_RD_DATA_AXI4_S_i;
      output                              FIFO_WE_EN_AXI4_S_o;
      output                              FIFO_RE_EN_AXI4_S_o;
      input                               FIFO_FULL_i;
      input                               FIFO_EMPTY_i;

 
      wire cur_rd_trans_done;
      wire cur_rd_trans_done_s;      
      wire TLAST_EN;
      wire TLAST_EN_s;


      wire aresetn;
      wire sresetn;

      assign aresetn = (RESET_TYPE == 1) ? 1'b1 : M_AXIS_ARESETN_i;
      assign sresetn = (RESET_TYPE == 1) ? M_AXIS_ARESETN_i : 1'b1;



      COREFIFO_AXI4S_SLAVE_IF #(
         .RESET_TYPE             (RESET_TYPE),
         .NUM_STAGES             (NUM_STAGES),
         .READ_MODE              (READ_MODE),
         .TDATA_WIDTH            (AXIS_TDATA_WIDTH),
         .TID_WIDTH              (AXIS_TID_WIDTH),
         .TDEST_WIDTH            (AXIS_TDEST_WIDTH),
         .TUSER_WIDTH            (AXIS_TUSER_WIDTH),
         .WWIDTH_CORE            (WWIDTH_CORE),

         .ENABLE_TSTRB           (ENABLE_TSTRB),
         .ENABLE_TKEEP           (ENABLE_TKEEP),
         .ENABLE_TLAST           (ENABLE_TLAST),
         .ENABLE_TUSER           (ENABLE_TUSER),
         .ENABLE_TDEST           (ENABLE_TDEST),
         .ENABLE_TID             (ENABLE_TID)
      )
      U_COREFIFO_AXI4S_SLAVE_IF (
         .S_AXIS_ACLK_i          (S_AXIS_ACLK_i),
         .S_AXIS_ARESETN_i       (S_AXIS_ARESETN_i),
         .S_AXIS_TVALID_i        (S_AXIS_TVALID_i),
         .S_AXIS_TREADY_o        (S_AXIS_TREADY_o),
         .S_AXIS_TDATA_i         (S_AXIS_TDATA_i),
         .S_AXIS_TSTRB_i         (S_AXIS_TSTRB_i),
         .S_AXIS_TKEEP_i         (S_AXIS_TKEEP_i),
         .S_AXIS_TLAST_i         (S_AXIS_TLAST_i),
         .S_AXIS_TID_i           (S_AXIS_TID_i),
         .S_AXIS_TDEST_i         (S_AXIS_TDEST_i),
         .S_AXIS_TUSER_i         (S_AXIS_TUSER_i),

         .FIFO_WR_DATA_AXIS_o    (FIFO_WR_DATA_AXI4_S_o),
         .FIFO_WE_EN_AXIS_o      (FIFO_WE_EN_AXI4_S_o),
         .S_AXIS_TLAST_o         (TLAST_EN),
         .CUR_RD_TRANS_DONE_i    (cur_rd_trans_done_s),
         .FIFO_FULL_i            (FIFO_FULL_i)
      );



   
      COREFIFO_AXI4S_MASTER_IF #(
         .RESET_TYPE             (RESET_TYPE),   
         .NUM_STAGES             (NUM_STAGES),
         .READ_MODE              (READ_MODE),
         .TDATA_WIDTH            (AXIS_TDATA_WIDTH),
         .TID_WIDTH              (AXIS_TID_WIDTH),
         .TDEST_WIDTH            (AXIS_TDEST_WIDTH),
         .TUSER_WIDTH            (AXIS_TUSER_WIDTH),
         .WWIDTH_CORE            (WWIDTH_CORE),

         .ENABLE_TSTRB           (ENABLE_TSTRB),
         .ENABLE_TKEEP           (ENABLE_TKEEP),
         .ENABLE_TLAST           (ENABLE_TLAST),
         .ENABLE_TUSER           (ENABLE_TUSER),
         .ENABLE_TDEST           (ENABLE_TDEST),
         .ENABLE_TID             (ENABLE_TID)
      )
      U_COREFIFO_AXI4S_MASTER_IF (
         .M_AXIS_ACLK_i          (M_AXIS_ACLK_i),
         .M_AXIS_ARESETN_i       (M_AXIS_ARESETN_i),
         .M_AXIS_TVALID_o        (M_AXIS_TVALID_o),
         .M_AXIS_TREADY_i        (M_AXIS_TREADY_i),
         .M_AXIS_TDATA_o         (M_AXIS_TDATA_o),
         .M_AXIS_TSTRB_o         (M_AXIS_TSTRB_o),
         .M_AXIS_TKEEP_o         (M_AXIS_TKEEP_o),
         .M_AXIS_TLAST_o         (M_AXIS_TLAST_o),
         .M_AXIS_TID_o           (M_AXIS_TID_o),
         .M_AXIS_TDEST_o         (M_AXIS_TDEST_o),
         .M_AXIS_TUSER_o         (M_AXIS_TUSER_o),

         .FIFO_RD_DATA_AXIS_i    (FIFO_RD_DATA_AXI4_S_i),
         .FIFO_RD_EN_AXIS_o      (FIFO_RE_EN_AXI4_S_o),
         .TLAST_EN_i             (TLAST_EN_s),
         .CUR_RD_TRANS_DONE_o    (cur_rd_trans_done),
         .FIFO_EMPTY_i           (FIFO_EMPTY_i)
      );

    generate  
       if  (SYNC == 1) begin
	      reg  TLAST_EN_reg;
		  
          always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
             if ((!aresetn) || (!sresetn)) begin
                TLAST_EN_reg   <= 1'b0;
             end else begin
                TLAST_EN_reg   <= TLAST_EN;
             end
          end
          assign  TLAST_EN_s  = TLAST_EN_reg;

       end else begin
	      //To align fifo empty and tlast_en two clock cycle latency is added to tlast_en
          CORESYNC_PULSE_CDC # (.NUM_STAGES(NUM_STAGES+2),.SYNC_RESET (RESET_TYPE)) tlast_en_wr (
             .SRC_CLK            (S_AXIS_ACLK_i),
             .DSTN_CLK           (M_AXIS_ACLK_i),
             .SRC_RESET          (S_AXIS_ARESETN_i),
             .DSTN_RESET         (M_AXIS_ARESETN_i),
             .PULSE_IN           (TLAST_EN),
             .SYNC_PULSE         (TLAST_EN_s)
           ) ;
       end
    endgenerate
    
    generate  
       if  (SYNC == 1) begin
	      reg  cur_rd_trans_done_reg;
		  
          always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
             if ((!aresetn) || (!sresetn)) begin
                cur_rd_trans_done_reg   <= 1'b0;
             end else begin
                cur_rd_trans_done_reg   <= cur_rd_trans_done;
             end
          end
	   assign  cur_rd_trans_done_s = cur_rd_trans_done_reg;
       end else begin
          CORESYNC_PULSE_CDC # (.NUM_STAGES(NUM_STAGES),.SYNC_RESET (RESET_TYPE)) cur_rd_trans_done_rd (
             .SRC_CLK            (M_AXIS_ACLK_i),
             .DSTN_CLK           (S_AXIS_ACLK_i),
             .SRC_RESET          (M_AXIS_ARESETN_i),
             .DSTN_RESET         (S_AXIS_ARESETN_i),
             .PULSE_IN           (cur_rd_trans_done),
             .SYNC_PULSE         (cur_rd_trans_done_s)
           ) ;
       end
    endgenerate

endmodule 
