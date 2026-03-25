`timescale 1 ns / 100 ps
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
module caxi4pc_buff_upcnv #(
  parameter W_DWIDTH    = 64,
  parameter W_MEM_SIZE  = 8192,
  parameter W_ADDRWIDTH = 13,
  parameter R_DWIDTH    = 128,
  parameter R_MEM_SIZE  = 4096,
  parameter R_ADDRWIDTH = 12,
  parameter RAM_SEL     = 2,
  parameter PIPE = 2
  )(
  input  wire w_clk,
  input  wire r_clk,
  input  wire w_en,
  input  wire r_en,
  input  wire [W_ADDRWIDTH:0] w_addr,
  input  wire [R_ADDRWIDTH:0] r_addr,
  input  wire [W_DWIDTH-1:0] w_data,
  output wire [R_DWIDTH-1:0] r_data
  );

  generate
    if(RAM_SEL == 2) //LSRAM
    begin  : rxbuf_lsram
      caxi4pc_buff_upcnv_lsram #(
        .W_DWIDTH( W_DWIDTH ),
        .W_MEM_SIZE ( W_MEM_SIZE ),
        .W_ADDRWIDTH ( W_ADDRWIDTH ),
        .R_DWIDTH ( R_DWIDTH ),
        .R_MEM_SIZE ( R_MEM_SIZE ),
        .R_ADDRWIDTH ( R_ADDRWIDTH ),
        .PIPE ( PIPE )
        ) u_caxi4pc_buff_upcnv_lsram (
        .w_clk ( w_clk ),
        .r_clk ( r_clk ),
        .w_en  ( w_en ),
        .r_en  ( r_en ),
        .w_addr( w_addr ),
        .r_addr( r_addr ),
        .w_data( w_data ),
        .r_data( r_data )
      );
      end
      else if(RAM_SEL == 3)  //URAM
      begin : rxbuf_uram
        caxi4pc_buff_upcnv_usram #(
          .W_DWIDTH( W_DWIDTH ),
          .W_MEM_SIZE ( W_MEM_SIZE ),
          .W_ADDRWIDTH ( W_ADDRWIDTH ),
          .R_DWIDTH ( R_DWIDTH ),
          .R_MEM_SIZE ( R_MEM_SIZE ),
          .R_ADDRWIDTH ( R_ADDRWIDTH ),
          .PIPE ( PIPE )
          ) u_caxi4pc_buff_upcnv_usram (
          .w_clk ( w_clk ),
          .r_clk ( r_clk ),
          .w_en  ( w_en ),
          .r_en  ( r_en ),
          .w_addr( w_addr ),
          .r_addr( r_addr ),
          .w_data( w_data ),
          .r_data( r_data )
        );
        end
        else begin :rxbuf_reg
        caxi4pc_buff_upcnv_reg #( //FPGA Resources
          .W_DWIDTH( W_DWIDTH ),
          .W_MEM_SIZE ( W_MEM_SIZE ),
          .W_ADDRWIDTH ( W_ADDRWIDTH ),
          .R_DWIDTH ( R_DWIDTH ),
          .R_MEM_SIZE ( R_MEM_SIZE ),
          .R_ADDRWIDTH ( R_ADDRWIDTH ),
          .PIPE ( PIPE )
          ) u_caxi4pc_buff_upcnv_lut (
          .w_clk ( w_clk ),
          .r_clk ( r_clk ),
          .w_en  ( w_en ),
          .r_en  ( r_en ),
          .w_addr( w_addr ),
          .r_addr( r_addr ),
          .w_data( w_data ),
          .r_data( r_data )
        );
        end
      endgenerate
endmodule
