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

module caxi4pc_cmdsts_fifo
   #(
    //-----------------------------------------------------------------------------------
    // Parameter declaration
    //-----------------------------------------------------------------------------------
    parameter       RESET_TYPE              = 1,                     // Reset Type      	    
                                                                     // Defines the resetn type.
                                                                     // 1: Asynchronous resetn
                                                                     // 0: Synchronous resetn
	parameter       ADDR_WIDTH              = 32,                    // S2MM Address Width																   
    parameter       CMDSTS_FIFO_DEPTH       = 16,                    // Command/Status FIFO depth
	                                                                 // Defines the command/status FIFO depth.
    parameter       CMDSTS_RAM_TYPE         = 0,                     // Command/Status RAM Type
                                                                     // This parameter is used to configure RAM implementation for the command/status FIFO.
    parameter       CMDSTS_ECC              = 0,                     // Command/Status ECC Enable
                                                                     // This parameter is used to enable the command/status ECC for the AXI4 
                                                                     // 0: Disable command/status ECC 
                                                                     // 1: Enable command/status  ECC 
    parameter       CMDF_DWIDTH             = 136,																	  
    parameter       STSF_DWIDTH             = 32,					 // 9											  
    parameter       STATUS_WIDTH            = 32,					 // 9												  
    parameter       UNDEF_BSTLEN            = 0,																	  
    parameter       FAMILY                  = 26,
	parameter       PKT_DROP_OVF   		    = 0,
	parameter       PKT_DROP_ERR            = 0
   )	
	
   (
    // Clock and Reset interface---------------------------------------------------------
    // S2MM
    input   wire                                 clk,                // clock. All the interfaces used into S2MM block (AXI4-Lite target, AXI4-Stream target and AXI4 initiator) uses S2MM clock.
	    
    input   wire                                 resetn,              // This active-low resetn resets the core. S2MM_RESETN must be externally synchronized with the s2mm_clk clock domain.
                                                                          // Note: The resetn is synchronous or asynchronous type based on the RESET_TYPE parameter.
    // Register Interface
    input   wire   [ADDR_WIDTH-1:0]              address_reg,
    input   wire   [31:0]                        length_reg,
    input   wire   [31:0]                        control_reg,

    output                                       cmd_fifo_full,
	
    input                                        cmd_fifo_rden,
    output                                       cmd_fifo_empty,
	output [CMDF_DWIDTH-1:0]                     cmd_fifo_rdata, 

    // Status FIFO interface
    input   wire                                 sts_vld,
    input   wire   [STATUS_WIDTH-1:0]            sts_data,
	output                                       sts_fifo_full,
	
	input   wire                                 sts_read_req,	
	output  wire                                 sts_fifo_empty,
	output  wire   [STATUS_WIDTH-1:0]            sts_fifo_rdata,
	input                                        pkt_err_pl,
	input                                        pkt_ovf_pl

    //-----------------------------------------------------------------------------------
   );
   
   localparam FIFO_ECC = CMDSTS_ECC ? 2 : 0; //When ECC is enabled, it will be used in non-pipline mode. For FIFO non-piplined ECC parameter is set to 2.
   
   // Internal signal--------------------------------------------------------------------
   // Command FIFO Control signal
       
   wire                                 cmd_fifo_wren;
   wire   [CMDF_DWIDTH-1:0]             cmd_fifo_wdata; 

   // Status FIFO Control signal
   reg                                  sts_fifo_wren;   
   wire   [STATUS_WIDTH-1:0]            sts_fifo_wdata;  
   wire                                 sts_fifo_rden;   
   reg									sts_fifo_wren_d;
   

   //------------------------------------------------------------------------------------

   // Reset logic------------------------------------------------------------------------
   wire aresetn = (RESET_TYPE==1) ? 1'b1   : resetn;
   wire sresetn = (RESET_TYPE==1) ? resetn : 1'b1;
   //------------------------------------------------------------------------------------
   
   assign cmd_fifo_wren  = control_reg[0] & ~cmd_fifo_full;
   // Command FIFO Write Data
   // Address0 register = 32 bit     Length is variable
   // Address1 register = 32 bit     Length is variable
   // Length   register = 32 bit     Length is fixed 
   // Burst    type     = 02 bit     Length is fixed
   // Command  ID       = 05 bit     Length is fixed   
   // assign cmd_fifo_wdata = UNDEF_BSTLEN ? {address_reg,control_reg[8:1]} : {address_reg,length_reg,control_reg[8:1]};
	assign cmd_fifo_wdata = UNDEF_BSTLEN ? {address_reg,6'd0,control_reg[25:16],13'd0, control_reg[2:1]} : {address_reg,length_reg,6'd0,control_reg[25:16],13'd0,control_reg[2:1]};
	
   // Command/Status FIFO Instantiation--------------------------------------------------
   // Command FIFO
   // Controller type :                      -
   // Clock           : Single clock         -
   // Memory pipeline : Non-pipeline         -
   // ECC             : Disable              -  FIFO Operation
   // Reset type      : Synchronous resetn    -
   // Optimized for   : High Speed           -
   // FWFT            : Disable               -  
   caxi4pc_corefifo
   #
   (
    .RWIDTH             (CMDF_DWIDTH        ),
    .WWIDTH             (CMDF_DWIDTH        ),
    .RDEPTH             (CMDSTS_FIFO_DEPTH  ),
    .WDEPTH             (CMDSTS_FIFO_DEPTH  ),
    .CTRL_TYPE          (CMDSTS_RAM_TYPE    ),
    .ECC                (FIFO_ECC           ),
    .SYNC_RESET         (RESET_TYPE         ),
	.FWFT               (0                  ),
	.PIPE               (2                  ),
	.FAMILY             (FAMILY             )
   ) cmd_fifo_inst
   (                       
    .CLK                (clk                ),
    .RESET_N            (resetn             ),
    .WE                 (cmd_fifo_wren      ),
    .DATA               (cmd_fifo_wdata     ),
    .RE                 (cmd_fifo_rden      ),
    .Q                  (cmd_fifo_rdata     ),
    .EMPTY              (cmd_fifo_empty     ),
    .FULL               (cmd_fifo_full      ),
    //Unused ioports
    .WCLOCK             (1'b0               ),
    .RCLOCK             (1'b0               ),
    .WRESET_N           (1'b0               ),
    .RRESET_N           (1'b0               ),
    .AFULL              (                   ),    
    .AEMPTY             (                   ),    
    .OVERFLOW           (                   ),  
    .UNDERFLOW          (                   ), 
    .WACK               (                   ),      
    .DVLD               (                   ),      
    .WRCNT              (                   ),     
    .RDCNT              (                   ),     
    .MEMWE              (                   ),     
    .MEMRE              (                   ),     
    .MEMWADDR           (                   ),  
    .MEMRADDR           (                   ),  
    .MEMWD              (                   ),     
    .MEMRD              ({CMDF_DWIDTH{1'b0}}),
    .SB_CORRECT         (                   ),
    .DB_DETECT          (                   )
   );
   
  // assign sts_fifo_wren  = sts_vld | pkt_err_pl | pkt_ovf_pl;
   assign sts_fifo_wdata = sts_data;
   assign sts_fifo_rden  = sts_read_req;
   
	   
   always@(*)
     sts_fifo_wren  = sts_vld; 
   
   // Status FIFO  
   // Controller type :                      -
   // Clock           : Single clock         -
   // Memory pipeline : Non-pipeline         -
   // ECC             : Disable              -  FIFO Operation
   // Reset type      : Synchronous resetn    -
   // Optimized for   : High Speed           -
   // FWFT            : Disable               -  
   caxi4pc_corefifo
   #
   (
    .RWIDTH             (STATUS_WIDTH       ),
    .WWIDTH             (STATUS_WIDTH       ),
    .RDEPTH             (CMDSTS_FIFO_DEPTH  ),
    .WDEPTH             (CMDSTS_FIFO_DEPTH  ),
    .CTRL_TYPE          (CMDSTS_RAM_TYPE    ),
    .ECC                (FIFO_ECC           ),
    .SYNC_RESET         (RESET_TYPE         ),
    .FWFT               (1                  ),
    .PIPE               (1                  ),
	.FAMILY             (FAMILY             )
   ) sts_fifo_inst
   (                       
    .CLK                (clk                ),
    .RESET_N            (resetn             ),
    .WE                 (sts_fifo_wren      ),
    .DATA               (sts_fifo_wdata     ),
    .RE                 (sts_fifo_rden      ),
    .Q                  (sts_fifo_rdata     ),
    .EMPTY              (sts_fifo_empty     ),
    .FULL               (sts_fifo_full      ),
    //Unused ioports
    .WCLOCK             (1'b0               ),
    .RCLOCK             (1'b0               ),
    .WRESET_N           (1'b0               ),
    .RRESET_N           (1'b0               ),
    .AFULL              (                   ),    
    .AEMPTY             (                   ),    
    .OVERFLOW           (                   ),  
    .UNDERFLOW          (                   ), 
    .WACK               (                   ),      
    .DVLD               (                   ),      
    .WRCNT              (                   ),     
    .RDCNT              (                   ),     
    .MEMWE              (                   ),     
    .MEMRE              (                   ),     
    .MEMWADDR           (                   ),  
    .MEMRADDR           (                   ),  
    .MEMWD              (                   ),     
    .MEMRD              ({STATUS_WIDTH{1'b0}}),
    .SB_CORRECT         (                   ),
    .DB_DETECT          (                   )
   );   
   //------------------------------------------------------------------------------------

   //------------------------------------------------------------------------------------

   

   
  //-------------------------------------------------------------------------------------
  
   endmodule

