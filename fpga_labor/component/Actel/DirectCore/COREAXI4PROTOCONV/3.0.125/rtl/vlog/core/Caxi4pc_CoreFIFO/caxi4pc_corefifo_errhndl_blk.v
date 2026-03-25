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

module caxi4pc_corefifo_errhndl_blk
   #(
    //-----------------------------------------------------------------------------------
    // Parameter declaration
    //-----------------------------------------------------------------------------------
    parameter       PKT_DROP_OVF          = 0,                // Packet drop overflow | 0 : Disable, 1: Enable
    parameter       PKT_DROP_ERR          = 0,                // Packet drop error    | 0 : Disable, 1: Enable    	    
    parameter       WRITE_DEPTH           = 10,                                                                   
    parameter       WRITE_LOW             = 1                                                                
   )	
	
   (
    // Clock and Reset interface----------------------------------------------------
    input   wire                                 wclk,            
	    
    input   wire                                 aresetn,
	input   wire                                 sresetn,
    // Error handling block port interface------------------------------------------
	input   wire                                 we,         
	input   wire                                 sop,                // Start of packet
	input   wire                                 eop,                // End of packet
	input   wire                                 pkt_err,			 // Packet error input port
	input   wire    [WRITE_DEPTH - 1:0]          waddr,              // Write addreess
	input   wire                                 fifo_full,
	
	output  reg     [WRITE_DEPTH - 1:0]          waddr_hold,         // Holds the write address
	output  reg     			                 load_prevpkt_waddr, // Load the previous packet write address
	output  	     			                 we_ctrl,            // Write enable to control the write address memory
	output  	     			                 pkt_err_pl,
	output  	     			                 pkt_ovf_pl, 	
	output  	     			                 pkt_drop_pl,
	output  reg 	     			             tlast_dis
   );   
   
   localparam WDEPTH_CAL      = (WRITE_DEPTH == 0) ? WRITE_DEPTH : (WRITE_DEPTH-1);
  
   // Internal Signal--------------------------------------------------------------------
   wire                     pkt_drop_error;
   wire                     pkt_drop_overflow;
   reg 						wr_dis;
   wire 					pkt_ovf_hold;
   wire                     we_p;
   reg 						pkt_drop_err_d;
   reg						load_prevpkt_waddr_hold;
 //  wire 					pkt_err_pl;
 // wire 					pkt_ovf_pl;
   // --------------------------------------------------------------------------
   // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   // ||                                                                      ||
   // ||                     Start - of - Code                                ||
   // ||                                                                      ||
   // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   // --------------------------------------------------------------------------

   // --------------------------------------------------------------------------
   // Read and Write enables
   // --------------------------------------------------------------------------
    assign we_p  = WRITE_LOW ? (~we) : (we);
   
   // --------------------------------------------------------------------------
   // Conditions for packet drop due to error and packet drop due to overflow
   // --------------------------------------------------------------------------
   assign pkt_drop_error 		= 	eop & pkt_err;
   assign pkt_drop_overflow		= 	we_p & fifo_full;
   
   always @(posedge wclk or negedge aresetn) begin
        if (!aresetn | !sresetn) begin
           wr_dis <= 1'b0;
        end
        else if(pkt_drop_overflow || eop) begin
           wr_dis <= !eop;
           end
     end
   assign pkt_ovf_hold   = wr_dis | pkt_drop_overflow;
  
   assign we_ctrl		 = !pkt_ovf_hold & we_p;
   
   always @(posedge wclk or negedge aresetn) begin
        if (!aresetn | !sresetn) begin
           waddr_hold <= 'd0;
        end
        else  if (we_p == 1'b1)  begin  
		   if(sop==1)
               waddr_hold <= waddr;
           end
     end
	 	 
  always @(*) 
     if(PKT_DROP_ERR == 1 && PKT_DROP_OVF == 1) 
       load_prevpkt_waddr = ((pkt_drop_error | pkt_ovf_hold) & ~sop & eop | load_prevpkt_waddr_hold) ;
     else if(PKT_DROP_ERR == 1) 
       load_prevpkt_waddr = (pkt_drop_error & ~sop & eop | load_prevpkt_waddr_hold);
     else if(PKT_DROP_OVF == 1) 
       load_prevpkt_waddr = (pkt_ovf_hold & ~sop & eop | load_prevpkt_waddr_hold); 
     else 
       load_prevpkt_waddr = 1'b0;
 
   always @(posedge wclk or negedge aresetn) begin
     if (!aresetn | !sresetn)
	   pkt_drop_err_d    <= 1'b0;
	 else if(PKT_DROP_ERR == 1)
	   pkt_drop_err_d    <= pkt_drop_error;
	 else 
	   pkt_drop_err_d    <= 1'b0;
	 end
	// Added Tlast disable logic to S_AXIS_TLAST_s, when tlast_dis(for Overflow and packet drop error) is asserted then S_AXIS_TLAST_s is 0.
   always @(*) 
     if(PKT_DROP_ERR == 1 && PKT_DROP_OVF == 1) 
       tlast_dis = ((pkt_drop_error | pkt_ovf_hold) & eop) ;
     else if(PKT_DROP_ERR == 1) 
       tlast_dis = (pkt_drop_error & eop);
     else if(PKT_DROP_OVF == 1) 
       tlast_dis = (pkt_ovf_hold & eop); 
     else 
       tlast_dis = 1'b0;	
	
   always @(posedge wclk or negedge aresetn) begin
     if (!aresetn | !sresetn)
	   load_prevpkt_waddr_hold  <= 1'b0;
         else if(PKT_DROP_ERR == 1 && PKT_DROP_OVF == 1) 
	   load_prevpkt_waddr_hold  <= ((pkt_drop_error | pkt_ovf_hold) & sop & eop);
         else if(PKT_DROP_ERR == 1) 
           load_prevpkt_waddr_hold  <= (pkt_drop_error & sop & eop);
         else if(PKT_DROP_OVF == 1) 
           load_prevpkt_waddr_hold  <= (pkt_ovf_hold & sop & eop);
    end
	
   assign pkt_err_pl = pkt_drop_error & ~pkt_drop_err_d;
   assign pkt_ovf_pl = pkt_ovf_hold & eop;
   
   assign pkt_drop_pl = pkt_err_pl | pkt_ovf_pl;
     
endmodule
    
   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------