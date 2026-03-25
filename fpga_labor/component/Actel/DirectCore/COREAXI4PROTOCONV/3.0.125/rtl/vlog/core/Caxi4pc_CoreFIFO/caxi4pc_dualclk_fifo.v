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
module caxi4pc_dualclk_fifo(
//clk_wr     , // Clock input
//clk_rd     , // Clock input
clk,
aresetn,
sresetn,

//rst      , 
//rdclk_rst      ,

rd_en    , // Read enable
wr_en    , // Write Enable
load_prevpkt_waddr, //Load previous packet write address
waddr_hold,
we_ctrl,
memwaddr,
memwe,
memraddr,
memre,
fifo_empty    , // FIFO empty
fifo_full     ,  // FIFO full
sop,
pkt_drop_pl
);    
 
// FIFO constants
//parameter DATA_WIDTH 	   = 8;
//parameter ADDR_WIDTH       = 8;
parameter WRITE_DEPTH      = 10;
parameter READ_DEPTH       = WRITE_DEPTH;
parameter PREFETCH         = 1;
parameter FWFT             = 0;
parameter WRITE_LOW        = 1;
parameter READ_LOW         = 1;
parameter FULL_WRITE_DEPTH = 1024;
parameter FULL_READ_DEPTH  = 1024;
parameter WCLK_HIGH        = 1;
parameter FAMILY	       = 26;
   
   
localparam WDEPTH_CAL      = (WRITE_DEPTH == 0) ? WRITE_DEPTH : (WRITE_DEPTH-1);
localparam RDEPTH_CAL      = (READ_DEPTH == 0)  ? READ_DEPTH  : (READ_DEPTH-1);

// Port Declarations
//input                    clk_wr; // Clock input
//input                    clk_rd; // Clock input
input                    clk;
input                    aresetn;
input                    sresetn;
//input                    rst ;
//input                    rdclk_rst ;
input 					 load_prevpkt_waddr;
input  [WDEPTH_CAL:0]	 waddr_hold;
input 					 we_ctrl;
output [WDEPTH_CAL:0]    memwaddr;             // memory write address
output                   memwe;                // memory write enable
output [RDEPTH_CAL:0]    memraddr;             // memory read address
output                   memre;                // memory read enable

input                    rd_en ;
input                    wr_en ;
input                    sop ;
input                    pkt_drop_pl ;

output                   fifo_full ;
output                   fifo_empty ;


//-----------Internal variables-------------------
reg [WDEPTH_CAL:0]    wr_pointer;
reg [WDEPTH_CAL:0]    wr_d_pointer;
reg [RDEPTH_CAL:0]    rd_pointer;
reg [WDEPTH_CAL:0]    memwaddr_r;
reg [RDEPTH_CAL:0]    memraddr_r;
reg [WDEPTH_CAL :0]   wrfifo_usedw;
wire [WDEPTH_CAL :0]  wrptr_incr;

wire                     we_p;
wire                     re_p;
wire                     we_i;
wire                     re_i;
// --------------------------------------------------------------------------
// clocks and enables
// --------------------------------------------------------------------------
assign pos_clk   =  WCLK_HIGH  ? clk    : ~clk;

assign re_p  = READ_LOW  ? (~rd_en) : (rd_en);
assign we_p  = WRITE_LOW ? (~wr_en) : (wr_en);
   

//-----------Variable assignments---------------

assign we_i = we_p & !fifo_full ;
assign re_i = re_p & !fifo_empty;

assign wrptr_incr = (wr_pointer+1);

assign fifo_full  = (wrptr_incr == rd_pointer);
assign fifo_empty = (wr_pointer == rd_pointer); 

//assign fifo_full = ({~memwaddr_r[WDEPTH_CAL],memwaddr_r[WDEPTH_CAL-1:0]} == memraddr_r);
//assign fifo_empty = (memwaddr_r == memraddr_r); 

assign memwaddr  = memwaddr_r;
assign memraddr  = memraddr_r;
assign memwe     = we_i;
assign memre     = re_i;

//-----------Write domain----------------------
always @(posedge pos_clk or negedge aresetn )
  begin
     if ( !aresetn | !sresetn )
        wr_pointer <= 'h0;
     else if(load_prevpkt_waddr==1) 
		wr_pointer <= waddr_hold; 
     else if ( we_ctrl & ~(sop & pkt_drop_pl)) 												        
        wr_pointer <= wr_pointer + 1;   
  end

always @(posedge pos_clk or negedge aresetn )
  begin
     if ( !aresetn | !sresetn )
        wr_d_pointer <= 'h0;
	 else 
        wr_d_pointer <= wr_pointer;
  end
  
//-----------READ domain----------------------
always @(posedge pos_clk or negedge aresetn )
  begin
     if ( !aresetn | !sresetn ) 
        rd_pointer <= 'h0;
	 else if (rd_en ) 
        rd_pointer <= rd_pointer + 1;
  end

always @(posedge pos_clk or negedge aresetn )
  begin
     if ( !aresetn | !sresetn ) 
        wrfifo_usedw <= 'h0;
	 else if(FAMILY == 25) begin       
      if (wr_d_pointer >= rd_pointer)
        wrfifo_usedw <= wr_d_pointer - rd_pointer;
	  else 
	    wrfifo_usedw <= FULL_WRITE_DEPTH + wr_d_pointer - rd_pointer;
	 end
	 else begin
	  if (wr_pointer >= rd_pointer)
        wrfifo_usedw <= wr_pointer - rd_pointer;
	  else 
	    wrfifo_usedw <= FULL_WRITE_DEPTH + wr_pointer - rd_pointer;
     end
  end


// --------------------------------------------------------------------------
// Generate write and read addresses to the memory
// --------------------------------------------------------------------------
always @(posedge pos_clk or negedge aresetn )
  begin
     if ( !aresetn | !sresetn )      memwaddr_r <= 'h0;
     else if(load_prevpkt_waddr==1)  memwaddr_r <= waddr_hold; 
     else if ( we_ctrl & ~(sop & pkt_drop_pl))  memwaddr_r <= memwaddr_r + 1;
  end

always @(posedge pos_clk or negedge aresetn)
  begin
     if ( !aresetn | !sresetn ) 
        memraddr_r <= 'h0;
     else if ( re_i == 1'b1) 
        memraddr_r <= memraddr_r + 1;
  end
  
endmodule
  