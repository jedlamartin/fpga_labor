`timescale 1ns / 100ps

module mm2s_chkr #
(
  parameter                             DATA_WIDTH             = 32,
  parameter                             CMDSTS_FIFO_ENABLE     = 1,
  parameter                             CMDSTS_FIFO_DEPTH      = 16,
  parameter                             ADDR_WIDTH             = 32,
  parameter                             ENDIAN_CONV            = 0
)
(
  input                                 clk,
  input                                 arst_n,

  input                                 axi4l_awvalid,
  input                                 axi4l_awready,
  input [10:0]                          axi4l_awaddr, 
  input                                 axi4l_wvalid, 
  input                                 axi4l_wready, 
  input [31:0]                          axi4l_wdata,  
  input [3:0]                           axi4l_wstrb,    


  input                                 axi4s_t_tvalid,
  input                                 axi4s_t_tready,
  input                                 axi4s_t_tlast,
  input [DATA_WIDTH-1:0]                axi4s_t_tdata,
  input [(DATA_WIDTH/8)-1:0]            axi4s_t_tkeep,
							            
  input                                 axi4_slave_arid,    
  input [ADDR_WIDTH-1:0]                axi4_slave_araddr,  
  input [7:0]                           axi4_slave_arlen,   
  input [2:0]                           axi4_slave_arsize,  
  input [1:0]                           axi4_slave_arburst, 
  input                                 axi4_slave_arvalid, 
  input                                 axi4_slave_arready, 
										
  input [DATA_WIDTH-1:0]                axi4_slave_rdata,
  input                                 axi4_slave_rlast,
  input                                 axi4_slave_rvalid,
  input                                 axi4_slave_rready,  
  
  
  output reg [31:0]                     pkt_size,
  output                                axi4s_initr_en,
  input  [2:0]                          num_of_cmd   
);  

   localparam                           CMD_FIFO_DWIDTH = 25 + 32 + ADDR_WIDTH;          
   localparam                           ADDR_LSB_POS    = $clog2(DATA_WIDTH)-3;
   
   wire                                 axi4s_data_cmp  = axi4s_t_tvalid & axi4s_t_tready & axi4s_t_tlast;
   wire                                 axi4mm_data_cmp = axi4_slave_rvalid & axi4_slave_rready & axi4_slave_rlast;
   wire  [DATA_WIDTH-1:0]               mm2s_rdata;
   reg   [15:0]                         mm2s_raddr;
   reg   [15:0]                         mm2s_waddr;
   reg   [DATA_WIDTH-1:0]               mm2s_mem [65535:0];
   wire  [DATA_WIDTH-1:0]               mm2s_chkr_wdata;
   wire  [DATA_WIDTH-1:0]               mm2s_chkr_wdata_end_conv;
   integer                              i;
   
   reg  [10:0]                          axi4l_awaddr_reg;
						                
   reg  [31:0]                          len_reg = 0;
   reg  [31:0]                          addr_reg0 = 0;
   reg  [31:0]                          addr_reg1 = 0;
   reg  [25:0]                          ctrl_reg = 0;
   reg                                  txn_done;
   reg                                  txn_done_ctrl;
   reg  [9:0]                           cmd_cntr;
   
   reg  [CMD_FIFO_DWIDTH-1:0]           mm2s_cmd_mem [CMDSTS_FIFO_DEPTH:0];
   reg  [$clog2(CMDSTS_FIFO_DEPTH)-1:0] mm2s_cmd_waddr;
   reg  [$clog2(CMDSTS_FIFO_DEPTH)-1:0] mm2s_cmd_raddr;
   reg  [CMD_FIFO_DWIDTH-1:0]           mm2s_cmd_rdata;
   reg                                  mm2s_cmd_rdreq_static;
   reg                                  mm2s_cmd_rdreq_static_f1;
   reg                                  mm2s_cmd_rdreq;
   reg                                  mm2s_cmd_rdreq_f1;
   reg                                  mm2s_cmd_rdreq_f2; 
   reg                                  txn_done_hold; 

   wire [ADDR_WIDTH-1:0]                addr;   
   wire [31:0]                          len_byte;
   wire [1:0]                           chkr_arburst;
   wire [31:0]                          remaining_len;  
   reg  [31:0]                          xfer_len;  
   reg  [ADDR_WIDTH-1:0]                chkr_addr;  
   reg  [7:0]                           chkr_arlen;  
   reg  [31:0]                          total_byte_cnt;  
   wire [$clog2(DATA_WIDTH/8)-1:0]      last_byte;

   reg                      arvalid_reg;
   reg [ADDR_WIDTH-1:0]     araddr_reg;
   reg [7:0]                arlen_reg;
   reg [1:0]                arburst_reg;
   
   reg                      rvalid_reg;
   reg [DATA_WIDTH-1:0]     rdata_reg;
   reg                      rlast_reg;
   reg                      axi4_slave_addrph_cmpl;

   wire [ADDR_WIDTH-1:0]    addr_dbg;
   wire [ADDR_WIDTH-1:0]    addr_4k;
   wire [ADDR_WIDTH-1:0]    len_dbg;
   wire [ADDR_WIDTH-1:0]    arlen_dbg;
   							  
   
   localparam [10:0] MM2S_VERSNREG				= 11'h400;
   localparam [10:0] MM2S_CNTRLREG				= 11'h410;
   localparam [10:0] MM2S_STSREG				= 11'h414;
   localparam [10:0] MM2S_LENGTHREG				= 11'h418;
   localparam [10:0] MM2S_ADDRREG0				= 11'h41C;
   localparam [10:0] MM2S_ADDRREG1				= 11'h420;
   localparam [10:0] MM2S_INTRENBREG			= 11'h424;
   localparam [10:0] MM2S_INTRSRCREG			= 11'h428;
   localparam [10:0] MM2S_AXI4ERRCNTREG			= 11'h500;		
   
   assign mm2s_chkr_wdata = axi4_slave_rdata[DATA_WIDTH-1:0];
      
   generate
       if (ENDIAN_CONV == 1) //Need to check the endian conversion
       begin
   						    
           genvar i,j;
           for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
               assign mm2s_chkr_wdata_end_conv[(DATA_WIDTH - 1 - (i*8)) -: 8] = mm2s_chkr_wdata[(i*8) +: 8];
           end
       end else begin
           assign mm2s_chkr_wdata_end_conv   = mm2s_chkr_wdata;
       end
   endgenerate   
   
   assign addr          = mm2s_cmd_rdreq_f1 ? mm2s_cmd_rdata[ADDR_WIDTH+57-1:57] : addr;
   assign len_byte      = mm2s_cmd_rdreq_f1 ? mm2s_cmd_rdata[56:25] : len_byte;
   assign chkr_arburst  = mm2s_cmd_rdreq_f1 ? mm2s_cmd_rdata[1:0] : chkr_arburst;
   assign remaining_len = len_byte > xfer_len ? len_byte - xfer_len : 0;
   
   
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
      xfer_len <= 0;
    else if(mm2s_cmd_rdreq_f1)
      xfer_len <= 0;
    else if(axi4_slave_arvalid & axi4_slave_arready)
      xfer_len <= xfer_len + ((axi4_slave_arlen + 1) * (DATA_WIDTH/8));
  
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
      chkr_addr <= 0;
    else if(mm2s_cmd_rdreq_f1)
	  begin 
	    chkr_addr[ADDR_LSB_POS-1:0] <= 0;
        chkr_addr[ADDR_WIDTH-1:ADDR_LSB_POS]<= addr[ADDR_WIDTH-1:ADDR_LSB_POS];
	  end 
    else if(axi4_slave_arvalid & axi4_slave_arready & chkr_arburst[0])
      chkr_addr <= chkr_addr + ((axi4_slave_arlen + 1) * (DATA_WIDTH/8));
	  
  always@(posedge clk)
    axi4_slave_addrph_cmpl <= axi4_slave_arvalid & axi4_slave_arready;
  
  assign addr_dbg = chkr_addr[11:ADDR_LSB_POS];
  assign addr_4k  = (1<<(12-ADDR_LSB_POS));
  assign len_dbg  = remaining_len[31:ADDR_LSB_POS];
  assign arlen_dbg = chkr_arlen;
  
  always@(posedge clk)
    if(mm2s_cmd_rdreq_f2 | (axi4_slave_addrph_cmpl))
      begin 
  	    chkr_arlen = 255;
  	    if(mm2s_cmd_rdata[1:0] == 2'b00)
  	      chkr_arlen = 15;
  	    if((chkr_addr[11:ADDR_LSB_POS] + chkr_arlen) >=  (1<<(12-ADDR_LSB_POS)))
  	      chkr_arlen = (1<<(12-ADDR_LSB_POS)) - chkr_addr[11:ADDR_LSB_POS]-1;
        if(chkr_arlen > (remaining_len[31:ADDR_LSB_POS]-1))
  	      begin 
  	        chkr_arlen = (remaining_len[31:ADDR_LSB_POS]-1);
  		    if(remaining_len[ADDR_LSB_POS-1:0] != 0)
  		      chkr_arlen = (remaining_len[31:ADDR_LSB_POS]);
  		  end 		
	    if(remaining_len <= (DATA_WIDTH/8))
	      chkr_arlen = 0;		  
      end   	
  	
  always@(*)
    if(axi4_slave_arvalid & axi4_slave_arready)
      begin 
  	     if(axi4_slave_araddr !== chkr_addr)
		   begin 
  	         $display ($time, " MM2S AXI4 MM Initiator address is not correct. Expected =%x Received =%x\n",chkr_addr,axi4_slave_araddr);
			 $stop;
		   end 
	     
  	     if(axi4_slave_arlen !== chkr_arlen)
		   begin 
  	         $display ($time, " MM2S AXI4 MM Initiator arlen is not correct. Expected =%x Received =%x\n",chkr_arlen,axi4_slave_arlen);
			 #200;
			 $stop;
		   end 
	     
  	     if(axi4_slave_arsize !== ($clog2(DATA_WIDTH/8)))
		   begin 
  	         $display ($time, " MM2S AXI4 MM Initiator arsize is not correct. Expected =%x Received =%x\n",($clog2(DATA_WIDTH/8)),axi4_slave_arsize);
			 $stop;
		   end 
	     
  	     if(axi4_slave_arburst !== chkr_arburst)
		   begin 
  	         $display ($time, " MM2S AXI4 MM Initiator arburst is not correct. Expected =%x Received =%x\n",chkr_arburst,axi4_slave_arburst);
			 $stop;
		   end 
	     
  	     if(chkr_arburst[1])
		   begin 
  	         $display ($time, " Invalid burst type configured for MM2S AXI4 MM Initiator. Expected either Fixed or INCR. Received =%x\n",chkr_arburst);
			 $stop;
		   end 
  
  	end 
    	
  	
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
      total_byte_cnt <= 0;
    else if(mm2s_cmd_rdreq_f1)
      total_byte_cnt <= 0;
    else if(axi4s_t_tvalid & axi4s_t_tready)
      total_byte_cnt <= total_byte_cnt + (DATA_WIDTH/8);
  	
  assign last_byte = len_byte - total_byte_cnt;
  
   
  assign mm2s_rdata = mm2s_mem[mm2s_raddr];   
   
   
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
      mm2s_waddr <= 0;
    else if(axi4_slave_rvalid & axi4_slave_rready)
      mm2s_waddr <= mm2s_waddr + 1'b1;
  
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
      mm2s_raddr <= 0;
    else if(axi4s_t_tvalid & axi4s_t_tready)
      mm2s_raddr <= mm2s_raddr + 1'b1;
  
  always@(posedge clk)
    if(axi4_slave_rvalid & axi4_slave_rready)
      mm2s_mem[mm2s_waddr] <= mm2s_chkr_wdata_end_conv;
  	
  always@(negedge clk)
    if(axi4s_t_tvalid & axi4s_t_tready)	
      begin 
  	  for(i=0;i<(DATA_WIDTH/8);i=i+1)
  	    begin 
  	      if(axi4s_t_tdata[8*i +: 8] != mm2s_rdata[8*i +: 8])
  			begin 
  			  $display ($time," Data mismatch found at location = %d, Expected = %x Received = %x\n",i,mm2s_rdata[i*8 +: 8],axi4s_t_tdata[i*8 +: 8] );
  			  #200
  			  $stop;
  			end 
  		end 		  
  	end
   	
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
      axi4l_awaddr_reg <= 0;
    else if(axi4l_awvalid & axi4l_awready)
      axi4l_awaddr_reg <= axi4l_awaddr;
  	
  	
  always@(*)
    if(axi4l_wvalid & axi4l_wready & (axi4l_awaddr_reg == MM2S_CNTRLREG))
      begin 
  	  for(i=0; i<4; i=i+1)
  	    if(axi4l_wstrb[i])
  		  ctrl_reg[8*i +: 8] <= axi4l_wdata[8*i +: 8];
  	end 
    else 
      ctrl_reg[0] <= 1'b0;
  
  always@(*)
   if(axi4l_wvalid & axi4l_wready & (axi4l_awaddr_reg == MM2S_LENGTHREG))
      begin 
  	  for(i=0; i<4; i=i+1)
  	    if(axi4l_wstrb[i])
  		  len_reg[8*i +: 8] <= axi4l_wdata[8*i +: 8];
  	end 
  
  always@(*)
    if(axi4l_wvalid & axi4l_wready & (axi4l_awaddr_reg == MM2S_ADDRREG0))
      begin 
  	  for(i=0; i<4; i=i+1)
  	    if(axi4l_wstrb[i])
  		  addr_reg0[8*i +: 8] <= axi4l_wdata[8*i +: 8];
  	end 
   	
  always@(*)
   if(axi4l_wvalid & axi4l_wready & (axi4l_awaddr_reg == MM2S_ADDRREG1))
      begin 
  	  for(i=0; i<4; i=i+1)
  	    if(axi4l_wstrb[i])
  		  addr_reg1[8*i +: 8] <= axi4l_wdata[8*i +: 8];
  	end 		  
  		  
		  
  always@(*)
    if((remaining_len <= DATA_WIDTH/8) & axi4_slave_arvalid & axi4_slave_arready)
	  txn_done_ctrl = 1'b1;
	else if(txn_done)
	  txn_done_ctrl = 1'b0;
	   
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
      txn_done <= 0;
    else if(axi4_slave_rvalid & axi4_slave_rready & axi4_slave_rlast & ((remaining_len == 0) | txn_done_ctrl))
      txn_done <= 1'b1;
    else 
  	  txn_done <= 0;
  	
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
      cmd_cntr <= 0;
    else if(cmd_cntr == num_of_cmd)
      cmd_cntr <= 0;	
    else if(txn_done)
  	  cmd_cntr <= cmd_cntr + 1'b1;		
   	
   generate
     if(CMDSTS_FIFO_ENABLE)
       begin
   	
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             mm2s_cmd_waddr <= 0;
           else if(ctrl_reg[0])
             mm2s_cmd_waddr <= mm2s_cmd_waddr + 1'b1;  
   		  
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             mm2s_cmd_rdreq_static <= 0;
           else if(ctrl_reg[0])
             mm2s_cmd_rdreq_static <= 1;	
   		   else if(cmd_cntr == num_of_cmd)
   		     mm2s_cmd_rdreq_static <= 0;
   		  
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             mm2s_cmd_rdreq_static_f1 <= 0;
           else 
             mm2s_cmd_rdreq_static_f1 <= mm2s_cmd_rdreq_static;		  

         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             txn_done_hold <= 0;
		   else if(mm2s_cmd_waddr > mm2s_cmd_raddr)
		     txn_done_hold <= 0;
           else if(txn_done & (mm2s_cmd_waddr <= mm2s_cmd_raddr))
             txn_done_hold <= 1;
   
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             mm2s_cmd_rdreq <= 0;
		   else if((cmd_cntr == (num_of_cmd-1)) & txn_done)
		     mm2s_cmd_rdreq <= 0;			 
           else if((mm2s_cmd_rdreq_static & ~mm2s_cmd_rdreq_static_f1) | ((txn_done | txn_done_hold) & (mm2s_cmd_waddr > mm2s_cmd_raddr)))
             mm2s_cmd_rdreq <= 1;		  
   		   else 
   		     mm2s_cmd_rdreq <= 0;		  
   		  
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             {mm2s_cmd_rdreq_f2,mm2s_cmd_rdreq_f1} <= 0;
           else 
             {mm2s_cmd_rdreq_f2,mm2s_cmd_rdreq_f1} <= {mm2s_cmd_rdreq_f1,mm2s_cmd_rdreq};
   		  
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             mm2s_cmd_raddr <= 0;
           else if(mm2s_cmd_rdreq_f2)
             mm2s_cmd_raddr <= mm2s_cmd_raddr + 1'b1;			
     
         assign mm2s_cmd_rdata = mm2s_cmd_mem[mm2s_cmd_raddr];
   	  
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             pkt_size <= 0;
           else if(mm2s_cmd_rdreq_f1)
             pkt_size <= mm2s_cmd_rdata[40:25];
   		 
   	  assign axi4s_initr_en = mm2s_cmd_rdreq_f2;
   	  
   	  if(ADDR_WIDTH > 32)
   	    begin 
   		  always@(posedge clk)
               if(ctrl_reg[0])
                 mm2s_cmd_mem[mm2s_cmd_waddr] <= {addr_reg1,addr_reg0,len_reg,ctrl_reg[25:1]};
   		end 
   	  else 
   	    begin 
   		  always@(posedge clk)
               if(ctrl_reg[0])
                 mm2s_cmd_mem[mm2s_cmd_waddr] <= {addr_reg0,len_reg,ctrl_reg[25:1]};
   		end 	  
       end 	
   endgenerate	
	
	
   //AXI4 Protocol validation 
   
 
   always@(posedge clk)
   begin
     if(axi4_slave_arvalid & ~axi4_slave_arready)
       begin 
         arvalid_reg <= 1'b1;
   	     araddr_reg  <= axi4_slave_araddr;
   	     arlen_reg   <= axi4_slave_arlen;
   	     arburst_reg <= axi4_slave_arburst;
   	   end 
     else if(axi4_slave_arvalid & axi4_slave_arready)
       begin 
         arvalid_reg <= 1'b0;
   	     araddr_reg  <= 0;
   	     arlen_reg   <= 0;
   	     arburst_reg <= 0;
       end 
   	
     if(axi4_slave_rvalid & ~axi4_slave_rready)	
       begin
   	     rvalid_reg  <= axi4_slave_rvalid;
   	     rdata_reg   <= axi4_slave_rdata;
   	     rlast_reg   <= axi4_slave_rlast;
   	   end 
     else if(axi4_slave_rvalid & axi4_slave_rready)	
       begin 
   	     rvalid_reg  <= 0;
   	     rdata_reg   <= 0;
   	     rlast_reg   <= 0;
   	   end 
   	  
   end	
   	
   always@(*)
     begin 
       if(arvalid_reg & ~axi4_slave_arvalid & ~axi4_slave_arready)
         begin 
   	       $display ($time, " Error: ARVALID change before ARREADY \n");
           $stop;
         end 
   
       if((araddr_reg != axi4_slave_araddr) & arvalid_reg & axi4_slave_arvalid & ~axi4_slave_arready)
         begin 
   	       $display ($time, " Error: ARADDR change before ARREADY \n");
           $stop;
         end 
   
       if((arlen_reg != axi4_slave_arlen) & arvalid_reg & axi4_slave_arvalid & ~axi4_slave_arready)
         begin 
   	       $display ($time, " Error: ARLEN change before ARREADY \n");
           $stop;
         end 
   
       if((arburst_reg != axi4_slave_arburst) & arvalid_reg & axi4_slave_arvalid & ~axi4_slave_arready)
         begin 
   	       $display ($time, " Error: ARBURST change before ARREADY \n");
           $stop;
         end 
   
       if(rvalid_reg & ~axi4_slave_rvalid & ~axi4_slave_rready)
         begin 
   	       $display ($time, " Error: RVALID change before RREADY \n");
           $stop;
         end 
   
       if((rdata_reg != axi4_slave_rdata) & rvalid_reg & axi4_slave_rvalid & ~axi4_slave_rready)
         begin 
   	       $display ($time, " Error: RDATA change before RREADY \n");  
           $stop;
         end 
  
       if((rlast_reg != rlast_reg) & rvalid_reg & axi4_slave_rvalid & ~axi4_slave_rready)
         begin 
   	       $display ($time, " Error: RLAST change before RREADY \n");   
           $stop;
         end 
     end   	
endmodule 