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

module caxi4pc_axi4l_trgt_register
   #(
    //-----------------------------------------------------------------------------------
    // Parameter declaration
    //-----------------------------------------------------------------------------------
    parameter       ADDR_WIDTH              = 32,                // Address Width
	                                                             // Defines the address width for I_S2MMAXI4_AWADDR, I_S2MMAXI4_ARADDR of AXI4 initiator and T_AXI4S_TDEST of AXI4-stream target.	
    parameter       RESET_TYPE              = 1,                 // Reset Type      	    
                                                                 // Defines the reset type.
                                                                 // 1: Asynchronous reset
                                                                 // 0: Synchronous reset
    parameter       CMDSTS_FIFO_ENABLE      = 1,                                                                   
    parameter       STATUS_WIDTH            = 32,                // 9                                                
    parameter       UNDEF_BSTLEN            = 0,
	parameter       INTR_REG_WIDTH 			= 16,				// Interrupt register width
	parameter       CNTR_REG_WIDTH 			= 16,				// Counter register width
	parameter       SOURCE_REG_WIDTH 		= 32,				// Source register width
	parameter		ADDR_LAST 				= 11'h108,			// Last address
	parameter		WRITE_EN 				= 1'b1,              // for MM2S , it is 0
	parameter		REG_ADDR_OFFSET 		= 1'b0              // Register address offset, For S2MM = 0, MM2S =1
   )	
	
   (
    // Clock and Reset interface----------------------------------------------------
    // S2MM
    input   wire                                 clk,              // clock. All the interfaces used into S2MM block (AXI4-Lite target, AXI4-Stream target and AXI4 initiator) uses S2MM clock.
	    
    input   wire                                 resetn,            // This active-low reset resets the core. S2MM_RESETN must be externally synchronized with the clk clock domain.
                                                                   // Note: The reset is synchronous or asynchronous type based on the RESET_TYPE parameter.
    // AXI4-Lite Port Interface
    input   wire                                 axi4l_awvalid,    // AXI4-Lite write address valid. This signal indicates that valid write address and control information are available.
    output                                       axi4l_awready,    // AXI4-Lite write address ready. This signal indicates that the target is ready to accept an address and associated control signals.
    input   wire   [10:0]                        axi4l_awaddr,     // AXI4-Lite write address.
                                                              
    input   wire   [31:0]                        axi4l_wdata,      // AXI4-Lite write data.
    input   wire   [3:0]                         axi4l_wstrb,
    input   wire                                 axi4l_wvalid,     // AXI4-Lite write valid.
    output                                       axi4l_wready,     // AXI4-Lite Write ready.
                                                              
    output  reg   [1:0]                          axi4l_bresp,      // AXI4-Lite write response.
    output  reg                                  axi4l_bvalid,     // AXI4-Lite write response valid.
    input   wire                                 axi4l_bready,     // AXI4-Lite response ready.
                                                              
    input   wire   [10:0]                        axi4l_araddr,     // AXI4-Lite read address. The read address gives the address of the first transfer in a read burst transaction.  
    input   wire                                 axi4l_arvalid,    // AXI4-Lite read address valid. This signal indicates that the channel is signaling valid read address and control information. 
    output  reg                                  axi4l_arready,    // AXI4-Lite response ready. This signal indicates that the Target is ready to accept an address and associated control signals. 
                                                            
    input   wire                                 axi4l_rready, 
    output  reg    [31:0]                        axi4l_rdata,      // AXI4-Lite read data.
    output  reg    [1:0]                         axi4l_rresp,      // AXI4-Lite read response.
    output  reg                                  axi4l_rvalid,     // AXI4-Lite read valid. This signal indicates that the channel is signaling the required read data.
    
    output  reg    [ADDR_WIDTH-1:0]              address_reg,
    output  reg    [31:0]                        length_reg,
	output         [31:0]                        control_reg, 
	
	output  reg                                  sts_fifo_rden,
	input                                        sts_fifo_empty,
    input          [STATUS_WIDTH-1:0]            sts_fifo_rdata,
    
	input          [STATUS_WIDTH-1:0]            status, 
	input                                        cmd_fifo_full,
	
	input 		   								 rresp_err_pl,
	
    output  reg									 intr,
	output  reg									 err_intr,
	input                                        pkterr_intr_pl,
	input                                        pktovf_intr_pl,
	output 										 multi_pkt_intr_pl
	
    //-----------------------------------------------------------------------------------
   );   
   
   
   localparam [10:0] VERSNREG        = REG_ADDR_OFFSET ? 11'h400 : 11'h000;
   localparam [10:0] CNTRLREG        = REG_ADDR_OFFSET ? 11'h410 : 11'h010;
   localparam [10:0] STSREG          = REG_ADDR_OFFSET ? 11'h414 : 11'h014;
   localparam [10:0] LENGTHREG       = REG_ADDR_OFFSET ? 11'h418 : 11'h018;
   localparam [10:0] ADDRREG0        = REG_ADDR_OFFSET ? 11'h41C : 11'h01C;
   localparam [10:0] ADDRREG1        = REG_ADDR_OFFSET ? 11'h420 : 11'h020;
   localparam [10:0] INTRENBREG      = REG_ADDR_OFFSET ? 11'h424 : 11'h024;
   localparam [10:0] INTRSRCREG      = REG_ADDR_OFFSET ? 11'h428 : 11'h028;
   localparam [10:0] INTRTHRSHLDREG  = REG_ADDR_OFFSET ? 11'h42C : 11'h02C;
   localparam [10:0] MULPKTCNTREG    = REG_ADDR_OFFSET ? 11'h430 : 11'h030;
   localparam [10:0] AXI4ERRCNTREG   = REG_ADDR_OFFSET ? 11'h500 : 11'h100;
   localparam [10:0] PKTDRPERRCNTREG = 11'h104;
   localparam [10:0] PKTDRPOVFCNTREG = 11'h108;
   
   
   
   
   // Internal Signal--------------------------------------------------------------------
   reg    [10:0]                        axi4l_awaddr_reg;      
   reg    [31:0]                        control_reg_int;
   reg    [INTR_REG_WIDTH-1:0]          intr_clr_reg_int;
   reg    [31:0]                        address0_reg_int;
   reg    [31:0]                        address1_reg_int;
   reg                                  axi4l_awready_reg;
   reg                                  axi4l_wready_reg;
   reg                                  sts_done;
   reg                                  sts_fifo_rden_reg;
   wire									done_intr;
   wire									multi_pkt_intr;
   reg	 								multi_pkt_done_intr;
   reg									axi4_err_intr;
   reg                                  done_reg;
   wire	  [INTR_REG_WIDTH-1:0]    		intr_event;
   wire                                 axi4l_raddr_phs_cmp;
   reg									multi_pkt_intr_reg;
  // wire									multi_pkt_intr_pl;
   reg 									axi4_err_intr_reg;
   wire									axi4_err_intr_pl;
   reg									status_done_reg;
   wire 								status_done_reg_pl;
   reg    [10:0]                        axi4l_araddr_reg;   
   reg    [INTR_REG_WIDTH-1:0]          intr_enable_reg;  
   reg    [SOURCE_REG_WIDTH-1:0]        intr_source_reg;   
   reg    [INTR_REG_WIDTH-1:0]          intr_thrshld_cnt_reg;
   reg    [CNTR_REG_WIDTH-1:0]          axi4_err_cnt_reg;
   reg    [CNTR_REG_WIDTH-1:0]          pktdrop_err_cnt_reg;
   reg    [CNTR_REG_WIDTH-1:0]          pktdrop_ovf_cnt_reg;
   reg    [CNTR_REG_WIDTH-1:0]          pkt_trnsfr_cnt_reg; 
   reg    [CNTR_REG_WIDTH-1:0]          multi_pkt_cnt_reg; 
   
   
   integer                              i;
   integer								intr_source_index;
   
   wire aresetn = (RESET_TYPE==1) ? 1'b1   : resetn;
   wire sresetn = (RESET_TYPE==1) ? resetn : 1'b1;
   

   //------------------------------------------------------------------------------------
  
   // S2MM AXI4-Lite Write logic---------------------------------------------------------
   // axi4l_awready
   always@(posedge clk  or negedge aresetn)
   begin
      if((!aresetn) || (!sresetn))
     	 axi4l_awready_reg  <= 1'b1;
      else if (axi4l_bvalid & axi4l_bready)
         axi4l_awready_reg  <= 1'b1;
      else if(axi4l_awvalid & axi4l_awready)
         axi4l_awready_reg  <= 1'b0;
   end
   
   // axi4l_awaddr_reg
   always@(posedge clk or negedge aresetn)
   begin
      if((!aresetn) || (!sresetn))
         axi4l_awaddr_reg  <= 'd0;
      else if(axi4l_awvalid & axi4l_awready)
         axi4l_awaddr_reg  <= axi4l_awaddr;
   end

   // axi4l_wready
   always@(posedge clk or negedge aresetn)
   begin
      if((!aresetn) || (!sresetn))
         axi4l_wready_reg  <= 1'd0;
      else if (axi4l_wvalid & axi4l_wready)
         axi4l_wready_reg  <= 1'd0;
      else if(axi4l_awvalid & axi4l_awready)
         axi4l_wready_reg  <= 1'd1;
   end
   
