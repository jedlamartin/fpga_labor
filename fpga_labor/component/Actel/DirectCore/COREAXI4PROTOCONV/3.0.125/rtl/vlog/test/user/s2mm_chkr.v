`timescale 1ns / 100ps

module s2mm_chkr #
(
  parameter                  DATA_WIDTH             = 32,
  parameter                  CMDSTS_FIFO_ENABLE     = 1,
  parameter                  CMDSTS_FIFO_DEPTH      = 16,
  parameter                  ADDR_WIDTH             = 32,
  parameter                  ENDIAN_CONV            = 0
)
(
  input                      clk,
  input                      arst_n,
  
  input                      axi4l_awvalid,
  input                      axi4l_awready,
  input [10:0]               axi4l_awaddr, 
  input                      axi4l_wvalid, 
  input                      axi4l_wready, 
  input [31:0]               axi4l_wdata,  
  input [3:0]                axi4l_wstrb,  
  
  input                      axi4s_i_tvalid,
  input                      axi4s_i_tready,
  input                      axi4s_i_tlast,
  input [DATA_WIDTH-1:0]     axi4s_i_tdata,
  
  // AXI4 Initiator Write Interface Ports (S2MM_AXI4MM_INITR) 
  input                      axi4_slave_awid,    
  input [ADDR_WIDTH-1:0]     axi4_slave_awaddr,  
  input [7:0]                axi4_slave_awlen,   
  input [2:0]                axi4_slave_awsize,  
  input [1:0]                axi4_slave_awburst, 
  input                      axi4_slave_awvalid, 
  input                      axi4_slave_awready, 
  
  input [DATA_WIDTH-1:0]     axi4_slave_wdata,
  input [(DATA_WIDTH/8)-1:0] axi4_slave_wstrb,
  input                      axi4_slave_wlast,
  input                      axi4_slave_wvalid,
  input                      axi4_slave_wready,
  input                      axi4_slave_bvalid,
  input                      axi4_slave_bready,

  output reg [15:0]          pkt_size,
  output                     axi4s_initr_en,
  input  [2:0]               num_of_cmd  
);
localparam                     CMD_FIFO_DWIDTH = 25 + 32 + ADDR_WIDTH;
localparam                     ADDR_LSB_POS = $clog2(DATA_WIDTH)-3;


   localparam [10:0] S2MM_VERSNREG				= 11'h00;
   localparam [10:0] S2MM_CNTRLREG				= 11'h10;
   localparam [10:0] S2MM_STSREG				= 11'h14;
   localparam [10:0] S2MM_LENGTHREG				= 11'h18;
   localparam [10:0] S2MM_ADDRREG0				= 11'h1C;
   localparam [10:0] S2MM_ADDRREG1				= 11'h20;
   localparam [10:0] S2MM_INTRENBREG			= 11'h24;
   localparam [10:0] S2MM_INTRSRCREG			= 11'h28;
   localparam [10:0] S2MM_AXI4ERRCNTREG			= 11'h100;
   localparam [10:0] S2MM_PKTDRPERRCNTREG		= 11'h104;
   localparam [10:0] S2MM_PKTDRPOVFCNTREG		= 11'h108;
   
					                 
wire                                 axi4s_data_cmp  = axi4s_i_tvalid & axi4s_i_tready & axi4s_i_tlast;
wire                                 axi4mm_data_cmp = axi4_slave_wvalid & axi4_slave_wready & axi4_slave_wlast;
wire [DATA_WIDTH-1:0]                s2mm_rdata;
reg  [15:0]                          s2mm_raddr;
reg  [15:0]                          s2mm_waddr;
reg  [DATA_WIDTH-1:0]                s2mm_mem [65535:0];
					                 
reg  [10:0]                          axi4l_awaddr_reg;  
					                 
reg  [31:0]                          len_reg = 0;
reg  [31:0]                          addr_reg0 = 0;
reg  [31:0]                          addr_reg1 = 0;
reg  [25:0]                          ctrl_reg = 0;
reg                                  txn_done;
reg  [9:0]                           cmd_cntr;
wire [ADDR_WIDTH-1:0]                addr;

reg  [CMD_FIFO_DWIDTH-1:0]           s2mm_cmd_mem [CMDSTS_FIFO_DEPTH:0];
reg  [$clog2(CMDSTS_FIFO_DEPTH)-1:0] s2mm_cmd_waddr;
reg  [$clog2(CMDSTS_FIFO_DEPTH)-1:0] s2mm_cmd_raddr;
reg  [CMD_FIFO_DWIDTH-1:0]           s2mm_cmd_rdata;
reg                                  s2mm_cmd_rdreq_static;
reg                                  s2mm_cmd_rdreq_static_f1;
reg                                  s2mm_cmd_rdreq;
reg                                  s2mm_cmd_rdreq_f1;
reg                                  s2mm_cmd_rdreq_f2;
reg  [ADDR_WIDTH-1:0]                chkr_addr;
reg  [7:0]                           chkr_awlen;
wire  [1:0]                          chkr_awburst;
reg  [(DATA_WIDTH/8)-1:0]            chkr_wstrb;
wire [31:0]                          remaining_len;
wire [31:0]                          len_byte;
reg  [31:0]                          xfer_len;
reg  [31:0]                          total_byte_cnt;
wire [$clog2(DATA_WIDTH/8)-1:0]      last_byte;


wire  [DATA_WIDTH-1:0]               s2mm_chkr_wdata;
wire  [DATA_WIDTH-1:0]               s2mm_chkr_wdata_end_conv;

reg                                  axi4_slave_addrph_cmpl;
reg                                  txn_done_ctrl;
integer               i;

wire [ADDR_WIDTH-1:0]    addr_dbg;
wire [ADDR_WIDTH-1:0]    addr_4k;
wire [ADDR_WIDTH-1:0]    len_dbg;
wire [ADDR_WIDTH-1:0]    arlen_dbg;


assign s2mm_chkr_wdata = axi4s_i_tdata[DATA_WIDTH-1:0];
   
generate
    if (ENDIAN_CONV == 1) //Need to check the endian conversion
    begin						    
        genvar i,j;
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
            assign s2mm_chkr_wdata_end_conv[(DATA_WIDTH - 1 - (i*8)) -: 8] = s2mm_chkr_wdata[(i*8) +: 8];
        end
    end else begin
        assign s2mm_chkr_wdata_end_conv   = s2mm_chkr_wdata;
    end
endgenerate   

assign addr          = s2mm_cmd_rdreq_f1 ? s2mm_cmd_rdata[ADDR_WIDTH+57-1:57] : addr;
assign len_byte      = s2mm_cmd_rdreq_f1 ? s2mm_cmd_rdata[56:25] : len_byte;
assign chkr_awburst  = s2mm_cmd_rdreq_f1 ? s2mm_cmd_rdata[1:0] : chkr_awburst;
assign remaining_len = len_byte > xfer_len ? len_byte - xfer_len : 0;

always@(posedge clk or negedge arst_n)
  if(~arst_n)
    xfer_len <= 0;
  else if(s2mm_cmd_rdreq_f1)
    xfer_len <= 0;
  else if(axi4_slave_awvalid & axi4_slave_awready)
    xfer_len <= xfer_len + ((axi4_slave_awlen + 1) * (DATA_WIDTH/8));

always@(posedge clk or negedge arst_n)
  if(~arst_n)
    chkr_addr <= 0;
  else if(s2mm_cmd_rdreq_f1)
    begin 
	  chkr_addr[ADDR_LSB_POS-1:0] <= 0;
      chkr_addr[ADDR_WIDTH-1:ADDR_LSB_POS]<= addr[ADDR_WIDTH-1:ADDR_LSB_POS];	  
	end 
  else if(axi4_slave_awvalid & axi4_slave_awready & chkr_awburst[0])
    chkr_addr <= chkr_addr + ((axi4_slave_awlen + 1) * (DATA_WIDTH/8));

always@(posedge clk)
  axi4_slave_addrph_cmpl <= axi4_slave_awvalid & axi4_slave_awready;
  
assign addr_dbg = chkr_addr[11:ADDR_LSB_POS];
assign addr_4k  = (1<<(12-ADDR_LSB_POS));
assign len_dbg  = remaining_len[31:ADDR_LSB_POS];
assign arlen_dbg = chkr_awlen;
  
always@(posedge clk)
  if(s2mm_cmd_rdreq_f2 | (axi4_slave_addrph_cmpl))
    begin 
	  chkr_awlen = 255;
	  if(s2mm_cmd_rdata[1:0] == 2'b00)
	    chkr_awlen = 15;
	  if((chkr_addr[11:ADDR_LSB_POS] + chkr_awlen) >=  (1<<(12-ADDR_LSB_POS)))
	    chkr_awlen = (1<<(12-ADDR_LSB_POS)) - chkr_addr[11:ADDR_LSB_POS]-1;
      if(chkr_awlen > (remaining_len[31:ADDR_LSB_POS]-1))
	    begin 
	      chkr_awlen = (remaining_len[31:ADDR_LSB_POS]-1);
		  if(remaining_len[ADDR_LSB_POS-1:0] != 0)
		    chkr_awlen = (remaining_len[31:ADDR_LSB_POS]);
		end 
	  if(remaining_len <= (DATA_WIDTH/8))
	      chkr_awlen = 0;		  
		
    end 
	
	
	
always@(posedge clk)
  if(axi4_slave_awvalid & axi4_slave_awready)
    begin 
	  if(axi4_slave_awaddr !== chkr_addr)
         begin 
	      $display ($time, " S2MM AXI4 MM Initiator address is not correct. Expected =%x Received =%x\n",chkr_addr,axi4_slave_awaddr);
          $stop;
         end 

	  if(axi4_slave_awlen != chkr_awlen)
         begin 
	      $display ($time, " S2MM AXI4 MM Initiator awlen is not correct. Expected =%x Received =%x\n",chkr_awlen,axi4_slave_awlen);
          $stop;
         end 

	  if(axi4_slave_awsize !== ($clog2(DATA_WIDTH/8)))
         begin 
	      $display ($time, " S2MM AXI4 MM Initiator awsize is not correct. Expected =%x Received =%x\n",($clog2(DATA_WIDTH/8)),axi4_slave_awsize);
          $stop;
         end 

	  if(axi4_slave_awburst !== chkr_awburst)
         begin 
	      $display ($time, " S2MM AXI4 MM Initiator awburst is not correct. Expected =%x Received =%x\n",chkr_awburst,axi4_slave_awburst);
          $stop;
         end 

	  if(chkr_awburst[1])
         begin 
	      $display ($time, " Invalid burst type configured for S2MM AXI4 MM Initiator. Expected either Fixed or INCR. Received =%x\n",chkr_awburst);
          $stop;
         end 

	end 
  	
	
always@(posedge clk or negedge arst_n)
  if(~arst_n)
    total_byte_cnt <= 0;
  else if(s2mm_cmd_rdreq_f1)
    total_byte_cnt <= 0;
  else if(axi4_slave_wvalid & axi4_slave_wready)
    total_byte_cnt <= total_byte_cnt + (DATA_WIDTH/8);
	
assign last_byte = len_byte - total_byte_cnt;

always@(*)
  begin 
    if(axi4_slave_wvalid & axi4_slave_wready)
	  begin 
	    if(axi4_slave_wlast & (last_byte != 0) & (remaining_len == 0))
		  begin 
		    chkr_wstrb            = {(DATA_WIDTH/8){1'b0}};
            chkr_wstrb[last_byte] = 1'b1;
	        chkr_wstrb            = chkr_wstrb - 1'b1;
		  end 
		else 
		  chkr_wstrb = {(DATA_WIDTH/8){1'b1}};
	  end 
		  
  end 

	
assign s2mm_rdata = s2mm_mem[s2mm_raddr];

always@(posedge clk or negedge arst_n)
  if(~arst_n)
    s2mm_waddr <= 0;
  else if(axi4s_data_cmp)
    s2mm_waddr <= 0;
  else if(axi4s_i_tvalid & axi4s_i_tready)
    s2mm_waddr <= s2mm_waddr + 1'b1;

always@(posedge clk or negedge arst_n)
  if(~arst_n)
    s2mm_raddr <= 0;
  else if(txn_done)
    s2mm_raddr <= 0;
  else if(axi4_slave_wvalid & axi4_slave_wready)
    s2mm_raddr <= s2mm_raddr + 1'b1;

always@(posedge clk)
  if(axi4s_i_tvalid & axi4s_i_tready)
    s2mm_mem[s2mm_waddr] <= s2mm_chkr_wdata_end_conv;
	
	
always@(posedge clk)
  if(axi4_slave_wvalid & axi4_slave_wready)	
    begin 
      if(axi4_slave_wstrb !== chkr_wstrb)
	    begin 
	      $display ($time," Write Strobe mismatch found.Expected = %x Received = %x\n",chkr_wstrb,axi4_slave_wstrb);
	      #200;
		  $stop;
		end 
	end 
	
always@(posedge clk)
  if(axi4_slave_wvalid & axi4_slave_wready)	
    begin 
	  for(i=0;i<(DATA_WIDTH/8);i=i+1)
	    begin 
	      if(axi4_slave_wstrb[i])
		    begin 
			  if(axi4_slave_wdata[8*i +: 8] !== s2mm_rdata[8*i +: 8])
			    begin 
				  $display ($time," Data mismatch found at location = %d, Expected = %x Received = %x\n",i,s2mm_rdata[i*8 +: 8],axi4_slave_wdata[i*8 +: 8] );
				  #200
				  $stop;
				end 
			end 
		end 		  
	end 
	
	
   // Address register of S2MM_AXI4L_TRGT
   // Write address channel of axi4-lite
   // Valid address : Register name
   // 'h00          : S2MM control register    
   // 'h04          : S2MM status register
   // 'h08          : S2MM length register
   // 'h10          : S2MM address0 register
   // 'h0C          : S2MM address1 register
   always@(posedge clk or negedge arst_n)
     if(~arst_n)
       axi4l_awaddr_reg <= 0;
     else if(axi4l_awvalid & axi4l_awready)
       axi4l_awaddr_reg <= axi4l_awaddr;
   
   // Address register of S2MM_AXI4L_TRGT
   // Read address channel of axi4-lite
   // Valid address : Register name
   // 'h00          : S2MM control register    
   // 'h04          : S2MM status register
   // 'h08          : S2MM length register
   // 'h10          : S2MM address0 register
   // 'h0C          : S2MM address1 register   
   
   // S2MM control register write happen
   always@(*)
     if(axi4l_wvalid & axi4l_wready & (axi4l_awaddr_reg == S2MM_CNTRLREG))       //  axi4l_awaddr_reg == S2MM control register address 
       begin 
   	  for(i=0; i<4; i=i+1)
   	    if(axi4l_wstrb[i])
   		  ctrl_reg[8*i +: 8] <= axi4l_wdata[8*i +: 8];
   	end 
     else 
       ctrl_reg[0] <= 1'b0;
   
   
   // S2MM length register write happen
   always@(*)
    if(axi4l_wvalid & axi4l_wready & (axi4l_awaddr_reg == S2MM_LENGTHREG))        //  axi4l_awaddr_reg == S2MM length register address                 
       begin 
   	  for(i=0; i<4; i=i+1)
   	    if(axi4l_wstrb[i])
   		  len_reg[8*i +: 8] <= axi4l_wdata[8*i +: 8];
   	end 
   
   
   // S2MM address0 register write happen
   always@(*)
     if(axi4l_wvalid & axi4l_wready & (axi4l_awaddr_reg == S2MM_ADDRREG0))      //  axi4l_awaddr_reg == S2MM address0 register address
       begin 
   	  for(i=0; i<4; i=i+1)
   	    if(axi4l_wstrb[i])
   		  addr_reg0[8*i +: 8] <= axi4l_wdata[8*i +: 8];
   	end 
   
   
   // S2MM address1 register write happen
   always@(*)
    if(axi4l_wvalid & axi4l_wready & (axi4l_awaddr_reg == S2MM_ADDRREG1))       //  axi4l_awaddr_reg == S2MM address1 register address 
       begin 
   	  for(i=0; i<4; i=i+1)
   	    if(axi4l_wstrb[i])
   		  addr_reg1[8*i +: 8] <= axi4l_wdata[8*i +: 8];
   	end 		  
   always@(*)
     if((remaining_len <= DATA_WIDTH/8) & axi4_slave_awvalid & axi4_slave_awready)
	   txn_done_ctrl = 1'b1;
	 else if(txn_done)
	   txn_done_ctrl = 1'b0;
   // AXI4 Initiator Write Interface Ports (S2MM_AXI4MM_INITR)
   // S2MM AXI4 interface is done with transmission 
   always@(posedge clk or negedge arst_n)
     if(~arst_n)
       txn_done <= 0;
     else if(axi4_slave_wvalid & axi4_slave_wready & axi4_slave_wlast & ((remaining_len == 0) | txn_done_ctrl))
       txn_done <= 1;
     else 
   	   txn_done <= 0;
   
   // Command/transaction counter
   // It will increment after every transaction end 
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
   	     
		 // S2MM Command write address 
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             s2mm_cmd_waddr <= 0;
           else if(ctrl_reg[0])
             s2mm_cmd_waddr <= s2mm_cmd_waddr + 1'b1;  
   		 
		 // S2MM Command read request static
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             s2mm_cmd_rdreq_static <= 0;
           else if(ctrl_reg[0])
             s2mm_cmd_rdreq_static <= 1;	
   		   else if(cmd_cntr == num_of_cmd)
   		     s2mm_cmd_rdreq_static <= 0;
   		 
		 // S2MM Command read request static regiter 
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             s2mm_cmd_rdreq_static_f1 <= 0;
           else 
             s2mm_cmd_rdreq_static_f1 <= s2mm_cmd_rdreq_static;		  
         
		 // S2MM command read request generate
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             s2mm_cmd_rdreq <= 0;
		   else if((cmd_cntr == (num_of_cmd-1)) & txn_done)
		     s2mm_cmd_rdreq <= 0;
           else if((s2mm_cmd_rdreq_static & ~s2mm_cmd_rdreq_static_f1) | txn_done)
             s2mm_cmd_rdreq <= 1;		  
   		   else 
   		     s2mm_cmd_rdreq <= 0;		  
   		 
		 // S2MM command read request f2 and S2MM command read request f1
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             {s2mm_cmd_rdreq_f2,s2mm_cmd_rdreq_f1} <= 0;
           else 
             {s2mm_cmd_rdreq_f2,s2mm_cmd_rdreq_f1} <= {s2mm_cmd_rdreq_f1,s2mm_cmd_rdreq};
   		 
		 // S2MM command read address
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             s2mm_cmd_raddr <= 0;
           else if(s2mm_cmd_rdreq_f2)
             s2mm_cmd_raddr <= s2mm_cmd_raddr + 1'b1;			
         
		 // S2MM command read data
         assign s2mm_cmd_rdata = s2mm_cmd_mem[s2mm_cmd_raddr];
   	     
		 // Packet size 
         always@(posedge clk or negedge arst_n)
           if(~arst_n)
             pkt_size <= 0;
           else if(s2mm_cmd_rdreq_f1)
             pkt_size <= s2mm_cmd_rdata[40:25];
   		
		 // AXI4 Stream initiator enable 
   	     assign axi4s_initr_en = s2mm_cmd_rdreq_f2;
   	  
	  // Register stored into memory 
   	  if(ADDR_WIDTH > 32)
   	    begin 
   		  always@(posedge clk)
               if(ctrl_reg[0])
                 s2mm_cmd_mem[s2mm_cmd_waddr] <= {addr_reg1,addr_reg0,len_reg,ctrl_reg[25:1]};        // If Address width is > 'd32  
   		end 
   	  else 
   	    begin 
   		  always@(posedge clk)
               if(ctrl_reg[0])
                 s2mm_cmd_mem[s2mm_cmd_waddr] <= {addr_reg0,len_reg,ctrl_reg[25:1]};                  // If Address width is < 'd32
   		end 	  
       end 	
   endgenerate	
   
   
   //AXI4 Protocol validation 
   reg                      awvalid_reg;
   reg [ADDR_WIDTH-1:0]     awaddr_reg;
   reg [7:0]                awlen_reg;
   reg [1:0]                awburst_reg;
   
   reg                      wvalid_reg;
   reg [DATA_WIDTH-1:0]     wdata_reg;
   reg [(DATA_WIDTH/8)-1:0] wstrb_reg;
   reg                      wlast_reg;
   
   reg                      bvalid_reg;
   
   always@(posedge clk)
   begin
     if(axi4_slave_awvalid & ~axi4_slave_awready)
       begin 
         awvalid_reg <= 1'b1;
   	  awaddr_reg  <= axi4_slave_awaddr;
   	  awlen_reg   <= axi4_slave_awlen;
   	  awburst_reg <= axi4_slave_awburst;
   	end 
     else if(axi4_slave_awvalid & axi4_slave_awready)
       begin 
         awvalid_reg <= 1'b0;
   	  awaddr_reg  <= 0;
   	  awlen_reg   <= 0;
   	  awburst_reg <= 0;
       end 
   	
     if(axi4_slave_wvalid & ~axi4_slave_wready)	
       begin
   	  wvalid_reg  <= axi4_slave_wvalid;
   	  wdata_reg   <= axi4_slave_wdata;
   	  wstrb_reg   <= axi4_slave_wstrb;
   	  wlast_reg   <= axi4_slave_wlast;
   	end 
     else if(axi4_slave_wvalid & axi4_slave_wready)	
       begin 
   	  wvalid_reg  <= 0;
   	  wdata_reg   <= 0;
   	  wstrb_reg   <= 0;
   	  wlast_reg   <= 0;
   	end 
   	  
     if(axi4_slave_bvalid & ~axi4_slave_bready)	  
       bvalid_reg  <= axi4_slave_bvalid;
     else if (axi4_slave_bvalid & axi4_slave_bready)	   
   	bvalid_reg  <= 0;
   end	
   	
   always@(*)
     begin 
       if(awvalid_reg & ~axi4_slave_awvalid & ~axi4_slave_awready)
         begin 
   	       $display ($time, " Error: AWVALID change before AWREADY \n");
           $stop;
         end 
   
       if((awaddr_reg != axi4_slave_awaddr) & awvalid_reg & axi4_slave_awvalid & ~axi4_slave_awready)
         begin 
   	       $display ($time, " Error: AWADDR change before AWREADY \n");
           $stop;
         end 
   
       if((awlen_reg != axi4_slave_awlen) & awvalid_reg & axi4_slave_awvalid & ~axi4_slave_awready)
         begin 
   	       $display ($time, " Error: AWLEN change before AWREADY \n");
           $stop;
         end 
   
       if((awburst_reg != axi4_slave_awburst) & awvalid_reg & axi4_slave_awvalid & ~axi4_slave_awready)
         begin 
   	       $display ($time, " Error: AWBURST change before AWREADY \n");
           $stop;
         end 
   
       if(wvalid_reg & ~axi4_slave_wvalid & ~axi4_slave_wready)
         begin 
   	       $display ($time, " Error: WVALID change before WREADY \n");
           $stop;
         end 
   
       if((wdata_reg != axi4_slave_wdata) & wvalid_reg & axi4_slave_wvalid & ~axi4_slave_wready)
         begin 
   	       $display ($time, " Error: WDATA change before WREADY \n");
           $stop;
         end 
   
       if((wstrb_reg != axi4_slave_wstrb) & wvalid_reg & axi4_slave_wvalid & ~axi4_slave_wready)
         begin 
   	       $display ($time, " Error: WSTRB change before WREADY \n");
		   #200;
           $stop;
         end 
   
       if((wlast_reg != wlast_reg) & wvalid_reg & axi4_slave_wvalid & ~axi4_slave_wready)
         begin 
   	       $display ($time, " Error: WLAST change before WREADY \n");
           $stop;
         end 
   
       if(bvalid_reg & ~axi4_slave_bvalid & ~axi4_slave_bready)
         begin 
   	       $display ($time, " Error: BVALID change before BREADY \n");
           $stop;
         end 
   
     end   
endmodule 