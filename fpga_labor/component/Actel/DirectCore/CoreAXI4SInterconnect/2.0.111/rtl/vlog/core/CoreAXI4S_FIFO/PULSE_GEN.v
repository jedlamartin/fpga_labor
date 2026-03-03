// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 39813 $
// SVN $Date: 2022-01-07 16:35:31 +0530 (Fri, 07 Jan 2022) $
// 
// IP Core : CoreAXI4SInterconnect
//
// Module  : PULSE_GEN
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/
`timescale 1ns / 1ns
module PULSE_GEN
   (
      input  src_clk,
      input  src_reset,
      input  pulse_in,
      output reg toggle_out
   ) /* synthesis syn_hier="fixed" */;

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
   parameter SYNC_RESET = 0;

   wire aresetn;
   wire sresetn;

   assign aresetn = (SYNC_RESET == 1) ? 1'b1 : src_reset;
   assign sresetn = (SYNC_RESET == 1) ? src_reset : 1'b1;

   always @( posedge src_clk or negedge aresetn) begin
      if ((!aresetn) || (!sresetn)) begin
         toggle_out <= 1'b0;
      end else begin
         if (pulse_in) begin
            toggle_out <= ~toggle_out;
         end
      end
   end
endmodule
