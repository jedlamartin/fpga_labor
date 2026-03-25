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

module  caxi4pc_s2mm_data_fifo
   #(
    //-----------------------------------------------------------------------------------
    // Parameter declaration
    //-----------------------------------------------------------------------------------
    parameter       RESET_TYPE              = 1,                     // Reset Type      	    
                                                                     // Defines the reset type.
                                                                     // 1: Asynchronous reset
                                                                     // 0: Synchronous reset
	parameter       ADDR_WIDTH              = 32,                    // S2MM Address Width																   
    parameter       DATA_FIFO_DEPTH         = 16,                    // Data FIFO depth
	                                                                 // Defines the Data FIFO depth.
    parameter       DATA_RAM_TYPE           = 0,                     // Data RAM Type
                                                                     // This parameter is used to configure RAM implementation for the Data FIFO.
	parameter       USER_WIDTH              = 1,																	 

    parameter       DATA_ECC                = 0,                     // Data ECC Enable
                                                                     // This parameter is used to enable the Data ECC for the AXI4 
                                                                     // 0: Disable Data ECC 
                                                                     // 1: Enable Data  ECC
    parameter       DATA_WIDTH              = 32,																	 
	parameter       USER_DWIDTH             = 33,                    // Min: 37, Max = 2624															 
	parameter       DFIFO_DWIDTH            = 37,                    // Min: 37, Max = 2624															 
	parameter       USER_ENABLE             = 1,
	parameter       PKT_FIFO_ENABLE         = 0,
	parameter       ENDIAN_CONV             = 0,
	parameter       UNDEF_BSTLEN            = 0,
	parameter       FAMILY                  = 26,
	parameter       PKT_DROP_OVF            = 0,
	parameter       PKT_DROP_ERR            = 0
   )	
	
   (
    // Clock and Reset interface---------------------------------------------------------
    // S2MM
    input   wire                                 clk,                // clock. All the interfaces used into S2MM block (AXI4-Lite target, AXI4-Stream target and AXI4 initiator) uses S2MM clock.
	    
    input   wire                                 resetn,             // This active-low reset resets the core. S2MM_RESETN must be externally synchronized with the s2mm_clk clock domain.
                                                                     // Note: The reset is synchronous or asynchronous type based on the RESET_TYPE parameter.
    
    // AXI4-Stream Target Port Interface
    output  wire                                 axi4s_tready,       // AXI4-Stream ready indicates that the Target can accept a transfer in the current cycle.
    input   wire                                 axi4s_tvalid,       // AXI4-Stream valid indicates that the initiator is driving a valid transfer.
    input   wire                                 axi4s_tid,          // AXI4-Stream TID is the data stream identifier that indicates different streams of data.
    input   wire  [ADDR_WIDTH - 1:0]             axi4s_tdest,        // AXI4-Stream destination provides routing information for the data stream.
    input   wire  [DATA_WIDTH - 1:0]             axi4s_tdata,        // AXI4-Stream data is the primary payload that is used to provide the data that is passing across the interface.
    input   wire  [(DATA_WIDTH /8) - 1 :0]       axi4s_tkeep,        // AXI4-Stream keep is the byte qualifier that indicates whether the content of the associated byte of data is processed as part of the data stream.
    input   wire                                 axi4s_tlast,        // AXI4-Stream last indicates the boundary of a packet.      
    input   wire  [(USER_WIDTH - 1):0]           axi4s_tuser,        // AXI4-Stream target user defined sideband information that can be transmitted alongside the data stream.
	
	input   wire                                 pkt_err,
    // Data FIFO interface
	input   wire                                 data_fifo_rden,	
	output  wire                                 data_fifo_empty,
    output  wire  [DFIFO_DWIDTH - 1:0]           dout_fifo_rdata,
	
	output  wire                                 pkt_err_pl,
	output  wire                                 pkt_ovf_pl,
	output  wire  	                             debug
    //-----------------------------------------------------------------------------------
   );
   
   localparam PKT_DATA_RAM_TYPE    =    (DATA_RAM_TYPE == 1) ? 0 : 
	                                    (DATA_RAM_TYPE == 3) ? 1 :
	  							         DATA_RAM_TYPE;
   localparam PKT_DATA_TKEEP_EN    =   UNDEF_BSTLEN ? 1 : 0;

   localparam FIFO_ECC             = DATA_ECC ? 2 : 0; //When ECC is enabled, it will be used in non-pipline mode. For FIFO non-piplined ECC parameter is set to 2.										      
   
   // Internal signal--------------------------------------------------------------------  
   // Data FIFO Control signal
   wire                                 data_fifo_wren;
   wire   [USER_DWIDTH-1:0]             data_fifo_user;
   wire   [DFIFO_DWIDTH-1:0]            data_fifo_wrdata;
   wire                                 data_fifo_full;
   

   wire  [DATA_WIDTH-1:0]               wdata;
   wire  [DATA_WIDTH-1:0]               wdata_end_conv;
   wire  [USER_WIDTH-1:0]               udata;
   wire  [USER_WIDTH-1:0]               user_end_conv;   
   //------------------------------------------------------------------------------------

   // Reset logic------------------------------------------------------------------------
   wire aresetn = (RESET_TYPE==1) ? 1'b1   : resetn;
   wire sresetn = (RESET_TYPE==1) ? resetn : 1'b1;
   //------------------------------------------------------------------------------------
   assign wdata = axi4s_tdata[DATA_WIDTH-1:0];
   assign udata = USER_ENABLE ? axi4s_tuser : 0;
   
