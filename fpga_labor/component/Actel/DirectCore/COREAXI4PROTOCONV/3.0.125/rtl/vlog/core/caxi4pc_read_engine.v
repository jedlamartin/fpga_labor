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
module caxi4pc_read_engine #
(
  parameter AWIDTH             = 32,
  parameter DWIDTH             = 32,
  parameter DATA_FIFO_ENABLE   = 1,
  parameter UNALIGNED_TRANSFER = 0,
  parameter UNDEF_BSTLEN       = 0,
  parameter BURST_LENGTH       = 0,
  parameter CMDSTS_FIFO_ENABLE = 0,
  parameter USER_ENABLE        = 0,
  parameter UWIDTH             = 0,
  parameter RESET_TYPE         = 0,
  parameter ENDIAN_CONV        = 0,
  parameter CMDF_DWIDTH        = 95,
  parameter DATF_DWIDTH        = 72
)
(
  input                       aclk,
  input                       resetn,
  
  output                      axi4i_aid,   
  output reg [AWIDTH-1:0]     axi4i_addr,  
  output reg                  axi4i_avalid,
  input                       axi4i_aready,
  output reg [7:0]            axi4i_alen,  
  output [2:0]                axi4i_asize, 
  output [1:0]                axi4i_aburst,
  
  input                       axi4i_rvalid,                   
  output                      axi4i_rready,                   
  input  [DWIDTH-1:0]         axi4i_rdata,                   
  input                       axi4i_rlast,                   
  input  [UWIDTH-1:0]         axi4i_ruser,  
  
  input [1:0]                 axi4i_rresp,                   
  
  output                      tvalid,
  input                       tready,
  output                      tid,
  output [AWIDTH-1:0]         tdest,
  output [DWIDTH-1:0]         tdata,
  output reg [(DWIDTH/8)-1:0] tkeep,
  output                      tlast,
  output [UWIDTH-1:0]         tuser,
  
  input                       cmd_fifo_empty,
  output reg                  cmd_fifo_rden,
  input [CMDF_DWIDTH-1:0]     cmd_fifo_rdata,
  
  input [31:0]                control,     //control reg info from axi4l Target register 
  input [AWIDTH-1:0]          start_addr,  //start address from axi4l Target register
  input [31:0]                burst_len,   //length in bytes from axi4l Target register  
  
  input                       data_fifo_full, 
  output                      data_fifo_wren,
  output[DATF_DWIDTH-1:0]     data_fifo_wrdata, 
  
  output reg [31:0]           status,
  output reg                  sts_fifo_wren, 
  input                       sts_fifo_full,
  
  input 					  multi_pkt_intr_pl,
  output 					  rresp_err_pl
);

  

  localparam CMDID_OFFSET       = 0;
  localparam LEN_OFFSET         = CMDID_OFFSET + 31;
  localparam ADDR_START_OFFSET  = LEN_OFFSET + 32;
  localparam WRLEN_CNTR_WIDTH   = $clog2(256*(DWIDTH/8)); //Byte counter width. Based on Data width, width of the byte counter varies. 
                                                         //For 512 bit data width byte counter can go upto 256 * 64 (16384)
  localparam BYTE_IN_BEAT       = (DWIDTH/8);
  localparam ADDR_LSB_POS       = $clog2(DWIDTH)-3;
  localparam ADDR_BOUNDARY      = (4096 * 8) / DWIDTH;
  localparam MAX_FIX_BURST      = 16;
  localparam HI_FREQ            = 1;
  localparam AXI4_LEN_VEC_LIMIT = (13 - ADDR_LSB_POS) < 8 ? (13 - ADDR_LSB_POS) : 8;
  

  reg                                    drdy_en;
  reg                                    cmd_fifo_rden_f1;
  reg                                    cmd_fifo_rden_f2;
  reg                                    multi_burst_en;
  reg                                    cross_4kaddr;
  reg  [7:0]                             axi4_incr_burst_len;
  reg  [3:0]                             axi4_fix_burst_len;
  reg                                    addr_load_en_f1;
  reg                                    addr_load_en_f2;
  reg                                    addr_load_en_f3;
  reg  [32:0]                            remaining_bytes;
  wire [32:0]                            remaining_bytes_comb;
  reg  [2:0]                             axi_addr_phase_cmpl_dly;
  reg                                    axi_len_rdy;
  reg                                    axi_data_phase_cmpl_hld;
  reg                                    cmd_fifo_first_rdreq;
  reg                                    cmd_fifo_rdctrl;
  reg                                    read_pkt_done;


  
  wire                                   axi_addr_phase_cmpl;
  wire                                   axi_data_phase_cmpl;
  wire                                   addr_load_en;
  wire [AWIDTH-1:0]                      addr_load;
  wire [31:0]                            len_load;
  wire [1:0]                             burst_type;
  wire [12:0]                            axi_len_limit;
  wire                                   start;
  wire [ADDR_LSB_POS-1:0]                axi4_byte_valid; 
  reg  [(DWIDTH/8)-1:0]                  tkeep_ctrl;    

  
  wire  [DWIDTH-1:0]                     rdata_end_conv;  
  wire  [UWIDTH-1:0]                     ruser_end_conv;
  
  wire aresetn = (RESET_TYPE==1) ? 1'b1   : resetn;
  wire sresetn = (RESET_TYPE==1) ? resetn : 1'b1;
  
  //constant 
  assign axi4i_aid             = 0;
  assign axi4i_asize           = $clog2(DWIDTH/8);
  //
  assign axi4i_rready          = DATA_FIFO_ENABLE ? drdy_en & ~data_fifo_full : drdy_en & tready;
  assign axi4i_aburst          = burst_type ;
  assign axi_addr_phase_cmpl   = axi4i_avalid & axi4i_aready;
  assign axi_data_phase_cmpl   = axi4i_rvalid & axi4i_rready & axi4i_rlast;
  assign addr_load_en          = CMDSTS_FIFO_ENABLE ? cmd_fifo_rden_f2 : start;
  assign addr_load             = CMDSTS_FIFO_ENABLE ? cmd_fifo_rdata[AWIDTH+ADDR_START_OFFSET-1:ADDR_START_OFFSET] : start_addr;
  assign len_load              = CMDSTS_FIFO_ENABLE ? cmd_fifo_rdata[32+LEN_OFFSET-1:LEN_OFFSET] : burst_len;			
  assign burst_type            = CMDSTS_FIFO_ENABLE ? cmd_fifo_rdata[1:0] : control[2:1];
  
  assign data_fifo_wren        = DATA_FIFO_ENABLE ? (drdy_en & axi4i_rvalid & ~data_fifo_full) : 1'b0;
  assign tvalid                = DATA_FIFO_ENABLE ? 1'b0                                       : (drdy_en & axi4i_rvalid);
  assign tid                   = 0;
  assign tdest                 = 0;
  assign tdata                 = DATA_FIFO_ENABLE ? {DWIDTH{1'b0}} : rdata_end_conv;
//  assign tkeep                 = DATA_FIFO_ENABLE ? {(DWIDTH/8){1'b0}} : {(DWIDTH/8){1'b1}};
  assign tlast                 = (~multi_burst_en & axi4i_rlast);
  assign tuser                 = DATA_FIFO_ENABLE ? {UWIDTH{1'b0}} : ruser_end_conv;
  assign data_fifo_wrdata      = USER_ENABLE ? {axi4i_ruser,tkeep,tlast,axi4i_rdata} : {tkeep,tlast,axi4i_rdata};
  
   
generate
    if(DATA_FIFO_ENABLE == 0)
	  begin
        if (ENDIAN_CONV == 1)
          begin : mm2s_endian_conv_en
	    					    
            genvar i,j;
            for (i = 0; i < DWIDTH/8; i = i + 1) 
			  begin
                assign rdata_end_conv[(DWIDTH - 1 - (i*8)) -: 8] = axi4i_rdata[(i*8) +: 8];
              end
			  
            if(USER_ENABLE)
	    	  begin
                for (j = 0; j < UWIDTH/8; j = j + 1) 
				  begin		  
                    assign ruser_end_conv[(UWIDTH - 1 - (j*8)) -: 8] = axi4i_ruser[(j*8) +: 8];
	    	      end 
	    	  end
	    	else 
	    	  assign ruser_end_conv = 0;
          end 
	    else 
	      begin : mm2s_endian_conv_dis
            assign rdata_end_conv   = axi4i_rdata;
            assign ruser_end_conv   = axi4i_ruser;
          end
	  end
endgenerate     
	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
	  drdy_en <= 1'b0;
	else if(axi_addr_phase_cmpl)
	  drdy_en <= 1'b1;
	else if(axi_data_phase_cmpl)
	  drdy_en <= 1'b0;  	

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
	  {cmd_fifo_rden_f2,cmd_fifo_rden_f1} <= 0;
	else 
	  {cmd_fifo_rden_f2,cmd_fifo_rden_f1} <= {cmd_fifo_rden_f1,cmd_fifo_rden};

	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
	  axi4i_addr <= {AWIDTH{1'b0}};
	else if(addr_load_en)
	  begin 
	    if(UNALIGNED_TRANSFER) 
	      axi4i_addr <= addr_load;
		else 
		  begin 
		    axi4i_addr[ADDR_LSB_POS-1:0]      <= {ADDR_LSB_POS{1'b0}};
			axi4i_addr[AWIDTH-1:ADDR_LSB_POS] <= addr_load[AWIDTH-1:ADDR_LSB_POS];
		  end 	  
      end 
	else if(axi_addr_phase_cmpl & burst_type[0])
	  begin 
	    axi4i_addr[ADDR_LSB_POS-1:0]      <= {ADDR_LSB_POS{1'b0}};
	    axi4i_addr[AWIDTH-1:ADDR_LSB_POS] <= (axi4i_addr[AWIDTH-1:ADDR_LSB_POS] + axi4i_alen + 1'b1);		
	  end 
	  
  //Logic to detect 4K address boundary crossing.
  //As write transaction size is fixed to word, maximum 1K words can be written in single write transaction.
  //Subtract AXI4 Initiator write address from the 1023.
  assign axi_len_limit      = (1<<12) - axi4i_addr[11:0]; 
  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      remaining_bytes       <= 0;
	else if(addr_load_en)
	  remaining_bytes       <= {1'b0,len_load};
	else if(axi_addr_phase_cmpl)
	  //when remaining_bytes is less than the expr ((axi4i_alen + 1) << ADDR_LSB_POS), msb bit(32nd bit) of remaining_bytes is set to 1.
      remaining_bytes       <= remaining_bytes - ((axi4i_alen + 1) << ADDR_LSB_POS);	
    else if(remaining_bytes[32]) 
	  remaining_bytes       <= 0;	  

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      cross_4kaddr       <= 0;
    else 
      cross_4kaddr       <= ((remaining_bytes[12:0] > axi_len_limit) | (| remaining_bytes[31:13]));
	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      addr_load_en_f1       <= 0;
    else 
      addr_load_en_f1       <= addr_load_en;

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      addr_load_en_f2       <= 0;
    else 
      addr_load_en_f2       <= addr_load_en_f1;

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      addr_load_en_f3       <= 0;
    else 
      addr_load_en_f3       <= addr_load_en_f2;


  assign remaining_bytes_comb = axi_addr_phase_cmpl ?  remaining_bytes - ((axi4i_alen + 1) << ADDR_LSB_POS) : 1'b0;      
      
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      multi_burst_en <= 1'b0;
    else if(axi_addr_phase_cmpl)
      begin 
        if(remaining_bytes_comb[32] | (remaining_bytes_comb[31:0] == 0))// | ((remaining_bytes_comb[ADDR_LSB_POS:0] <= (DWIDTH/8)) & (~(| remaining_bytes_comb[31:ADDR_LSB_POS-1]))))
          multi_burst_en <= 1'b0;
        else 
          multi_burst_en <= 1'b1;
      end

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      status <= 0;
	else if(addr_load_en_f1)
	  begin 
		status[3:0]     <= 4'd0;
	    if(CMDSTS_FIFO_ENABLE)
	      status[25:16] <= cmd_fifo_rdata[24:15];
		else 
		  status[25:16] <= control[25:16];
	  end 
	else
	  begin 
  	    if(axi4i_rvalid & axi4i_rready)
	      begin 
	        if(status[3:2] == 2'b00)
		      begin 
	            status[3:2] <= axi4i_rresp;
		      end 
		    status[0]   <= (~multi_burst_en | remaining_bytes[32]) & axi4i_rlast;
	      end 
		if(CMDSTS_FIFO_ENABLE)                        // Multi_packet_done
          begin
		    if(multi_pkt_intr_pl)
              status[1]  <= 1'b1;
		  end			  
	  end 
	  
	// read response error pulse generation
   assign rresp_err_pl = (axi4i_rvalid & axi4i_rready & ((axi4i_rresp[1:0]==2'b10) | (axi4i_rresp[1:0]==2'b11))) ? 1'b1 : 1'b0 ;
  
   always@(posedge aclk or negedge aresetn)
     if(~aresetn | ~sresetn)
       read_pkt_done <= 0;
     else if(axi_data_phase_cmpl & (~multi_burst_en | remaining_bytes[32]))
       read_pkt_done <= 1'b1;
     else 
       read_pkt_done <= 1'b0;

   always@(posedge aclk or negedge aresetn)
     if(~aresetn | ~sresetn)
       sts_fifo_wren <= 0;
     else 
       sts_fifo_wren <= read_pkt_done;	

	
generate //generate block is added to avoid bit reversal error when DWIDTH is greater than 64
  if(DWIDTH < 128)
    begin : re_dwidth_lt_128
      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          axi4_incr_burst_len <= 0;
		else if(~axi4i_avalid)
		  begin 
            if(cross_4kaddr)
              begin
                if(| axi_len_limit[12:8+ADDR_LSB_POS]) //Indicates axi_len_limit is more than 255	  
                  axi4_incr_burst_len <= 255;
                else 
                  axi4_incr_burst_len <= axi_len_limit[ADDR_LSB_POS +: AXI4_LEN_VEC_LIMIT]-1'b1;			  
              end 
            else 
              begin 
                if(| remaining_bytes[31:8+ADDR_LSB_POS])	//Indicates remaining_bytes is more than 255  
                  axi4_incr_burst_len <= 255;
                else if(| remaining_bytes[ADDR_LSB_POS-1:0])
                  axi4_incr_burst_len <= remaining_bytes[ADDR_LSB_POS +: AXI4_LEN_VEC_LIMIT];
    	        else 
    	          axi4_incr_burst_len <= remaining_bytes[ADDR_LSB_POS +: AXI4_LEN_VEC_LIMIT]-1'b1;			  
              end
         end				  

       always@(posedge aclk or negedge aresetn)
         if(~aresetn | ~sresetn)
	       axi4_fix_burst_len <= 0;
	     else if(~axi4i_avalid)
		   begin 
	         if(cross_4kaddr)
               begin
                 if(| axi_len_limit[12:4+ADDR_LSB_POS]) //Indicates axi_len_limit is more than 255	  
	               axi4_fix_burst_len <= 15;
	             else 
	               axi4_fix_burst_len <= axi_len_limit[ADDR_LSB_POS +: 4]-1'b1;			  
			   end 
			 else
			   begin 
                 if(| remaining_bytes[31:4+ADDR_LSB_POS])	//Indicates remaining_bytes is more than 255  
	               axi4_fix_burst_len <= 15;
                 else if(| remaining_bytes[ADDR_LSB_POS-1:0])
                   axi4_fix_burst_len <= remaining_bytes[ADDR_LSB_POS +: 4];
    	         else 
    	           axi4_fix_burst_len <= remaining_bytes[ADDR_LSB_POS +: 4]-1'b1;				 			  
			   end
           end				  
    end 
  else 
    begin : re_dwidth_gt_128
      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          axi4_incr_burst_len <= 0;
        else if(~axi4i_avalid) 
		  begin 
		    if(cross_4kaddr)
              axi4_incr_burst_len <= axi_len_limit[ADDR_LSB_POS +: AXI4_LEN_VEC_LIMIT]-1'b1;
            else
              begin 
                if(| remaining_bytes[31:8+ADDR_LSB_POS])	//Indicates remaining_bytes is more than 255  
                  axi4_incr_burst_len <= 255;
                else if(| remaining_bytes[ADDR_LSB_POS-1:0])
                  axi4_incr_burst_len <= remaining_bytes[ADDR_LSB_POS +: AXI4_LEN_VEC_LIMIT];
                else 
                  axi4_incr_burst_len <= remaining_bytes[ADDR_LSB_POS +: AXI4_LEN_VEC_LIMIT]-1'b1;
              end
		  end
		  
      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          axi4_fix_burst_len <= 0;
		else if(~axi4i_avalid)
		  begin 
            if(cross_4kaddr)
		      begin 
                if(| axi_len_limit[12:4+ADDR_LSB_POS]) //Indicates axi_len_limit is more than 255	  
	              axi4_fix_burst_len <= 15;
	            else 
	              axi4_fix_burst_len <= axi_len_limit[ADDR_LSB_POS +: 4]-1'b1;			  
	 	      end 
            else
              begin 
                if(| remaining_bytes[31:4+ADDR_LSB_POS])	//Indicates remaining_bytes is more than 255  
                  axi4_fix_burst_len <= 15;
                else if(| remaining_bytes[ADDR_LSB_POS-1:0])
                  axi4_fix_burst_len <= remaining_bytes[ADDR_LSB_POS +: 4];
    	        else 
    	          axi4_fix_burst_len <= remaining_bytes[ADDR_LSB_POS +: 4]-1'b1;
              end 			  
		  end
    end 
endgenerate	  

		  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      axi4i_alen <= 0;
	else 
	  begin 
        if(burst_type[0])
          axi4i_alen <= axi4_incr_burst_len; 	
        else 
          axi4i_alen <= {4'h0,axi4_fix_burst_len};
	  end 

  //After address phase is completed, minimum 4 clock cycles required to calculate length for next transaction in multi burst transaction. 
  //three clock cycle delay is provided through axi_addr_phase_cmpl_dly and 4th clock cycle delay is provided through axi_len_rdy.
  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      axi_addr_phase_cmpl_dly <= 0;
	else
	  axi_addr_phase_cmpl_dly <= {axi_addr_phase_cmpl_dly[1:0],axi_addr_phase_cmpl};

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      axi_len_rdy <= 1'b0;
	else if(axi_addr_phase_cmpl_dly[2])
	  axi_len_rdy <= 1'b1;
	else if(axi4i_avalid)
	  axi_len_rdy <= 1'b0;
	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      axi_data_phase_cmpl_hld <= 1'b0;
	else if(axi_data_phase_cmpl & ~axi_len_rdy)
	  axi_data_phase_cmpl_hld <= 1'b1;
	else if(axi_len_rdy)
	  axi_data_phase_cmpl_hld <= 1'b0;	
	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      axi4i_avalid <= 0;
    else if(axi_addr_phase_cmpl)
      axi4i_avalid <= 1'b0;	
    else if(addr_load_en_f3 | (multi_burst_en & (axi_data_phase_cmpl | axi_data_phase_cmpl_hld) & axi_len_rdy))
      axi4i_avalid <= 1'b1; 		  
    
  assign start = control[0];

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  cmd_fifo_first_rdreq <= 1'b0;
	else if(CMDSTS_FIFO_ENABLE)
      begin 
        if(~cmd_fifo_empty)
	      cmd_fifo_first_rdreq <= 1'b1;
	  end 
	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  cmd_fifo_rdctrl <= 1'b0;
	else if(CMDSTS_FIFO_ENABLE)
	  begin 
        if(cmd_fifo_rden)
	      cmd_fifo_rdctrl <= 1'b0;
        else if(axi_data_phase_cmpl & (~multi_burst_en | remaining_bytes[32]))	  
	      cmd_fifo_rdctrl <= 1'b1;
	  end 
	  
  always@(*)
    if(~cmd_fifo_empty & CMDSTS_FIFO_ENABLE)
      cmd_fifo_rden = ~cmd_fifo_first_rdreq | (axi_data_phase_cmpl & ~multi_burst_en) | cmd_fifo_rdctrl;
    else  
      cmd_fifo_rden = 1'b0;	


  assign axi4_byte_valid = len_load[ADDR_LSB_POS-1:0]; //- remaining_bytes[ADDR_LSB_POS-1:0];  

  //convert binary to one hot
  always@(*)
    begin 
      tkeep_ctrl = 0;
  	  tkeep_ctrl[axi4_byte_valid] = 1'b1;
    end 		

  always@(*)
    if(axi4i_rvalid & axi4i_rlast & (axi4_byte_valid != 0) & ~multi_burst_en)
     tkeep = tkeep_ctrl -1'b1;
    else 
     tkeep = {DWIDTH/8{1'b1}};
endmodule 