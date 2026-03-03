// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 39713 $
// SVN $Date: 2021-12-17 19:22:00 +0530 (Fri, 17 Dec 2021) $
// 
// IP Core : CoreAXI4SInterconnect
//
// Module  : SYNC_RAM_BLOCK
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/

`timescale 1ns / 1ns
module SYNC_RAM_BLOCK #
   (
      parameter integer	ECC          = 0,
      parameter         RAM_TYPE     = 0,  // 0 - Fabric 1 - uSRAM 2 - LSRAM	
      parameter integer	MEM_DEPTH    = 1024,
      parameter integer	ADDR_WIDTH   = 10,
      parameter integer	DATA_WIDTH   = 32
   )
   (
      input  wire                  clk,
      input  wire                  wr_en,
      input  wire                  rd_en,	  
      input  wire [ADDR_WIDTH-1:0] rd_addr,
      input  wire [ADDR_WIDTH-1:0] wr_addr,
      input  wire [DATA_WIDTH-1:0] data_in,
      output reg  [DATA_WIDTH-1:0] data_out
   );

   generate 
      if(ECC ==1 && RAM_TYPE ==2 ) begin          // lsram , ECC enabled

         reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0] /*synthesis syn_ramstyle= "ecc , lsram"  */;
         
         always @(posedge clk) begin
		   if(rd_en)
             data_out <= mem[rd_addr];
         end

         always @(posedge clk) begin
            if (wr_en) begin
               mem[wr_addr] <= data_in;
            end
         end
      end else if (ECC ==1 && RAM_TYPE ==1 ) begin // uram , ECC enabled

         reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0]  /*synthesis syn_ramstyle= "ecc , uram"  */;
		 
         always @(posedge clk) begin
		   if(rd_en)
             data_out <= mem[rd_addr];
         end
		 
         always @(posedge clk) begin
            if (wr_en) begin
               mem[wr_addr] <= data_in;
            end
         end
      end else if (ECC ==0 && RAM_TYPE ==2 ) begin // lsram , ECC disabled

         reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0]  /*synthesis syn_ramstyle= "lsram"  */;
		 
         always @(posedge clk) begin
		   if(rd_en)
             data_out <= mem[rd_addr];
         end
		 
         always @(posedge clk) begin
            if (wr_en) begin
               mem[wr_addr] <= data_in;
            end
         end
      end else if (ECC ==0 && RAM_TYPE ==1 ) begin // uram , ECC disabled

         reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0]  /*synthesis syn_ramstyle= "uram"  */;
		 
         always @(posedge clk) begin
		   if(rd_en)
             data_out <= mem[rd_addr];
         end
		 
         always @(posedge clk) begin
            if (wr_en) begin
               mem[wr_addr] <= data_in;
            end
         end
      end else if (ECC ==0 && RAM_TYPE ==0 ) begin // registers , ECC disabled

         reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0] /*synthesis syn_ramstyle= "registers"  */;
		 
         always @(posedge clk) begin
		   if(rd_en)
             data_out <= mem[rd_addr];
         end
		 
         always @(posedge clk) begin
            if (wr_en) begin
               mem[wr_addr] <= data_in;
            end
         end
      end 

   endgenerate
endmodule
