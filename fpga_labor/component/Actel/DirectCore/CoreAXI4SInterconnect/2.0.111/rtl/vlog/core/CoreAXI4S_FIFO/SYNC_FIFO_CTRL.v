// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 39031 $
// SVN $Date: 2021-10-07 17:37:44 +0530 (Thu, 07 Oct 2021) $
// 
// IP Core : CoreAXI4SInterconnect
//
// Module  : SYNC_FIFO_CTRL
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/

`timescale 1ns / 1ns
module SYNC_FIFO_CTRL #
(
   parameter         RESET_TYPE    = 0,
   parameter integer FIFO_SIZE     = 24,
   parameter integer ADDRESS_WIDTH = 5
)
(
   // inputs
   clk,
   rst,
   wr_rqst,
   rd_rqst,
   //outputs
   wrptr,
   rdptr,
   fifo_full,
   fifo_empty
);

   // WIRES
   input clk;
   input rst;
   input wr_rqst;
   input rd_rqst;

   output [ADDRESS_WIDTH-1:0] wrptr;
   output [ADDRESS_WIDTH-1:0] rdptr; 
   output fifo_full;
   output fifo_empty;


   reg [ADDRESS_WIDTH-1:0] wrptr;
   reg [ADDRESS_WIDTH-1:0] rdptr; 
   reg fifo_full;
   reg fifo_empty;

   reg [ADDRESS_WIDTH:0]    entries_in_fifo;

   wire [ADDRESS_WIDTH-1:0] wrptr_next;
   wire [ADDRESS_WIDTH-1:0] rdptr_next; 

   wire we;
   wire re;
   
   wire a_rst;
   wire s_rst;

   wire [ADDRESS_WIDTH:0] entries_plus1;
   wire [ADDRESS_WIDTH:0] entries_minus1;

   assign a_rst = (RESET_TYPE == 1) ? 1'b1 : rst;
   assign s_rst = (RESET_TYPE == 1) ? rst : 1'b1;

   assign wrptr_next = (wrptr == (FIFO_SIZE-1)) ? 'b0 : (wrptr + 1);
   assign rdptr_next = (rdptr == (FIFO_SIZE-1)) ? 'b0 : (rdptr + 1); 
 
   assign we = wr_rqst & !fifo_full;
   assign re = rd_rqst & !fifo_empty;

   assign entries_plus1 = entries_in_fifo + 1;
   assign entries_minus1 = entries_in_fifo - 1;

   always @(posedge clk or negedge a_rst) begin
      if ((!a_rst) || (!s_rst)) begin
         fifo_full       <= 1'b0;
         fifo_empty      <= 1'b1;
	 entries_in_fifo <= 'b0;
	 wrptr           <= 'b0;
         rdptr           <= 'b0;
      end else begin
         if (we) wrptr <= wrptr_next;
         if (re) rdptr <= rdptr_next;
	 // Handle flags if writing and not reading
	 if (we & !re) begin
            fifo_empty <= 1'b0;
            if (wrptr_next == rdptr) begin
               fifo_full       <= 1'b1;
               entries_in_fifo <= FIFO_SIZE;
	    end else begin
               entries_in_fifo <= entries_plus1;		   
            end	 
	 end  
         // Handle flags if reading and not writing
         if (re & !we) begin
            fifo_full <= 1'b0;
            if (rdptr_next == wrptr) begin
               fifo_empty      <= 1'b1;
               entries_in_fifo <= 'b0;
            end else begin
               entries_in_fifo <= entries_minus1;		  
            end	 
         end  
      end
   end

endmodule
