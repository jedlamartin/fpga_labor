// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 39588 $
// SVN $Date: 2021-12-13 20:19:21 +0530 (Mon, 13 Dec 2021) $
// 
// IP Core : CoreAXI4SInterconnect
//
// Module  : CORESYNC_PULSE_CDC
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 1ns
module CORESYNC_PULSE_CDC(
                              input      SRC_CLK,
                              input      DSTN_CLK,
                              input      SRC_RESET,
                              input      DSTN_RESET,
                              input      PULSE_IN,
                              output     SYNC_PULSE
                             )/* synthesis syn_preserve = 1 syn_hier = "fixed" syn_noprune=1*/;

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
   parameter NUM_STAGES = 2;
   parameter SYNC_RESET = 1;
  
   wire toggle;
 

//////////// toggle generator 

      PULSE_GEN # (.SYNC_RESET(SYNC_RESET)) 
      u_pulse_gen	
         (
            .src_clk       (SRC_CLK),
            .src_reset     (SRC_RESET),
            .pulse_in      (PULSE_IN),
            .toggle_out    (toggle)
         );		 
   
/////////////////// pulse synchronizer 

      PULSE_CDC  # ( .NUM_STAGES(NUM_STAGES), .SYNC_RESET(SYNC_RESET)) 
      u_pulse_cdc_sync   
         (
	    .clk             (DSTN_CLK),
	    .reset           (DSTN_RESET),
	    .data_in         (toggle),
	    .sync_pulse      (SYNC_PULSE)
	 );

endmodule // corefifo_doubleSync
   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
