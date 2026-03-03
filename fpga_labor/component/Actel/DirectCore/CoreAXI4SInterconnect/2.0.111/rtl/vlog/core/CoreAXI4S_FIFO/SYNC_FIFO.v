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
// Module  : SYNC_FIFO
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/

`timescale 1ns / 1ns
module SYNC_FIFO #

  (
    parameter          RESET_TYPE          = 0,
    parameter          RAM_TYPE            = 0,  // 0 - Fabric 1 - uSRAM 2 - LSRAM	
    parameter          ECC                 = 0,
    parameter integer  MEM_DEPTH           = 512,
    parameter integer  DATA_WIDTH          = 32
  )
  (
      rst,
      clk,
      wr_en,
      rd_en,
      data_in,

      data_out,
      fifo_full,
      fifo_empty
  );

  localparam FIFO_SIZE = ($clog2(MEM_DEPTH) < 2) ? 4 : MEM_DEPTH;
  localparam FIFO_ADDR_WIDTH = ($clog2(MEM_DEPTH) < 2) ? 2 : $clog2(MEM_DEPTH);
 
     input rst;
     input clk;

     input wr_en;
     input rd_en;
     input [DATA_WIDTH -1 : 0] data_in;

     output [DATA_WIDTH -1 : 0] data_out;

     output fifo_full;
     output fifo_empty;
	 
	 
     wire  rst;
     wire  clk;

     wire  wr_en;
     wire  rd_en;
     wire [DATA_WIDTH -1:0] data_in;

     wire [DATA_WIDTH -1:0] data_out;
     wire fifo_full;
     wire fifo_empty;
   
     wire  [FIFO_ADDR_WIDTH-1:0] wr_addr;
     wire  [FIFO_ADDR_WIDTH-1:0] rd_addr;


     wire  [DATA_WIDTH -1:0] data_in_fifo ;
     wire  wr_en_fifo;
  

   SYNC_RAM_BLOCK #
   (  
      .ECC          ( ECC ),
      .RAM_TYPE     ( RAM_TYPE ),
      .MEM_DEPTH    ( FIFO_SIZE ),
      .ADDR_WIDTH   ( FIFO_ADDR_WIDTH ),
      .DATA_WIDTH   ( DATA_WIDTH )
   )
   ram (
      .clk            ( clk ),
      .wr_en          ( wr_en_fifo ),
	  .rd_en          ( rd_en ),
      .rd_addr        ( rd_addr[FIFO_ADDR_WIDTH-1:0] ),
      .wr_addr        ( wr_addr[FIFO_ADDR_WIDTH-1:0] ),
      .data_in        ( data_in_fifo ),
      .data_out       ( data_out )
   );

   assign data_in_fifo =  data_in;
   assign wr_en_fifo   =    wr_en;
   
   SYNC_FIFO_CTRL #
   (
      .RESET_TYPE     ( RESET_TYPE ),
      .FIFO_SIZE      ( FIFO_SIZE ),
      .ADDRESS_WIDTH  ( FIFO_ADDR_WIDTH )
   )
   fifo_ctrl_inst (
      .clk            ( clk ),
      .rst            ( rst ),
      .wr_rqst	      ( wr_en_fifo),  
      .rd_rqst	      ( rd_en ), 	  
      .wrptr	      ( wr_addr ),
      .rdptr	      ( rd_addr ),
      .fifo_full      ( fifo_full ),
      .fifo_empty     ( fifo_empty )
   );

endmodule

