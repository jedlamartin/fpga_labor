`timescale 1ns / 100ps

module axi4s_initr_model #
(
  parameter         DATA_WIDTH = 32
)
(
  input                       clk,
  input                       arst_n,             
				              
  output reg                  axi4s_i_tvalid,             
  input                       axi4s_i_tready,            
  output reg                  axi4s_i_tlast,             
  output     [DATA_WIDTH-1:0] axi4s_i_tdata,             
 	
  input                       axi4s_initr_en,
  output reg [15:0]           pkt_mem_rdaddr,           
  input      [DATA_WIDTH-1:0] pkt_mem_rddata,
  input      [2:0]            num_of_cmd, 
  input      [15:0]           pkt_size 
);

  reg                         axi4s_initr_start;
  reg [15:0]                  len_cnt;
  reg [15:0]                  pkt_size_adj;
  
  localparam ADDR_LSB_POS   = $clog2(DATA_WIDTH)-3;
  

  always@(*)
	if(pkt_size[ADDR_LSB_POS-1:0] != 0)
	  pkt_size_adj = pkt_size + (DATA_WIDTH/8);
	else 
	  pkt_size_adj = pkt_size;
	  
  always@(*)
	if((len_cnt >= (pkt_size_adj[15:ADDR_LSB_POS]-1)) & axi4s_i_tready & axi4s_i_tvalid)
	  axi4s_i_tlast = 1;
	else 
	  axi4s_i_tlast = 0;
	  
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
	  axi4s_i_tvalid <= 0;
	else if(axi4s_i_tlast & axi4s_i_tready & axi4s_i_tvalid)
	  axi4s_i_tvalid <= 0;
	else if(axi4s_initr_start)
	  axi4s_i_tvalid <= 1;
  
  assign axi4s_i_tdata   = pkt_mem_rddata;

 
  always@(posedge clk or negedge arst_n)
    if(~arst_n)
	  pkt_mem_rdaddr <= 0;
	else if(axi4s_initr_start)
	  begin
        if(axi4s_i_tready & axi4s_i_tvalid)	  
	      pkt_mem_rdaddr <= pkt_mem_rdaddr + 1;
	  end 
    else 
      pkt_mem_rdaddr <= 0;	


  always@(posedge clk or negedge arst_n)
    if(~arst_n)
	  axi4s_initr_start <= 0;
	else if(axi4s_i_tready & axi4s_i_tvalid & axi4s_i_tlast)
	  axi4s_initr_start <= 0;
	else if(axi4s_initr_en)
	  axi4s_initr_start <= 1;

  always@(posedge clk or negedge arst_n)
    if(~arst_n)
	  len_cnt <= 0;
	else if(axi4s_i_tlast & axi4s_i_tready & axi4s_i_tvalid)
      len_cnt <= 0;
	else if(axi4s_initr_start & axi4s_i_tready & axi4s_i_tvalid)
	  len_cnt <= len_cnt + 1; 
	  	  
endmodule 