//generate
 // if(UNDEF_BSTLEN)   
 //   begin : undef_burstlen_en
      always@(posedge clk or negedge aresetn)
        begin
          if((!aresetn) || (!sresetn))
            begin
              address0_reg_int    <= 'd0;
              address1_reg_int    <= 'd0;
              control_reg_int     <= 'd0;
			  intr_enable_reg	  <= 'd0;
			  intr_clr_reg_int	  <= 'd0;
			  intr_thrshld_cnt_reg<= 'd0;
            end
          else if(axi4l_wvalid == 1'b1 && axi4l_wready == 1'b1)
            begin
              case (axi4l_awaddr_reg)
                CNTRLREG: begin 
                            for(i=0; i<4; i=i+1)
                              begin
                                if(axi4l_wstrb[i])
                                  control_reg_int[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
                              end
			              end 
		        ADDRREG0: begin 
                            for(i=0; i<4; i=i+1)
                              begin
                                if(axi4l_wstrb[i])
                                  address0_reg_int[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
                              end
		                  end
                ADDRREG1: begin 
                            for(i=0; i<4; i=i+1)
                              begin
                                if(axi4l_wstrb[i])
                                  address1_reg_int[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
                              end
		  	              end
				INTRENBREG: begin 
                              for(i=0; i<2; i=i+1)
                                begin
                                  if(axi4l_wstrb[i])
                                    intr_enable_reg[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
                                end
		  	                end	
				INTRSRCREG: begin 
                              for(i=0; i<2; i=i+1)
                                begin
                                  if(axi4l_wstrb[i])
                                    intr_clr_reg_int[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
                                end
		  	                end	
				INTRTHRSHLDREG: begin 
								  if(CMDSTS_FIFO_ENABLE)
								    begin
                                      for(i=0; i<2; i=i+1)
                                        begin
                                          if(axi4l_wstrb[i])
                                            intr_thrshld_cnt_reg[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
                                        end
									end
								  else intr_thrshld_cnt_reg <= 16'b0;
								end			
              endcase
            end
	      else 
	        begin 
	          control_reg_int[0] <= 1'b0;
			  intr_clr_reg_int   <= 'd0;
	        end 
        end
		
      always@(posedge clk or negedge aresetn)
        begin
          if((!aresetn) || (!sresetn))
            length_reg  <= 32'd1;
		  else if(UNDEF_BSTLEN)
			begin
			  if(CMDSTS_FIFO_ENABLE)
				begin 
				  if(sts_fifo_rden)
                    length_reg <= sts_fifo_rdata[63:32];
				end 
			  else 
				begin 
				  if(~sts_done)
					length_reg   <= status[63:32];			
				end 
			end
		  else 
		    begin
			  if(axi4l_wvalid == 1'b1 && axi4l_wready == 1'b1 && axi4l_awaddr_reg == LENGTHREG)
			    for(i=0; i<4; i=i+1)
                    begin
                      if(axi4l_wstrb[i])
                        length_reg[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
                    end
			end
		end
	

   assign control_reg	  = control_reg_int[31:0];
  
   
   generate 
     if(ADDR_WIDTH > 32)
	   begin : addr_width_gt_32
	     always@(*)
		   begin 
	         address_reg[31:0]            = address0_reg_int;
		     address_reg[ADDR_WIDTH-1:32] = address1_reg_int[ADDR_WIDTH-32-1:0];		   
		   end 
	   end 
	 else 
	   begin : addr_width_lt_32
	     always@(*)
	       address_reg = address0_reg_int[ADDR_WIDTH-1:0];
	   end 
   endgenerate      

   // axi4l_bvalid
   always@(posedge clk or negedge aresetn)
   begin
      if((!aresetn) || (!sresetn))
         axi4l_bvalid  <= 1'd0;
      else if(axi4l_bvalid == 1'b1 && axi4l_bready == 1'b1)
         axi4l_bvalid  <= 1'd0;
      else if(axi4l_wvalid == 1'b1 && axi4l_wready == 1'b1)
         axi4l_bvalid  <= 1'b1;
   end

   // axi4l_bresp
   always@(posedge clk or negedge aresetn)
   begin
      if((!aresetn) || (!sresetn))
         axi4l_bresp  <= 2'b00;
      else if(axi4l_bvalid & axi4l_bready)
         axi4l_bresp  <= 2'b00;
      else if(axi4l_awvalid & axi4l_awready & (axi4l_awaddr > ADDR_LAST))
         axi4l_bresp  <= 2'b10;
   end

   assign axi4l_raddr_phs_cmp = (axi4l_arvalid & axi4l_arready);
   // axi4l_arready
   always@(posedge clk or negedge aresetn)
   begin
      if((!aresetn) || (!sresetn))
         axi4l_arready  <= 1'd1;
      else if(axi4l_rvalid & axi4l_rready)
         axi4l_arready  <= 1'd1;
      else if(axi4l_raddr_phs_cmp)
         axi4l_arready  <= 1'b0;
   end

   always@(posedge clk or negedge aresetn)
   begin
      if((!aresetn) || (!sresetn))
         axi4l_araddr_reg  <= 'd0;
      else if(axi4l_arvalid & axi4l_arready)
         axi4l_araddr_reg  <= axi4l_araddr;
   end   
   
  always@(posedge clk or negedge aresetn)
    if((!aresetn) || (!sresetn))
      sts_done <= 1'b1;
    else if(control_reg_int[0])
      sts_done <= 1'b0;   

   // axi4l_rvalid
   generate 
     if(CMDSTS_FIFO_ENABLE)
	   begin : cmdsts_fifo_en
	     reg axi4l_raddr_phs_cmp_reg;

         //hold awready low if command fifo is full when CMDSTS_FIFO_ENABLE is set to 1
		 
         assign axi4l_awready = axi4l_awready_reg & ~cmd_fifo_full;		 
		 
        //hold wready low if command fifo is full when CMDSTS_FIFO_ENABLE is set to 1
   
         assign axi4l_wready = axi4l_wready_reg & ~cmd_fifo_full;
		 
		 
         always@(posedge clk or negedge aresetn)
           if((!aresetn) || (!sresetn))
	         axi4l_raddr_phs_cmp_reg <= 1'b0;
		   else 
			 axi4l_raddr_phs_cmp_reg <= axi4l_raddr_phs_cmp;        			 

         always@(posedge clk or negedge aresetn)
           begin
             if((!aresetn) || (!sresetn))
               axi4l_rvalid  <= 1'd0;
             else if(axi4l_rvalid & axi4l_rready)
               axi4l_rvalid  <= 1'd0;
            // else if(sts_fifo_rden)
            //   axi4l_rvalid  <= axi4l_raddr_phs_cmp_reg;
	         else 
	           axi4l_rvalid  <= axi4l_raddr_phs_cmp;
		  end
			 
		 always@(*)
		   if(axi4l_raddr_phs_cmp & ~sts_fifo_empty & ((axi4l_araddr == INTRSRCREG) | (axi4l_araddr == STSREG)))
		     sts_fifo_rden = 1'b1;
		   else 
		     sts_fifo_rden = 1'b0;
			 
		 always@(posedge clk or negedge aresetn)
		   if((!aresetn) || (!sresetn))
		     sts_fifo_rden_reg <= 1'b0;
		   else 
		     sts_fifo_rden_reg <= sts_fifo_rden;		
			 
         always@(posedge clk or negedge aresetn)
           begin
             if((!aresetn) || (!sresetn))
               axi4l_rdata  <= 32'd0;
             else 
               begin			   
                 case (axi4l_araddr)
				   VERSNREG			: axi4l_rdata  <= {8'd3,8'd0,16'd0};
				   CNTRLREG   		: axi4l_rdata  <= control_reg;
				   STSREG   		: axi4l_rdata  <= {31'd0,sts_done};
                   LENGTHREG    	: axi4l_rdata  <= length_reg;    
                   ADDRREG0     	: axi4l_rdata  <= address0_reg_int;
                   ADDRREG1     	: axi4l_rdata  <= address1_reg_int;
				   INTRENBREG   	: axi4l_rdata  <= {{32-INTR_REG_WIDTH{1'b0}},intr_enable_reg};
				   INTRSRCREG       : axi4l_rdata  <= intr_source_reg;
				   INTRTHRSHLDREG   : axi4l_rdata  <= {{32-INTR_REG_WIDTH{1'b0}},intr_thrshld_cnt_reg};
				   MULPKTCNTREG    	: axi4l_rdata  <= {{32-CNTR_REG_WIDTH{1'b0}},multi_pkt_cnt_reg};
				   AXI4ERRCNTREG    : axi4l_rdata  <= {{32-CNTR_REG_WIDTH{1'b0}},axi4_err_cnt_reg};
				   PKTDRPERRCNTREG  : axi4l_rdata  <= {{32-CNTR_REG_WIDTH{1'b0}},pktdrop_err_cnt_reg};
				   PKTDRPOVFCNTREG  : axi4l_rdata  <= {{32-CNTR_REG_WIDTH{1'b0}},pktdrop_ovf_cnt_reg};
	               default 			: axi4l_rdata  <= 32'd0;
                 endcase
				 
				 if(sts_fifo_rden)
				   axi4l_rdata  <= {sts_fifo_rdata[31:0]} ; // Add it in Status fifo ovf, err, mutlibit done
               end
           end    		   
	   end 
	 else 
	   begin : cmdsts_fifo_dis
	   
         assign axi4l_awready = axi4l_awready_reg;	
		 
         assign axi4l_wready  = axi4l_wready_reg;
		 
		 
         always@(posedge clk or negedge aresetn)
           begin
             if((!aresetn) || (!sresetn))
               axi4l_rvalid  <= 1'd0;
             else if(axi4l_rvalid & axi4l_rready)
               axi4l_rvalid  <= 1'd0;
	         else 
	           axi4l_rvalid  <= axi4l_raddr_phs_cmp;
		   end
			   
         //assign  sts_fifo_rden = 1'b0;
		 always@(*)
		   sts_fifo_rden = 1'b0;
		   
         always@(posedge clk or negedge aresetn)
           begin
             if((!aresetn) || (!sresetn))
               axi4l_rdata  <= 32'd0;
             else 
               begin
                 case (axi4l_araddr)
				   VERSNREG		   :  axi4l_rdata  <= {8'd3,8'd0,16'd0};
				   CNTRLREG 	   :  axi4l_rdata  <= control_reg;
                   STSREG   	   :  axi4l_rdata  <= {6'd0,status[25:16],10'd0,status[5:1],(status[0] | sts_done)};
                   LENGTHREG  	   :  axi4l_rdata  <= length_reg;    
                   ADDRREG0   	   :  axi4l_rdata  <= address0_reg_int;
                   ADDRREG1        :  axi4l_rdata  <= address1_reg_int;
				   INTRENBREG      :  axi4l_rdata  <= {{32-INTR_REG_WIDTH{1'b0}},intr_enable_reg};
				   INTRSRCREG      :  axi4l_rdata  <= intr_source_reg;
				   INTRTHRSHLDREG  :  axi4l_rdata  <= {{32-INTR_REG_WIDTH{1'b0}},intr_thrshld_cnt_reg};
				   MULPKTCNTREG    :  axi4l_rdata  <= {{32-CNTR_REG_WIDTH{1'b0}},multi_pkt_cnt_reg};
				   AXI4ERRCNTREG   :  axi4l_rdata  <= {{32-CNTR_REG_WIDTH{1'b0}},axi4_err_cnt_reg};
				   PKTDRPERRCNTREG :  axi4l_rdata  <= {{32-CNTR_REG_WIDTH{1'b0}},pktdrop_err_cnt_reg};
				   PKTDRPOVFCNTREG :  axi4l_rdata  <= {{32-CNTR_REG_WIDTH{1'b0}},pktdrop_ovf_cnt_reg};
	               default  	   :  axi4l_rdata  <= 32'd0;
                 endcase
               end		 
	       end 
       end
   endgenerate 

   always@(posedge clk or negedge aresetn)
   begin
      if((!aresetn) || (!sresetn))
         axi4l_rresp  <= 2'b00;
	  else if(axi4l_rvalid & axi4l_rready)
	     axi4l_rresp  <= 2'b00;
      else if(axi4l_raddr_phs_cmp & (axi4l_araddr > ADDR_LAST))
         axi4l_rresp  <= 2'b10;
   end
   //------------------------------------------------------------------------------------

   //Interrupt logic

    always@(posedge clk or negedge aresetn)
      begin
       if((!aresetn) || (!sresetn))
		  multi_pkt_done_intr <= 1'b0;
	   else if(intr_thrshld_cnt_reg !=0 && CMDSTS_FIFO_ENABLE == 1)
			begin
			 if((pkt_trnsfr_cnt_reg >= (intr_thrshld_cnt_reg - 1)) && status_done_reg_pl )             // generate a pulse for this
			   multi_pkt_done_intr <= 1'b1; 
			 else
			   multi_pkt_done_intr <= 1'b0;   
			end
	   else 
		  multi_pkt_done_intr <= 1'b0;
	  end
	 
	always@(posedge clk or negedge aresetn)
      begin
       if((!aresetn) || (!sresetn))
		 multi_pkt_intr_reg  <= 1'b0;
	   else
	     multi_pkt_intr_reg  <= multi_pkt_done_intr;
	  end

    assign multi_pkt_intr_pl = multi_pkt_done_intr & !multi_pkt_intr_reg;

	   
	 always@(posedge clk or negedge aresetn)
      begin
       if((!aresetn) || (!sresetn))
		  axi4_err_intr <= 1'b0;
	   else if((status[3:2]==2'b10) | (status[3:2]==2'b11))           // Deassert this and generate a pulse
		  axi4_err_intr <= 1'b1;
	   else if((status[3:2]==2'b00))           // Deassert this and generate a pulse
		  axi4_err_intr <= 1'b0;  
	  end
	
	always@(posedge clk or negedge aresetn)
      begin
       if((!aresetn) || (!sresetn))
		 axi4_err_intr_reg  <= 1'b0;
	   else
	     axi4_err_intr_reg  <= axi4_err_intr;
	  end

    assign axi4_err_intr_pl = axi4_err_intr & !axi4_err_intr_reg;
	
	
    assign done_intr          = CMDSTS_FIFO_ENABLE ? ~sts_fifo_empty & sts_fifo_rdata[0]: status[0] & ~done_reg;
    assign multi_pkt_intr     = CMDSTS_FIFO_ENABLE ? multi_pkt_cnt_reg != 0: 0;
   
    assign intr_event 	      = {{INTR_REG_WIDTH-5{1'b0}},pkterr_intr_pl,pktovf_intr_pl,axi4_err_intr_pl,multi_pkt_intr,done_intr};
  
   always@(posedge clk or negedge aresetn)
     begin
       if((!aresetn) || (!sresetn))
		  done_reg <= 0;
	   else                 
		  done_reg <= status[0] & (CMDSTS_FIFO_ENABLE == 0);
	 end
  // interrupt logic for Done and Multi packet done bit
   always@(posedge clk or negedge aresetn)
     begin
       if((!aresetn) || (!sresetn))
		  intr <= 0;
	   else                  
		  intr <= (|(intr_source_reg[1:0] & intr_enable_reg[1:0]));
	 end
  
  //interrupt logic for axi4 error, packet drop error, packet drop overflow and ECC bits
   always@(posedge clk or negedge aresetn)
     begin
       if((!aresetn) || (!sresetn))
		  err_intr <= 0;
	   else                  
		  err_intr <= (|(intr_source_reg[10:2] & intr_enable_reg[10:2]));
	 end
  
   always@(posedge clk or negedge aresetn)
     begin
       if((!aresetn) || (!sresetn))
		  intr_source_reg           <= {SOURCE_REG_WIDTH{1'b0}};
	   else begin
	     if(CMDSTS_FIFO_ENABLE) 
		   begin
		     if(sts_fifo_rden)
		       intr_source_reg[25:16] <= sts_fifo_rdata[25:16];
		   end 
		 else 
		   intr_source_reg[25:16] <= status[25:16];
		 for (intr_source_index=0; intr_source_index<INTR_REG_WIDTH-1; intr_source_index = intr_source_index + 1) begin
	       if(intr_event[intr_source_index])	   	    intr_source_reg[intr_source_index] <= 1'b1;
		   if(intr_clr_reg_int[intr_source_index]) 		intr_source_reg[intr_source_index] <= 1'b0;
		 end
	   end
	 end
   // Packet transfer counter register
   always@(posedge clk or negedge aresetn)
      begin
       if((!aresetn) || (!sresetn))
		 status_done_reg  <= 1'b0;
	   else
	     status_done_reg  <= status[0];
	  end

    assign status_done_reg_pl = status[0] & !status_done_reg;
	
   always@(posedge clk or negedge aresetn)
    begin
		if((!aresetn) || (!sresetn))
	      pkt_trnsfr_cnt_reg <= 16'd0;
		else if(intr_thrshld_cnt_reg !=0 && CMDSTS_FIFO_ENABLE == 1)
		  begin 
		    if(status_done_reg_pl)
		      pkt_trnsfr_cnt_reg <= pkt_trnsfr_cnt_reg + 1'b1;
		    else if(multi_pkt_intr_pl)
		      pkt_trnsfr_cnt_reg <= 16'd0;          //check the priority
	      end
        else 
          pkt_trnsfr_cnt_reg <= 0;  		
	end 
	
	
	/* // Multi packet transfer count register
	always@(posedge clk or negedge aresetn)
    begin
		if((!aresetn) || (!sresetn))
	      multi_pkt_cnt_reg <= 16'd0;
		else if(intr_thrshld_cnt_reg !=0 && CMDSTS_FIFO_ENABLE == 1)
		  begin 
		    if(multi_pkt_intr_pl ^ intr_source_reg[1])
			  begin			   
				if(multi_pkt_intr_pl)
				   multi_pkt_cnt_reg <= multi_pkt_cnt_reg + 1'b1;
				else
				   multi_pkt_cnt_reg <= multi_pkt_cnt_reg - 1;  
		      end
	      end
        else 
          multi_pkt_cnt_reg <= 0;  		
	end */
	// Multi packet transfer count register
	always@(posedge clk or negedge aresetn)
    begin
		if((!aresetn) || (!sresetn))
	      multi_pkt_cnt_reg <= 16'd0;
		else if(intr_thrshld_cnt_reg !=0 && CMDSTS_FIFO_ENABLE == 1)
		  begin 
		    if(multi_pkt_intr_pl & intr_source_reg[1])
			   multi_pkt_cnt_reg <= multi_pkt_cnt_reg;
			else if(intr_source_reg[1])
			   multi_pkt_cnt_reg <= 0;
			else if(multi_pkt_intr_pl)
			   multi_pkt_cnt_reg <= multi_pkt_cnt_reg + 1;  
		  end
        else 
          multi_pkt_cnt_reg <= 0;  		
	end 
	
   // AXI4 Error counter register
   always@(posedge clk or negedge aresetn)
    begin
		if((!aresetn) || (!sresetn))
			axi4_err_cnt_reg <= {CNTR_REG_WIDTH{1'b0}};
		else if(axi4l_wvalid == 1'b1 && axi4l_wready == 1'b1 && axi4l_awaddr_reg == AXI4ERRCNTREG)
		 begin
		    for(i=0; i<2; i=i+1)
              begin
               if(axi4l_wstrb[i])
                 axi4_err_cnt_reg[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
              end
		 end	
		else if (WRITE_EN) 
		 begin 
		    if(axi4_err_intr_pl) 						 							// err_rsp_pl
			axi4_err_cnt_reg <= axi4_err_cnt_reg + 1'b1;
		 end																		//rvalid and rready, generate a pulse from read engine and pass it here
		else if (rresp_err_pl)        														// From read engine pass Read error response (status[3:2]==2'b10) | (status[3:2]==2'b11), axi4i_rresp
			axi4_err_cnt_reg <= axi4_err_cnt_reg + 1'b1; 							// All stats counter needs clearing logic
	end 
	//Packet drop due to error counter register
	always@(posedge clk or negedge aresetn)
    begin
		if((!aresetn) || (!sresetn))
			pktdrop_err_cnt_reg <= {CNTR_REG_WIDTH{1'b0}};
		else if(axi4l_wvalid == 1'b1 && axi4l_wready == 1'b1 && axi4l_awaddr_reg == PKTDRPERRCNTREG)
		 begin
		    for(i=0; i<2; i=i+1)
              begin
               if(axi4l_wstrb[i])
                 pktdrop_err_cnt_reg[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
              end
		 end						   // Use different parameter name 
		else if (pkterr_intr_pl)
			pktdrop_err_cnt_reg <= pktdrop_err_cnt_reg + 1'b1;
	end 
	//Packet drop due to overflow counter register
	always@(posedge clk or negedge aresetn)
    begin
		if((!aresetn) || (!sresetn))
			pktdrop_ovf_cnt_reg <= {CNTR_REG_WIDTH{1'b0}};
		else if(axi4l_wvalid == 1'b1 && axi4l_wready == 1'b1 && axi4l_awaddr_reg == PKTDRPOVFCNTREG)
		 begin
		    for(i=0; i<2; i=i+1)
              begin
               if(axi4l_wstrb[i])
                  pktdrop_ovf_cnt_reg[i*8 +: 8] <= axi4l_wdata[i*8 +: 8];
              end
		 end		
		else if (pktovf_intr_pl)
			pktdrop_ovf_cnt_reg <= pktdrop_ovf_cnt_reg + 1'b1;
	end
	
endmodule
