module buffer_mem #
(
  parameter     DATA_WIDTH = 32
)
(
  input                   clk,   
  input                   wren,  
  input  [15:0]           wraddr,
  input  [DATA_WIDTH-1:0] wrdata,
  input  [15:0]           rdaddr,
  output [DATA_WIDTH-1:0] rddata
);

reg [DATA_WIDTH-1:0] mem [65535:0];

assign rddata = mem[rdaddr];

always@(posedge clk)
  if(wren)
    mem[wraddr] <= wrdata;
	
endmodule 