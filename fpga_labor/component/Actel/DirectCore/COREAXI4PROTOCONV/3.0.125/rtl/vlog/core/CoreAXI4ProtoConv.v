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

module COREAXI4PROTOCONV
   #(
    //-----------------------------------------------------------------------------------
    // Parameter declaration
    //-----------------------------------------------------------------------------------
    // MM2S Parameters
    parameter       MM2S_ENABLE                  = 1,                     // MM2S Enable
                                                                          // 0: Disable MM2S block 
							                                              // 1: Enable MM2S block
    parameter       MM2S_ADDR_WIDTH              = 32,                    // MM2S Address Width
	                                                                      // Defines the address width for I_MM2SAXI4_AWADDR of AXI4 initiator and T_AXI4S_TDEST of AXI4- stream target
    parameter       MM2S_DATA_WIDTH              = 32,                    // MM2S Data Width (in bits)
	                                                                      // Defines the data width for I_AXI4S_TDATA of AXI4 Stream initiator and I_MM2SAXI4_WDATA, I_MM2SAXI4_RDATA of AXI4 initiator
    parameter       MM2S_DATA_FIFO_ENABLE	     = 1,                     // MM2S Data FIFO Enable
                                                                          // 0: Disable the data FIFO
                                                                          // 1: Enable the data FIFO
    parameter       MM2S_DATA_FIFO_DEPTH         = 64,                    // MM2S Data FIFO Depth 
	                                                                      // Defines the data FIFO depth
    parameter       MM2S_DATA_RAM_TYPE           = 2,                     // MM2S Data RAM Type
	                                                                      // 1 - Fabric 3 - uSRAM 2 - LSRAM  
	                                                                      // This parameter is used to configure RAM implementation for the data FIFO
    parameter       MM2S_DATA_ECC                = 0,                     // MM2S Data ECC Enable 
	                                                                      // This parameter is used to enable the ECC for the AXI4
								                                          // 0: Disable the data ECC
								                                          // 1: Enable the data ECC
    parameter       MM2S_PKT_FIFO_ENABLE         = 0,                     // MM2S Store and Forward FIFO Enable
	                                                                      // There are two modes of operation for the FIFO, store and forward and cut through. 
								                                          // This parameter is used to select store and forward or cut through of data FIFO.
																		  
    parameter       MM2S_ENDIAN_CONV             = 0,                     // Enable Big to Little Endian Conversion
                                                                          // 0: Disable endian conversion. This option should be selected when data input on the AXI4 side interface is in little-endian format.
								                                          // 1: Enable endian conversion. This option should be selected when data input on the AXI4 side interface is in big-endian format.
    parameter       MM2S_CMDSTS_FIFO_ENABLE      = 1,                     // MM2S Command Status FIFO Enable
                                                                          // 0: Disable the command/status FIFO
								                                          // 1: Enable the command/status FIFO
    parameter       MM2S_CMDSTS_FIFO_DEPTH       = 16,                    // MM2S Command/Status FIFO depth
	                                                                      // Defines the command/status FIFO depth.
    parameter       MM2S_CMDSTS_RAM_TYPE         = 3,                     // MM2S Command/Status RAM Type
                                                                          // This parameter is used to configure RAM implementation for the command/status FIFO.
    parameter       MM2S_CMDSTS_ECC              = 0,                     // MM2S Command/Status ECC Enable 
                                                                          // This parameter is used to enable the command/status ECC for the AXI4
                                                                          // 0: Disable command/Status ECC 
                                                                          // 1: Enable command/Status ECC 
    parameter       MM2S_USER_ENABLE             = 0,             
	parameter       MM2S_USER_WIDTH              = 1,                     // MM2S User Width (in bits)
	                                                                      // Defines the user width for I_MM2SAXI4S_TUSER of AXI4-Stream initiator and I_MM2SAXI4_WUSER of AXI4 initiator.

    // S2MM Parameters
    parameter       S2MM_ENABLE                  = 1,                     // S2MM Enable
                                                                          // 0: Disable S2MM block 
							                                              // 1: Enable S2MM block   
    parameter       S2MM_ADDR_WIDTH              = 32,                    // S2MM Address Width
	                                                                      // Defines the address width for I_S2MMAXI4_AWADDR, I_S2MMAXI4_ARADDR of AXI4 initiator and T_AXI4S_TDEST of AXI4-stream target.
    parameter       S2MM_DATA_WIDTH              = 32,                    // S2MM Data Width (in bits)
	                                                                      // Defines the data width for T_AXI4S_TDATA of AXI4-Stream target, I_S2MMAXI4_WDATA and I_S2MMAXI4_RDATA of AXI4 initiator.
    parameter       S2MM_DATA_FIFO_ENABLE	     = 1,                     // S2MM Data FIFO Enable
                                                                          // 0: Disable the data FIFO
                                                                          // 1: Enable the data FIFO
    parameter       S2MM_DATA_FIFO_DEPTH         = 64,                    // S2MM Data FIFO Depth 
	                                                                      // Defines the data FIFO depth
    parameter       S2MM_DATA_RAM_TYPE           = 2,                     // S2MM Data RAM Type
	                                                                      // This parameter is used to configure RAM implementation for the data FIFO.
    parameter       S2MM_DATA_ECC                = 0,                     // S2MM Data ECC Enable 
	                                                                      // This parameter is used to enable the ECC for the AXI4
								                                          // 0: Disable the data ECC
								                                          // 1: Enable the data ECC
    parameter       S2MM_PKT_FIFO_ENABLE         = 0,                     // S2MM Store and Forward FIFO Enable
	                                                                      // There are two modes of operation for the FIFO, store and forward and cut through. 
								                                          // This parameter is used to select store and forward or cut through of data FIFO.
    parameter       S2MM_ENDIAN_CONV             = 0,                     // Enable Big to Little Endian Conversion
                                                                          // 0: Disable endian conversion. This option should be selected when data input on the AXI4-Stream side interface is in little-endian format.
                                                                          // 1: Enable endian conversion. This option should be selected when data input on the AXI4-Stream side interface is in big-endian format.
    parameter       S2MM_UNDEF_BSTLEN            = 0,                     // S2MM Undefined Burst Length
                                                                          // 0: Disable the undefined burst length for S2MM
                                                                          // 1: Enables the undefined burst length for S2MM, 
								                                          // This parameter should be enabled when the number of bytes to be received on the AXI4-Stream interface of S2MM block is unknown.
    parameter [8:0] S2MM_BURST_LENGTH            = 32,                    // S2MM Burst Length
                                                                          // Defines the maximum AXI4-memory mapped burst length data beats.
								                                          // This parameter is visible to user when S2MM Undefined Burst Length is enabled.
    parameter       S2MM_CMDSTS_FIFO_ENABLE      = 1,                     // S2MM Command Status FIFO Enable
                                                                          // 0: Disable the command/status FIFO
                                                                          // 1: Enable the command/status FIFO
    parameter       S2MM_CMDSTS_FIFO_DEPTH       = 16,                    // S2MM Command/Status FIFO depth
	                                                                      // Defines the command/status FIFO depth.
    parameter       S2MM_CMDSTS_RAM_TYPE         = 3,                     // S2MM Command/Status RAM Type
                                                                          // This parameter is used to configure RAM implementation for the command/status FIFO.
    parameter       S2MM_CMDSTS_ECC              = 0,                     // S2MM Command/Status ECC Enable
                                                                          // This parameter is used to enable the command/status ECC for the AXI4 
                                                                          // 0: Disable command/status ECC 
                                                                          // 1: Enable command/status  ECC 
    parameter       S2MM_USER_ENABLE             = 0, 
    parameter       S2MM_USER_WIDTH              = 1,                     // S2MM User Width (in bits)
                                                                          // Defines the user width for  T_AXI4S_TUSER of AXI4-Stream target and I_S2MMAXI4_WUSER of AXI4 initiator.
	parameter       S2MM_PKT_DROP_OVF            = 0, 					  // Drop the packets when S2MM Data FIFO is overflow.  
																		  // 0: Disable the packet drop overflow
                                                                          // 1: Enable the packet drop overflow 
	parameter       S2MM_PKT_DROP_ERR            = 0,					  // Drop the packet when input port S2MM_PKT_ERR is asserted.	
    parameter       RESET_TYPE              	 = 0,                     // Reset Type      	    
                                                                          // Defines the reset type.
                                                                          // 0: Asynchronous reset
                                                                          // 1: Synchronous reset	
	parameter       FAMILY                       = 26,																		    
    parameter       TGIGEN_DISPLAY_SYMBOL        = 1																		   
   )								      
   
   (
    // Clock and Reset interface----------------------------------------------------
    input   wire                                 ACLK,                   // All the interfaces used into S2MM or MM2S block (AXI4-Lite target, AXI4-Stream target and AXI4 initiator) uses ACLK.
																	     
    input   wire                                 RESETN,                 // This active-low reset resets the core. RESETN must be externally synchronized with the ACLK clock domain.
                                                                              // Note: The reset is synchronous or asynchronous type based on the RESET_TYPE parameter.
    // I/O Ports                                                         
    // AXI4-Lite Port Interface                                          
    input   wire                                 T_AXI4L_AWVALID,         // AXI4-Lite write address valid. This signal indicates that valid write address and control information are available.
    output  wire                                 T_AXI4L_AWREADY,         // AXI4-Lite write address ready. This signal indicates that the target is ready to accept an address and associated control signals.
    input   wire   [10:0]                        T_AXI4L_AWADDR,          // AXI4-Lite write address.
                                                                          // This information determines the number of data transfers associated with the address.
																	     
    input   wire   [31:0]                        T_AXI4L_WDATA,           // AXI4-Lite write data.
    input   wire   [3:0]                         T_AXI4L_WSTRB,           // AXI4-Lite write strobes.
    input   wire                                 T_AXI4L_WVALID,          // AXI4-Lite write valid.
    output  wire                                 T_AXI4L_WREADY,          // AXI4-Lite Write ready.
																	     
    output  wire   [1:0]                         T_AXI4L_BRESP,           // AXI4-Lite write response.
    output  wire                                 T_AXI4L_BVALID,          // AXI4-Lite write response valid.
    input   wire                                 T_AXI4L_BREADY,          // AXI4-Lite response ready.
																	     
    input   wire   [10:0]                        T_AXI4L_ARADDR,          // AXI4-Lite read address. The read address gives the address of the first transfer in a read burst transaction.  
    input   wire                                 T_AXI4L_ARVALID,         // AXI4-Lite read address valid. This signal indicates that the channel is signaling valid read address and control information. 
    output  wire                                 T_AXI4L_ARREADY,         // AXI4-Lite response ready. This signal indicates that the target is ready to accept an address and associated control signals. 
																	     
    output  wire   [31:0]                        T_AXI4L_RDATA,           // AXI4-Lite read data.
    output  wire   [1:0]                         T_AXI4L_RRESP,           // AXI4-Lite read response.
    output  wire                                 T_AXI4L_RVALID,          // AXI4-Lite read valid. This signal indicates that the channel is signaling the required read data.
    input   wire                                 T_AXI4L_RREADY,          // AXI4-Lite read ready. This signal indicates that the Initiator can accept the read data and response information.
    // S2MM  
    // AXI4-Stream Target Port Interface
    output  wire                                 T_AXI4S_TREADY,          // AXI4-Stream ready indicates that the target can accept a transfer in the current cycle.
    input   wire                                 T_AXI4S_TVALID,          // AXI4-Stream valid indicates that the initiator is driving a valid transfer.
    input   wire                                 T_AXI4S_TID,             // AXI4-Stream TID is the data stream identifier that indicates different streams of data.
    input   wire  [S2MM_ADDR_WIDTH - 1:0]        T_AXI4S_TDEST,           // AXI4-Stream destination provides routing information for the data stream.
    input   wire  [S2MM_DATA_WIDTH - 1:0]        T_AXI4S_TDATA,           // AXI4-Stream data is the primary payload that is used to provide the data that is passing across the interface.
    input   wire  [(S2MM_DATA_WIDTH /8) - 1 :0]  T_AXI4S_TKEEP,           // AXI4-Stream keep is the byte qualifier that indicates whether the content of the associated byte of data is processed as part of the data stream.
    input   wire                                 T_AXI4S_TLAST,           // AXI4-Stream last indicates the boundary of a packet.      
    input   wire  [(S2MM_USER_WIDTH - 1):0]      T_AXI4S_TUSER,           // AXI4-Stream target user defined sideband information that can be transmitted alongside the data stream.

    // AXI4 Initiator Write Interface 
	output  wire                                 I_S2MMAXI4_AWID,
    output  wire  [S2MM_ADDR_WIDTH - 1:0]        I_S2MMAXI4_AWADDR,       // AXI4 initiator write address. The write address gives the address of the first transfer in a write burst transaction.    
    output  wire                                 I_S2MMAXI4_AWVALID,      // AXI4 initiator write address valid. This signal indicates that valid write address and control information are available.  
    input   wire                                 I_S2MMAXI4_AWREADY,      // AXI4 initiator write address ready. This signal indicates that the target is ready to accept an address and associated control signals.   
    output  wire  [7:0]                          I_S2MMAXI4_AWLEN,        // AXI4 initiator the burst length gives the exact number of transfers in a burst. 
                                                                          // This information determines the number of data transfers associated with the address.   
    output  wire  [2:0]                          I_S2MMAXI4_AWSIZE,       // AXI4 initiator burst size signal indicates the size of each transfer in the burst.
    output  wire  [1:0]                          I_S2MMAXI4_AWBURST,      // AXI4 initiator burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
    input   wire                                 I_S2MMAXI4_WREADY,       // AXI4 initiator write ready. This signal indicates that the target can accept the write data.
    output  wire                                 I_S2MMAXI4_WVALID,       // AXI4 initiator write valid This signal indicates that valid write data and strobes are available.
    output  wire  [S2MM_DATA_WIDTH - 1:0]        I_S2MMAXI4_WDATA,        // AXI4 initiator write data.
    output  wire  [(S2MM_DATA_WIDTH/8) - 1:0]    I_S2MMAXI4_WSTRB,        // AXI4 initiator write strobes. This signal indicates which byte lanes hold valid data.
                                                                          // There is one write strobe bit for each eight bits of the write data bus.    
    output  wire                                 I_S2MMAXI4_WLAST,        // AXI4 initiator write last. This signal indicates the last transfer in a write burst.
    output  wire  [S2MM_USER_WIDTH - 1:0]        I_S2MMAXI4_WUSER,        // AXI4 initiator write user signal.
    output  wire                                 I_S2MMAXI4_BREADY,       // AXI4 initiator response ready. This signal indicates that the Initiator can accept a write response.
    input   wire                                 I_S2MMAXI4_BVALID,       // AXI4 initiator write response valid. This signal indicates that the channel is signaling a valid write response.    
    input   wire                                 I_S2MMAXI4_BID,          // AXI4 initiator write response valid. This signal indicates that the channel is signaling a valid write response.    
    input   wire   [1:0]                         I_S2MMAXI4_BRESP,        // AXI4 initiator write response. This signal indicates the status of the write transaction.
    
	// S2MM Interrupt Ports
	output  wire 								 S2MM_INT,				  // S2MM_INT is asserted when S2MM Done or S2MM Multi PKT Done bits of the S2MM Interrupt Source Register is set to 1 and corresponding bits of S2MM Interrupt Enable register is set to 1. 
	output  wire 								 S2MM_ERR_INT,			  // 
	
	input   wire 								 S2MM_PKT_ERR, 			  // Core drops the packet when this port is set to high. This port will be sampled on EOP boundary (AXI4 Stream TLAST) is detected. 
																		  // This port will be exposed to the user only when GUI parameter S2MM Store and Forward FIFO Enable is enabled. 
    // MM2S

    // AXI4-Stream Target Port Interface
    input   wire                                 I_AXI4S_TREADY,          // AXI4-Stream ready indicates that the target can accept a transfer in the current cycle.
    output  wire                                 I_AXI4S_TVALID,          // AXI4-Stream initiator valid indicates that the Initiator is driving a valid transfer.
                                                                          // A transfer takes place when both I_AXI4S_TVALID and I_AXI4S_TREADY are asserted.
    output  wire                                 I_AXI4S_TID,             // AXI4-Stream TID is the data stream identifier that indicates different streams of data.
    output  wire  [MM2S_ADDR_WIDTH - 1:0]        I_AXI4S_TDEST,           // AXI4-Stream destination provides routing information for the data stream.
    output  wire  [MM2S_DATA_WIDTH - 1:0]        I_AXI4S_TDATA,           // AXI4-Stream initiator data is the primary payload that is used to provide the data that is passing across the interface.
    output  wire  [(MM2S_DATA_WIDTH /8) - 1 :0]  I_AXI4S_TKEEP,           // AXI4-Stream keep is the byte qualifier that indicates whether the content of the associated byte of data is processed as part of the data stream.
    output  wire                                 I_AXI4S_TLAST,           // AXI4-Stream last indicates the boundary of a packet.      
    output  wire  [(MM2S_USER_WIDTH - 1):0]      I_AXI4S_TUSER,           // AXI4-Stream initiator user defined sideband information that can be transmitted alongside the data stream

    // AXI4 Initiator Read Interface Ports 
    output  wire                                 I_MM2SAXI4_ARID,         // AXI4 initiator Read address ID.
    input   wire                                 I_MM2SAXI4_ARREADY,      // AXI4 Target read address ready. This signal indicates that the target is ready to accept an address and associated control signals.
    output  wire                                 I_MM2SAXI4_ARVALID,      // AXI4 initiator read address valid. This signal indicates that the channel is signaling valid read address and control information.
    output  wire  [(MM2S_ADDR_WIDTH - 1):0]      I_MM2SAXI4_ARADDR,       // AXI4 initiator read address. The read address gives the address of the first transfer in a read burst transaction.
    output  wire  [7:0]                          I_MM2SAXI4_ARLEN,        // AXI4 initiator burst length. This signal indicates the exact number of transfers in a burst.
    output  wire  [2:0]                          I_MM2SAXI4_ARSIZE,       // AXI4 initiator burst size. This signal indicates the size of each transfer in the burst.   
    output  wire  [1:0]                          I_MM2SAXI4_ARBURST,      // AXI4 initiator burst type. The burst type and the size information determine how the address for each transfer within the burst is calculated.
    input   wire                                 I_MM2SAXI4_RID,          // AXI4 initiator read ID tag.
    output  wire                                 I_MM2SAXI4_RREADY,       // AXI4 initiator Read ready. This signal indicates that the Initiator can accept the read data and response information.
    input   wire                                 I_MM2SAXI4_RVALID,       // AXI4 target read valid. This signal indicates that the channel is signaling the required read data.
    input   wire  [(MM2S_DATA_WIDTH - 1):0]      I_MM2SAXI4_RDATA,        // AXI4 target Read data.
    input   wire                                 I_MM2SAXI4_RLAST,        // AXI4 target read last. This signal indicates the last transfer in a read burst.
    input   wire  [1:0]                          I_MM2SAXI4_RRESP,        // AXI4 target read response. This signal indicates the status of the read transfer.
    input   wire [(MM2S_USER_WIDTH - 1):0]       I_MM2SAXI4_RUSER,         // IP Core does not support user defined signal in the read data channel.      

   // MM2S Interrupt Ports
    output  wire 								 MM2S_INT,
	output  wire 								 MM2S_ERR_INT,
	
	output  wire  				  			     DEBUG
   );
    
    // Internal signal-------------------------------------------------------------
	//S2MM local parameter

    localparam S2MM_USER_DWIDTH          =    S2MM_USER_ENABLE  ? S2MM_USER_WIDTH +  S2MM_DATA_WIDTH : S2MM_DATA_WIDTH; 
    // Parameter declaration                                           tkeep            tlst      tdata	
    localparam S2MM_DATF_DWIDTH          =    S2MM_UNDEF_BSTLEN ? (S2MM_DATA_WIDTH/8)	+ 1 + S2MM_USER_DWIDTH : S2MM_USER_DWIDTH;

	//                                                             ADDRESS       Res+CMDID+Reserve+BURST TYPE   ADDRESS        LENGTH   Res+CMDID+Reserve+BURST TYPE
	localparam S2MM_CMDF_DWIDTH          =    S2MM_UNDEF_BSTLEN ? S2MM_ADDR_WIDTH +  31              :  S2MM_ADDR_WIDTH +  32    +      31;
	//                                        Res CMDID Reserve Err_Resp Reserve Done
    localparam S2MM_STSF_DWIDTH          =    6 +  10  +  12  +  2 	+  1  +    1;
                                                                                   //Length
    localparam S2MM_STATUS_WIDTH         =    S2MM_UNDEF_BSTLEN ? S2MM_STSF_DWIDTH + 32 : S2MM_STSF_DWIDTH;	
	localparam S2MM_ADDR_LAST 			 =	  11'h108;				  // S2MM last address
	localparam S2MM_INTR_REG_WIDTH 		 =    16;
	localparam S2MM_CNTR_REG_WIDTH 		 =    16;
	localparam S2MM_WRITE_EN 			 = 	  1'b1;
	
	//MM2S local parameter
	
	// Parameter declaration                                               tuser     tkeep                   tlast    tdata         tkeep                 tlast        tdata
    localparam MM2S_DATF_DWIDTH          =    MM2S_USER_ENABLE ? (MM2S_USER_WIDTH +(MM2S_DATA_WIDTH/8) + 1 + MM2S_DATA_WIDTH) : ((MM2S_DATA_WIDTH/8) + 1    + MM2S_DATA_WIDTH); 	
	//                                        ADDRESS           LENGTH   Res+CMDID+Reserve+BURST TYPE
	localparam MM2S_CMDF_DWIDTH          =    MM2S_ADDR_WIDTH +  32    +      31;
	//                                       Res CMDID Reserve Err_Resp Reserve Done
    localparam MM2S_STSF_DWIDTH          =     6 + 10  +  12  +  2 	+  1  +    1;
	localparam MM2S_ADDR_LAST			 =    11'h500;          // MM2S last address
	localparam MM2S_INTR_REG_WIDTH 		 =    16;
	localparam MM2S_CNTR_REG_WIDTH 		 =    16;
	localparam MM2S_WRITE_EN 			 = 	  1'b0;
	//localparam REG_ADDR_OFFSET 			 = 	  MM2S_ENABLE ? 1'b1: (S2MM_ENABLE ? 1'b0 : 1'b0);         //// Register address offset, For S2MM = 0, MM2S =1, 
	
	// S2MM/MM2S
    // AXI4-Lite Port Interface
	wire                                 s2mm_awvalid;
	wire                                 s2mm_awready;
	wire   [10:0]                        s2mm_awaddr; 
	
	wire   [31:0]                        s2mm_wdata;  
	wire   [3:0]                         s2mm_wstrb;  
	wire                                 s2mm_wvalid; 
	wire                                 s2mm_wready; 
 
	wire   [1:0]						 s2mm_bresp;  
	wire								 s2mm_bvalid; 
	wire								 s2mm_bready;
	
    wire   [10:0]                        s2mm_araddr; 
    wire                                 s2mm_arvalid;
    wire                                 s2mm_arready;
	
    wire   [31:0]                        s2mm_rdata;  
    wire   [1:0]                         s2mm_rresp;  
    wire                                 s2mm_rvalid; 
	wire                                 s2mm_rready; 
	
	wire                                 mm2s_awvalid;
	wire                                 mm2s_awready;
	wire   [10:0]                        mm2s_awaddr; 
										
	wire   [31:0]                        mm2s_wdata;  
	wire   [3:0]                         mm2s_wstrb;  
	wire                                 mm2s_wvalid; 
	wire                                 mm2s_wready; 
										
	wire   [1:0]						 mm2s_bresp;  
	wire								 mm2s_bvalid; 
	wire								 mm2s_bready;
										
    wire   [10:0]                        mm2s_araddr; 
    wire                                 mm2s_arvalid;
    wire                                 mm2s_arready;
										 
    wire   [31:0]                        mm2s_rdata;  
    wire   [1:0]                         mm2s_rresp;  
    wire                                 mm2s_rvalid; 
	wire                                 mm2s_rready; 
    //s2mm cmd/sts fifo signals                                                
    wire   [S2MM_ADDR_WIDTH-1:0]         s2mm_address_reg;                     
    wire   [31:0]                        s2mm_length_reg;                     
    wire   [31:0]                        s2mm_control_reg;	                  
	wire                                 s2mm_cmd_fifo_full;                             
	wire                                 s2mm_cmd_fifo_rden;                 
	wire                                 s2mm_cmd_fifo_empty;                
	wire   [S2MM_CMDF_DWIDTH-1:0]        s2mm_cmd_fifo_rdata;	             
	wire                                 s2mm_sts_fifo_rden;                 
	wire                                 s2mm_sts_fifo_empty;                
	wire   [S2MM_STATUS_WIDTH-1:0]       s2mm_sts_fifo_rdata;                
	                                                                         
	wire                                 s2mm_sts_fifo_vld;                  
	wire                                 s2mm_sts_fifo_full;                 
	wire   [S2MM_STATUS_WIDTH-1:0]       s2mm_we_status;                     
	                                                                         
	wire                                 s2mm_data_fifo_empty;               
	
	wire                                 s2mm_we_tready;
	wire                                 s2mm_dataf_tready;
	
    wire   [MM2S_ADDR_WIDTH-1:0]         mm2s_address_reg;
    wire   [31:0]                        mm2s_length_reg;
    wire   [31:0]                        mm2s_control_reg;	
	wire                                 mm2s_cmd_fifo_full;
	wire                                 mm2s_cmd_fifo_rden;
	wire                                 mm2s_cmd_fifo_empty;
	wire   [MM2S_CMDF_DWIDTH-1:0]        mm2s_cmd_fifo_rdata;	
	wire                                 mm2s_sts_fifo_rden;
	wire                                 mm2s_sts_fifo_empty;
	wire   [MM2S_STSF_DWIDTH-1:0]        mm2s_sts_fifo_rdata;
	
	wire                                 mm2s_re_tvalid;
	wire                                 mm2s_re_tready;
	wire                                 mm2s_re_tid;  
	wire   [MM2S_ADDR_WIDTH-1:0]         mm2s_re_tdest;
	wire   [MM2S_DATA_WIDTH-1:0]         mm2s_re_tdata;
	wire   [(MM2S_DATA_WIDTH/8)-1:0]     mm2s_re_tkeep;
	wire                                 mm2s_re_tlast;
	wire   [MM2S_USER_WIDTH-1:0]         mm2s_re_tuser;
	
	wire                                 mm2s_dataf_tvalid;
	wire                                 mm2s_dataf_tready;
	wire                                 mm2s_dataf_tid;  
	wire   [MM2S_ADDR_WIDTH-1:0]         mm2s_dataf_tdest;
	wire   [MM2S_DATA_WIDTH-1:0]         mm2s_dataf_tdata;
	wire   [(MM2S_DATA_WIDTH/8)-1:0]     mm2s_dataf_tkeep;
	wire                                 mm2s_dataf_tlast;
	wire   [MM2S_USER_WIDTH-1:0]         mm2s_dataf_tuser;	
	
	
	wire                                 mm2s_data_fifo_wren;
	wire                                 mm2s_data_fifo_full;
	wire   [MM2S_DATF_DWIDTH-1:0]        mm2s_data_fifo_wrdata;
	
	wire                                 mm2s_sts_fifo_vld;
	wire                                 mm2s_sts_fifo_full;
	wire   [MM2S_STSF_DWIDTH-1:0]        mm2s_re_status;
	
	wire 								 mm2s_rresp_err_pl;
    
    // Command/Status FIFO Interface
	
	// Data FIFO inetrface
	wire                                 s2mm_data_fifo_rden;
	wire   [(S2MM_DATF_DWIDTH-1):0]      s2mm_data_fifo_rdata; 
	
	wire                                 pkt_err_pulse;
	wire 								 pkt_ovf_pulse;
	wire 								 pktovf_intr_pulse;
	wire 								 pkterr_intr_pulse;
	wire 								 s2mm_multi_pkt_pulse;
	wire 								 s2mm_multi_pkt_intr_en;
	wire 								 mm2s_multi_pkt_pulse;
	wire 								 mm2s_multi_pkt_intr_en;
    //-----------------------------------------------------------------------------------
	
   //------------------------------------------------------------------------------------
   
   assign  I_AXI4S_TVALID  = MM2S_DATA_FIFO_ENABLE ? mm2s_dataf_tvalid : mm2s_re_tvalid;
   assign  I_AXI4S_TID     = MM2S_DATA_FIFO_ENABLE ? mm2s_dataf_tid    : mm2s_re_tid;  
   assign  I_AXI4S_TDEST   = MM2S_DATA_FIFO_ENABLE ? mm2s_dataf_tdest  : mm2s_re_tdest;
   assign  I_AXI4S_TDATA   = MM2S_DATA_FIFO_ENABLE ? mm2s_dataf_tdata  : mm2s_re_tdata;
   assign  I_AXI4S_TKEEP   = MM2S_DATA_FIFO_ENABLE ? mm2s_dataf_tkeep  : mm2s_re_tkeep;
   assign  I_AXI4S_TLAST   = MM2S_DATA_FIFO_ENABLE ? mm2s_dataf_tlast  : mm2s_re_tlast;
   assign  I_AXI4S_TUSER   = MM2S_DATA_FIFO_ENABLE ? mm2s_dataf_tuser  : mm2s_re_tuser;
   
   assign  mm2s_re_tready     = I_AXI4S_TREADY;
   assign  mm2s_dataf_tready  = I_AXI4S_TREADY;
   
   assign  T_AXI4S_TREADY     = S2MM_DATA_FIFO_ENABLE ? s2mm_dataf_tready : s2mm_we_tready;

		caxi4pc_axi4l_decoder 
	   #(
        .RESET_TYPE          	                 ( RESET_TYPE            	 ),
		.S2MM_ENABLE                             ( S2MM_ENABLE               ),
		.MM2S_ENABLE                             ( MM2S_ENABLE               )
		)   
		caxi4pc_axi4l_decoder_inst
		(
		// Clock and Reset interface             
		// S2MM                                  
		.clk                                     ( ACLK                      ),
		.resetn                                  ( RESETN                    ),
		// AXI4-Lite Port Interface                                        
		.t_axi4l_awvalid                         ( T_AXI4L_AWVALID           ),
		.t_axi4l_awready                         ( T_AXI4L_AWREADY           ),
		.t_axi4l_awaddr                          ( T_AXI4L_AWADDR            ),
		                                                                   
		.t_axi4l_wdata                           ( T_AXI4L_WDATA             ),
		.t_axi4l_wstrb                           ( T_AXI4L_WSTRB             ),
		.t_axi4l_wvalid                          ( T_AXI4L_WVALID            ),
		.t_axi4l_wready                          ( T_AXI4L_WREADY            ),
		                                                                    
		.t_axi4l_bresp                           ( T_AXI4L_BRESP             ),
		.t_axi4l_bvalid                          ( T_AXI4L_BVALID            ),
		.t_axi4l_bready                          ( T_AXI4L_BREADY            ),
		                                                                     
		.t_axi4l_araddr                          ( T_AXI4L_ARADDR            ),
		.t_axi4l_arvalid                         ( T_AXI4L_ARVALID           ),
		.t_axi4l_arready                         ( T_AXI4L_ARREADY           ),
		                                                                  
		.t_axi4l_rdata                           ( T_AXI4L_RDATA             ),
		.t_axi4l_rresp                           ( T_AXI4L_RRESP             ),
		.t_axi4l_rvalid                          ( T_AXI4L_RVALID            ),
		.t_axi4l_rready                          ( T_AXI4L_RREADY            ),
		// S2MM AXI4-Lite Port Interface                                        
		.s2mm_axi4l_awvalid                         ( s2mm_awvalid           ),
		.s2mm_axi4l_awready                         ( s2mm_awready           ),
		.s2mm_axi4l_awaddr                          ( s2mm_awaddr            ),
																	         
		.s2mm_axi4l_wdata                           ( s2mm_wdata             ),
		.s2mm_axi4l_wstrb                           ( s2mm_wstrb             ),
		.s2mm_axi4l_wvalid                          ( s2mm_wvalid            ),
		.s2mm_axi4l_wready                          ( s2mm_wready            ),
																	         
		.s2mm_axi4l_bresp                           ( s2mm_bresp             ),
		.s2mm_axi4l_bvalid                          ( s2mm_bvalid            ),
		.s2mm_axi4l_bready                          ( s2mm_bready            ),
																	         
		.s2mm_axi4l_araddr                          ( s2mm_araddr            ),
		.s2mm_axi4l_arvalid                         ( s2mm_arvalid           ),
		.s2mm_axi4l_arready                         ( s2mm_arready           ),
																	         
		.s2mm_axi4l_rdata                           ( s2mm_rdata             ),
		.s2mm_axi4l_rresp                           ( s2mm_rresp             ),
		.s2mm_axi4l_rvalid                          ( s2mm_rvalid            ),
		.s2mm_axi4l_rready                          ( s2mm_rready            ),
		// MM2S AXI4-Lite Port Interface                                        
		.mm2s_axi4l_awvalid                         ( mm2s_awvalid           ),
		.mm2s_axi4l_awready                         ( mm2s_awready           ),
		.mm2s_axi4l_awaddr                          ( mm2s_awaddr            ),
                                                                   
		.mm2s_axi4l_wdata                           ( mm2s_wdata             ),
		.mm2s_axi4l_wstrb                           ( mm2s_wstrb             ),
		.mm2s_axi4l_wvalid                          ( mm2s_wvalid            ),
		.mm2s_axi4l_wready                          ( mm2s_wready            ),
		                                                               
		.mm2s_axi4l_bresp                           ( mm2s_bresp             ),
		.mm2s_axi4l_bvalid                          ( mm2s_bvalid            ),
		.mm2s_axi4l_bready                          ( mm2s_bready            ),
		                                                               
		.mm2s_axi4l_araddr                          ( mm2s_araddr            ),
		.mm2s_axi4l_arvalid                         ( mm2s_arvalid           ),
		.mm2s_axi4l_arready                         ( mm2s_arready           ),
		                                                             
		.mm2s_axi4l_rdata                           ( mm2s_rdata             ),
		.mm2s_axi4l_rresp                           ( mm2s_rresp             ),
		.mm2s_axi4l_rvalid                          ( mm2s_rvalid            ),
		.mm2s_axi4l_rready                          ( mm2s_rready            )			
		);
		   
   
   generate   
      if(S2MM_ENABLE)
      begin : s2mm_en  
         caxi4pc_axi4l_trgt_register 
         #(
           .RESET_TYPE                           ( RESET_TYPE          		 ),
           .ADDR_WIDTH                           ( S2MM_ADDR_WIDTH           ),
           .CMDSTS_FIFO_ENABLE                   ( S2MM_CMDSTS_FIFO_ENABLE   ),
           .STATUS_WIDTH                         ( S2MM_STATUS_WIDTH         ),
           .UNDEF_BSTLEN                         ( S2MM_UNDEF_BSTLEN         ),
		   .INTR_REG_WIDTH						 ( S2MM_INTR_REG_WIDTH       ),
		   .CNTR_REG_WIDTH						 ( S2MM_CNTR_REG_WIDTH		 ),
		   .ADDR_LAST 							 ( S2MM_ADDR_LAST 			 ),
		   .WRITE_EN							 ( S2MM_WRITE_EN			 ),
		   .REG_ADDR_OFFSET						 ( 0            			 )
          )                                        
          caxi4pc_s2mm_register_inst              
         (                                         
          // Clock and Reset interface             
          // S2MM                                  
          .clk                                   ( ACLK                      ),
          .resetn                                ( RESETN                    ),
          // AXI4-Lite Port Interface                                        
          .axi4l_awvalid                         ( s2mm_awvalid              ),           
          .axi4l_awready                         ( s2mm_awready              ),           
          .axi4l_awaddr                          ( s2mm_awaddr               ),           
                                                                              
          .axi4l_wdata                           ( s2mm_wdata                ),           
          .axi4l_wstrb                           ( s2mm_wstrb                ),           
          .axi4l_wvalid                          ( s2mm_wvalid               ),           
          .axi4l_wready                          ( s2mm_wready               ),           
                                                                       
          .axi4l_bresp                           ( s2mm_bresp                ),           
          .axi4l_bvalid                          ( s2mm_bvalid               ),           
          .axi4l_bready                          ( s2mm_bready               ),           
                                                                                 
          .axi4l_araddr                          ( s2mm_araddr               ),           
          .axi4l_arvalid                         ( s2mm_arvalid              ),           
          .axi4l_arready                         ( s2mm_arready              ),           
                                                                                 
          .axi4l_rdata                           ( s2mm_rdata                ),           
          .axi4l_rresp                           ( s2mm_rresp                ),           
          .axi4l_rvalid                          ( s2mm_rvalid               ),           
          .axi4l_rready                          ( s2mm_rready               ),           
												                                      
           //Registers                             
          .address_reg                           ( s2mm_address_reg          ),
          .length_reg                            ( s2mm_length_reg           ),
          .control_reg                           ( s2mm_control_reg          ),
  	       
		   //Status fifo signals                    
		  .sts_fifo_rden                         ( s2mm_sts_fifo_rden        ),
		  .sts_fifo_empty                        ( s2mm_sts_fifo_empty       ),
		  .sts_fifo_rdata                        ( s2mm_sts_fifo_rdata       ),
												   
		  //Status coming from the write engine if  status fifo is disabled. 
		  .status                                ( s2mm_we_status            ),
		  
		  //Command fifo signals 
		  .cmd_fifo_full                         ( s2mm_cmd_fifo_full        ),
		  .rresp_err_pl							 ( 							 ),
		  // Interrupt Ports
		  .intr									 ( S2MM_INT 				 ),
		  .err_intr								 ( S2MM_ERR_INT 			 ),
		  .pkterr_intr_pl						 ( pkterr_intr_pulse	     ),
		  .pktovf_intr_pl						 ( pktovf_intr_pulse		 ),
		  .multi_pkt_intr_pl					 ( s2mm_multi_pkt_pulse		 )
         );


	    caxi4pc_write_engine # 
		(
		  .AWIDTH                                ( S2MM_ADDR_WIDTH           ),
		  .DWIDTH                                ( S2MM_DATA_WIDTH           ),
		  .DATA_FIFO_ENABLE                      ( S2MM_DATA_FIFO_ENABLE     ),
		  .PKT_FIFO_ENABLE                       ( S2MM_PKT_FIFO_ENABLE      ),
		  //.UNALIGNED_TRANSFER                    ( S2MM_UNALIGNED_TRANSFER   ),
		  .UNDEF_BSTLEN                          ( S2MM_UNDEF_BSTLEN         ),
          .BURST_LENGTH                          ( S2MM_BURST_LENGTH         ),
          .CMDSTS_FIFO_ENABLE                    ( S2MM_CMDSTS_FIFO_ENABLE   ),
          .USER_ENABLE                           ( S2MM_USER_ENABLE          ),
          .UWIDTH                                ( S2MM_USER_WIDTH           ),
          .RESET_TYPE                            ( RESET_TYPE           ),
          .ENDIAN_CONV                           ( S2MM_ENDIAN_CONV          ),
          .CMDF_DWIDTH                           ( S2MM_CMDF_DWIDTH          ),
          .DATF_DWIDTH                           ( S2MM_DATF_DWIDTH          ),
          .STATUS_WIDTH                          ( S2MM_STATUS_WIDTH         ),
          .PKT_DROP_ERR                          ( S2MM_PKT_DROP_ERR         ),
          .PKT_DROP_OVF                          ( S2MM_PKT_DROP_OVF         )	
		) caxi4pc_write_engine_inst 
		(
		  .aclk                                  ( ACLK              	     ),
		  .resetn                                ( RESETN              		 ), 		  
		  .axi4i_aid                             ( I_S2MMAXI4_AWID           ),  
		  .axi4i_addr                            ( I_S2MMAXI4_AWADDR         ),  
		  .axi4i_avalid                          ( I_S2MMAXI4_AWVALID        ),
		  .axi4i_aready                          ( I_S2MMAXI4_AWREADY        ),
		  .axi4i_alen                            ( I_S2MMAXI4_AWLEN          ),  
		  .axi4i_asize                           ( I_S2MMAXI4_AWSIZE         ), 
		  .axi4i_aburst                          ( I_S2MMAXI4_AWBURST        ),
		  .axi4i_wvalid                          ( I_S2MMAXI4_WVALID         ),
		  .axi4i_wready                          ( I_S2MMAXI4_WREADY         ),
		  .axi4i_wdata                           ( I_S2MMAXI4_WDATA          ), 
		  .axi4i_wstrb                           ( I_S2MMAXI4_WSTRB          ), 
		  .axi4i_wlast                           ( I_S2MMAXI4_WLAST          ), 
		  .axi4i_wuser                           ( I_S2MMAXI4_WUSER          ), 
		  .axi4i_bready                          ( I_S2MMAXI4_BREADY         ),
		  .axi4i_bvalid                          ( I_S2MMAXI4_BVALID         ),
		  .axi4i_bid                             ( I_S2MMAXI4_BID            ),
		  .axi4i_bresp                           ( I_S2MMAXI4_BRESP          ), 
		  .tvalid                                ( T_AXI4S_TVALID            ),
		  .tready                                ( s2mm_we_tready            ),
		  .tid                                   ( T_AXI4S_TID               ),
		  .tdest                                 ( T_AXI4S_TDEST             ),
		  .tdata                                 ( T_AXI4S_TDATA             ),
		  .tkeep                                 ( T_AXI4S_TKEEP             ),
		  .tlast                                 ( T_AXI4S_TLAST             ),
		  .tuser                                 ( T_AXI4S_TUSER             ),
		  .cmd_fifo_empty                        ( s2mm_cmd_fifo_empty       ),
		  .cmd_fifo_rden                         ( s2mm_cmd_fifo_rden        ),
		  .cmd_fifo_rdata                        ( s2mm_cmd_fifo_rdata       ),
		  .control                               ( s2mm_control_reg          ),     
		  .start_addr                            ( s2mm_address_reg          ),  
		  .burst_len                             ( s2mm_length_reg           ),   
		  .data_fifo_empty                       ( s2mm_data_fifo_empty      ), 
		  .data_fifo_rden                        ( s2mm_data_fifo_rden       ),
		  .data_fifo_rddata                      ( s2mm_data_fifo_rdata      ),
		  .status                                ( s2mm_we_status            ),
		  .sts_fifo_wren                         ( s2mm_sts_fifo_vld         ), 
		  .sts_fifo_full                         ( s2mm_sts_fifo_full        ),
		  .pkt_err_pl                   	  	 ( pkt_err_pulse		     ),
		  .pkt_ovf_pl                    	 	 ( pkt_ovf_pulse  		     ),
		  .pktovf_intr_pl                    	 ( pktovf_intr_pulse  		 ),
		  .pkterr_intr_pl                    	 ( pkterr_intr_pulse  		 ),
		  .multi_pkt_intr_pl					 ( s2mm_multi_pkt_pulse		 )
		);
