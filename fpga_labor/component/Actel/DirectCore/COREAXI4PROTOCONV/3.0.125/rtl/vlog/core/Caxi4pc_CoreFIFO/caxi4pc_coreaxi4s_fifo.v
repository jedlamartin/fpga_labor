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

module caxi4pc_coreaxi4s_fifo #
(
   parameter                RESET_TYPE       = 0,   //
   parameter                SYNC             = 0,   // Synchronous or Asynchronous operation | 1 - Single Clock(Synchronous), 0 - Dual clock(Asynchronous)
   parameter                PIPE             = 1,   // 1: Address pipeline 2: address and data pipeline 
   parameter                ECC              = 0,   // 0: ECC disable , 1: ECC enable


   parameter                RAM_TYPE         = 0,   // 0 - Fabric 1 - uSRAM 2 - LSRAM
   parameter                NUM_STAGES       = 2,   // To select number of synchronizer stages.
   parameter                READ_MODE        = 0,   // 0: flow through mode  1: wait for tlast


   parameter                WFIFO_DEPTH       = 32,
   parameter                RFIFO_DEPTH       = 32,
   parameter                AXIS_TTDATA_WIDTH = 64,  // Bytes
   parameter                AXIS_ITDATA_WIDTH = 128,  // Bytes
   parameter                AXIS_TTID_WIDTH   = 32,  // Bits
   parameter                AXIS_ITID_WIDTH   = 32,  // Bits
   parameter                AXIS_TTDEST_WIDTH = 32,  // Bits
   parameter                AXIS_ITDEST_WIDTH = 32,  // Bits
   parameter                AXIS_TTUSER_WIDTH = 256, // Bits
   parameter                AXIS_ITUSER_WIDTH = 256, // Bits


   parameter                ENABLE_AFULL     = 1,
   parameter                AFULL_THR        = 32,
   parameter                ENABLE_TSTRB     = 1,
   parameter                ENABLE_TKEEP     = 1,
   parameter                ENABLE_TLAST     = 1,
   parameter                ENABLE_TUSER     = 1,
   parameter                ENABLE_TDEST     = 1,
   parameter                ENABLE_TID       = 1, 
   
   parameter                EOP_OFFSET       = 8,
   
   parameter                PKT_DROP_OVF     = 0,
   parameter                PKT_DROP_ERR     = 0

)(
      // --------------------------------------------------------------------------
   // I/O Declaration
   // --------------------------------------------------------------------------
   // AXI4 Stream Interface
   // ----------------------------------------
   // Inputs
   // ----------------------------------------
   // Clocks and Reset
   input                                AXI4S_ACLK,
   input                                AXI4S_IACLK,
   input                                AXI4S_TACLK,
   input                                AXI4S_ARESETN,
   input                                AXI4S_IARESETN,
   input                                AXI4S_TARESETN,
   //AXI4_S Initiator Port Interface Signals
   input                                AXI4S_ITREADY,
   output                               AXI4S_ITVALID,
   output [AXIS_ITDATA_WIDTH-1: 0]      AXI4S_ITDATA,
   output [(AXIS_ITDATA_WIDTH/8)-1: 0]  AXI4S_ITSTRB,
   output [(AXIS_ITDATA_WIDTH/8)-1: 0]  AXI4S_ITKEEP,
   output                               AXI4S_ITLAST,
   output [AXIS_ITID_WIDTH -1: 0]       AXI4S_ITID,
   output [AXIS_ITDEST_WIDTH -1: 0]     AXI4S_ITDEST,
   output [AXIS_ITUSER_WIDTH-1: 0]      AXI4S_ITUSER,

   //AXI4_S Target Port Interface Signals
   input                                AXI4S_TTVALID,
   input [AXIS_TTDATA_WIDTH - 1 : 0]    AXI4S_TTDATA,
   input [(AXIS_TTDATA_WIDTH/8)- 1: 0]  AXI4S_TTSTRB,
   input [(AXIS_TTDATA_WIDTH/8)- 1: 0]  AXI4S_TTKEEP,
   input                                AXI4S_TTLAST,
   input [AXIS_TTID_WIDTH - 1 : 0]      AXI4S_TTID,
   input [AXIS_TTDEST_WIDTH - 1 : 0]    AXI4S_TTDEST,
   input [AXIS_TTUSER_WIDTH - 1 : 0]    AXI4S_TTUSER,
   output                               AXI4S_TTREADY,

   //input [$clog2(WFIFO_AFULL_THR)-1:0]      AFULL_IN,
   output                               ALMOST_FULL,
   
   input                                pkt_err,
   output                               pkt_err_pl,
   output                               pkt_ovf_pl,
   output                               debug
);
   // --------------------------------------------------------------------------
   // Local PARAMETER Declaration
   // --------------------------------------------------------------------------
   //


   localparam  [0:0] UPDN_CNV        = (AXIS_TTDATA_WIDTH < AXIS_ITDATA_WIDTH); // 1 - UP conv 0 - down conv
   localparam  [7:0] DNCNV_RATIO     = ~UPDN_CNV ? (AXIS_TTDATA_WIDTH/AXIS_ITDATA_WIDTH) : 1;
   localparam  [7:0] UPCNV_RATIO     = UPDN_CNV ? (AXIS_ITDATA_WIDTH/AXIS_TTDATA_WIDTH) : 1;

   localparam   WWIDTH_CORE_LAST     = (ENABLE_TLAST == 0) ? (AXIS_TTDATA_WIDTH)    : (AXIS_TTDATA_WIDTH)+DNCNV_RATIO;
   localparam   WWIDTH_CORE_USER     = (ENABLE_TUSER == 0) ? (WWIDTH_CORE_LAST)     : (WWIDTH_CORE_LAST+(AXIS_TTUSER_WIDTH));
   localparam   WWIDTH_CORE_DEST     = (ENABLE_TDEST == 0) ? (WWIDTH_CORE_USER)     : (WWIDTH_CORE_USER+(AXIS_TTDEST_WIDTH * DNCNV_RATIO));
   localparam   WWIDTH_CORE_TID      = (ENABLE_TID   == 0) ? (WWIDTH_CORE_DEST)     : (WWIDTH_CORE_DEST+(AXIS_TTID_WIDTH * DNCNV_RATIO));
   localparam   WWIDTH_CORE_TKEEP    = (ENABLE_TKEEP == 0) ? (WWIDTH_CORE_TID)      : (WWIDTH_CORE_TID+(AXIS_TTDATA_WIDTH/8));
   localparam   WWIDTH_CORE_TSTRB    = (ENABLE_TSTRB == 0) ? (WWIDTH_CORE_TKEEP)    : (WWIDTH_CORE_TKEEP+(AXIS_TTDATA_WIDTH/8));


   localparam   RWIDTH_CORE_LAST     = (ENABLE_TLAST == 0) ? (AXIS_ITDATA_WIDTH)    : (AXIS_ITDATA_WIDTH)+UPCNV_RATIO;
   localparam   RWIDTH_CORE_USER     = (ENABLE_TUSER == 0) ? (RWIDTH_CORE_LAST)     : (RWIDTH_CORE_LAST+(AXIS_ITUSER_WIDTH));
   localparam   RWIDTH_CORE_DEST     = (ENABLE_TDEST == 0) ? (RWIDTH_CORE_USER)     : (RWIDTH_CORE_USER+(AXIS_ITDEST_WIDTH * UPCNV_RATIO));
   localparam   RWIDTH_CORE_TID      = (ENABLE_TID   == 0) ? (RWIDTH_CORE_DEST)     : (RWIDTH_CORE_DEST+(AXIS_ITID_WIDTH * DNCNV_RATIO));
   localparam   RWIDTH_CORE_TKEEP    = (ENABLE_TKEEP == 0) ? (RWIDTH_CORE_TID)      : (RWIDTH_CORE_TID+(AXIS_ITDATA_WIDTH/8));
   localparam   RWIDTH_CORE_TSTRB    = (ENABLE_TSTRB == 0) ? (RWIDTH_CORE_TKEEP)    : (RWIDTH_CORE_TKEEP+(AXIS_ITDATA_WIDTH/8));


   localparam   FIFO_WDATA_WIDTH     = WWIDTH_CORE_TSTRB;
   localparam   FIFO_RDATA_WIDTH     = RWIDTH_CORE_TSTRB;



   // Output Status Flags

   // --------------------------------------------------------------------------
   // Internal signals
   // --------------------------------------------------------------------------

   wire                              full_s;
   wire                              empty_s;
   wire                              wr_en_s;
   wire                              rd_en_s;

   wire [FIFO_RDATA_WIDTH -1 :0]     rd_data_axi4s_s;
   wire [FIFO_WDATA_WIDTH -1 :0]     wr_data_axi4s_s;

   wire 							 tlast_dis;
   wire 							 pkt_sop;
   wire								 pkt_eop;

  caxi4pc_corefifo
  #(
   .FAMILY         (27               ),
   .SYNC           (SYNC             ),
   .RWIDTH         (FIFO_RDATA_WIDTH ),
   .WWIDTH         (FIFO_WDATA_WIDTH ),
   .RDEPTH         (RFIFO_DEPTH      ),
   .WDEPTH         (WFIFO_DEPTH      ),
   .WRITE_ACK      (1'b0             ),
   .READ_DVALID    (1'b0             ),
   .CTRL_TYPE      (RAM_TYPE         ),
   .AE_STATIC_EN   (1'b0             ),
   .AF_STATIC_EN   (ENABLE_AFULL     ),
   .AF_DYN_EN      (1'b0             ),
   .AEVAL          (0                ),
   .AFVAL          (AFULL_THR        ),
   .PIPE           (PIPE             ),
   .PREFETCH       (1'b0             ),
   .FWFT           (1'b0             ),
   .ECC            (ECC              ),
   .NUM_STAGES     (NUM_STAGES       ),
   .SYNC_RESET     (RESET_TYPE       ),
   .PKT_DROP_OVF   (PKT_DROP_OVF     ),
   .PKT_DROP_ERR   (PKT_DROP_ERR	 )
  )
  u_caxi4pc_corefifo(
   .CLK        (AXI4S_ACLK      ),
   .WCLOCK     (AXI4S_TACLK     ),
   .RCLOCK     (AXI4S_IACLK     ),
   .RESET_N    (AXI4S_ARESETN   ),
   .WRESET_N   (AXI4S_TARESETN  ),
   .RRESET_N   (AXI4S_IARESETN  ),
   .DATA       (wr_data_axi4s_s ),
   .WE         (wr_en_s         ),
   .RE         (rd_en_s         ),
   .MEMRD      (),
   .SB_CORRECT (),
   .DB_DETECT  (),
   .Q          (rd_data_axi4s_s ),
   .FULL       (full_s          ),
   .EMPTY      (empty_s         ),
   .AFULL      (ALMOST_FULL     ),
   .AFULL_IN   (                ),
   .AEMPTY     (),
   .OVERFLOW   (),
   .UNDERFLOW  (),
   .WACK       (),
   .DVLD       (),
   .WRCNT      (),
   .RDCNT      (),
   .MEMWE      (),
   .MEMRE      (),
   .MEMWADDR   (),
   .MEMRADDR   (),
   .MEMWD      (),
   .pkt_err    (pkt_err        ),
   .sop 	   (pkt_sop		   ),
   .eop 	   (pkt_eop 	   ),
   .tlast_dis  (tlast_dis      ),
   .pkt_err_pl (pkt_err_pl	   ),
   .pkt_ovf_pl (pkt_ovf_pl	   ),
   .debug	   (debug  		   )
  );

   caxi4pc_corefifo_axi4s_if # (
      .SYNC                   (SYNC               ),
      .READ_MODE              (READ_MODE          ),
      .PIPE                   (PIPE               ),
      .ECC                    (ECC                ),
      .RESET_TYPE             (RESET_TYPE         ),
      .NUM_STAGES             (NUM_STAGES         ),
      .AXIS_TTDATA_WIDTH      (AXIS_TTDATA_WIDTH  ),
      .AXIS_ITDATA_WIDTH      (AXIS_ITDATA_WIDTH  ),
      .AXIS_TTID_WIDTH        (AXIS_TTID_WIDTH    ),
      .AXIS_ITID_WIDTH        (AXIS_ITID_WIDTH    ),
      .AXIS_TTDEST_WIDTH      (AXIS_TTDEST_WIDTH  ),
      .AXIS_ITDEST_WIDTH      (AXIS_ITDEST_WIDTH  ),
      .AXIS_TTUSER_WIDTH      (AXIS_TTUSER_WIDTH  ),
      .AXIS_ITUSER_WIDTH      (AXIS_ITUSER_WIDTH  ),
      .WWIDTH_CORE            (FIFO_WDATA_WIDTH   ),
      .RWIDTH_CORE            (FIFO_RDATA_WIDTH   ),

      .ENABLE_TSTRB           (ENABLE_TSTRB       ),
      .ENABLE_TKEEP           (ENABLE_TKEEP       ),
      .ENABLE_TLAST           (ENABLE_TLAST       ),
      .ENABLE_TUSER           (ENABLE_TUSER       ),
      .ENABLE_TDEST           (ENABLE_TDEST       ),
      .ENABLE_TID             (ENABLE_TID         ),
      .UPDN_CNV               (UPDN_CNV           ),
      .DNCNV_RATIO            (DNCNV_RATIO        ),
      .UPCNV_RATIO            (UPCNV_RATIO        ),
	  
	  .EOP_OFFSET             (EOP_OFFSET         ),
	  .PKT_DROP_OVF           (PKT_DROP_OVF       )
	  
   )
   u_caxi4pc_corefifo_axi4s_if (
      .M_AXIS_ACLK_i         (AXI4S_IACLK    ),
      .S_AXIS_ACLK_i         (AXI4S_TACLK    ),
      .M_AXIS_ARESETN_i      (AXI4S_IARESETN ),
      .S_AXIS_ARESETN_i      (AXI4S_TARESETN ),
      //Initiator Port Interface Signals
      .M_AXIS_TVALID_o       (AXI4S_ITVALID  ),
      .M_AXIS_TREADY_i       (AXI4S_ITREADY  ),
      .M_AXIS_TDATA_o        (AXI4S_ITDATA   ),
      .M_AXIS_TSTRB_o        (AXI4S_ITSTRB   ),
      .M_AXIS_TKEEP_o        (AXI4S_ITKEEP   ),
      .M_AXIS_TLAST_o        (AXI4S_ITLAST   ),
      .M_AXIS_TID_o          (AXI4S_ITID     ),
      .M_AXIS_TDEST_o        (AXI4S_ITDEST   ),
      .M_AXIS_TUSER_o        (AXI4S_ITUSER   ),
      //Target Port Interface Signals
      .S_AXIS_TVALID_i       (AXI4S_TTVALID  ),
      .S_AXIS_TREADY_o       (AXI4S_TTREADY  ),
      .S_AXIS_TDATA_i        (AXI4S_TTDATA   ),
      .S_AXIS_TSTRB_i        (AXI4S_TTSTRB   ),
      .S_AXIS_TKEEP_i        (AXI4S_TTKEEP   ),
      .S_AXIS_TLAST_i        (AXI4S_TTLAST   ),
      .S_AXIS_TID_i          (AXI4S_TTID     ),
      .S_AXIS_TDEST_i        (AXI4S_TTDEST   ),
      .S_AXIS_TUSER_i        (AXI4S_TTUSER   ),
      .FIFO_WR_DATA_AXI4_S_o (wr_data_axi4s_s),
      .FIFO_RD_DATA_AXI4_S_i (rd_data_axi4s_s),
      .FIFO_WE_EN_AXI4_S_o   (wr_en_s        ),
      .FIFO_RE_EN_AXI4_S_o   (rd_en_s        ),
      .FIFO_FULL_i           (full_s         ),
      .FIFO_EMPTY_i          (empty_s        ),
	  .sop 					 (pkt_sop 		 ),
	  .eop 					 (pkt_eop     	 ),
	  .tlast_dis             (tlast_dis      )
   );

endmodule
