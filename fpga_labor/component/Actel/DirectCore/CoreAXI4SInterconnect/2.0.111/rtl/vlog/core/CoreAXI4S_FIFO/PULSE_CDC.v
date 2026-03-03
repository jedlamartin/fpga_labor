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
// Module  : PULSE_CDC
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/

`timescale 1ns / 1ns
module PULSE_CDC
   (
      input  clk,
      input  reset,
      input  data_in,
      output sync_pulse
   ) /* synthesis syn_preserve=1 syn_hier = "fixed" syn_noprune=1*/;

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
   parameter NUM_STAGES = 2;
   parameter SYNC_RESET = 0;
 
   wire aresetn;
   wire sresetn;

   assign aresetn = (SYNC_RESET == 1) ? 1'b1 : reset;
   assign sresetn = (SYNC_RESET == 1) ? reset : 1'b1;


   reg  [NUM_STAGES:0] sync_ff /* synthesis syn_preserve = 1 */;

   always @( posedge clk or negedge aresetn) 
     if(!aresetn | !sresetn)
       sync_ff <= 0;
     else 
       sync_ff <= {sync_ff[NUM_STAGES-1:0], data_in};
   
   assign sync_pulse = sync_ff[NUM_STAGES] ^ sync_ff[NUM_STAGES-1];

endmodule