//	  end
//      if (S2MM_CMDSTS_FIFO_ENABLE) 
      if (S2MM_CMDSTS_FIFO_ENABLE) 
	    begin : s2mm_cmdsts_fifo_en
	      caxi4pc_cmdsts_fifo #
		    (
              .RESET_TYPE                        ( RESET_TYPE           	 ),
              .ADDR_WIDTH                        ( S2MM_ADDR_WIDTH           ),
              .CMDSTS_FIFO_DEPTH                 ( S2MM_CMDSTS_FIFO_DEPTH    ),
              .CMDSTS_RAM_TYPE                   ( S2MM_CMDSTS_RAM_TYPE      ),
              .CMDSTS_ECC                        ( S2MM_CMDSTS_ECC           ),
              .CMDF_DWIDTH                       ( S2MM_CMDF_DWIDTH          ),
              .STSF_DWIDTH                       ( S2MM_STSF_DWIDTH          ),
              .STATUS_WIDTH                      ( S2MM_STATUS_WIDTH         ),
		      .UNDEF_BSTLEN                      ( S2MM_UNDEF_BSTLEN         ),			  
		      .FAMILY                            ( FAMILY                    ),
			  .PKT_DROP_OVF						 ( S2MM_PKT_DROP_OVF		 ),
		      .PKT_DROP_ERR						 ( S2MM_PKT_DROP_ERR		 )
            )
             caxi4pc_cmdsts_fifo_inst
            (
             // Clock and Reset interface
             // S2MM
             .clk                                ( ACLK                 	 ),
             .resetn                             ( RESETN               	 ),
             // AXI4-Lite Port Interface                                     
		  														     
             .address_reg                        ( s2mm_address_reg          ),
             .length_reg                         ( s2mm_length_reg           ), 
             .control_reg                        ( s2mm_control_reg          ),
		  														     
		     .cmd_fifo_full                      ( s2mm_cmd_fifo_full        ),
		     .cmd_fifo_rden                      ( s2mm_cmd_fifo_rden        ),
		     .cmd_fifo_empty                     ( s2mm_cmd_fifo_empty       ),
		     .cmd_fifo_rdata                     ( s2mm_cmd_fifo_rdata       ),
		  														     
		     .sts_vld                            ( s2mm_sts_fifo_vld         ),
		     .sts_data                           ( s2mm_we_status            ),
		     .sts_fifo_full                      ( s2mm_sts_fifo_full        ),
		     .sts_read_req                       ( s2mm_sts_fifo_rden        ),
		     .sts_fifo_empty                     ( s2mm_sts_fifo_empty       ),
		     .sts_fifo_rdata                     ( s2mm_sts_fifo_rdata       ),
			 .pkt_err_pl                     	 ( pkt_err_pulse		     ),
			 .pkt_ovf_pl                     	 ( pkt_ovf_pulse  		     )
            ); 
		end
		  
      if (S2MM_DATA_FIFO_ENABLE)                 
        begin : s2mm_data_fifo_en
		  caxi4pc_s2mm_data_fifo #                                        
          (                                        
           .RESET_TYPE                           ( RESET_TYPE           	 ),     
           .ADDR_WIDTH                           ( S2MM_ADDR_WIDTH           ),
           .DATA_FIFO_DEPTH                      ( S2MM_DATA_FIFO_DEPTH      ),              
           .DATA_RAM_TYPE	                     ( S2MM_DATA_RAM_TYPE        ),      
           .USER_WIDTH                           ( S2MM_USER_WIDTH           ),
           .DATA_ECC	                         ( S2MM_DATA_ECC             ),
           .DATA_WIDTH                           ( S2MM_DATA_WIDTH           ),		   
           .USER_DWIDTH                          ( S2MM_USER_DWIDTH          ),
           .DFIFO_DWIDTH                         ( S2MM_DATF_DWIDTH          ),
           .USER_ENABLE                          ( S2MM_USER_ENABLE          ),
           .PKT_FIFO_ENABLE                      ( S2MM_PKT_FIFO_ENABLE      ),
           .ENDIAN_CONV                          ( S2MM_ENDIAN_CONV          ),
           .UNDEF_BSTLEN                         ( S2MM_UNDEF_BSTLEN         ),			  
		   .FAMILY                               ( FAMILY                    ),
		   .PKT_DROP_OVF						 ( S2MM_PKT_DROP_OVF		 ),
		   .PKT_DROP_ERR						 ( S2MM_PKT_DROP_ERR		 )
          ) caxi4pc_s2mm_datafifo_inst												   
          (                                        
          .clk                                   ( ACLK                 	 ),
          .resetn                                ( RESETN              		 ),       
               					                         
          .axi4s_tready                          ( s2mm_dataf_tready         ),
          .axi4s_tvalid                          ( T_AXI4S_TVALID            ),
          .axi4s_tid                             ( T_AXI4S_TID               ),   
          .axi4s_tdest                           ( T_AXI4S_TDEST             ), 
          .axi4s_tdata                           ( T_AXI4S_TDATA             ), 
          .axi4s_tkeep                           ( T_AXI4S_TKEEP             ), 
          .axi4s_tlast                           ( T_AXI4S_TLAST             ), 
          .axi4s_tuser                           ( T_AXI4S_TUSER             ), 
               					                           
          .data_fifo_rden                        ( s2mm_data_fifo_rden       ),
          .data_fifo_empty                       ( s2mm_data_fifo_empty      ),
          .dout_fifo_rdata                       ( s2mm_data_fifo_rdata      ),
		  .pkt_err 								 ( S2MM_PKT_ERR				 ),
		  .pkt_err_pl							 ( pkt_err_pulse	    	 ),
		  .pkt_ovf_pl							 ( pkt_ovf_pulse			 ),
		  .debug								 ( DEBUG 					 )
          );                                       
		end       
     end		
   endgenerate     
   
   generate
      if(MM2S_ENABLE)
      begin : mm2s_en
         caxi4pc_axi4l_trgt_register 
         #(
           .RESET_TYPE                          ( RESET_TYPE            	 ),
		   .ADDR_WIDTH                          ( MM2S_ADDR_WIDTH            ),
           .CMDSTS_FIFO_ENABLE                  ( MM2S_CMDSTS_FIFO_ENABLE    ),
		   .STATUS_WIDTH                        ( MM2S_STSF_DWIDTH           ), //For S2MM if S2MM_UNDEF_BSTLEN is enabled then received bytes 32 bits are stored in status along 
		                                                                        //with other status bits. For MM2S, status width is fixed 9
           .UNDEF_BSTLEN                        ( 1'b0                       ), //Undefined burst length is supported only for S2MM.
		   .INTR_REG_WIDTH						( MM2S_INTR_REG_WIDTH        ),
		   .CNTR_REG_WIDTH						( MM2S_CNTR_REG_WIDTH        ),
		   .ADDR_LAST 							( MM2S_ADDR_LAST 			 ),
		   .WRITE_EN							( MM2S_WRITE_EN				 ),
		   .REG_ADDR_OFFSET						( 1						     )
          )
          caxi4pc_mm2s_register_inst
         (
          // Clock and Reset interface
          // S2MM
          .clk                                  ( ACLK                       ),
          .resetn                               ( RESETN                     ),
          // AXI4-Lite Port Interface                                        
          .axi4l_awvalid                        ( mm2s_awvalid          ),       
          .axi4l_awready                        ( mm2s_awready          ),       
          .axi4l_awaddr                         ( mm2s_awaddr           ),       
                                                                
          .axi4l_wdata                          ( mm2s_wdata            ),       
		  .axi4l_wstrb                          ( mm2s_wstrb            ),       
          .axi4l_wvalid                         ( mm2s_wvalid           ),       
          .axi4l_wready                         ( mm2s_wready           ),       
                                                                
          .axi4l_bresp                          ( mm2s_bresp            ),       
          .axi4l_bvalid                         ( mm2s_bvalid           ),       
          .axi4l_bready                         ( mm2s_bready           ),       
                                                                
          .axi4l_araddr                         ( mm2s_araddr           ),       
          .axi4l_arvalid                        ( mm2s_arvalid          ),       
          .axi4l_arready                        ( mm2s_arready          ),       
                                                                 
          .axi4l_rdata                          ( mm2s_rdata            ),       
          .axi4l_rresp                          ( mm2s_rresp            ),       
          .axi4l_rvalid                         ( mm2s_rvalid           ),       
          .axi4l_rready                         ( mm2s_rready           ),			                  
           //Registers                          
          .address_reg                          ( mm2s_address_reg           ),
          .length_reg                           ( mm2s_length_reg            ),
          .control_reg                          ( mm2s_control_reg           ),
		  //Status fifo signals
		  .sts_fifo_rden                        ( mm2s_sts_fifo_rden         ),
		  .sts_fifo_empty                       ( mm2s_sts_fifo_empty        ),
		  .sts_fifo_rdata                       ( mm2s_sts_fifo_rdata        ),
		  
		  //Status coming from the read engine if status fifo is disabled. 
		  .status                               ( mm2s_re_status             ),
		  
		  //Command fifo signals 
		  .cmd_fifo_full                        ( mm2s_cmd_fifo_full         ),
		  // AXI4 error pulse
		  .rresp_err_pl                         ( mm2s_rresp_err_pl          ),
		  // Interrupt Ports
		  .intr									 ( MM2S_INT 				 ),
		  .err_intr								 ( MM2S_ERR_INT 			 ),
		  .pkterr_intr_pl						 ( 1'b0 					 ),
		  .pktovf_intr_pl						 ( 1'b0						 ),
		  .multi_pkt_intr_pl					 ( mm2s_multi_pkt_pulse		 )
         ); 

	    caxi4pc_read_engine # 
		(
		  .AWIDTH                                ( MM2S_ADDR_WIDTH           ),
		  .DWIDTH                                ( MM2S_DATA_WIDTH           ),
		  .DATA_FIFO_ENABLE                      ( MM2S_DATA_FIFO_ENABLE     ),
		  .UNALIGNED_TRANSFER                    ( 0                         ),
		  .UNDEF_BSTLEN                          ( 0                         ),
          .BURST_LENGTH                          ( 0                         ),
          .CMDSTS_FIFO_ENABLE                    ( MM2S_CMDSTS_FIFO_ENABLE   ),
          .USER_ENABLE                           ( MM2S_USER_ENABLE          ),
          .UWIDTH                                ( MM2S_USER_WIDTH           ),
          .RESET_TYPE                            ( RESET_TYPE           ),
          .ENDIAN_CONV                           ( MM2S_ENDIAN_CONV          ),
          .CMDF_DWIDTH                           ( MM2S_CMDF_DWIDTH          ),
          .DATF_DWIDTH                           ( MM2S_DATF_DWIDTH          )

		) caxi4pc_read_engine_inst 
		(
		  .aclk                                  ( ACLK                		 ),
		  .resetn                                ( RESETN              		 ), 		  
		  .axi4i_aid                             ( I_MM2SAXI4_ARID           ),   
		  .axi4i_addr                            ( I_MM2SAXI4_ARADDR         ),  
		  .axi4i_avalid                          ( I_MM2SAXI4_ARVALID        ),
		  .axi4i_aready                          ( I_MM2SAXI4_ARREADY        ),
		  .axi4i_alen                            ( I_MM2SAXI4_ARLEN          ),  
		  .axi4i_asize                           ( I_MM2SAXI4_ARSIZE         ), 
		  .axi4i_aburst                          ( I_MM2SAXI4_ARBURST        ),
		  .axi4i_rvalid                          ( I_MM2SAXI4_RVALID         ),
		  .axi4i_rready                          ( I_MM2SAXI4_RREADY         ),
		  .axi4i_rdata                           ( I_MM2SAXI4_RDATA          ), 
		  .axi4i_rlast                           ( I_MM2SAXI4_RLAST          ), 
		  .axi4i_ruser                           ( I_MM2SAXI4_RUSER          ), 
		  .axi4i_rresp                           ( I_MM2SAXI4_RRESP          ), 
		  .tvalid                                ( mm2s_re_tvalid            ),
		  .tready                                ( mm2s_re_tready            ),
		  .tid                                   ( mm2s_re_tid               ),
		  .tdest                                 ( mm2s_re_tdest             ),
		  .tdata                                 ( mm2s_re_tdata             ),
		  .tkeep                                 ( mm2s_re_tkeep             ),
		  .tlast                                 ( mm2s_re_tlast             ),
		  .tuser                                 ( mm2s_re_tuser             ),
		  .cmd_fifo_empty                        ( mm2s_cmd_fifo_empty       ),
		  .cmd_fifo_rden                         ( mm2s_cmd_fifo_rden        ),
		  .cmd_fifo_rdata                        ( mm2s_cmd_fifo_rdata       ),
		  .control                               ( mm2s_control_reg          ),     
		  .start_addr                            ( mm2s_address_reg          ),  
		  .burst_len                             ( mm2s_length_reg           ),   
		  .data_fifo_full                        ( mm2s_data_fifo_full       ), 
		  .data_fifo_wren                        ( mm2s_data_fifo_wren       ),
		  .data_fifo_wrdata                      ( mm2s_data_fifo_wrdata     ),
		  .status                                ( mm2s_re_status            ),
		  .sts_fifo_wren                         ( mm2s_sts_fifo_vld         ), 
		  .sts_fifo_full                         ( mm2s_sts_fifo_full        ),
		  .rresp_err_pl                          ( mm2s_rresp_err_pl         ),
		  .multi_pkt_intr_pl					 ( mm2s_multi_pkt_pulse		 )
		);
		
        if (MM2S_CMDSTS_FIFO_ENABLE) 
		begin : mm2s_cmdsts_fifo_en
          caxi4pc_cmdsts_fifo 
          #(
            .RESET_TYPE                         ( RESET_TYPE            	 ),
            .ADDR_WIDTH                         ( MM2S_ADDR_WIDTH            ),
            .CMDSTS_FIFO_DEPTH                  ( MM2S_CMDSTS_FIFO_DEPTH     ),
            .CMDSTS_RAM_TYPE                    ( MM2S_CMDSTS_RAM_TYPE       ),
            .CMDSTS_ECC                         ( MM2S_CMDSTS_ECC            ),
            .CMDF_DWIDTH                        ( MM2S_CMDF_DWIDTH           ),
            .STSF_DWIDTH                        ( MM2S_STSF_DWIDTH           ),
            .STATUS_WIDTH                       ( MM2S_STSF_DWIDTH           ),			  
		    .FAMILY                             ( FAMILY                     ),
			.PKT_DROP_OVF                       ( 1'b0			             ),
			.PKT_DROP_ERR                       ( 1'b0			             )
           )
           caxi4pc_mm2s_cmdsts_fifo
          (
           // Clock and Reset interface
           // MM2S
           .clk                                 ( ACLK                  	 ),
           .resetn                              ( RESETN                	 ),
           // AXI4-Lite Port Interface
	      
           .address_reg                         ( mm2s_address_reg           ),
           .length_reg                          ( mm2s_length_reg            ), 
           .control_reg                         ( mm2s_control_reg           ),
																		     
		   .cmd_fifo_full                       ( mm2s_cmd_fifo_full         ),
		   .cmd_fifo_rden                       ( mm2s_cmd_fifo_rden         ),
		   .cmd_fifo_empty                      ( mm2s_cmd_fifo_empty        ),
		   .cmd_fifo_rdata                      ( mm2s_cmd_fifo_rdata        ),
																		     
		   .sts_vld                             ( mm2s_sts_fifo_vld          ),
		   .sts_data                            ( mm2s_re_status             ),
		   .sts_fifo_full                       ( mm2s_sts_fifo_full         ),
		   .sts_read_req                        ( mm2s_sts_fifo_rden         ),
		   .sts_fifo_empty                      ( mm2s_sts_fifo_empty        ),
		   .sts_fifo_rdata                      ( mm2s_sts_fifo_rdata        ),
		   .pkt_err_pl                     	    ( 1'b0				         ),
		   .pkt_ovf_pl                     	    ( 1'b0  		  		     )		   
          );	
		end		 

        if(MM2S_DATA_FIFO_ENABLE)
        begin : mm2s_datafifo_en
          caxi4pc_mm2s_data_fifo #
		  (
           .RESET_TYPE                          ( RESET_TYPE           		),   
	       .ADDR_WIDTH                          ( MM2S_ADDR_WIDTH           ),
           .DATA_FIFO_DEPTH                     ( MM2S_DATA_FIFO_DEPTH      ),         
           .DATA_RAM_TYPE                       ( MM2S_DATA_RAM_TYPE        ),      
           .DATA_WIDTH                          ( MM2S_DATA_WIDTH           ),   
           .USER_WIDTH                          ( MM2S_USER_WIDTH           ),
           .DATA_ECC                            ( MM2S_DATA_ECC             ),
           .DATF_DWIDTH                         ( MM2S_DATF_DWIDTH          ),
           .USER_ENABLE                         ( MM2S_USER_ENABLE          ),
           .PKT_FIFO_ENABLE                     ( MM2S_PKT_FIFO_ENABLE      ),
		   .ENDIAN_CONV                         ( MM2S_ENDIAN_CONV          ),			  
		   .FAMILY                              ( FAMILY                    )
          )	caxi4pc_mm2s_datafifo_inst 
          (
           // Clock and Reset interface
           // S2MM
           .clk                                 ( ACLK                	    ),
           .resetn                              ( RESETN              	    ),
	       														         
           .axi4s_tready                        ( mm2s_dataf_tready         ),     
           .axi4s_tvalid                        ( mm2s_dataf_tvalid         ),     
           .axi4s_tid                           ( mm2s_dataf_tid            ),                       
           .axi4s_tdest                         ( mm2s_dataf_tdest          ),        
           .axi4s_tdata                         ( mm2s_dataf_tdata          ),      
           .axi4s_tkeep                         ( mm2s_dataf_tkeep          ),      
           .axi4s_tlast                         ( mm2s_dataf_tlast          ),      
           .axi4s_tuser                         ( mm2s_dataf_tuser          ),      
	       														               
	       .data_fifo_full                      ( mm2s_data_fifo_full       ),
	       .data_fifo_wren                      ( mm2s_data_fifo_wren       ),
           .data_fifo_wrdata                    ( mm2s_data_fifo_wrdata     )
          );
        end		
      end    
   endgenerate   
   //-----------------------------------------------------------------------------------
   

   //-----------------------------------------------------------------------------------
   //-----------------------------------------------------------------------------------
 //synthesis translate_off
 
//synthesis translate_off
 
  reg [15:0] axi4s_tx_pkt_cnt = 0;
  reg [15:0] axi4s_rx_pkt_cnt = 0;
  reg [15:0] mm2s_tx_pkt_cnt = 0;
  reg [15:0] mm2s_tx_pkt_beat_cnt = 0;
  reg [15:0] mm2s_rx_pkt_cnt = 0;
  reg [15:0] mm2s_rx_pkt_beat_cnt = 0;
  reg [15:0] mm2s_addr_pkt_cnt = 0;

  always@(posedge ACLK)
    if(T_AXI4S_TREADY & T_AXI4S_TVALID & T_AXI4S_TLAST)
	  axi4s_tx_pkt_cnt <= axi4s_tx_pkt_cnt + 1;  
 
  always@(posedge ACLK)
    if(I_S2MMAXI4_WREADY & I_S2MMAXI4_WVALID & I_S2MMAXI4_WLAST)
	  axi4s_rx_pkt_cnt <= axi4s_rx_pkt_cnt + 1;   
 
  always@(posedge ACLK)
    if(I_MM2SAXI4_RREADY & I_MM2SAXI4_RVALID & I_MM2SAXI4_RLAST)
	  mm2s_tx_pkt_cnt <= mm2s_tx_pkt_cnt + 1;  
 
  always@(posedge ACLK)
    if(I_AXI4S_TREADY & I_AXI4S_TVALID & I_AXI4S_TLAST)
	  mm2s_rx_pkt_cnt <= mm2s_rx_pkt_cnt + 1;  
 
  always@(posedge ACLK)
    if(I_MM2SAXI4_RREADY & I_MM2SAXI4_RVALID)
	  mm2s_tx_pkt_beat_cnt <= mm2s_tx_pkt_beat_cnt + 1;  
 
  always@(posedge ACLK)
    if(I_AXI4S_TREADY & I_AXI4S_TVALID)
	  mm2s_rx_pkt_beat_cnt <= mm2s_rx_pkt_beat_cnt + 1;  
 
 always@(posedge ACLK)
    if(I_MM2SAXI4_ARREADY & I_MM2SAXI4_ARVALID)
	  mm2s_addr_pkt_cnt <= mm2s_addr_pkt_cnt + 1;  
 
//synthesis translate_on 

endmodule

