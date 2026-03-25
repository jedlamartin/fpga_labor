// **************************************************************************
// Microchip Corporation Proprietary and Confidential
// Copyright 2024 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description : 
//
// SVN Revision Information :
// SVN $Revision : $
// SVN $Date : $
// 
// Revision Information :
// Date    SAR    Description
//
// Notes :
//
// **************************************************************************

`timescale 1ns / 100ps

module caxi4pc_corefifo_NstagesSync(
                  clk,
                  //rstn,
                  arstn,//added in v3.0
                  srstn,//added in v3.0
                  inp,
                  sync_out
                  );

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
  parameter NUM_STAGES = 2;
  parameter ADDRWIDTH = 3;

input clk;
//input rstn;commented in v3.0
input arstn;//added in v3.0
input srstn;//added in v3.0
input [ADDRWIDTH : 0 ] inp;
output [ADDRWIDTH : 0 ] sync_out;

//reg [WIDTH -1:0] signal_out;

reg [ADDRWIDTH : 0 ] shift_mem_reg [NUM_STAGES-1:0] ;


integer i;
always @ ( posedge clk or negedge arstn)
  begin
    if (!arstn | !srstn)
      begin
        for(i=0; i< NUM_STAGES; i = i+1)
          begin
		    shift_mem_reg[i] <= 'h0;
          end
      end
  else
    begin
	  for(i=0; i< NUM_STAGES; i = i+1) begin 
	    if(i == 0)
		  shift_mem_reg[i] <= inp;
		else 
		  shift_mem_reg[i] <= shift_mem_reg[i-1];
	  end
    end
end

assign sync_out = shift_mem_reg[NUM_STAGES-1];



endmodule // corefifo_doubleSync

   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
