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
// Module  : COREFIFO_AXI4S_IF
//
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP.
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 100ps

module caxi4pc_corefifo_axi4s_if
   (
      M_AXIS_ACLK_i,
      S_AXIS_ACLK_i,
      M_AXIS_ARESETN_i,
      S_AXIS_ARESETN_i,
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

      FIFO_WR_DATA_AXI4_S_o,
      FIFO_RD_DATA_AXI4_S_i,
      FIFO_WE_EN_AXI4_S_o,
      FIFO_RE_EN_AXI4_S_o,
      FIFO_FULL_i,
      FIFO_EMPTY_i,
	  
	  sop,
	  eop,
	  tlast_dis
   );

      parameter                           SYNC             = 0;
      parameter                           RESET_TYPE       = 0;
      parameter                           NUM_STAGES       = 2;
      parameter                           READ_MODE        = 0;
      parameter                           PIPE             = 1;
      parameter                           ECC              = 0;


      parameter                           AXIS_TTDATA_WIDTH = 512;
      parameter                           AXIS_ITDATA_WIDTH = 512;
      parameter                           AXIS_TTID_WIDTH   = 32;
      parameter                           AXIS_ITID_WIDTH   = 32;
      parameter                           AXIS_TTDEST_WIDTH = 32;
      parameter                           AXIS_ITDEST_WIDTH = 32;
      parameter                           AXIS_TTUSER_WIDTH = 4096;
      parameter                           AXIS_ITUSER_WIDTH = 4096;
      parameter                           WWIDTH_CORE       = 9281;
      parameter                           RWIDTH_CORE       = 9281;

      parameter                           ENABLE_TSTRB     = 1;
      parameter                           ENABLE_TKEEP     = 1;
      parameter                           ENABLE_TLAST     = 1;
      parameter                           ENABLE_TUSER     = 1;
      parameter                           ENABLE_TDEST     = 1;
      parameter                           ENABLE_TID       = 1;
	  
      parameter                           EOP_OFFSET       = 1;
      parameter                           PKT_DROP_OVF     = 0;


      parameter   [0:0]                   UPDN_CNV         = 0;
      parameter   [7:0]                   DNCNV_RATIO      = 2;
      parameter   [7:0]                   UPCNV_RATIO      = 2;

      input                               M_AXIS_ACLK_i;
      input                               S_AXIS_ACLK_i;
      input                               M_AXIS_ARESETN_i;
      input                               S_AXIS_ARESETN_i;
      //Initiator Port Interface Signals
      output                              M_AXIS_TVALID_o;
      input                               M_AXIS_TREADY_i;
      output [AXIS_ITDATA_WIDTH-1:0]      M_AXIS_TDATA_o;
      output [(AXIS_ITDATA_WIDTH/8)-1:0]  M_AXIS_TSTRB_o;
      output [(AXIS_ITDATA_WIDTH/8)-1:0]  M_AXIS_TKEEP_o;
      output [AXIS_ITID_WIDTH-1:0]        M_AXIS_TID_o;
      output [AXIS_ITDEST_WIDTH-1:0]      M_AXIS_TDEST_o;
      output [AXIS_ITUSER_WIDTH-1:0]      M_AXIS_TUSER_o;
      output                              M_AXIS_TLAST_o;

      //Target Port Interface Signals
      input                               S_AXIS_TVALID_i;
      output                              S_AXIS_TREADY_o;
      input  [AXIS_TTDATA_WIDTH-1:0]      S_AXIS_TDATA_i;
      input  [(AXIS_TTDATA_WIDTH/8)-1:0]  S_AXIS_TSTRB_i;
      input  [(AXIS_TTDATA_WIDTH/8)-1:0]  S_AXIS_TKEEP_i;
      input  [AXIS_TTID_WIDTH-1:0]        S_AXIS_TID_i;
      input  [AXIS_TTDEST_WIDTH-1:0]      S_AXIS_TDEST_i;
      input  [AXIS_TTUSER_WIDTH-1:0]      S_AXIS_TUSER_i;
      input                               S_AXIS_TLAST_i;


      output [WWIDTH_CORE-1:0]            FIFO_WR_DATA_AXI4_S_o;
      input  [RWIDTH_CORE-1:0]            FIFO_RD_DATA_AXI4_S_i;
      output                              FIFO_WE_EN_AXI4_S_o;
      output                              FIFO_RE_EN_AXI4_S_o;
      input                               FIFO_FULL_i;
      input                               FIFO_EMPTY_i;

	  output 							  sop;
	  output 							  eop;
      input				  			  	  tlast_dis;
	  
      wire cur_rd_trans_done;
      wire cur_rd_trans_done_s;
      wire TLAST_EN;
      wire TLAST_EN_s;
      
      wire aresetn;
      wire sresetn;

      assign aresetn = (RESET_TYPE == 1) ? 1'b1 : M_AXIS_ARESETN_i;
      assign sresetn = (RESET_TYPE == 1) ? M_AXIS_ARESETN_i : 1'b1;

      caxi4pc_axi4s_target_if #(
         .RESET_TYPE             (RESET_TYPE        ),
         .NUM_STAGES             (NUM_STAGES        ),
         .READ_MODE              (READ_MODE         ),

         .TTDATA_WIDTH           (AXIS_TTDATA_WIDTH ),
         .TTID_WIDTH             (AXIS_TTID_WIDTH   ),
         .TTDEST_WIDTH           (AXIS_TTDEST_WIDTH ),
         .TTUSER_WIDTH           (AXIS_TTUSER_WIDTH ),

         .ITDATA_WIDTH           (AXIS_ITDATA_WIDTH ),
         .ITID_WIDTH             (AXIS_ITID_WIDTH   ),
         .ITDEST_WIDTH           (AXIS_ITDEST_WIDTH ),
         .ITUSER_WIDTH           (AXIS_ITUSER_WIDTH ),

         .WIDTH_CORE             (WWIDTH_CORE       ),

         .ENABLE_TSTRB           (ENABLE_TSTRB      ),
         .ENABLE_TKEEP           (ENABLE_TKEEP      ),
         .ENABLE_TLAST           (ENABLE_TLAST      ),
         .ENABLE_TUSER           (ENABLE_TUSER      ),
         .ENABLE_TDEST           (ENABLE_TDEST      ),
         .ENABLE_TID             (ENABLE_TID        ),

         .UPDN_CNV               (UPDN_CNV          ),
         .DNCNV_RATIO            (DNCNV_RATIO       ),
         .UPCNV_RATIO            (UPCNV_RATIO       ),
         .PKT_DROP_OVF           (PKT_DROP_OVF      )
      )
      U_COREFIFO_AXI4S_TARGET_IF (
         .S_AXIS_ACLK_i          (S_AXIS_ACLK_i         ),
         .S_AXIS_ARESETN_i       (S_AXIS_ARESETN_i      ),
         .S_AXIS_TVALID_i        (S_AXIS_TVALID_i       ),
         .S_AXIS_TREADY_o        (S_AXIS_TREADY_o       ),
         .S_AXIS_TDATA_i         (S_AXIS_TDATA_i        ),
         .S_AXIS_TSTRB_i         (S_AXIS_TSTRB_i        ),
         .S_AXIS_TKEEP_i         (S_AXIS_TKEEP_i        ),
         .S_AXIS_TLAST_i         (S_AXIS_TLAST_i        ),
         .S_AXIS_TID_i           (S_AXIS_TID_i          ),
         .S_AXIS_TDEST_i         (S_AXIS_TDEST_i        ),
         .S_AXIS_TUSER_i         (S_AXIS_TUSER_i        ),

         .FIFO_WR_DATA_AXIS_o    (FIFO_WR_DATA_AXI4_S_o ),
         .FIFO_WE_EN_AXIS_o      (FIFO_WE_EN_AXI4_S_o   ),
         .S_AXIS_TLAST_o         (TLAST_EN              ),
         .CUR_RD_TRANS_DONE_i    (cur_rd_trans_done_s   ),
         .FIFO_FULL_i            (FIFO_FULL_i           ),
		 .sop            		 (sop      		        ),
		 .eop           		 (eop                   ),
		 .tlast_dis   		     (tlast_dis    			)
      );

      caxi4pc_axi4s_initiator_if #(
         .RESET_TYPE             (RESET_TYPE        ),
         .NUM_STAGES             (NUM_STAGES        ),
         .READ_MODE              (READ_MODE         ),
         .PIPE                   (PIPE              ),
         .ECC                    (ECC               ),

         .ITDATA_WIDTH           (AXIS_ITDATA_WIDTH ),
         .ITID_WIDTH             (AXIS_ITID_WIDTH   ),
         .ITDEST_WIDTH           (AXIS_ITDEST_WIDTH ),
         .ITUSER_WIDTH           (AXIS_ITUSER_WIDTH ),

         .TTDATA_WIDTH           (AXIS_TTDATA_WIDTH ),
         .TTID_WIDTH             (AXIS_TTID_WIDTH   ),
         .TTDEST_WIDTH           (AXIS_TTDEST_WIDTH ),
         .TTUSER_WIDTH           (AXIS_TTUSER_WIDTH ),

         .WIDTH_CORE             (RWIDTH_CORE       ),

         .ENABLE_TSTRB           (ENABLE_TSTRB      ),
         .ENABLE_TKEEP           (ENABLE_TKEEP      ),
         .ENABLE_TLAST           (ENABLE_TLAST      ),
         .ENABLE_TUSER           (ENABLE_TUSER      ),
         .ENABLE_TDEST           (ENABLE_TDEST      ),
         .ENABLE_TID             (ENABLE_TID        ),

         .UPDN_CNV               (UPDN_CNV          ),
         .DNCNV_RATIO            (DNCNV_RATIO       ),
         .UPCNV_RATIO            (UPCNV_RATIO       ), 
		 
         .EOP_OFFSET             (EOP_OFFSET        )
      )
      U_COREFIFO_AXI4S_INITIATOR_IF (
         .M_AXIS_ACLK_i          (M_AXIS_ACLK_i        ),
         .M_AXIS_ARESETN_i       (M_AXIS_ARESETN_i     ),
         .M_AXIS_TVALID_o        (M_AXIS_TVALID_o      ),
         .M_AXIS_TREADY_i        (M_AXIS_TREADY_i      ),
         .M_AXIS_TDATA_o         (M_AXIS_TDATA_o       ),
         .M_AXIS_TSTRB_o         (M_AXIS_TSTRB_o       ),
         .M_AXIS_TKEEP_o         (M_AXIS_TKEEP_o       ),
         .M_AXIS_TLAST_o         (M_AXIS_TLAST_o       ),
         .M_AXIS_TID_o           (M_AXIS_TID_o         ),
         .M_AXIS_TDEST_o         (M_AXIS_TDEST_o       ),
         .M_AXIS_TUSER_o         (M_AXIS_TUSER_o       ),

         .FIFO_RD_DATA_AXIS_i    (FIFO_RD_DATA_AXI4_S_i),
         .FIFO_RD_EN_AXIS_o      (FIFO_RE_EN_AXI4_S_o  ),
         .TLAST_EN_i             (TLAST_EN_s           ),
         .CUR_RD_TRANS_DONE_o    (cur_rd_trans_done    ),
         .FIFO_EMPTY_i           (FIFO_EMPTY_i         )
      );

    generate
       if  (SYNC == 1) begin
	      reg  TLAST_EN_reg;

          always @(posedge M_AXIS_ACLK_i or negedge aresetn) begin
             if ((!aresetn) || (!sresetn)) begin
                TLAST_EN_reg   <= 1'b0;
             end else begin
                TLAST_EN_reg   <= TLAST_EN ; //& !tlast_dis
             end
          end
          assign  TLAST_EN_s  = TLAST_EN_reg;

       end else begin
	      //To align fifo empty and tlast_en two clock cycle latency is added to tlast_en
          caxi4pc_cdc_pulse_sync # (.NUM_STAGES(NUM_STAGES+2),.SYNC_RESET (RESET_TYPE)) tlast_en_wr (
             .src_clk            (S_AXIS_ACLK_i),
             .dstn_clk           (M_AXIS_ACLK_i),
             .src_reset_n        (S_AXIS_ARESETN_i),
             .dstn_reset_n       (M_AXIS_ARESETN_i),
             .pulse_in           (TLAST_EN),
             .sync_pulse         (TLAST_EN_s)
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
          caxi4pc_cdc_pulse_sync # (.NUM_STAGES(NUM_STAGES),.SYNC_RESET (RESET_TYPE)) cur_rd_trans_done_rd (
             .src_clk            (M_AXIS_ACLK_i),
             .dstn_clk           (S_AXIS_ACLK_i),
             .src_reset_n        (M_AXIS_ARESETN_i),
             .dstn_reset_n       (S_AXIS_ARESETN_i),
             .pulse_in           (cur_rd_trans_done),
             .sync_pulse         (cur_rd_trans_done_s)
           ) ;
       end
    endgenerate

endmodule
