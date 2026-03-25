`timescale 1ns / 100ps

module axi4mm_trgt_model #
(
  parameter [0:0]     S2MM_ENABLE      = 1,  
  parameter [0:0]     MM2S_ENABLE      = 1,
  parameter           DATA_WIDTH       = 32,
  parameter           ADDR_WIDTH       = 32,
  parameter           MM2S_DATA_WIDTH  = 32,
  parameter           MM2S_ADDR_WIDTH  = 32  
)
(

  input                            clk,
  input                            arst_n,
					               
  input                            axi4_slave_awid,
  input [ADDR_WIDTH - 1:0]         axi4_slave_awaddr,     
  input [7:0]                      axi4_slave_awlen,      
  input [2:0]                      axi4_slave_awsize,     
  input [1:0]                      axi4_slave_awburst,    
  input                            axi4_slave_awvalid,    
  output                           axi4_slave_awready,    
							       
  input [DATA_WIDTH - 1: 0]        axi4_slave_wdata,
  input [(DATA_WIDTH/8)-1:0]       axi4_slave_wstrb,
  input                            axi4_slave_wlast,
  input                            axi4_slave_wvalid,     
  output                           axi4_slave_wready,
					               
  output                           axi4_slave_bid,
  output [1:0]                     axi4_slave_bresp,
  output reg                       axi4_slave_bvalid,
  input                            axi4_slave_bready,
					               
  input                            axi4_slave_arid,
  input [MM2S_ADDR_WIDTH- 1:0]     axi4_slave_araddr,
  input [7:0]                      axi4_slave_arlen,
  input [2:0]                      axi4_slave_arsize,
  input [1:0]                      axi4_slave_arburst,
  input                            axi4_slave_arvalid,
  output                           axi4_slave_arready,
					               
  output [MM2S_DATA_WIDTH - 1:0]   axi4_slave_rdata,
  output reg                       axi4_slave_rlast,
  output                           axi4_slave_rvalid,
  input                            axi4_slave_rready,
  output                           axi4_slave_rid,
  output [1:0]                     axi4_slave_rresp,
					               
  output reg [15:0]                pkt_mem_rdaddr,  
  input  [DATA_WIDTH-1:0]          pkt_mem_rddata,
  input                            pkt_mem_clr,
							       
  input                            axi4_write_error_en,
  input                            axi4_read_error_en
);

  reg         awready_en;
  reg         wready_ctrl;
  reg         rvalid_en;
  reg         arready_en;
  reg [7:0]   axi4_word_cnt;
  reg         rvalid_ctrl;  
  reg         axi4_slave_err_resp;
  reg         axi4_slave_wrerr_resp;
  reg [7:0]   arlen_reg;

  
  integer    i;

generate 
  if(S2MM_ENABLE)
    begin   
      always@(posedge clk or negedge arst_n)
        if(~arst_n)
	      awready_en <= 1'b0;
	    else 
	      awready_en <= {$random} % 2;
      
      always@(posedge clk or negedge arst_n)
        if(~arst_n)
	      wready_ctrl <= 1'b0;
	    else 
	      wready_ctrl <= {$random} % 2; 
      
      assign axi4_slave_awready = awready_en;
      assign axi4_slave_wready  = wready_ctrl;

      always@(posedge clk or negedge arst_n)
        if(~arst_n)
          axi4_slave_wrerr_resp <= 0;
        else if(axi4_write_error_en)
          begin 
            if(axi4_slave_wvalid & axi4_slave_wready & axi4_slave_wlast)
      	      axi4_slave_wrerr_resp <= 1;
      	    else if(axi4_slave_bvalid & axi4_slave_bready)
              axi4_slave_wrerr_resp <= 0;
          end
        else 
          axi4_slave_wrerr_resp <= 1'b0;  

      assign axi4_slave_bid        = 0;
      assign axi4_slave_bresp[1]   = axi4_slave_wrerr_resp;  
      assign axi4_slave_bresp[0]   = 0;  
  
      always@(posedge clk or negedge arst_n)
        if(~arst_n)
	      axi4_slave_bvalid <= 1'b0;
	    else if(axi4_slave_bvalid & axi4_slave_bready)
	      axi4_slave_bvalid <= 1'b0;
	    else if(axi4_slave_wvalid & axi4_slave_wready & axi4_slave_wlast)
          axi4_slave_bvalid <= 1'b1;	      
	end 
endgenerate	
 
generate 
  if(MM2S_ENABLE)
    begin 
      always@(posedge clk or negedge arst_n)
        if(~arst_n)
          arlen_reg <= 0;
        else if(axi4_slave_arvalid & axi4_slave_arready)
          arlen_reg <= axi4_slave_arlen;
  
      always@(posedge clk or negedge arst_n)
        if(~arst_n)
          pkt_mem_rdaddr <= 0;
        else if(pkt_mem_clr)
          pkt_mem_rdaddr <= 0;
        else if(axi4_slave_rvalid & axi4_slave_rready)
          pkt_mem_rdaddr <= pkt_mem_rdaddr+1;  
  
      always@(posedge clk or negedge arst_n)
        if(~arst_n)
          rvalid_en <= 0;
        else if(axi4_slave_rvalid & axi4_slave_rready & axi4_slave_rlast)
          rvalid_en <= 1'b0;
        else if(axi4_slave_arvalid & axi4_slave_arready)
          rvalid_en <= 1;
  
      always@(posedge clk or negedge arst_n)
        if(~arst_n)
    	  arready_en <= 1'b0;
    	else 
    	  arready_en <= {$random} % 2;

      always@(posedge clk or negedge arst_n)
        if(~arst_n)
          rvalid_ctrl <= 1'b0;
        else if(axi4_slave_rready)
          rvalid_ctrl <= {$random} % 2;
        else 
	      rvalid_ctrl <= 1'b1;
  
      always@(posedge clk)
        if(axi4_read_error_en & axi4_slave_rvalid & axi4_slave_rready)
          axi4_slave_err_resp <= {$random} % 3;  
        else 
          axi4_slave_err_resp <= 0;
	  
      assign axi4_slave_arready  = arready_en;
      assign axi4_slave_rid      = 0;
      assign axi4_slave_rresp[1] = axi4_read_error_en ? axi4_slave_err_resp : 0;
      assign axi4_slave_rresp[0] = 0;
      assign axi4_slave_rvalid   = rvalid_en ? rvalid_ctrl : 1'b0;
      assign axi4_slave_rdata    = pkt_mem_rddata;

      always@(posedge clk or negedge arst_n)
        if(~arst_n)
          axi4_slave_rlast <= 0;
        else if(axi4_slave_rvalid & axi4_slave_rready & axi4_slave_rlast)
          axi4_slave_rlast <= 1'b0;
        else if(((axi4_word_cnt == arlen_reg-1) & axi4_slave_rvalid & axi4_slave_rready) | (axi4_slave_arvalid & axi4_slave_arready & (axi4_slave_arlen == 0)))
          axi4_slave_rlast <= 1; 
     	  
      always@(posedge clk or negedge arst_n)
        if(~arst_n)
          axi4_word_cnt <= 0;
        else if(axi4_slave_arvalid & axi4_slave_arready)
          axi4_word_cnt <= 0;
        else if(axi4_slave_rvalid & axi4_slave_rready)
          axi4_word_cnt <= axi4_word_cnt + 1'b1;		  
    end 
endgenerate	  
endmodule 