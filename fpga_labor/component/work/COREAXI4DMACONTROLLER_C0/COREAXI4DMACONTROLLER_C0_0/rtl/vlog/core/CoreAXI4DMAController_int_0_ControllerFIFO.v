// ********************************************************************/
// Microchip Corporation Proprietary and Confidential
// Copyright 2023 Microchip Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROCHIP LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// IP Core:      COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_CoreAXI4DMAController_int_0_ControllerFIFO
// SVN Revision Information:
// SVN $Revision:  $
// SVN $Date:  $
//
//
// *********************************************************************/
module COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_CoreAXI4DMAController_int_0_ControllerFIFO (
    // Inputs
    clock,
    resetn,
    wrEn,
    wrData,
    rdEn,
    // Outputs
    rdData,
    fifoFull,
    wMarkFull,
    fifoEmpty,
	
	//ECC flags
	error_flag_sb_fifo,
	error_flag_db_fifo
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter FIFO_WIDTH      = 8;
parameter WATERMARK_DEPTH = 2;
parameter ECC 			  = 1;
parameter FAMILY 		  = 25;				

// Include file containing the implementation of clog2() function
`include "./coreaxi4dmacontroller_utility_functions.v"

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
// Instantiate 3 locations more than the user depth to prevent worse case
// scenario number of interrupt events held in the pipeline from overrunning
// this interrupt queue.
localparam FIFO_DEPTH       = WATERMARK_DEPTH + 3;
localparam FIFO_DEPTH_WIDTH = clog2(FIFO_DEPTH-1);

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                   clock;
input                   resetn;
input                   wrEn;
input  [FIFO_WIDTH-1:0] wrData;
input                   rdEn;
output  [FIFO_WIDTH-1:0] rdData;
output                  fifoFull;
output                  wMarkFull;
output                  fifoEmpty;


output 					error_flag_sb_fifo;
output 					error_flag_db_fifo;


////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////

reg [FIFO_DEPTH_WIDTH-1:0]  wrAddr;
reg [FIFO_DEPTH_WIDTH-1:0]  rdAddr;
reg [FIFO_DEPTH_WIDTH:0]    unitCnt;

reg [FIFO_DEPTH_WIDTH-1:0]  rdAddr_reg;


	always @ (posedge clock or negedge resetn)
		begin
			if (!resetn)
				rdAddr_reg <= 0;
			else
				rdAddr_reg <= rdAddr;
				
		end
		
//assign error_flag_sb_fifo  =  A_SB_CORRECT_fifo_0 | B_SB_CORRECT_fifo_0;
//assign error_flag_db_fifo  =  A_DB_DETECT_fifo_0  | B_DB_DETECT_fifo_0;
		
   generate
   begin    
      if ((FAMILY >= 28) && (ECC == 0))
      begin
         COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_coreaxi4dmacontroller_raminfer_eccdis             
         #(                                              
         .RDEPTH_CAL   (FIFO_DEPTH_WIDTH-1 ),     // Read Address Width                     
         .WDEPTH_CAL   (FIFO_DEPTH_WIDTH-1 ),     // Write Address Width
         .RWIDTH       (FIFO_WIDTH         ),     // Read Data Width 
         .WWIDTH       (FIFO_WIDTH         ),     // Write Data Width       
         .SYNC         (1                  ),     // SYNC = 1 [Syncronous], SYNC = 0 [Asyncronous]            
         .ECC          (0                  ),     // ECC  = 0        
         .FAMILY       (FAMILY             ),     // FAMILY = 28       
         .RAM_OPT      (0                  ),     // RAM_OPT = 1 [LSRAM with Low Power], RAM_OPT = 0 [LSRAM with High Speed]
         .PIPE         (2                  ),     // PIPE = 1 [non_pipelined], PIPE = 2 [Pipelined]  
         .RAM_SEL      (3                  ),     // RAM_SEL = 2 [LSRAM], RAM_SEL = 3 [uSRAM]       
         .RDEPTH       (2**FIFO_DEPTH_WIDTH   ),     
         .WDEPTH       (2**FIFO_DEPTH_WIDTH   )             
         )                                               
		 LI_ram_wrapper_fifo_0                         
		 (                                                  
		  .CLK            (clock              ),         
		  .WCLOCK         (                   ), 
		  .RCLOCK         (                   ), 
		  .DATA           (wrData             ), 
		  .fifo_MEMWADDR  (wrAddr             ), 
          .fifo_MEMWE     (wrEn               ),
          .fifo_MEMRE_int (rdEn               ),
          .RDATA_int      (rdData             ),
          .ram_raddr      (rdAddr             )
         );
         assign error_flag_sb_fifo = 0;
         assign error_flag_db_fifo = 0;      
      end
      else
      begin 
	     COREAXI4DMACONTROLLER_C0_COREAXI4DMACONTROLLER_C0_0_ram_fifo_0 #(
	     .WIDTH(FIFO_WIDTH),
	     .DEPTH(FIFO_DEPTH_WIDTH)	
	     )
	     LI_ram_wrapper_fifo_0(
	     .CLOCK(clock),
	     .RESET_N(resetn),
	     .WEN(wrEn),
	     .WADDR(wrAddr),
	     .WDATA(wrData),
	     .REN(rdEn),
	     .RADDR(rdAddr),
	     .RDATA(rdData),
         .SB_CORRECT(error_flag_sb_fifo),   
         .DB_DETECT (error_flag_db_fifo ) 	
	     );
      end 	
    end
	endgenerate
	

////////////////////////////////////////////////////////////////////////////////
// unit counter
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			begin
				unitCnt <= {(FIFO_DEPTH_WIDTH+1){1'b0}};
			end
		else
			begin
				case ({wrEn, rdEn})
					2'b01:
						begin
							unitCnt <= unitCnt - 1'b1;
						end
					2'b10:
						begin
							if (!fifoFull)
								begin
									unitCnt <= unitCnt + 1'b1;
								end
							else
								begin
									unitCnt <= unitCnt;
								end
						end
					default:
						begin
							unitCnt <= unitCnt;
						end
				endcase
			end
	end
assign fifoFull  = (unitCnt == FIFO_DEPTH);
assign fifoEmpty = (unitCnt == {(FIFO_DEPTH_WIDTH+1){1'b0}});
assign wMarkFull = (unitCnt == WATERMARK_DEPTH);

////////////////////////////////////////////////////////////////////////////////
// Write address pointer
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			begin
				wrAddr <= {FIFO_DEPTH_WIDTH{1'b0}};
			end
		else
			begin
				if (wrEn)
					begin
						if (wrAddr == FIFO_DEPTH-1)
							begin
								wrAddr <= {FIFO_DEPTH_WIDTH{1'b0}};
							end
						else
							begin
								wrAddr <= wrAddr + 1'b1;
							end
					end
			end
	end
////////////////////////////////////////////////////////////////////////////////
// Read address pointer
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			begin
				rdAddr <= {FIFO_DEPTH_WIDTH{1'b0}};
			end
		else
			begin
				if (rdEn)
					begin
						if (rdAddr == FIFO_DEPTH-1)
							begin
								rdAddr <= {FIFO_DEPTH_WIDTH{1'b0}};
							end
						else
							begin
								rdAddr <= rdAddr + 1'b1;
							end
					end
			end
	end


	//generate
	//			begin
	//				reg [FIFO_WIDTH-1:0] RAM [0:FIFO_DEPTH-1]/*synthesis syn_ramstyle="ecc"*/;
	//
	//				////////////////////////////////////////////////////////////////////////////////
	//				// RAM inference - Sync write, sync read
	//				////////////////////////////////////////////////////////////////////////////////
	//				always @ (posedge clock)
	//					begin
	//						rdData = RAM[rdAddr_reg];
	//						if (wrEn) 
	//							RAM[wrAddr] <= wrData;
	//							
	//							
	//					end
	//
	//				//assign rdData = RAM[rdAddr];
	//
	// endgenerate
endmodule // intControllerFIFO