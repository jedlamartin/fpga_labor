// ********************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2023 Microchip Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// IP Core:      CoreAXI4DMAController_RAM_1K20_wrapper
//
// SVN Revision Information:
// SVN $Revision: 44739 $
// SVN $Date: 2023-11-02 11:43:34 +0530 (Thu, 02 Nov 2023) $
//
//
// *********************************************************************/
module COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_CoreAXI4DMAController_RAM_1K20_wrapper (
    // Inputs
    clock,
	resetn,
    wrEn,
    wrAddr,
    wrData,
    rdEn,
    rdAddr,
    
    // Outputs
    rdData,
	error_flag_sb_bd,
	error_flag_db_bd
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter FAMILY            = 28;
parameter NUM_INT_BDS_WIDTH = 2;
parameter RD_PIPELINE       = 1;
parameter ECC 				= 1;
////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// Inputs
input                           clock;
input                           resetn;
input                           wrEn;
input [NUM_INT_BDS_WIDTH-1:0]   wrAddr;
input [31:0]                    wrData;
input                           rdEn;
input [NUM_INT_BDS_WIDTH-1:0]   rdAddr;

// Outputs
output  [31:0]                   rdData;
output reg error_flag_sb_bd;
output reg error_flag_db_bd;

wire error_flag_sb_bd_mem;
wire error_flag_db_bd_mem;

reg rdEn_f1;
reg rdEn_f2;

wire [8:0]raddr_1;
wire [8:0]waddr_1;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
//reg[31:0] mem [511:0]/*synthesis syn_ramstyle="lsram,ecc"*/;
//reg[NUM_INT_BDS_WIDTH-1:0] rdAddr_reg;

always @(posedge clock or negedge resetn) 
	if(!resetn)
		begin
			rdEn_f1 <= 1'b0;
			rdEn_f2 <= 1'b0;
		end
	else
		begin
			rdEn_f1	 <= rdEn;
			rdEn_f2 <= rdEn_f1;
		end
		
always @(posedge clock or negedge resetn) 
	if(!resetn)
		begin
			error_flag_sb_bd <= 1'b0;
			error_flag_db_bd <= 1'b0;
		end
	else	
		begin
			if(rdEn_f2)
				begin
					error_flag_sb_bd <= error_flag_sb_bd_mem;
					error_flag_db_bd <= error_flag_db_bd_mem;						
				end
		end
			

assign waddr_1 = ({{(9-NUM_INT_BDS_WIDTH){1'b0}},wrAddr});				
assign raddr_1 = ({{(9-NUM_INT_BDS_WIDTH){1'b0}},rdAddr});				
			
   generate
   begin    
      // Need to pass family parameter from top
      if ((FAMILY >= 28) && (ECC == 0))
      begin
         COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_coreaxi4dmacontroller_raminfer_eccdis             
         #(                                              
         .RDEPTH_CAL   (8                  ),     // Read Address Width                     
         .WDEPTH_CAL   (8                  ),     // Write Address Width
         .RWIDTH       (32                 ),     // Read Data Width 
         .WWIDTH       (32                 ),     // Write Data Width       
         .SYNC         (1                  ),     // SYNC = 1 [Syncronous], SYNC = 0 [Asyncronous]            
         .ECC          (0                  ),     // ECC  = 0        
         .FAMILY       (FAMILY             ),     // FAMILY = 28       
         .RAM_OPT      (0                  ),     // RAM_OPT = 1 [LSRAM with Low Power], RAM_OPT = 0 [LSRAM with High Speed]            
         .PIPE         (2                  ),     // PIPE = 1 [non_pipelined], PIPE = 2 [Pipelined] 
         .RAM_SEL      (2                  ),     // RAM_SEL = 2 [LSRAM], RAM_SEL = 3 [uSRAM]       
         .RDEPTH       (512                ),     
         .WDEPTH       (512                )             
         )                                               
         LI_ram_wrapper_fifo_pf2_3                           
         (                                               
          .CLK            (clock              ),        
          .WCLOCK         (                   ),
          .RCLOCK         (                   ),
          .DATA           (wrData             ),
          .fifo_MEMWADDR  (waddr_1            ),
          .fifo_MEMWE     (wrEn               ),
          .fifo_MEMRE_int (rdEn               ),
          .RDATA_int      (rdData             ),
          .ram_raddr      (raddr_1            )
         );
 		 assign error_flag_sb_bd_mem = 0;
		 assign error_flag_db_bd_mem = 0;	     
      end 
      else
      begin	
	     COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_ram_bd #(                            
	        .WIDTH(32),
	        .DEPTH(9)	
	        )
	  
	     	LI_ram_wrapper_bd(
	     .CLOCK(clock),
	     .RESET_N(resetn),
	     .WEN(wrEn ),
	     .WADDR(waddr_1),
	     .WDATA(wrData),
	     .REN(rdEn),
	     .RADDR(raddr_1),
	     .RDATA(rdData),
         .SB_CORRECT(error_flag_sb_bd_mem),  
         .DB_DETECT (error_flag_db_bd_mem) 	
	     );
      end 	
    end
	endgenerate

//generate 
//	if(ECC)
//		begin
//			reg[31:0] mem [511:0]/*synthesis syn_ramstyle="lsram,ecc"*/;
//			
//			always @(posedge clock) 
//				begin
//					if(rdEn_f2)
//						begin
//							error_flag_sb_bd <= error_flag_sb_bd_mem;
//							error_flag_db_bd <= error_flag_db_bd_mem;
//											
//						end
//				end
//			
//			always @(posedge clock) 
//				begin
//					{rdEn_f2,rdEn_f1} <= {rdEn_f1,rdEn};
//				end
//		
////////////////////////////////////////////////////
////////////behavioural code for memory/////////////
///////////////////////////////////////////////////
//			 always @(posedge clock) 
//				begin
//					rdAddr_reg <= rdAddr; 
//					rdData <= mem[rdAddr_reg];      
//					
//					if(wrEn)
//						begin
//							mem[wrAddr] <= wrData;
//						  //  mem[rdAddr_w] <= wrData[{{8{1'b0}}, wrData[31:20]}];
//						end
//				end
//		end
//		
//	else
//		begin
//			reg[31:0] mem [511:0]/*synthesis syn_ramstyle="lsram"*/;
//		
////////////////////////////////////////////////////
////////////behavioural code for memory/////////////
///////////////////////////////////////////////////
//			 always @(posedge clock) 
//				begin
//					rdAddr_reg <= rdAddr; 
//					rdData <= mem[rdAddr_reg];      
//					
//					if(wrEn)
//						begin
//							mem[wrAddr] <= wrData;
//						  //  mem[rdAddr_w] <= wrData[{{8{1'b0}}, wrData[31:20]}];
//						end
//				end			
//		end
//endgenerate		
/*
////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire [19:0] rdDataUpper;
wire [19:0] rdDataLower;
wire        bypass;

assign rdData = {rdDataUpper[11:0], rdDataLower[19:0]};
assign bypass = (RD_PIPELINE == 1) ? 1'b0 : 1'b1;

////////////////////////////////////////////////////////////////////////////////
// RAM1K20 macro instantiation
////////////////////////////////////////////////////////////////////////////////
RAM1K20 RAM_1K20_INST (
    .A_DOUT         (rdDataUpper),
    .B_DOUT         (rdDataLower), 
    .DB_DETECT      (),
    .SB_CORRECT     (), 
    .ACCESS_BUSY    (),
    .A_ADDR         ({{(9-NUM_INT_BDS_WIDTH){1'b1}},rdAddr[NUM_INT_BDS_WIDTH-1:0], {5{1'b0}}}),
    .A_BLK_EN       (3'b111),
    .A_CLK          (clock), 
    .A_DIN          ({{8{1'b0}}, wrData[31:20]}),
    .A_REN          (rdEn),
    .A_WEN          (2'b11),
    .A_DOUT_EN      (1'b1),
    .A_DOUT_ARST_N  (1'b1),
    .A_DOUT_SRST_N  (1'b1),
    .B_ADDR         ({{(9-NUM_INT_BDS_WIDTH){1'b1}}, wrAddr[NUM_INT_BDS_WIDTH-1:0], {5{1'b0}}}),
    .B_BLK_EN       ({wrEn, 2'b11}),
    .B_CLK          (clock),
    .B_DIN          ({wrData[19:0]}),
    .B_REN          (1'b1),
    .B_WEN          (2'b11), 
    .B_DOUT_EN      (1'b1),
    .B_DOUT_ARST_N  (1'b1),
    .B_DOUT_SRST_N  (1'b1), 
    .ECC_EN         (1'b0),
    .BUSY_FB        (1'b0),
    .A_WIDTH        (3'b101), 
    .A_WMODE        (2'b00),
    .A_BYPASS       (bypass),
    .B_WIDTH        (3'b101),
    .B_WMODE        (2'b00),
    .B_BYPASS       (bypass),
    .ECC_BYPASS     (1'b0)
);*/
endmodule // CoreAXI4DMAController_RAM_1K20_wrapper
