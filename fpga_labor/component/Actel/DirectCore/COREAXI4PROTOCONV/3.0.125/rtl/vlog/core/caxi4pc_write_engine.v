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

module caxi4pc_write_engine #
(
  parameter       AWIDTH             = 32,
  parameter       DWIDTH             = 32,
  parameter       DATA_FIFO_ENABLE   = 1,
  parameter       PKT_FIFO_ENABLE    = 0,
  //parameter UNALIGNED_TRANSFER = 0,
  parameter       UNDEF_BSTLEN       = 0,
  parameter [8:0] BURST_LENGTH       = 16,
  parameter       CMDSTS_FIFO_ENABLE = 0,
  parameter       USER_ENABLE        = 0,
  parameter       UWIDTH             = 0,
  parameter       RESET_TYPE         = 0,
  parameter       ENDIAN_CONV        = 0,
  parameter       CMDF_DWIDTH        = 95,
  parameter       DATF_DWIDTH        = 72,
  parameter       STATUS_WIDTH       = 32,
  parameter       PKT_DROP_OVF       = 0,
  parameter       PKT_DROP_ERR       = 0
)
(
  input                         aclk,
  input                         resetn,
							    
  output                        axi4i_aid,  
  output reg [AWIDTH-1:0]       axi4i_addr,  
  output reg                    axi4i_avalid,
  input                         axi4i_aready,
  output reg [7:0]              axi4i_alen,  
  output [2:0]                  axi4i_asize, 
  output [1:0]                  axi4i_aburst,
							    
  output reg                    axi4i_wvalid,                   
  input                         axi4i_wready,                   
  output [DWIDTH-1:0]           axi4i_wdata,                   
  output reg [(DWIDTH/8)-1:0]   axi4i_wstrb,                   
  output reg                    axi4i_wlast,                   
  output [UWIDTH-1:0]           axi4i_wuser,  
							    
  output                        axi4i_bready,                   
  input                         axi4i_bvalid,                   
  input                         axi4i_bid,                   
  input [1:0]                   axi4i_bresp,                   
  
  input                         tvalid,
  output                        tready,
  input                         tid,
  input [AWIDTH-1:0]            tdest,
  input [DWIDTH-1:0]            tdata,
  input [(DWIDTH/8)-1:0]        tkeep,
  input                         tlast,
  input [UWIDTH-1:0]            tuser,
  
  input                         cmd_fifo_empty,
  output reg                    cmd_fifo_rden,
  input [CMDF_DWIDTH-1:0]       cmd_fifo_rdata,
  
  input [31:0]                  control,     //control reg info from axi4l Target register 
  input [AWIDTH-1:0]            start_addr,  //start address from axi4l Target register
  input [31:0]                  burst_len,   //length in bytes from axi4l Target register  
  
  input                         data_fifo_empty, 
  output reg                    data_fifo_rden,
  input [DATF_DWIDTH-1:0]       data_fifo_rddata, 
  
  output reg [STATUS_WIDTH-1:0] status,
  output reg                    sts_fifo_wren, 
  input                         sts_fifo_full,
  input                         pkt_err_pl,
  input                         pkt_ovf_pl,
  input 						multi_pkt_intr_pl,
  output wire	     			pktovf_intr_pl,
  output wire					pkterr_intr_pl
);

  localparam       FSM_WIDTH          = 5;
									  
									  
  localparam       CMDID_OFFSET       = 0;
  localparam       LEN_OFFSET         = CMDID_OFFSET + 31;
  localparam       ADDR_START_OFFSET  = UNDEF_BSTLEN ? LEN_OFFSET : LEN_OFFSET + 32;
  localparam       WRLEN_CNTR_WIDTH   = $clog2(256*(DWIDTH/8)); //Byte counter width. Based on Data width, width of the byte counter varies. 
                                                          //For 512 bit data width byte counter can go upto 256 * 64 = 16384
  localparam       BYTE_IN_BEAT       = (DWIDTH/8);
  localparam       ADDR_LSB_POS       = $clog2(DWIDTH/8);
  localparam       ADDR_BOUNDARY      = (4096 * 8) / DWIDTH;
  localparam       MAX_FIX_BURST      = 16;
  localparam       HI_FREQ            = 1;
  localparam [8:0] AXI4_BURST_LENGTH  = BURST_LENGTH - 1;
  localparam       AXI4_LEN_VEC_LIMIT = (13 - ADDR_LSB_POS) < 8 ? (13 - ADDR_LSB_POS) : 8;
  

  reg                                    dvalid_en;
  reg                                    cmd_fifo_rden_f1;
  reg                                    cmd_fifo_rden_f2;
  reg                                    multi_burst_en;
  reg                                    cross_4kaddr;
  reg  [7:0]                             axi4_incr_burst_len;
  reg  [3:0]                             axi4_fix_burst_len;
  reg                                    addr_load_en_f1;
  reg                                    addr_load_en_f2;
  reg                                    addr_load_en_f3;
  reg  [7:0]                             burlen_cnt;
  reg  [(DWIDTH/8)-1:0]                  axi4_wstrb_ctrl;    
  reg  [32:0]                            remaining_bytes;
  wire [32:0]                            remaining_bytes_comb;

  
  wire                                   axi_addr_phase_cmpl;
  wire                                   axi_data_phase_cmpl;
  wire                                   axi_wrrsp_phase_cmpl;
  wire                                   addr_load_en;
  wire [AWIDTH-1:0]                      addr_load;
  wire [31:0]                            len_load;
  wire [1:0]                             burst_type;
  wire [12:0]                            axi_len_limit;
  wire                                   start;
  wire [ADDR_LSB_POS-1:0]                axi4_byte_valid; 
  reg                                    axi4_undef_tlast_comb;  
  wire                                   axi4_undef_tlast;  
  reg  [(DWIDTH/8)-1:0]                  axi4_undef_tkeep_comb;  
  wire [(DWIDTH/8)-1:0]                  axi4_undef_tkeep;  
  reg                                    axi4_undef_wrstrb_ctrl_reg;  
  wire                                   axi4_undef_wrstrb_ctrl;  
  reg  [2:0]                             axi_addr_phase_cmpl_dly;
  reg                                    axi_len_rdy;
  reg                                    axi_data_phase_cmpl_hld;
  reg                                    axi4_wvalid_dly;
  reg                                    cmd_fifo_first_rdreq;
  reg                                    pkt_inprogrs;
  reg                                    pkt_inprogrs_d;
  reg                                    start_ctrl;
  reg                                    start_enable;
  reg                                    cmd_fifo_rdctrl;
  reg                                    start_rdctrl;
  reg                                    start_hold;
  reg [3:0]                              axi_addr_rsp_cntr;
  reg                                    axi_wrrsp_phase_cmpl_d;
  reg                                    axi_avalid_ctrl;
  reg                                    write_pkt_done;
  reg [7:0]                              str_frwrd_cntr;
  wire                                   axi4s_cmpl;
  reg									 axi4s_cmpl_valid;
  reg                                    pktdrop_hold;
  reg                                    axi4s_cmpl_hold;
  reg                                    pktovf_hold;
  reg                                    pkterr_hold;
  
  
  
  wire  [DWIDTH-1:0]                     wdata_end_conv;  
  wire  [UWIDTH-1:0]                     wuser_end_conv;
  
  integer                                byte_valid;
    
  wire aresetn = (RESET_TYPE==1) ? 1'b1   : resetn;
  wire sresetn = (RESET_TYPE==1) ? resetn : 1'b1;
  
  //constant 
  assign axi4i_aid             = 0;
  assign axi4i_asize           = $clog2(DWIDTH/8);
  //
  assign axi4i_aburst          = burst_type ;
  assign axi_addr_phase_cmpl   = axi4i_avalid & axi4i_aready;
  assign axi_data_phase_cmpl   = axi4i_wvalid & axi4i_wready & axi4i_wlast;
  assign axi_wrrsp_phase_cmpl  = axi4i_bvalid;
  assign addr_load_en          = CMDSTS_FIFO_ENABLE ? cmd_fifo_rden_f2 : start_enable;
  assign addr_load             = CMDSTS_FIFO_ENABLE ? cmd_fifo_rdata[AWIDTH+ADDR_START_OFFSET-1:ADDR_START_OFFSET] : start_addr;
  assign burst_type            = CMDSTS_FIFO_ENABLE ? cmd_fifo_rdata[1:0] : control[2:1];
  
  assign tready                = DATA_FIFO_ENABLE ? 1'b1                           : (dvalid_en & axi4i_wready & ~axi4_undef_wrstrb_ctrl);
  assign axi4i_wdata           = axi4_undef_wrstrb_ctrl ? {DWIDTH{1'b0}} : DATA_FIFO_ENABLE ? data_fifo_rddata[DWIDTH-1:0] : wdata_end_conv;
  assign axi4i_wuser           = axi4_undef_wrstrb_ctrl ? {UWIDTH{1'b0}} : DATA_FIFO_ENABLE ? (USER_ENABLE ? data_fifo_rddata[UWIDTH+DWIDTH-1:DWIDTH] : 0) : wuser_end_conv;  
	  

generate
    if(DATA_FIFO_ENABLE == 0)
	  begin
        if (ENDIAN_CONV == 1)
          begin : s2mm_endian_conv_en
	    					    
            genvar i,j;
            for (i = 0; i < DWIDTH/8; i = i + 1) 
			  begin
                assign wdata_end_conv[(DWIDTH - 1 - (i*8)) -: 8] = tdata[(i*8) +: 8];
              end
			  
            if(USER_ENABLE)
	    	  begin
                for (j = 0; j < UWIDTH/8; j = j + 1) 
				  begin		  
                    assign wuser_end_conv[(UWIDTH - 1 - (j*8)) -: 8] = tuser[(j*8) +: 8];
	    	      end 
	    	  end
	    	else 
	    	  assign wuser_end_conv = 0;
          end 
	    else 
	      begin : s2mm_endian_conv_dis
            assign wdata_end_conv   = tdata;
            assign wuser_end_conv   = tuser;
          end
	  end
endgenerate    
	  
generate
  if(UNDEF_BSTLEN)
    begin : we_undef_burst_en
	  reg    [31:0]  rcvd_byte_cnt;
	  reg            multi_burst_en_reg;
      
	  assign len_load   = (BURST_LENGTH << ($clog2 (DWIDTH/8))); //convert burst length into bytes
		
      always@(*)
	    if(DATA_FIFO_ENABLE)
		  begin 
		    if(USER_ENABLE)
	          axi4_undef_tlast_comb   =  data_fifo_rddata[UWIDTH+DWIDTH]; 
			else 
			  axi4_undef_tlast_comb   =  data_fifo_rddata[DWIDTH]; 
		  end		
		else 
		  axi4_undef_tlast_comb   =  tlast;     

      assign axi4_undef_tlast = axi4_undef_tlast_comb;		  

      always@(*)
	    if(DATA_FIFO_ENABLE)
		  begin 
		    if(USER_ENABLE)
	          axi4_undef_tkeep_comb   =  data_fifo_rddata[UWIDTH+DWIDTH+1+(DWIDTH/8)-1:UWIDTH+DWIDTH+1]; 
			else 
			  axi4_undef_tkeep_comb   =  data_fifo_rddata[DWIDTH+1+(DWIDTH/8)-1:DWIDTH+1]; 
		  end 
		else 
		  axi4_undef_tkeep_comb   =  tkeep;   
		  
      assign axi4_undef_tkeep = axi4_undef_tkeep_comb;		  
		  
      always@(*)		  
	    if(DATA_FIFO_ENABLE)
          data_fifo_rden = (dvalid_en & axi4i_wready & ~data_fifo_empty & ~axi4_undef_wrstrb_ctrl);
        else  
          data_fifo_rden = 1'b0;
		  

      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          axi4_undef_wrstrb_ctrl_reg <= 1'b0;
        else if(axi_data_phase_cmpl)
          axi4_undef_wrstrb_ctrl_reg <= 1'b0;
        else if(axi4i_wvalid & axi4i_wready & axi4_undef_tlast)
  	      axi4_undef_wrstrb_ctrl_reg <= 1'b1;
		  
      assign axi4_undef_wrstrb_ctrl = axi4_undef_wrstrb_ctrl_reg;		  
		  
      always@(*)
	    if(DATA_FIFO_ENABLE)
          axi4i_wvalid   =  (dvalid_en & (~data_fifo_empty | axi4_undef_wrstrb_ctrl) & axi4_wvalid_dly); 
		else 
		  axi4i_wvalid   =  (dvalid_en & (tvalid | axi4_undef_wrstrb_ctrl) & axi4_wvalid_dly); 				  
		  
      always@(*)
        begin 
          axi4i_wstrb = axi4_undef_tkeep;
   		  if(axi4_undef_wrstrb_ctrl)
  		    axi4i_wstrb = {(DWIDTH/8){1'b0}};
  	    end 

      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          rcvd_byte_cnt = 0;
		else if(addr_load_en)
		  rcvd_byte_cnt = 0;
		else if(axi4i_wvalid & axi4i_wready)
		  begin 
		    for(byte_valid=0; byte_valid < (DWIDTH/8); byte_valid = byte_valid + 1)
			  rcvd_byte_cnt = rcvd_byte_cnt + axi4i_wstrb[byte_valid];
		  end 

      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          status <= {STATUS_WIDTH{1'b0}};
    	else if(addr_load_en_f1)
    	  begin 
    	    status[5:0]  <= 6'd0;
			//Packet drop due tp error and overflow is supported only for Store and forward mode, When UNDEF_BSTLEN is enabled store and forward cannot be enabled
			// Due to this status bits of packet drop flags are always set to zero
    	    if(CMDSTS_FIFO_ENABLE)
    	      status[25:16] <= cmd_fifo_rdata[24:15];
    		else 
    		  status[25:16] <= control[25:16];
    	  end 
    	else begin 
		  if(axi_wrrsp_phase_cmpl)
    	    begin 
    	      if(status[3:2] == 2'b00)
    		    begin 
    	          status[3:2] <= axi4i_bresp;
    		    end 
			  status[63:32]  <= rcvd_byte_cnt;
    	    end
		  if(CMDSTS_FIFO_ENABLE) 
		    begin 
		      if(axi_data_phase_cmpl)
		        status[0]  <= ~multi_burst_en;
			end 
		  else 
		    begin 
			  if((~(| axi_addr_rsp_cntr) & ~multi_burst_en & axi_wrrsp_phase_cmpl_d))
			    status[0]  <= 1'b1;
			end
		  if(CMDSTS_FIFO_ENABLE)                        // Packet drop overflow and packet drop error status
           begin
			  if(multi_pkt_intr_pl)
                status[1]  <= 1'b1;
           end
        end 			
		  
	  
      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          multi_burst_en_reg <= 1'b0;
        else 
          multi_burst_en_reg <= multi_burst_en;
		
      //When UNDEF_BSTLEN is 1, burst needs to be broken into multiple AXI4 MM transfers can be decided only when last burst is transmitted. 
      //All the logic qualifies multi_burst_en signal when data phase is completed. So made multi_burst_en logic from sequential to combo. 
      always@(*)
        if(axi_data_phase_cmpl)
          multi_burst_en = ~(axi4_undef_wrstrb_ctrl | axi4_undef_tlast);
        //else if(axi_addr_phase_cmpl)
        //  multi_burst_en = 1'b0;				  
		else 
		  multi_burst_en = multi_burst_en_reg;
	  
      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          cross_4kaddr       <= 0;
        else 
          //cross_4kaddr       <= (BURST_LENGTH[8:0] > axi_len_limit[ADDR_LSB_POS+AXI4_LEN_VEC_LIMIT-1:ADDR_LSB_POS]);	
          cross_4kaddr       <= ~(BURST_LENGTH < axi_len_limit[12:ADDR_LSB_POS]);	


      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          axi4_incr_burst_len <= 0;
        else if(~axi4i_avalid)
          begin		
            if(cross_4kaddr)
                begin
                  //if(axi_len_limit[ADDR_LSB_POS +: AXI4_LEN_VEC_LIMIT] < BURST_LENGTH)
                    axi4_incr_burst_len <= axi_len_limit[ADDR_LSB_POS +: AXI4_LEN_VEC_LIMIT]-1'b1;
      	          //else 
      	          //  axi4_incr_burst_len <= AXI4_BURST_LENGTH[7:0];
                end 
            else
              axi4_incr_burst_len <= AXI4_BURST_LENGTH[7:0];
          end 
			  
      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          axi4_fix_burst_len <= 0;
        else if(~axi4i_avalid)
          begin		
            if(cross_4kaddr)
              begin
                //if(axi_len_limit[ADDR_LSB_POS +: 4] < BURST_LENGTH[4:0])
                  axi4_fix_burst_len <= axi_len_limit[ADDR_LSB_POS +: 4]-1'b1;
                //else 
         	    //  axi4_fix_burst_len <= AXI4_BURST_LENGTH[3:0];
              end
            else
              axi4_fix_burst_len <= AXI4_BURST_LENGTH[3:0];				 
          end
    end //UNDEF_BSTLEN end
  else 
    begin : we_undef_burst_dis
	
      assign len_load = CMDSTS_FIFO_ENABLE ? cmd_fifo_rdata[32+LEN_OFFSET-1:LEN_OFFSET] : burst_len;
	  
	  
	  assign axi4_undef_tlast   = 1'b0;		

      
	  assign axi4_undef_tkeep   = {(DWIDTH/8){1'b1}};	
		
      
      assign axi4_undef_wrstrb_ctrl = 1'b0;		 
		
      always@(*)		  
	    if(DATA_FIFO_ENABLE)
          data_fifo_rden = (dvalid_en & axi4i_wready & ~data_fifo_empty & axi4_wvalid_dly);
        else  
          data_fifo_rden = 1'b0;
		
      always@(*)
	    if(DATA_FIFO_ENABLE)
          axi4i_wvalid   =  dvalid_en & ~data_fifo_empty & axi4_wvalid_dly; 
		else 
		  axi4i_wvalid   =  dvalid_en & tvalid & axi4_wvalid_dly; 
		
      assign axi4_byte_valid = len_load[ADDR_LSB_POS-1:0] - remaining_bytes[ADDR_LSB_POS-1:0];  

      //convert binary to one hot
      always@(*)
        begin 
          axi4_wstrb_ctrl = 0;
      	  axi4_wstrb_ctrl[axi4_byte_valid] = 1'b1;
        end 		

      always@(*)
        if(axi4i_wvalid & axi4i_wlast & (axi4_byte_valid != 0) & ~multi_burst_en)
  	      axi4i_wstrb = axi4_wstrb_ctrl -1'b1;
  	    else 
  	      axi4i_wstrb = {DWIDTH/8{1'b1}};
		  
 		
      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          status <= 0;
    	else if(addr_load_en_f1 | (start & (CMDSTS_FIFO_ENABLE == 0)))
    	  begin 
    	    status[5:0]     <= 6'd0;
			if((PKT_DROP_ERR == 1) | (PKT_DROP_OVF == 1))
			  begin			    
				if(pktovf_intr_pl & ~start) begin
				  status[4]  <= 1'b1;
				  status[25:16] <= 10'd0;   end
				if(pkterr_intr_pl & ~start) begin
				  status[5]  <= 1'b1;
				  status[25:16] <= 10'd0;   end
			  end
    	    if(CMDSTS_FIFO_ENABLE)
			  begin
				if(((PKT_DROP_ERR == 1) & pkterr_intr_pl) | ((PKT_DROP_OVF == 1) & pktovf_intr_pl))
				  status[25:16] <= 10'd0; 
				else
				  status[25:16] <= cmd_fifo_rdata[24:15];
			  end
    		else 
			  begin    		    
				if(((PKT_DROP_ERR == 1) & pkterr_intr_pl) | ((PKT_DROP_OVF == 1) & pktovf_intr_pl))
				  status[25:16] <= 10'd0;
				else 
				  status[25:16] <= control[25:16];
			  end
    	  end 
    	else 
		  begin  
		    if(axi_wrrsp_phase_cmpl)
    	      begin 
    	        if(status[3:2] == 2'b00)
    		      begin 
    	            status[3:2] <= axi4i_bresp;
    		      end 
    	      end 				
		    if(CMDSTS_FIFO_ENABLE) 
		      begin 
		        if(axi_data_phase_cmpl)
		          status[0]  <= ~multi_burst_en;
			  end 
		    else 
		      begin 
			    if((~(| axi_addr_rsp_cntr) & ~multi_burst_en & axi_wrrsp_phase_cmpl_d))
			      status[0]  <= 1'b1;
			  end 
			if(CMDSTS_FIFO_ENABLE) 
			  begin
			    if(multi_pkt_intr_pl)
			      status[1]  <= 1'b1;
			  end
          end 			
/*
      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          status <= 0;
    	else if(addr_load_en_f1 | (start & (CMDSTS_FIFO_ENABLE == 0)))
    	  begin 
    	    status[5:0]     <= 6'd0;			
		    if(pktovf_intr_pl & ~start)
			  status[4]  <= 1'b1;
			if(pkterr_intr_pl & ~start)
			  status[5]  <= 1'b1;				
			  
    	    if(CMDSTS_FIFO_ENABLE)
    	      status[25:16] <= cmd_fifo_rdata[24:15];
    		else 
    		  status[25:16] <= control[25:16];
    	  end 
    	else 
		  begin  
		    if(axi_wrrsp_phase_cmpl)
    	      begin 
    	        if(status[3:2] == 2'b00)
    		      begin 
    	            status[3:2] <= axi4i_bresp;
    		      end 
    	      end 				
		    if(CMDSTS_FIFO_ENABLE) 
		      begin 
		        if(axi_data_phase_cmpl)
		          status[0]  <= ~multi_burst_en;
			  end 
		    else 
		      begin 
			    if((~(| axi_addr_rsp_cntr) & ~multi_burst_en & axi_wrrsp_phase_cmpl_d))
			      status[0]  <= 1'b1;
			  end 
			if(CMDSTS_FIFO_ENABLE) 
			  begin
			    if(multi_pkt_intr_pl)
			      status[1]  <= 1'b1;
			  end
          end 	
*/
      assign remaining_bytes_comb = axi_addr_phase_cmpl ?  remaining_bytes - ((axi4i_alen + 1) << ADDR_LSB_POS) : 1'b0;      


      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          multi_burst_en <= 1'b0;
        else if(axi_addr_phase_cmpl)
          begin 
            if(remaining_bytes_comb[32] | (remaining_bytes_comb[31:0] == 0)) //(remaining_bytes_comb[32] | ((remaining_bytes_comb[ADDR_LSB_POS:0] <= (DWIDTH/8)) & (~(| remaining_bytes_comb[31:ADDR_LSB_POS-1]))))
              multi_burst_en <= 1'b0;
            else 
              multi_burst_en <= 1'b1;
          end
		  
      always@(posedge aclk or negedge aresetn)
        if(~aresetn | ~sresetn)
          cross_4kaddr       <= 0;
        else 
          cross_4kaddr       <= ((remaining_bytes[12:0] > axi_len_limit) | (| remaining_bytes[31:13]));		  

      if(DWIDTH < 128)		
        begin : we_dwidth_lt_128
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
		end //DWIDTH < 128 end 
	  else 
	    begin : we_dwidth_gt_128
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
    	              axi4_incr_burst_len <= remaining_bytes[ADDR_LSB_POS +: AXI4_LEN_VEC_LIMIT] - 1'b1;
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
		end //DWIDTH < 128 else end   		
    end //UNDEF_BSTLEN else end
endgenerate	

	  

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
	  dvalid_en <= 1'b0;
	else if(axi_data_phase_cmpl)
	  dvalid_en <= 1'b0;  	 
	else if(axi_addr_phase_cmpl | axi_addr_phase_cmpl_dly[2])
	  dvalid_en <= axi4_wvalid_dly;

  assign axi4i_bready = 1'b1;  

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
	    /* if(UNALIGNED_TRANSFER) 
	      axi4i_addr <= addr_load;
		else 
		  begin  */
		    axi4i_addr[ADDR_LSB_POS-1:0]      <= {ADDR_LSB_POS{1'b0}};
			axi4i_addr[AWIDTH-1:ADDR_LSB_POS] <= addr_load[AWIDTH-1:ADDR_LSB_POS];
		  //end 	  
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
    else if(DATA_FIFO_ENABLE & PKT_FIFO_ENABLE & (PKT_DROP_ERR | PKT_DROP_OVF))
      addr_load_en_f3       <= addr_load_en_f2 & ~pktdrop_hold;
	else 
	  addr_load_en_f3       <= addr_load_en_f2;
	  
	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      write_pkt_done <= 0;
	else if((~(| axi_addr_rsp_cntr) & ~multi_burst_en & axi_wrrsp_phase_cmpl_d))
	  write_pkt_done <= 1'b1;
	else 
	  write_pkt_done <= 1'b0;
	  
   always@(posedge aclk or negedge aresetn)
     if(~aresetn | ~sresetn)
       sts_fifo_wren <= 0;
     else if(DATA_FIFO_ENABLE & PKT_FIFO_ENABLE & (PKT_DROP_ERR | PKT_DROP_OVF))
       begin
	     sts_fifo_wren <= (write_pkt_done | (pktdrop_hold & addr_load_en_f1));
       end
     else
       sts_fifo_wren <= write_pkt_done;
	
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      pktovf_hold <= 0;
	else if(pkt_ovf_pl)
	  pktovf_hold <= 1'b1;
	else if(pktdrop_hold & addr_load_en_f1)
	  pktovf_hold <= 1'b0;	

   assign pktovf_intr_pl = pktdrop_hold & addr_load_en_f1 & pktovf_hold;

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      pkterr_hold <= 0;
	else if(pkt_err_pl)
	  pkterr_hold <= 1'b1;
	else if(pktdrop_hold & addr_load_en_f1)
	  pkterr_hold <= 1'b0;	
	
   assign pkterr_intr_pl = pktdrop_hold & addr_load_en_f1 & pkterr_hold;
	
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

  //When axi_addr_rsp_cntr is > 12 then awvalid is de-asserted. But when axi_addr_rsp_cntr < 12 then when multi_burst_en is asserted, awvalid should be asserted and next 
  //transaction should be sent. 
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      axi_avalid_ctrl <= 1'b0;
	else if((axi_addr_rsp_cntr > 12) & axi_data_phase_cmpl)
	  axi_avalid_ctrl <= 1'b1;	
	else if(axi_wrrsp_phase_cmpl_d | axi4i_avalid)
	  axi_avalid_ctrl <= 1'b0;	

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      axi4i_avalid <= 0;
    else if(axi_addr_phase_cmpl | (axi_addr_rsp_cntr > 12))
      axi4i_avalid <= 1'b0;	
    else if(addr_load_en_f3 | (((multi_burst_en & (axi_data_phase_cmpl | axi_data_phase_cmpl_hld | axi_avalid_ctrl)) & axi_len_rdy)))
      axi4i_avalid <= 1'b1;

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  burlen_cnt <= 0;
    else if(axi4i_avalid)
      burlen_cnt <= axi4i_alen;
    else if(axi4i_wvalid & axi4i_wready)
      burlen_cnt <= burlen_cnt - 1'b1;
 	
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  axi4i_wlast <= 1'b0;
    else if(axi_data_phase_cmpl)
      axi4i_wlast <= 1'b0;
    else if((axi_addr_phase_cmpl & (axi4i_alen == 0)) | ((burlen_cnt == 1) & axi4i_wvalid & axi4i_wready))
  	  axi4i_wlast <= 1'b1;
	
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  axi4_wvalid_dly <= 1'b1;
    else if(addr_load_en_f3 | (multi_burst_en & (axi_data_phase_cmpl | axi_data_phase_cmpl_hld) & axi_len_rdy))
	  begin 
	    if(burst_type[0])
          axi4_wvalid_dly <= (axi4_incr_burst_len > 1); 	
        else 
          axi4_wvalid_dly <= ({4'h0,axi4_fix_burst_len} > 1);
	  end 
    else if(axi_addr_phase_cmpl_dly[1])
  	  axi4_wvalid_dly <= 1'b1;	

  assign start = control[0];
  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  pkt_inprogrs <= 1'b0;
	else if(CMDSTS_FIFO_ENABLE) 
      begin 
		if(addr_load_en)
	      pkt_inprogrs <= 1'b1;
		else if(axi_wrrsp_phase_cmpl_d)
		  pkt_inprogrs <= 1'b0;		
	  end 
	else 
	  pkt_inprogrs <= 1'b0;
	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  pkt_inprogrs_d <= 1'b0;
	else if(CMDSTS_FIFO_ENABLE) 
      begin 
		pkt_inprogrs_d <= pkt_inprogrs;		
	  end 
	else 
	  pkt_inprogrs_d <= 1'b0;

	  
	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  axi4s_cmpl_hold <= 1'b0;
     else if(start_ctrl ^ cmd_fifo_first_rdreq)
      axi4s_cmpl_hold <= 1'b0;	
	else if(axi4s_cmpl) 
	  axi4s_cmpl_hold <= 1'b1;
	
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  cmd_fifo_rdctrl <= 1'b0;
	else if(CMDSTS_FIFO_ENABLE)
	  begin 
	    if(DATA_FIFO_ENABLE & PKT_FIFO_ENABLE & (PKT_DROP_ERR | PKT_DROP_OVF))
		  begin 
		    if(cmd_fifo_rden)
	          cmd_fifo_rdctrl <= 1'b0;
		    else if(((~(| axi_addr_rsp_cntr)) & ~multi_burst_en & axi_wrrsp_phase_cmpl_d) | 
			          (addr_load_en_f1 & (pktovf_intr_pl | pkterr_intr_pl)))	  
	          cmd_fifo_rdctrl <= 1'b1;
		  end 
		else 
		  begin 
		    if(cmd_fifo_rden)
	          cmd_fifo_rdctrl <= 1'b0;
		    else if((~(| axi_addr_rsp_cntr)) & ~multi_burst_en & axi_wrrsp_phase_cmpl_d)	  
	          cmd_fifo_rdctrl <= 1'b1;		  
		  end 
	  end 

  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  cmd_fifo_first_rdreq <= 1'b0;
	else if(CMDSTS_FIFO_ENABLE) 
      begin 
	    if(DATA_FIFO_ENABLE & PKT_FIFO_ENABLE & (PKT_DROP_ERR | PKT_DROP_OVF))
		  begin 
            if(~cmd_fifo_empty & str_frwrd_cntr > 0 )
	          cmd_fifo_first_rdreq <= 1'b1;
		  end 
		else 
		  begin 
			if(~cmd_fifo_empty)
			  cmd_fifo_first_rdreq <= 1'b1;
		  end 
	  end 
	else 
	  cmd_fifo_first_rdreq <= 1'b0;
	  
  always@(*)
    if(DATA_FIFO_ENABLE & PKT_FIFO_ENABLE & (PKT_DROP_ERR | PKT_DROP_OVF)) 
	  begin 
	    if(~cmd_fifo_empty & CMDSTS_FIFO_ENABLE & (str_frwrd_cntr > 0))
	      cmd_fifo_rden = (~cmd_fifo_first_rdreq | cmd_fifo_rdctrl);	
	    else 
	      cmd_fifo_rden = 1'b0;
	  end else 
      begin 
	   if(~cmd_fifo_empty & CMDSTS_FIFO_ENABLE)
	     cmd_fifo_rden = (~cmd_fifo_first_rdreq | cmd_fifo_rdctrl);	
	   else 
	     cmd_fifo_rden = 1'b0;
	  end 

	  
  //counter to keep track of number of write request sent and number of respsonse recevied. This counter is used to generate status fifo write request. 
  //when this counter is 0 and response is recevied, status fifo write request should be asserted. This counter is used to control awvalid as well. 
  //when this counter is more than 12, awvalid is de-asserted. 
  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  axi_addr_rsp_cntr <= 0;
	else if(axi_addr_phase_cmpl ^ axi_wrrsp_phase_cmpl)
	  begin 
        if(axi_addr_phase_cmpl)
	      axi_addr_rsp_cntr <= axi_addr_rsp_cntr + 1'b1;
        else if(| axi_addr_rsp_cntr)	  
	      axi_addr_rsp_cntr <= axi_addr_rsp_cntr - 1'b1;
	  end 

	  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      axi_wrrsp_phase_cmpl_d <= 1'b0;
    else 
      axi_wrrsp_phase_cmpl_d  <= axi_wrrsp_phase_cmpl;
	  
  assign axi4s_cmpl = tlast & tvalid & tready;	  
  
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)                 
      start_hold      <= 1'b0;
	else if(addr_load_en)	
      start_hold      <= 1'b0;
	else if(start & (str_frwrd_cntr == 0))	
	  start_hold      <= 1'b1;

	
  always@(*)
    begin 
	  if(PKT_FIFO_ENABLE & DATA_FIFO_ENABLE)
	    begin
		  if(PKT_DROP_ERR & PKT_DROP_OVF)
		    axi4s_cmpl_valid = axi4s_cmpl & ~(pkt_err_pl | pkt_ovf_pl);
		  else if(PKT_DROP_ERR)
		    axi4s_cmpl_valid = axi4s_cmpl & ~(pkt_err_pl);
		  else if(PKT_DROP_OVF)
		    axi4s_cmpl_valid = axi4s_cmpl & ~(pkt_ovf_pl);
		  else 
		    axi4s_cmpl_valid = axi4s_cmpl;
		end
	  else 
	    axi4s_cmpl_valid = 0;
	end
	
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      str_frwrd_cntr <= 0;
    else if(PKT_FIFO_ENABLE & DATA_FIFO_ENABLE & (PKT_DROP_ERR | PKT_DROP_OVF))
	  begin 
	    if(CMDSTS_FIFO_ENABLE ==1)
		  begin
	        if(axi4s_cmpl ^ cmd_fifo_rden) 
		      begin 
		        if(axi4s_cmpl)
		    	  str_frwrd_cntr <= str_frwrd_cntr + 1'b1; 
		    	else if(str_frwrd_cntr != 0)
		    	  str_frwrd_cntr <= str_frwrd_cntr - 1'b1;
              end 
          end
		else
		  begin
		    if(axi4s_cmpl | start_hold)               //(axi4s_cmpl ^ start_hold | start_ctrl
			  begin 
				if(axi4s_cmpl)
				  str_frwrd_cntr <= str_frwrd_cntr + 1'b1; 
				else if(str_frwrd_cntr > 0)
				  str_frwrd_cntr <= str_frwrd_cntr - 1'b1; 
			  end 
		  end
	  end 
	else 
	  str_frwrd_cntr <= 0;
	 
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)	
	  start_enable <= 1'b0;
	else if(PKT_FIFO_ENABLE & DATA_FIFO_ENABLE & (PKT_DROP_ERR | PKT_DROP_OVF)) 
	  start_enable <=  ((str_frwrd_cntr > 0) & (start | start_hold));
	else 
	  start_enable <= start;
	
  always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
      pktdrop_hold <= 1'b0;
    else if(PKT_FIFO_ENABLE & DATA_FIFO_ENABLE & (PKT_DROP_ERR | PKT_DROP_OVF))
	  begin 
	    if(addr_load_en_f2)
		  pktdrop_hold <= 1'b0;
	    else if(axi4s_cmpl & ((pkt_err_pl & PKT_DROP_ERR) | (pkt_ovf_pl & PKT_DROP_OVF)))
	      pktdrop_hold <= 1'b1;
	  end 
	else 
	  pktdrop_hold <= 1'b0;
   
   // When Command status fifo is disabled
   
   always@(posedge aclk or negedge aresetn)
    if(~aresetn | ~sresetn)
  	  start_ctrl <= 1'b0;
	else if(CMDSTS_FIFO_ENABLE == 0) 
      begin 
	    if(DATA_FIFO_ENABLE & PKT_FIFO_ENABLE & (PKT_DROP_ERR | PKT_DROP_OVF))
		  begin 
            if((|str_frwrd_cntr))
	          start_ctrl <= start;
		  end 
		else 
		  begin 
	          start_ctrl <= start;		
		  end 
	  end 
	else 
	  start_ctrl <= 1'b0;
	     
endmodule 