generate
    if (ENDIAN_CONV == 1) //Need to check the endian conversion
      begin : s2mm_endconv_en
						    
        genvar i,j;
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            assign wdata_end_conv[(DATA_WIDTH - 1 - (i*8)) -: 8] = wdata[(i*8) +: 8];
        end

        if(USER_ENABLE)
		begin
          for (j = 0; j < USER_WIDTH/8; j = j + 1) begin		  
            assign user_end_conv[(USER_WIDTH - 1 - (j*8)) -: 8] = udata[(j*8) +: 8];
		  end 
		end
		else 
		  assign user_end_conv = 0;
      end 
	else
 	  begin : s2mm_endconv_dis
        assign wdata_end_conv   = wdata;
        assign user_end_conv    = udata;
      end
endgenerate   
  
generate 
  if(PKT_FIFO_ENABLE)
    begin : s2mm_strfrwd_en
	  wire                      data_fifo_rvalid;
	  wire                      data_fifo_wready;
	  wire [DATA_WIDTH-1:0]     dout_fifo_readdata;
	  wire [(DATA_WIDTH/8)-1:0] dout_fifo_tkeep;
	  wire [USER_WIDTH-1:0]     dout_fifo_wuser;
	  wire                      dout_fifo_tlast;
	  reg  [DFIFO_DWIDTH-1:0]   rdata_fifo_pack;
	  
	  caxi4pc_coreaxi4s_fifo #
	    (
		  .RESET_TYPE                         ( RESET_TYPE                ),
		  .SYNC                               ( 1'b1                      ),
		  .PIPE 							  ( 1						  ),
		  .ECC                                ( FIFO_ECC                  ),	
		  
		  .RAM_TYPE                           ( PKT_DATA_RAM_TYPE         ),
		  .NUM_STAGES                         ( 2                         ),
		  .READ_MODE                          ( 1                         ),
		  
		  .WFIFO_DEPTH                        ( DATA_FIFO_DEPTH           ),
		  .RFIFO_DEPTH                        ( DATA_FIFO_DEPTH           ),
		  .AXIS_TTDATA_WIDTH                  ( DATA_WIDTH                ),
		  .AXIS_ITDATA_WIDTH                  ( DATA_WIDTH                ),
		  .AXIS_TTID_WIDTH                    ( 1                         ),
		  .AXIS_ITID_WIDTH                    ( 1                         ),
		  .AXIS_TTDEST_WIDTH                  ( 32                        ),
		  .AXIS_ITDEST_WIDTH                  ( 32                        ),
		  .AXIS_TTUSER_WIDTH                  ( USER_WIDTH                ),
		  .AXIS_ITUSER_WIDTH                  ( USER_WIDTH                ),
		  
		  .ENABLE_AFULL                       ( 0                         ),
		  .ENABLE_TSTRB                       ( 0                         ),
		  .ENABLE_TKEEP                       ( PKT_DATA_TKEEP_EN         ),
		  .ENABLE_TLAST                       ( 1                         ),
		  .ENABLE_TUSER                       ( USER_ENABLE               ),
		  .ENABLE_TDEST                       ( 0                         ),
		  .ENABLE_TID                         ( 0                         ),
		  .PKT_DROP_OVF					 	  ( PKT_DROP_OVF		      ),
		  .PKT_DROP_ERR						  ( PKT_DROP_ERR		      )
	    ) pktfifo_inst
		(
		  .AXI4S_ACLK                         ( clk                       ),
		  .AXI4S_IACLK                        ( clk                       ),		  
		  .AXI4S_TACLK                        ( clk                       ),
		  .AXI4S_ARESETN                      ( resetn                    ),
		  .AXI4S_IARESETN                     ( resetn                    ),
		  .AXI4S_TARESETN                     ( resetn                    ),
		  //FIFO READ DOMAIN PORTS
		  .AXI4S_ITVALID                      ( data_fifo_rvalid          ),
		  .AXI4S_ITREADY                      ( data_fifo_rden            ),
		  .AXI4S_ITDATA                       ( dout_fifo_readdata        ),
		  .AXI4S_ITKEEP                       ( dout_fifo_tkeep           ),
		  .AXI4S_ITLAST                       ( dout_fifo_tlast           ),
		  .AXI4S_ITUSER                       ( dout_fifo_wuser           ),
		  .AXI4S_ITID                         (      				      ),
		  .AXI4S_ITDEST                       (      				      ),
		  .AXI4S_ITSTRB                       (     			          ),
		  //FIFO WRITE DOMAIN PORTS
		  .AXI4S_TTVALID                      ( axi4s_tvalid              ),
		  .AXI4S_TTREADY                      ( data_fifo_wready          ),
		  .AXI4S_TTDATA                       ( wdata_end_conv            ),
		  .AXI4S_TTKEEP                       ( axi4s_tkeep               ),
		  .AXI4S_TTLAST                       ( axi4s_tlast               ),
		  .AXI4S_TTUSER                       ( user_end_conv             ),
		  .AXI4S_TTID                         (         			      ),
		  .AXI4S_TTDEST                       (         			      ),
		  .AXI4S_TTSTRB                       (     			          ),
		  
		  .pkt_err							  ( pkt_err					  ),
		  .pkt_err_pl						  ( pkt_err_pl				  ),
		  .pkt_ovf_pl						  ( pkt_ovf_pl				  ),
		  .debug						 	  ( debug				 	  )
		);
	  
	  assign data_fifo_empty  = ~data_fifo_rvalid;
	  assign data_fifo_full   = ~data_fifo_wready;
	  
	  always@(*)
	    if(UNDEF_BSTLEN)
		  begin 
		    if(USER_ENABLE)
			  rdata_fifo_pack = {dout_fifo_tkeep,dout_fifo_tlast,dout_fifo_wuser,dout_fifo_readdata};
			else 
			  rdata_fifo_pack = {dout_fifo_tkeep,dout_fifo_tlast,dout_fifo_readdata};
		  end 
		else 
		  begin 
		    if(USER_ENABLE)
			  rdata_fifo_pack = {dout_fifo_wuser,dout_fifo_readdata};
			else 
			  rdata_fifo_pack = dout_fifo_readdata;
		  end 
	      
	  assign dout_fifo_rdata  = rdata_fifo_pack;
	  
	end 
  else 
    begin : s2mm_cutthr_en
      // Data FIFO Instantiation------------------------------------------------------------
      // Controller type :                      -
      // Clock           : Single clock         -
      // Memory pipeline : Non-pipeline         -
      // ECC             : Disable              - FIFO Operation
      // Reset type      : Synchronous reset    -
      // Optimized for   : High Speed           -
      // FWFT            : Enable               -  
      caxi4pc_corefifo #
      (
       .RWIDTH             ( DFIFO_DWIDTH        ),
       .WWIDTH             ( DFIFO_DWIDTH        ),   
       .RDEPTH             ( DATA_FIFO_DEPTH     ),
       .WDEPTH             ( DATA_FIFO_DEPTH     ),
       .CTRL_TYPE          ( DATA_RAM_TYPE       ),
       .ECC                ( FIFO_ECC            ),
	   .SYNC_RESET         ( RESET_TYPE          ),
	   .FWFT               ( 1                   ),
	   .PIPE               ( 1                   ),
	   .FAMILY             ( FAMILY              )						  
      ) data_fifo_inst    
      (                        
       .CLK                ( clk                 ),
       .RESET_N            ( resetn              ),	
       .WE                 ( data_fifo_wren      ),
       .DATA               ( data_fifo_wrdata    ),
       .RE                 ( data_fifo_rden      ),
       .Q                  ( dout_fifo_rdata     ),	
       .EMPTY              ( data_fifo_empty     ),
       .FULL               ( data_fifo_full      ),
       //Unused ioports                          
       .WCLOCK             ( 1'b0                ),    
       .RCLOCK             ( 1'b0                ),    
       .WRESET_N           ( 1'b0                ),
       .RRESET_N           ( 1'b0                ),
       .AFULL              (                     ),     
       .AEMPTY             (                     ),    
       .OVERFLOW           (                     ),  
       .UNDERFLOW          (                     ), 
       .WACK               (                     ),      
       .DVLD               (                     ),      
       .WRCNT              (                     ),     
       .RDCNT              (                     ),     
       .MEMWE              (                     ),     
       .MEMRE              (                     ),     
       .MEMWADDR           (                     ),  
       .MEMRADDR           (                     ),  
       .MEMWD              (                     ),     
       .MEMRD              ({DFIFO_DWIDTH{1'b0}} ),     
       .SB_CORRECT         (                     ),
       .DB_DETECT          (                     ),
	   .debug			   ( debug				 )
      );   
	end 
endgenerate	
   //------------------------------------------------------------------------------------
  
   // Data FIFO logic--------------------------------------------------------------------
   // Data FIFO write logic
   // Data FIFO Write enable logic
   // Data FIFO write enable indicates valid write data
   assign data_fifo_wren   = axi4s_tvalid & ~data_fifo_full;

   // Data FIFO Write Data
   assign data_fifo_user   = USER_ENABLE ? {user_end_conv,wdata_end_conv} : wdata_end_conv; 
   assign data_fifo_wrdata = UNDEF_BSTLEN ? {axi4s_tkeep,axi4s_tlast,data_fifo_user} : data_fifo_user;
   
   //------------------------------------------------------------------------------------
   
   // AXI4 Stream ready logic------------------------------------------------------------
   assign  axi4s_tready    = PKT_DROP_OVF ? 1'b1 : ~data_fifo_full;
   //------------------------------------------------------------------------------------
   // debug port used for internal verification purpose only
  
 //  assign debug  = data_fifo_full;
  


endmodule
	 
