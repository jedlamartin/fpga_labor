/******************************************************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2021 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// SVN Revision Information:
// SVN $Revision: 40738 $
// SVN $Date: 2022-06-08 20:42:30 +0530 (Wed, 08 Jun 2022) $
// 
// IP Core : CoreAXI4SInterconnect
//
// Module  : ASYNC_FIFO
// 
//
// Abstract : This is a sub module of CoreAXI4SInterconnect IP. 
// Notes    :
// ******************************************************************************************************/


`timescale 1ns / 1ns
module ASYNC_FIFO #

   (
      parameter integer  MEM_DEPTH         = 4,
      parameter          RESET_TYPE        = 0,
      parameter          RAM_TYPE          = 0,  // 0 - Fabric 1 - uSRAM 2 - LSRAM	
      parameter          ECC               = 1,
      parameter integer  DATA_WIDTH        = 20,
      parameter integer  NUM_STAGES        = 2
   )
   (
      input wire                     W_RST_N,
      input wire                     R_RST_N,
      input wire                     CLK_WR,
      input wire                     CLK_RD,
      input wire                     WR_EN,
      input wire                     RD_EN,
      input wire [DATA_WIDTH-1:0]    DATA_IN,

      output wire [DATA_WIDTH-1:0]   DATA_OUT,
      output reg                     FIFO_FULL,
      output reg                     FIFO_EMPTY
   );



   // parameter SYNC_RESET = (FAMILY == 25) ? 1 : 0;

   localparam FIFO_ADDR_WIDTH = (MEM_DEPTH < 4) ? 2 : $clog2(MEM_DEPTH);

   wire AW_RST_N;
   wire SW_RST_N;
   wire AR_RST_N;
   wire SR_RST_N;
 
   wire fifoWe;
   wire fifoRe;

   wire [DATA_WIDTH-1:0]      infoOut_reg;
  
					   
   reg [((FIFO_ADDR_WIDTH+1)*NUM_STAGES)-1 : 0 ] wrptr_sync_ff /* synthesis syn_preserve = 1 */;
   reg [((FIFO_ADDR_WIDTH+1)*NUM_STAGES)-1 : 0 ] rdptr_sync_ff /* synthesis syn_preserve = 1 */;

   integer i,j;

   reg [FIFO_ADDR_WIDTH:0]  wbin;
   reg [FIFO_ADDR_WIDTH:0]  wgrey /* synthesis syn_preserve = 1 */;
   wire [FIFO_ADDR_WIDTH:0] wgraynext, wbinnext,rptr_gray_sync;
   reg  [FIFO_ADDR_WIDTH:0] rptr_bin_sync;
   reg  [FIFO_ADDR_WIDTH:0] rptr_bin_sync2;
   reg  [FIFO_ADDR_WIDTH:0] rdiff_bus;
   wire wfull_val;
   
   reg [FIFO_ADDR_WIDTH:0]  rbin;
   reg [FIFO_ADDR_WIDTH:0]  rgrey /* synthesis syn_preserve = 1 */;
   wire [FIFO_ADDR_WIDTH:0] rgraynext,rbinnext,wptr_gray_sync;
   reg  [FIFO_ADDR_WIDTH:0] wptr_bin_sync;
   reg  [FIFO_ADDR_WIDTH:0] wptr_bin_sync2;
   reg  [FIFO_ADDR_WIDTH:0] wdiff_bus;
   wire rempty_val;
   
   wire [FIFO_ADDR_WIDTH-1:0] waddr,raddr;
   
   assign AW_RST_N = (RESET_TYPE == 1) ? 1'b1 : W_RST_N;
   assign SW_RST_N = (RESET_TYPE == 1) ? W_RST_N : 1'b1;
   assign AR_RST_N = (RESET_TYPE == 1) ? 1'b1 : R_RST_N;
   assign SR_RST_N = (RESET_TYPE == 1) ? R_RST_N : 1'b1;

   assign DATA_OUT   = infoOut_reg;
   assign fifoWe     = (WR_EN & ~FIFO_FULL);
   assign fifoRe     = (RD_EN & ~FIFO_EMPTY);

   
  // generate 
  // if (ECC == 1) begin   
      ASYNC_RAM_BLOCK#
      (
         .ECC          ( ECC ),
         .RAM_TYPE     ( RAM_TYPE ),
         .MEM_DEPTH    ( 2**(FIFO_ADDR_WIDTH) ),
         .ADDR_WIDTH   ( FIFO_ADDR_WIDTH ),
         .DATA_WIDTH   ( DATA_WIDTH ) 
      )
      ram (
         .clk_wr       ( CLK_WR ),
         .clk_rd       ( CLK_RD ),
         .wr_en        ( fifoWe ),
		 .rd_en        ( fifoRe ),
         .wr_addr      ( waddr ),
         .rd_addr      ( raddr ),
         .data_in      ( DATA_IN ),
         .data_out     ( infoOut_reg )
      );

 
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////Write CLOCK DOMAIN ////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 
  // GRAYSTYLE2 pointer
   always @(posedge CLK_WR or negedge AW_RST_N)
     if (!AW_RST_N | !SW_RST_N) 
	   {wbin, wgrey} <= 0;
     else 
	   {wbin, wgrey} <= {wbinnext, wgraynext};
	   
// Memory write-address pointer (okay to use binary to address memory)
   assign waddr = wbin[FIFO_ADDR_WIDTH-1:0];
   
   assign wbinnext = wbin + fifoWe;
   
   assign wgraynext = (wbinnext>>1) ^ wbinnext;
   
   always@(*) 
     wdiff_bus = (wbinnext - rptr_bin_sync2);
	 
   always @(*) begin	
      rptr_bin_sync[FIFO_ADDR_WIDTH]  = rptr_gray_sync[FIFO_ADDR_WIDTH];      	
      for(i=FIFO_ADDR_WIDTH;i>0;i = i-1) begin
         rptr_bin_sync[i-1]     = (rptr_bin_sync[i] ^ rptr_gray_sync[i-1]);
      end	 
   end 
   
   always @(posedge CLK_WR or negedge AW_RST_N)
     begin
        if(!AW_RST_N | !SW_RST_N) begin
          rptr_bin_sync2  <= 'h0;
        end
        else begin
     	  rptr_bin_sync2 <= rptr_bin_sync;
        end
     end
   
//------------------------------------------------------------------
// Simplified version of the three necessary full-tests:
// assign wfull_val=((wgnext[FIFO_ADDR_WIDTH] !=wq2_rgrey[FIFO_ADDR_WIDTH] ) &&
// (wgnext[FIFO_ADDR_WIDTH-1] !=wq2_rgrey[FIFO_ADDR_WIDTH-1]) &&
// (wgnext[FIFO_ADDR_WIDTH-2:0]==wq2_rgrey[FIFO_ADDR_WIDTH-2:0]));
//------------------------------------------------------------------
   assign wfull_val  = WR_EN ?  (wdiff_bus > (MEM_DEPTH-1)) : 
                                (wdiff_bus >= (MEM_DEPTH));    
   
   always @(posedge CLK_WR or negedge AW_RST_N)
     if (!AW_RST_N | !SW_RST_N) 
       FIFO_FULL <= 1'b0;
     else if(wfull_val)
       FIFO_FULL <= 1'b1;
	 else 
	   FIFO_FULL <= 1'b0;
      
   //KA - Added support of NUM_STAGES synchronizer
   always @ ( posedge CLK_WR or negedge AW_RST_N)     	
     if(!AW_RST_N | !SW_RST_N)
       rdptr_sync_ff <= {((FIFO_ADDR_WIDTH+1)*NUM_STAGES){1'b0}};
     else 
       rdptr_sync_ff <= {rdptr_sync_ff[((FIFO_ADDR_WIDTH+1)*(NUM_STAGES-1))-1:0],rgrey};

    assign rptr_gray_sync = rdptr_sync_ff [((FIFO_ADDR_WIDTH+1)*NUM_STAGES)-1:((FIFO_ADDR_WIDTH+1)*(NUM_STAGES-1))];
	
	
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////READ CLOCK DOMAIN ////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   always @(posedge CLK_RD or negedge AR_RST_N)
     if (!AR_RST_N | !SR_RST_N) 
	   {rbin,rgrey} <= 0;
     else 
	   {rbin,rgrey} <= {rbinnext,rgraynext};
	   
   // Memory read-address pointer (okay to use binary to address memory)
   assign raddr         = rbin[FIFO_ADDR_WIDTH-1:0];
   assign rbinnext      = rbin + fifoRe;
   assign rgraynext     = (rbinnext>>1) ^ rbinnext;
//---------------------------------------------------------------
// FIFO empty when the next rgrey == synchronized wptr or on reset
//---------------------------------------------------------------
   assign rempty_val = (rdiff_bus < 1);
   
   always @(posedge CLK_RD or negedge AR_RST_N)
     if (!AR_RST_N | !SR_RST_N) 
	   FIFO_EMPTY <= 1'b1;
     else if((fifoRe & (rdiff_bus == 0))) 
	   FIFO_EMPTY <= 1'b1;	
     else if((RD_EN & (rdiff_bus == 1))) 
	   FIFO_EMPTY <= 1'b0;	
	 else 
	   FIFO_EMPTY <= rempty_val;	 
	
   //KA - Added support of NUM_STAGES synchronizer

   always @ ( posedge CLK_RD or negedge AR_RST_N)     	
     if(!AR_RST_N | !SR_RST_N)
       wrptr_sync_ff <= {((FIFO_ADDR_WIDTH+1)*NUM_STAGES){1'b0}};
     else 
       wrptr_sync_ff <= {wrptr_sync_ff[((FIFO_ADDR_WIDTH+1)*(NUM_STAGES-1))-1:0],wgrey};


    assign wptr_gray_sync = wrptr_sync_ff [((FIFO_ADDR_WIDTH+1)*NUM_STAGES)-1:((FIFO_ADDR_WIDTH+1)*(NUM_STAGES-1))];
	
	
    always @(*) begin
	
      wptr_bin_sync[FIFO_ADDR_WIDTH]  = wptr_gray_sync[FIFO_ADDR_WIDTH];      
	
      for(j=FIFO_ADDR_WIDTH;j>0;j = j-1) begin
         wptr_bin_sync[j-1]     = (wptr_bin_sync[j] ^ wptr_gray_sync[j-1]);
      end
	end

   always @(posedge CLK_RD or negedge AR_RST_N)
     begin
        if(!AR_RST_N | !SR_RST_N) 
          wptr_bin_sync2  <= 'h0;
        else
          wptr_bin_sync2 <= wptr_bin_sync;
     end
	 
   always@(*) 
     rdiff_bus = (wptr_bin_sync2 - rbinnext);	 

endmodule
