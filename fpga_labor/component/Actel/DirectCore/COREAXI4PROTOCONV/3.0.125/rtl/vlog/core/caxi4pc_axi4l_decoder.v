// **************************************************************************
// Microchip Corporation Proprietary and Confidential
// Copyright 2024 Microchip Corporation. All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description : caxi4pc_axi4l_trgt_register module.
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

module caxi4pc_axi4l_decoder
   #(
    //-----------------------------------------------------------------------------------
    // Parameter declaration
    //-----------------------------------------------------------------------------------
    parameter       RESET_TYPE              = 1,                  // Reset Type      	    
                                                                 // Defines the reset type.
                                                                 // 1: Asynchronous reset
                                                                 // 0: Synchronous reset
	parameter       S2MM_ENABLE             = 1,
	parameter       MM2S_ENABLE             = 1
   )	
	
   (
    // Clock and Reset interface----------------------------------------------------
    // S2MM
    input   wire                                clk,             		// clock. All the interfaces used into S2MM block (AXI4-Lite target, AXI4-Stream target and AXI4 initiator) uses S2MM clock.
	    
    input   wire                                resetn,         	    // This active-low reset resets the core. S2MM_RESETN must be externally synchronized with the clk clock domain.
																    // Note: The reset is synchronous or asynchronous type based on the RESET_TYPE parameter.
	// AXI4-Lite Port Interface                                         																	
	input   wire                                t_axi4l_awvalid,         // AXI4-Lite write address valid. This signal indicates that valid write address and control information are available.
    output  reg                                 t_axi4l_awready,         // AXI4-Lite write address ready. This signal indicates that the target is ready to accept an address and associated control signals.
    input   wire   [10:0]                       t_axi4l_awaddr,          // AXI4-Lite write address.
																	  // This information determines the number of data transfers associated with the address.
    input   wire   [31:0]                       t_axi4l_wdata,           // AXI4-Lite write data.
    input   wire   [3:0]                        t_axi4l_wstrb,           // AXI4-Lite write strobes.
    input   wire                                t_axi4l_wvalid,          // AXI4-Lite write valid.
    output  reg                                 t_axi4l_wready,          // AXI4-Lite Write ready.
    												     
    output  reg    [1:0]                        t_axi4l_bresp,           // AXI4-Lite write response.
    output  reg                                 t_axi4l_bvalid,          // AXI4-Lite write response valid.
    input   wire                                t_axi4l_bready,          // AXI4-Lite response ready.
    												     
    input   wire   [10:0]                       t_axi4l_araddr,          // AXI4-Lite read address. The read address gives the address of the first transfer in a read burst transaction.  
    input   wire                                t_axi4l_arvalid,         // AXI4-Lite read address valid. This signal indicates that the channel is signaling valid read address and control information. 
    output  reg                                 t_axi4l_arready,         // AXI4-Lite response ready. This signal indicates that the target is ready to accept an address and associated control signals. 
    												     
    output  wire   [31:0]                       t_axi4l_rdata,           // AXI4-Lite read data.
    output  reg    [1:0]                        t_axi4l_rresp,           // AXI4-Lite read response.
    output  reg                                 t_axi4l_rvalid,          // AXI4-Lite read valid. This signal indicates that the channel is signaling the required read data.
    input   wire                                t_axi4l_rready,         // AXI4-Lite read ready. This signal indicates that the Initiator can accept the read data and response information.
	
    // S2MM AXI4-Lite Port Interface
    output  reg                                 s2mm_axi4l_awvalid,    // AXI4-Lite write address valid. This signal indicates that valid write address and control information are available.
    input                                       s2mm_axi4l_awready,    // AXI4-Lite write address ready. This signal indicates that the target is ready to accept an address and associated control signals.
    output  reg    [10:0]                       s2mm_axi4l_awaddr,     // AXI4-Lite write address.
                                                           
    output         [31:0]                       s2mm_axi4l_wdata,      // AXI4-Lite write data.
    output         [3:0]                        s2mm_axi4l_wstrb,
    output  reg                                 s2mm_axi4l_wvalid,     // AXI4-Lite write valid.
    input                                       s2mm_axi4l_wready,     // AXI4-Lite Write ready.
                                                         
    input	       [1:0]                        s2mm_axi4l_bresp,      // AXI4-Lite write response.
    input                                       s2mm_axi4l_bvalid,     // AXI4-Lite write response valid.
    output  reg                                 s2mm_axi4l_bready,     // AXI4-Lite response ready.
                                                           
    output  reg    [10:0]                       s2mm_axi4l_araddr,     // AXI4-Lite read address. The read address gives the address of the first transfer in a read burst transaction.  
    output  reg                                 s2mm_axi4l_arvalid,    // AXI4-Lite read address valid. This signal indicates that the channel is signaling valid read address and control information. 
    input	                                    s2mm_axi4l_arready,    // AXI4-Lite response ready. This signal indicates that the Target is ready to accept an address and associated control signals. 
                                                         
    output  reg                                 s2mm_axi4l_rready, 
    input          [31:0]                       s2mm_axi4l_rdata,      // AXI4-Lite read data.
    input          [1:0]                        s2mm_axi4l_rresp,      // AXI4-Lite read response.
    input 	                                    s2mm_axi4l_rvalid,      // AXI4-Lite read valid. This signal indicates that the channel is signaling the required read data.
    // MM2S AXI4-Lite Port Interface
    output  reg                                 mm2s_axi4l_awvalid,    // AXI4-Lite write address valid. This signal indicates that valid write address and control information are available.
    input                                       mm2s_axi4l_awready,    // AXI4-Lite write address ready. This signal indicates that the target is ready to accept an address and associated control signals.
    output  reg   [10:0]                        mm2s_axi4l_awaddr,     // AXI4-Lite write address.
                                                          
    output        [31:0]                        mm2s_axi4l_wdata,      // AXI4-Lite write data.
    output        [3:0]                         mm2s_axi4l_wstrb,
    output  reg                                 mm2s_axi4l_wvalid,     // AXI4-Lite write valid.
    input                                       mm2s_axi4l_wready,     // AXI4-Lite Write ready.
                                                         
    input	      [1:0]                         mm2s_axi4l_bresp,      // AXI4-Lite write response.
    input                                       mm2s_axi4l_bvalid,     // AXI4-Lite write response valid.
    output  reg                                 mm2s_axi4l_bready,     // AXI4-Lite response ready.
                                                           
    output  reg   [10:0]                        mm2s_axi4l_araddr,     // AXI4-Lite read address. The read address gives the address of the first transfer in a read burst transaction.  
    output  reg                                 mm2s_axi4l_arvalid,    // AXI4-Lite read address valid. This signal indicates that the channel is signaling valid read address and control information. 
    input	                                    mm2s_axi4l_arready,    // AXI4-Lite response ready. This signal indicates that the Target is ready to accept an address and associated control signals. 
                                                         
    output  reg                                 mm2s_axi4l_rready, 
    input         [31:0]                        mm2s_axi4l_rdata,      // AXI4-Lite read data.
    input         [1:0]                         mm2s_axi4l_rresp,      // AXI4-Lite read response.
    input 	                                    mm2s_axi4l_rvalid      // AXI4-Lite read valid. This signal indicates that the channel is signaling the required read data.   	
    //-----------------------------------------------------------------------------------
   );   
      

   wire s2mm_wsel;
   wire s2mm_rsel;
   wire s2mm_wen;
   wire s2mm_ren;
   reg  s2mm_wsel_reg;
   reg  s2mm_rsel_reg;

   wire aresetn = (RESET_TYPE==1) ? 1'b1   : resetn;
   wire sresetn = (RESET_TYPE==1) ? resetn : 1'b1;
   

   //------------------------------------------------------------------------------------
   assign s2mm_wsel = S2MM_ENABLE ? ((t_axi4l_awaddr < 11'h400) & (t_axi4l_awvalid == 1) ) ? 1 : 0 : 0;
   assign s2mm_rsel = S2MM_ENABLE ? ((t_axi4l_araddr < 11'h400) & (t_axi4l_arvalid == 1) ) ? 1 : 0 : 0;
   
   assign s2mm_wen  = (s2mm_wsel | s2mm_wsel_reg);
   assign s2mm_ren  = (s2mm_rsel | s2mm_rsel_reg);
   
   //Logic for S2MM/MM2S Write and Read phase internal signals
 generate 
  if(S2MM_ENABLE) begin  
     always@(posedge clk or negedge aresetn)
     begin
       if(~aresetn | ~sresetn)
         s2mm_wsel_reg <= 1'b0;
	   else if(s2mm_wsel_reg & (s2mm_axi4l_bvalid == 1) & s2mm_axi4l_bready)
	     s2mm_wsel_reg <= 1'b0;
	   else if(s2mm_wsel)
	     s2mm_wsel_reg <= 1'b1;
     end   
     
     always@(posedge clk or negedge aresetn)
     begin
       if(~aresetn | ~sresetn)
         s2mm_rsel_reg <= 1'b0;
	   else if(s2mm_rsel_reg & s2mm_axi4l_rvalid & s2mm_axi4l_rready)
	     s2mm_rsel_reg <= 1'b0;
	   else if(t_axi4l_arvalid & s2mm_rsel)
	     s2mm_rsel_reg <= 1'b1;
     end  
  end else begin 
     always@(*)
	   s2mm_wsel_reg = ~sresetn;
	
     always@(*)
	   s2mm_rsel_reg = ~sresetn;	
  end 
endgenerate   
 
  
   //S2MM and MM2S AXI4-Lite AWVALID logic
   always@(*)
   begin
     s2mm_axi4l_awvalid    = 1'b0;
     mm2s_axi4l_awvalid    = 1'b0;
	 if(s2mm_wsel)
	    s2mm_axi4l_awvalid = t_axi4l_awvalid;
	  else
	    mm2s_axi4l_awvalid = t_axi4l_awvalid;
   end   

   //S2MM and MM2S AXI4-Lite AWREADY logic     
   always@(*)
   begin
	 if(s2mm_wen)
	    t_axi4l_awready = s2mm_axi4l_awready;
	  else
	    t_axi4l_awready = MM2S_ENABLE ? mm2s_axi4l_awready : 0;
   end   
   
   //Logic for S2MM/MM2S Write and Read address
   always@(*)
   begin
     s2mm_axi4l_awaddr = t_axi4l_awaddr;
     mm2s_axi4l_awaddr = t_axi4l_awaddr;
   end   

   always@(*)
   begin
     s2mm_axi4l_araddr = t_axi4l_araddr;
     mm2s_axi4l_araddr = t_axi4l_araddr;
   end   
   
    //Logic for S2MM/MM2S Write and Read data
	assign s2mm_axi4l_wdata = t_axi4l_wdata;
	assign mm2s_axi4l_wdata = t_axi4l_wdata;

    //Logic for S2MM/MM2S strobes
	assign s2mm_axi4l_wstrb    = t_axi4l_wstrb;
	assign mm2s_axi4l_wstrb    = t_axi4l_wstrb;


	assign t_axi4l_rdata    = (s2mm_rsel | s2mm_rsel_reg) ? s2mm_axi4l_rdata : MM2S_ENABLE ? mm2s_axi4l_rdata : 0;

	
   //S2MM and MM2S AXI4-Lite WVALID logic
   always@(*)
   begin
     s2mm_axi4l_wvalid = 1'b0;
     mm2s_axi4l_wvalid = 1'b0;
	 if(s2mm_wen)
	    s2mm_axi4l_wvalid = t_axi4l_wvalid;
	  else
	    mm2s_axi4l_wvalid = t_axi4l_wvalid;
   end  

   //S2MM and MM2S AXI4-Lite WREADY logic 
   always@(*)
   begin
	 if(s2mm_wen)
	    t_axi4l_wready = s2mm_axi4l_wready;
	  else
	    t_axi4l_wready = MM2S_ENABLE ? mm2s_axi4l_wready : 0;
   end   	

   //S2MM and MM2S AXI4-Lite BRESP logic
   always@(*)
   begin
	 if(s2mm_wen)
	    t_axi4l_bresp = s2mm_axi4l_bresp;
	  else
	    t_axi4l_bresp = MM2S_ENABLE ? mm2s_axi4l_bresp : 0;
   end 	

   //S2MM and MM2S AXI4-Lite BVALID logic
   always@(*)
   begin
	 if(s2mm_wen)
	    t_axi4l_bvalid = s2mm_axi4l_bvalid;
	  else
	    t_axi4l_bvalid = MM2S_ENABLE ? mm2s_axi4l_bvalid : 0;
   end 	

   //S2MM and MM2S AXI4-Lite BREADY logic
   always@(*)
   begin
     mm2s_axi4l_bready = 1'b0;
     s2mm_axi4l_bready = 1'b0;	 
	 if(s2mm_wen)
	    s2mm_axi4l_bready = t_axi4l_bready;
	  else
	    mm2s_axi4l_bready = t_axi4l_bready;
   end 
   
   //S2MM and MM2S AXI4-Lite ARVALID logic
   always@(*)
   begin
     s2mm_axi4l_arvalid    = 1'b0;
     mm2s_axi4l_arvalid    = 1'b0;
	 if(s2mm_ren)
	    s2mm_axi4l_arvalid = t_axi4l_arvalid;
	  else
	    mm2s_axi4l_arvalid = t_axi4l_arvalid;
   end   
   

   
   //S2MM and MM2S AXI4-Lite ARREADY logic   
   always@(*)
   begin
	 if(s2mm_ren)
	    t_axi4l_arready = s2mm_axi4l_arready;
	 else
	    t_axi4l_arready = MM2S_ENABLE ? mm2s_axi4l_arready : 0;
   end 
      	   
   //S2MM and MM2S AXI4-Lite RVALID logic
   always@(*)
   begin
	 if(s2mm_ren)
	    t_axi4l_rvalid = s2mm_axi4l_rvalid;
	  else
	    t_axi4l_rvalid = MM2S_ENABLE ? mm2s_axi4l_rvalid : 0;
   end 	
   	
   //S2MM and MM2S AXI4-Lite RREADY logic
   always@(*)
   begin
     s2mm_axi4l_rready = 1'b0;
     mm2s_axi4l_rready = 1'b0;
	 if(s2mm_ren)
	    s2mm_axi4l_rready = t_axi4l_rready;
	  else
	    mm2s_axi4l_rready = t_axi4l_rready;
   end   
   

   //S2MM and MM2S AXI4-Lite RRESP logic
   always@(*)
   begin
	 if(s2mm_ren)
	    t_axi4l_rresp = s2mm_axi4l_rresp;
	  else
	    t_axi4l_rresp = MM2S_ENABLE ? mm2s_axi4l_rresp : 0;
   end 	
endmodule