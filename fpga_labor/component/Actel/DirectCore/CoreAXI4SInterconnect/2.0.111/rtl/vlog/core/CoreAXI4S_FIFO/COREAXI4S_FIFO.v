// ******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 40494 $
// SVN $Date: 2022-04-22 20:31:25 +0530 (Fri, 22 Apr 2022) $
// 
// IP Core : CoreAXI4SInterconnect
//
// Module  : COREAXI4S_FIFO
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP , COREAXI4S_FIFO is a configurable Soft FIFO controller with AXI4 Stream Interface. 
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 1ns

module COREAXI4S_FIFO (
                 // Clocks and Reset
                 AXI4S_IACLK,
                 AXI4S_TACLK,
                 AXI4S_IARESETN,
                 AXI4S_TARESETN,
                 //Master Port Interface Signals
                 AXI4S_ITVALID,
                 AXI4S_ITREADY,
                 AXI4S_ITDATA,
                 AXI4S_ITSTRB,
                 AXI4S_ITKEEP,
                 AXI4S_ITLAST,
                 AXI4S_ITID,
                 AXI4S_ITDEST,
                 AXI4S_ITUSER,
                 //Slave Port Interface Signals
                 AXI4S_TTVALID,
                 AXI4S_TTREADY,
                 AXI4S_TTDATA,
                 AXI4S_TTSTRB,
                 AXI4S_TTKEEP,
                 AXI4S_TTLAST,
                 AXI4S_TTID,
                 AXI4S_TTDEST,
                 AXI4S_TTUSER
                 );
   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
   //
   parameter                RESET_TYPE       = 0;   //
   parameter                SYNC             = 0;   // Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
   parameter                ECC              = 0;   // 0: ECC disable , 1: ECC enable


   parameter                RAM_TYPE         = 0;   // 0 - Fabric 1 - uSRAM 2 - LSRAM	
   parameter                NUM_STAGES       = 2;   // To select number of synchronizer stages.
   parameter                READ_MODE        = 0;   // 0: flow through mode  1: wait for tlast


   parameter                FIFO_DEPTH       = 32;
   parameter                AXIS_TDATA_WIDTH = 32;  // Bytes
   parameter                AXIS_TID_WIDTH   = 32;  // Bits 
   parameter                AXIS_TDEST_WIDTH = 32;  // Bits
   parameter                AXIS_TUSER_WIDTH = 256; // Bits  

   
   parameter                ENABLE_TSTRB     = 1;
   parameter                ENABLE_TKEEP     = 1;
   parameter                ENABLE_TLAST     = 1;
   parameter                ENABLE_TUSER     = 1;
   parameter                ENABLE_TDEST     = 1;
   parameter                ENABLE_TID       = 1;
      
    
  
   localparam   WIDTH_CORE_LAST     = (ENABLE_TLAST == 0) ? (8*AXIS_TDATA_WIDTH)  : (8*AXIS_TDATA_WIDTH)+1;
   localparam   WIDTH_CORE_USER     = (ENABLE_TUSER == 0) ? (WIDTH_CORE_LAST)     : (WIDTH_CORE_LAST+AXIS_TUSER_WIDTH);
   localparam   WIDTH_CORE_DEST     = (ENABLE_TDEST == 0) ? (WIDTH_CORE_USER)     : (WIDTH_CORE_USER+AXIS_TDEST_WIDTH);
   localparam   WIDTH_CORE_TID      = (ENABLE_TID   == 0) ? (WIDTH_CORE_DEST)     : (WIDTH_CORE_DEST+AXIS_TID_WIDTH);
   localparam   WIDTH_CORE_TKEEP    = (ENABLE_TKEEP == 0) ? (WIDTH_CORE_TID)      : (WIDTH_CORE_TID+AXIS_TDATA_WIDTH);
   localparam   WIDTH_CORE_TSTRB    = (ENABLE_TSTRB == 0) ? (WIDTH_CORE_TKEEP)    : (WIDTH_CORE_TKEEP+AXIS_TDATA_WIDTH);

   localparam   FIFO_DATA_WIDTH     = WIDTH_CORE_TSTRB;


   // --------------------------------------------------------------------------
   // I/O Declaration
   // --------------------------------------------------------------------------
   // AXI4 Stream Interface
   // ----------------------------------------
   // Inputs
   // ----------------------------------------
   // Clocks and Reset
   input                                AXI4S_IACLK;
   input                                AXI4S_TACLK;
   input                                AXI4S_IARESETN;
   input                                AXI4S_TARESETN;
   //AXI4_S Master Port Interface Signals
   input                                AXI4S_ITREADY;
   output                               AXI4S_ITVALID;
   output [(8*AXIS_TDATA_WIDTH) -1: 0]  AXI4S_ITDATA;
   output [AXIS_TDATA_WIDTH-1: 0]       AXI4S_ITSTRB;
   output [AXIS_TDATA_WIDTH-1: 0]       AXI4S_ITKEEP;
   output                               AXI4S_ITLAST;
   output [AXIS_TID_WIDTH -1: 0]        AXI4S_ITID;
   output [AXIS_TDEST_WIDTH -1: 0]      AXI4S_ITDEST;
   output [AXIS_TUSER_WIDTH-1: 0]       AXI4S_ITUSER;

   //AXI4_S Slave Port Interface Signals
   input                                AXI4S_TTVALID;
   input [(8*AXIS_TDATA_WIDTH) - 1 : 0] AXI4S_TTDATA;
   input [AXIS_TDATA_WIDTH - 1 : 0]     AXI4S_TTSTRB;
   input [AXIS_TDATA_WIDTH - 1 : 0]     AXI4S_TTKEEP;
   input                                AXI4S_TTLAST;
   input [AXIS_TID_WIDTH - 1 : 0]       AXI4S_TTID;
   input [AXIS_TDEST_WIDTH - 1 : 0]     AXI4S_TTDEST; 
   input [AXIS_TUSER_WIDTH - 1 : 0]     AXI4S_TTUSER;
   output                               AXI4S_TTREADY;

   // Output Status Flags

   // --------------------------------------------------------------------------
   // Internal signals
   // --------------------------------------------------------------------------

   wire                              full_s;
   wire                              empty_s;
   wire                              wr_en_s;
   wire                              rd_en_s;

   wire [FIFO_DATA_WIDTH -1 :0]      rd_data_axi4s_s;
   wire [FIFO_DATA_WIDTH -1 :0]      wr_data_axi4s_s;



   generate 
      if (SYNC == 0) begin   
      ASYNC_FIFO #(
         .RESET_TYPE            (RESET_TYPE),
         .ECC                   (ECC),
         .RAM_TYPE              (RAM_TYPE),
         .MEM_DEPTH             (FIFO_DEPTH),
         .DATA_WIDTH            (FIFO_DATA_WIDTH),
         .NUM_STAGES            (NUM_STAGES)		 
      )
      U_CDCFIFO (
         .W_RST_N               (AXI4S_TARESETN),
         .R_RST_N               (AXI4S_IARESETN),
         .CLK_WR                (AXI4S_TACLK),
         .CLK_RD                (AXI4S_IACLK),
         .WR_EN                 (wr_en_s),
         .RD_EN                 (rd_en_s),
         .DATA_IN               (wr_data_axi4s_s),
         .DATA_OUT              (rd_data_axi4s_s),
         .FIFO_FULL             (full_s),
         .FIFO_EMPTY            (empty_s)
      );
      end
      else if (SYNC ==1 ) begin
      SYNC_FIFO #(
         .RESET_TYPE            (RESET_TYPE),
         .RAM_TYPE              (RAM_TYPE),
         .ECC                   (ECC),
         .MEM_DEPTH             (FIFO_DEPTH),
         .DATA_WIDTH            (FIFO_DATA_WIDTH)
      )
      U_SYNCFIFO(
         .rst                   (AXI4S_TARESETN),
         .clk                   (AXI4S_TACLK),
         .wr_en                 (wr_en_s),
         .rd_en                 (rd_en_s),
         .data_in               (wr_data_axi4s_s),
         .data_out              (rd_data_axi4s_s),
         .fifo_full             (full_s),
         .fifo_empty            (empty_s)
  );
      end
   endgenerate




   COREFIFO_AXI4S_IF #(
      .SYNC                  (SYNC),
      .READ_MODE             (READ_MODE),
      .RESET_TYPE            (RESET_TYPE),
      .NUM_STAGES            (NUM_STAGES),
      .AXIS_TDATA_WIDTH      (AXIS_TDATA_WIDTH),
      .AXIS_TID_WIDTH        (AXIS_TID_WIDTH),
      .AXIS_TDEST_WIDTH      (AXIS_TDEST_WIDTH),
      .AXIS_TUSER_WIDTH      (AXIS_TUSER_WIDTH),
      .WWIDTH_CORE           (FIFO_DATA_WIDTH),

      .ENABLE_TSTRB          (ENABLE_TSTRB),
      .ENABLE_TKEEP          (ENABLE_TKEEP),
      .ENABLE_TLAST          (ENABLE_TLAST),
      .ENABLE_TUSER          (ENABLE_TUSER),
      .ENABLE_TDEST          (ENABLE_TDEST),
      .ENABLE_TID            (ENABLE_TID)
   )
   U_COREFIFO_AXI4_S_IF (
      .M_AXIS_ACLK_i         (AXI4S_IACLK),
      .S_AXIS_ACLK_i         (AXI4S_TACLK),
      .M_AXIS_ARESETN_i      (AXI4S_IARESETN),
      .S_AXIS_ARESETN_i      (AXI4S_TARESETN),
      //Master Port Interface Signals
      .M_AXIS_TVALID_o       (AXI4S_ITVALID),
      .M_AXIS_TREADY_i       (AXI4S_ITREADY),
      .M_AXIS_TDATA_o        (AXI4S_ITDATA),
      .M_AXIS_TSTRB_o        (AXI4S_ITSTRB),
      .M_AXIS_TKEEP_o        (AXI4S_ITKEEP),
      .M_AXIS_TLAST_o        (AXI4S_ITLAST),
      .M_AXIS_TID_o          (AXI4S_ITID),
      .M_AXIS_TDEST_o        (AXI4S_ITDEST),
      .M_AXIS_TUSER_o        (AXI4S_ITUSER),
      //Slave Port Interface Signals
      .S_AXIS_TVALID_i       (AXI4S_TTVALID),
      .S_AXIS_TREADY_o       (AXI4S_TTREADY),
      .S_AXIS_TDATA_i        (AXI4S_TTDATA),
      .S_AXIS_TSTRB_i        (AXI4S_TTSTRB),
      .S_AXIS_TKEEP_i        (AXI4S_TTKEEP),
      .S_AXIS_TLAST_i        (AXI4S_TTLAST),
      .S_AXIS_TID_i          (AXI4S_TTID),
      .S_AXIS_TDEST_i        (AXI4S_TTDEST),
      .S_AXIS_TUSER_i        (AXI4S_TTUSER),
      .FIFO_WR_DATA_AXI4_S_o (wr_data_axi4s_s),
      .FIFO_RD_DATA_AXI4_S_i (rd_data_axi4s_s),
      .FIFO_WE_EN_AXI4_S_o   (wr_en_s),
      .FIFO_RE_EN_AXI4_S_o   (rd_en_s),
      .FIFO_FULL_i           (full_s),
      .FIFO_EMPTY_i          (empty_s)
   );

endmodule 
