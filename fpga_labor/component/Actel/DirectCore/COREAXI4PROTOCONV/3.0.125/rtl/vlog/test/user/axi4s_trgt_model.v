`timescale 1ns / 100ps

module axi4s_trgt_model
 #(
   parameter   DATA_WIDTH  =  32
 )  
(
  input                          clk,
  input                          arst_n,             
				                 
  input                          axi4s_t_tvalid,             
  output reg                     axi4s_t_tready,            
  input                          axi4s_t_tlast,             
  input      [DATA_WIDTH - 1:0]  axi4s_t_tdata,             
  input      [3:0]               axi4s_t_tkeep,
  input                          axi4s_tready_en
 	
);

  always@(posedge clk or negedge arst_n)
    if(~arst_n)
	  axi4s_t_tready <= 1'b0;
	else if(axi4s_tready_en)
	  axi4s_t_tready <= {$random} % 2;
	else 
	  axi4s_t_tready <= 1'b0;
      
	  	  
endmodule 