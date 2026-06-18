// ----------------------------------------------------------------------------
// Smart High-Level Synthesis Tool Version 2025.2
// Copyright (c) 2015-2025 Microchip Technology Inc. All Rights Reserved.
// For support, please visit https://onlinedocs.microchip.com/v2/keyword-lookup?keyword=techsupport&redirect=true&version=latest.
// Date: Thu Jun 11 22:28:55 2026
// ----------------------------------------------------------------------------
`define MEMORY_CONTROLLER_ADDR_SIZE 32
//
// NOTE:// If you take this code outside the SmartHLS directory structure
// into your own, then you should adjust this constant accordingly.
// E.g. for simulation on Modelsim:
//		vlog +define+MEM_INIT_DIR=/path/to/rtl/mem_init/ fir_hls.v  ...
//
`ifndef MEM_INIT_DIR
`define MEM_INIT_DIR "../hdl/"
`endif


`timescale 1 ns / 1 ns


module fir_hw_top
(
  input  clk,
  input  reset,

  output                          axi4target_arready,
  input                           axi4target_arvalid,
  input  [12 - 1:0] axi4target_araddr,
  input  [1 - 1:0] axi4target_arid,
  input  [1:0]                    axi4target_arburst,
  input  [7:0]                    axi4target_arlen,
  input  [2:0]                    axi4target_arsize,
  input  [3:0]                    axi4target_arcache,
  input  [1:0]                    axi4target_arlock,
  input  [2:0]                    axi4target_arprot,
  input  [3:0]                    axi4target_arqos,
  input  [3:0]                    axi4target_arregion,
  input  [0:0]                    axi4target_aruser,

  input                           axi4target_rready,
  output                          axi4target_rvalid,
  output [64 - 1:0] axi4target_rdata,
  output [1 - 1:0] axi4target_rid,
  output                          axi4target_rlast,
  output [1:0]                    axi4target_rresp,
  output [0:0]                    axi4target_ruser,

  output                          axi4target_awready,
  input                           axi4target_awvalid,
  input  [12 - 1:0] axi4target_awaddr,
  input  [1 - 1:0] axi4target_awid,
  input  [1:0]                    axi4target_awburst,
  input  [7:0]                    axi4target_awlen,
  input  [2:0]                    axi4target_awsize,
  input  [3:0]                    axi4target_awcache,
  input  [1:0]                    axi4target_awlock,
  input  [2:0]                    axi4target_awprot,
  input  [3:0]                    axi4target_awqos,
  input  [3:0]                    axi4target_awregion,
  input  [0:0]                    axi4target_awuser,

  output                          axi4target_wready,
  input                           axi4target_wvalid,
  input  [64 - 1:0] axi4target_wdata,
  input                           axi4target_wlast,
  input  [64/8 - 1:0] axi4target_wstrb,
  input  [0:0]                    axi4target_wuser,

  output                          axi4target_bvalid,
  input                           axi4target_bready,
  output [1 - 1:0] axi4target_bid,
  output [1:0]                    axi4target_bresp,
  output [0:0]                    axi4target_buser,
  input  start,
  output reg  ready,
  output reg  finish,
  input [23:0] input_l,
  output reg  input_l_ready,
  input  input_l_valid,
  input [23:0] input_r,
  output reg  input_r_ready,
  input  input_r_valid,
  output reg [31:0] res_data,
  input  res_ready,
  output reg  res_valid,
  output reg [7:0] res_last,
  output reg [3:0] res_keep
);


localparam ADDR_WIDTH = 12;
localparam AXI_DATA_WIDTH = 64;
localparam AXI_ID_WIDTH = 1;
localparam RAM_DATA_WIDTH = 32;
localparam NUM_RAM = 1;
localparam [3 * NUM_RAM - 1:0] RAM_DATA_SIZES = {3'd2};
localparam [NUM_RAM * ADDR_WIDTH - 1:0] RAM_ADDR_OFFSET = {12'h40};
localparam [NUM_RAM * ADDR_WIDTH - 1:0] RAM_ADDR_RANGE = {12'h800};
localparam [NUM_RAM * 2 - 1:0] RAM_CONFIG = {2'd0};
localparam [NUM_RAM - 1:0] USES_BYTE_ENABLES = 1'b1;
localparam [NUM_RAM - 1:0] COALESCE_SAME_WORD_WRITES = 1'b0;
localparam [NUM_RAM - 1:0] USES_ACTGENO = 1'b0;
localparam NUM_ARG_WORDS = 3;
localparam RAM_WSTRB_WIDTH = RAM_DATA_WIDTH/8;

localparam AXI_RRESP_ALWAYS_ZERO = 0;

// Accelerator side interface.
wire [NUM_ARG_WORDS * 32 - 1:0] arguments;

wire [NUM_RAM                   - 1:0] accel_clken;
wire [NUM_RAM * ADDR_WIDTH      - 1:0] accel_address_a;
wire [NUM_RAM * ADDR_WIDTH      - 1:0] accel_address_b;
wire [NUM_RAM                   - 1:0] accel_read_en_a;
wire [NUM_RAM                   - 1:0] accel_read_en_b;
wire [NUM_RAM                   - 1:0] accel_write_en_a;
wire [NUM_RAM                   - 1:0] accel_write_en_b;
wire [NUM_RAM * RAM_WSTRB_WIDTH - 1:0] accel_byte_en_a;
wire [NUM_RAM * RAM_WSTRB_WIDTH - 1:0] accel_byte_en_b;
wire [NUM_RAM * RAM_DATA_WIDTH  - 1:0] accel_write_data_a;
wire [NUM_RAM * RAM_DATA_WIDTH  - 1:0] accel_write_data_b;
wire [NUM_RAM * RAM_DATA_WIDTH  - 1:0] accel_read_data_a;
wire [NUM_RAM * RAM_DATA_WIDTH  - 1:0] accel_read_data_b;


reg accel_active;
always @ (posedge clk) begin
  if (reset)       accel_active <= 0;
  else if (start)  accel_active <= 1;
  else if (finish) accel_active <= 0;
end


fir_hw_axi4slv # (
  .ENABLE_ACCEL_CTRL (0),
  .ADDR_WIDTH (ADDR_WIDTH),
  .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
  .AXI_ID_WIDTH (AXI_ID_WIDTH),
  .RAM_DATA_WIDTH (RAM_DATA_WIDTH),
  .NUM_RAM (NUM_RAM),
  .READ_LATENCY (1),
  .RAM_DATA_SIZES (RAM_DATA_SIZES),
  .RAM_ADDR_OFFSET (RAM_ADDR_OFFSET),
  .RAM_ADDR_RANGE (RAM_ADDR_RANGE),
  .RAM_CONFIG (RAM_CONFIG),
  .USES_BYTE_ENABLES (USES_BYTE_ENABLES),
  .COALESCE_SAME_WORD_WRITES (COALESCE_SAME_WORD_WRITES),
  .USES_ACTGENO (USES_ACTGENO),
  .NUM_ARG_WORDS (NUM_ARG_WORDS),
  .AXI_RRESP_ALWAYS_ZERO (AXI_RRESP_ALWAYS_ZERO)
) axi4slv_inst (
  .clk (clk),
  .reset (reset),
  .accel_active (accel_active),

  .axi4target_arready (axi4target_arready),
  .axi4target_arvalid (axi4target_arvalid),
  .axi4target_araddr (axi4target_araddr),
  .axi4target_arid (axi4target_arid),
  .axi4target_arburst (axi4target_arburst),
  .axi4target_arlen (axi4target_arlen),
  .axi4target_arsize (axi4target_arsize),
  .axi4target_arcache (axi4target_arcache),
  .axi4target_arlock (axi4target_arlock),
  .axi4target_arprot (axi4target_arprot),
  .axi4target_arqos (axi4target_arqos),
  .axi4target_arregion (axi4target_arregion),
  .axi4target_aruser (axi4target_aruser),

  .axi4target_rready (axi4target_rready),
  .axi4target_rvalid (axi4target_rvalid),
  .axi4target_rdata (axi4target_rdata),
  .axi4target_rid (axi4target_rid),
  .axi4target_rlast (axi4target_rlast),
  .axi4target_rresp (axi4target_rresp),
  .axi4target_ruser (axi4target_ruser),

  .axi4target_awready (axi4target_awready),
  .axi4target_awvalid (axi4target_awvalid),
  .axi4target_awaddr (axi4target_awaddr),
  .axi4target_awid (axi4target_awid),
  .axi4target_awburst (axi4target_awburst),
  .axi4target_awlen (axi4target_awlen),
  .axi4target_awsize (axi4target_awsize),
  .axi4target_awcache (axi4target_awcache),
  .axi4target_awlock (axi4target_awlock),
  .axi4target_awprot (axi4target_awprot),
  .axi4target_awqos (axi4target_awqos),
  .axi4target_awregion (axi4target_awregion),
  .axi4target_awuser (axi4target_awuser),

  .axi4target_wready (axi4target_wready),
  .axi4target_wvalid (axi4target_wvalid),
  .axi4target_wdata (axi4target_wdata),
  .axi4target_wlast (axi4target_wlast),
  .axi4target_wstrb (axi4target_wstrb),
  .axi4target_wuser (axi4target_wuser),

  .axi4target_bvalid (axi4target_bvalid),
  .axi4target_bready (axi4target_bready),
  .axi4target_bid (axi4target_bid),
  .axi4target_bresp (axi4target_bresp),
  .axi4target_buser (axi4target_buser),

  .arguments (arguments),
  .return_val (64'b0),

  .accel_clken (accel_clken),
  .accel_address_a (accel_address_a),
  .accel_address_b (accel_address_b),
  .accel_write_en_a (accel_write_en_a),
  .accel_write_en_b (accel_write_en_b),
  .accel_byte_en_a (accel_byte_en_a),
  .accel_byte_en_b (accel_byte_en_b),
  .accel_write_data_a (accel_write_data_a),
  .accel_write_data_b (accel_write_data_b),
  .accel_read_data_a (accel_read_data_a),
  .accel_read_data_b (accel_read_data_b)
);

fir_hw_hw_top fir_hw_inst (
  .clk (clk),
  .reset (reset),
  .tlast_dnum (arguments[0 +: 16]),
  .smpl_rd_num (arguments[32 +: 8]),
  .tap_num_m1 (arguments[64 +: 16]),

  .coeff_hw_clken (accel_clken[0]),
  .coeff_hw_address_a (accel_address_a [0 * ADDR_WIDTH +: 9]),
  .coeff_hw_read_en_a (accel_read_en_a [0]),
  .coeff_hw_read_data_a (accel_read_data_a [0 * RAM_DATA_WIDTH +: 32]),
  .coeff_hw_address_b (accel_address_b [0 * ADDR_WIDTH +: 9]),
  .coeff_hw_read_en_b (accel_read_en_b [0]),
  .coeff_hw_read_data_b (accel_read_data_b [0 * RAM_DATA_WIDTH +: 32]),
  .start (start),
  .ready (ready),
  .finish (finish),
  .input_l (input_l),
  .input_l_ready (input_l_ready),
  .input_l_valid (input_l_valid),
  .input_r (input_r),
  .input_r_ready (input_r_ready),
  .input_r_valid (input_r_valid),
  .res_data (res_data),
  .res_ready (res_ready),
  .res_valid (res_valid),
  .res_last (res_last),
  .res_keep (res_keep)
);

endmodule


`timescale 1 ns / 1 ns
module fir_hw_hw_top
(
	clk,
	reset,
	start,
	ready,
	finish,
	tlast_dnum,
	smpl_rd_num,
	tap_num_m1,
	input_l,
	input_l_ready,
	input_l_valid,
	input_r,
	input_r_ready,
	input_r_valid,
	res_data,
	res_ready,
	res_valid,
	res_last,
	res_keep,
	coeff_hw_clken,
	coeff_hw_read_en_a,
	coeff_hw_address_a,
	coeff_hw_read_data_a,
	coeff_hw_read_en_b,
	coeff_hw_address_b,
	coeff_hw_read_data_b
);

input  clk;
input  reset;
input  start;
output reg  ready;
output reg  finish;
input [15:0] tlast_dnum;
input [7:0] smpl_rd_num;
input [15:0] tap_num_m1;
input [23:0] input_l;
output reg  input_l_ready;
input  input_l_valid;
input [23:0] input_r;
output reg  input_r_ready;
input  input_r_valid;
output reg [31:0] res_data;
input  res_ready;
output reg  res_valid;
output reg [7:0] res_last;
output reg [3:0] res_keep;
output reg  coeff_hw_clken;
output reg  coeff_hw_read_en_a;
output reg [8:0] coeff_hw_address_a;
input [31:0] coeff_hw_read_data_a;
output reg  coeff_hw_read_en_b;
output reg [8:0] coeff_hw_address_b;
input [31:0] coeff_hw_read_data_b;
reg  fir_hw_inst_clk;
reg  fir_hw_inst_reset;
reg  fir_hw_inst_start;
wire  fir_hw_inst_ready;
wire  fir_hw_inst_finish;
reg [15:0] fir_hw_inst_tlast_dnum;
reg [7:0] fir_hw_inst_smpl_rd_num;
reg [15:0] fir_hw_inst_tap_num_m1;
reg [23:0] fir_hw_inst_input_l;
wire  fir_hw_inst_input_l_ready;
reg  fir_hw_inst_input_l_valid;
reg [23:0] fir_hw_inst_input_r;
wire  fir_hw_inst_input_r_ready;
reg  fir_hw_inst_input_r_valid;
wire [31:0] fir_hw_inst_res_data;
reg  fir_hw_inst_res_ready;
wire  fir_hw_inst_res_valid;
wire [7:0] fir_hw_inst_res_last;
wire [3:0] fir_hw_inst_res_keep;
wire  fir_hw_inst_coeff_hw_clken;
wire  fir_hw_inst_coeff_hw_read_en_a;
wire [8:0] fir_hw_inst_coeff_hw_address_a;
reg [31:0] fir_hw_inst_coeff_hw_read_data_a;
wire  fir_hw_inst_coeff_hw_read_en_b;
wire [8:0] fir_hw_inst_coeff_hw_address_b;
reg [31:0] fir_hw_inst_coeff_hw_read_data_b;
reg  fir_hw_inst_finish_reg;


fir_hw_fir_hw fir_hw_inst (
	.clk (fir_hw_inst_clk),
	.reset (fir_hw_inst_reset),
	.start (fir_hw_inst_start),
	.ready (fir_hw_inst_ready),
	.finish (fir_hw_inst_finish),
	.tlast_dnum (fir_hw_inst_tlast_dnum),
	.smpl_rd_num (fir_hw_inst_smpl_rd_num),
	.tap_num_m1 (fir_hw_inst_tap_num_m1),
	.input_l (fir_hw_inst_input_l),
	.input_l_ready (fir_hw_inst_input_l_ready),
	.input_l_valid (fir_hw_inst_input_l_valid),
	.input_r (fir_hw_inst_input_r),
	.input_r_ready (fir_hw_inst_input_r_ready),
	.input_r_valid (fir_hw_inst_input_r_valid),
	.res_data (fir_hw_inst_res_data),
	.res_ready (fir_hw_inst_res_ready),
	.res_valid (fir_hw_inst_res_valid),
	.res_last (fir_hw_inst_res_last),
	.res_keep (fir_hw_inst_res_keep),
	.coeff_hw_clken (fir_hw_inst_coeff_hw_clken),
	.coeff_hw_read_en_a (fir_hw_inst_coeff_hw_read_en_a),
	.coeff_hw_address_a (fir_hw_inst_coeff_hw_address_a),
	.coeff_hw_read_data_a (fir_hw_inst_coeff_hw_read_data_a),
	.coeff_hw_read_en_b (fir_hw_inst_coeff_hw_read_en_b),
	.coeff_hw_address_b (fir_hw_inst_coeff_hw_address_b),
	.coeff_hw_read_data_b (fir_hw_inst_coeff_hw_read_data_b)
);



always @(*) begin
	fir_hw_inst_clk = clk;
end
always @(*) begin
	fir_hw_inst_reset = reset;
end
always @(*) begin
	fir_hw_inst_start = start;
end
always @(*) begin
	fir_hw_inst_tlast_dnum = tlast_dnum;
end
always @(*) begin
	fir_hw_inst_smpl_rd_num = smpl_rd_num;
end
always @(*) begin
	fir_hw_inst_tap_num_m1 = tap_num_m1;
end
always @(*) begin
	fir_hw_inst_input_l = input_l;
end
always @(*) begin
	fir_hw_inst_input_l_valid = input_l_valid;
end
always @(*) begin
	fir_hw_inst_input_r = input_r;
end
always @(*) begin
	fir_hw_inst_input_r_valid = input_r_valid;
end
always @(*) begin
	fir_hw_inst_res_ready = res_ready;
end
always @(*) begin
	fir_hw_inst_coeff_hw_read_data_a = coeff_hw_read_data_a;
end
always @(*) begin
	fir_hw_inst_coeff_hw_read_data_b = coeff_hw_read_data_b;
end
always @(posedge clk) begin
	if ((reset | fir_hw_inst_start)) begin
		fir_hw_inst_finish_reg <= 1'd0;
	end
	if (fir_hw_inst_finish) begin
		fir_hw_inst_finish_reg <= 1'd1;
	end
end
always @(*) begin
	ready = fir_hw_inst_ready;
end
always @(*) begin
	finish = fir_hw_inst_finish;
end
always @(*) begin
	input_l_ready = fir_hw_inst_input_l_ready;
end
always @(*) begin
	input_r_ready = fir_hw_inst_input_r_ready;
end
always @(*) begin
	res_data = fir_hw_inst_res_data;
end
always @(*) begin
	res_valid = fir_hw_inst_res_valid;
end
always @(*) begin
	res_last = fir_hw_inst_res_last;
end
always @(*) begin
	res_keep = fir_hw_inst_res_keep;
end
always @(*) begin
	coeff_hw_clken = fir_hw_inst_coeff_hw_clken;
end
always @(*) begin
	coeff_hw_read_en_a = fir_hw_inst_coeff_hw_read_en_a;
end
always @(*) begin
	coeff_hw_address_a = fir_hw_inst_coeff_hw_address_a;
end
always @(*) begin
	coeff_hw_read_en_b = fir_hw_inst_coeff_hw_read_en_b;
end
always @(*) begin
	coeff_hw_address_b = fir_hw_inst_coeff_hw_address_b;
end

endmodule

`timescale 1 ns / 1 ns
module fir_hw_fir_hw
(
	clk,
	reset,
	start,
	ready,
	finish,
	tlast_dnum,
	smpl_rd_num,
	tap_num_m1,
	input_l,
	input_l_ready,
	input_l_valid,
	input_r,
	input_r_ready,
	input_r_valid,
	res_data,
	res_ready,
	res_valid,
	res_last,
	res_keep,
	coeff_hw_clken,
	coeff_hw_read_en_a,
	coeff_hw_address_a,
	coeff_hw_read_data_a,
	coeff_hw_read_en_b,
	coeff_hw_address_b,
	coeff_hw_read_data_b
);

parameter [3:0] SHLS_0 = 4'd0;
parameter [3:0] SHLS_F_fir_hw_BB_0_1 = 4'd1;
parameter [3:0] SHLS_F_fir_hw_BB_0_2 = 4'd2;
parameter [3:0] SHLS_F_fir_hw_BB_1_3 = 4'd3;
parameter [3:0] SHLS_F_fir_hw_BB_1_4 = 4'd4;
parameter [3:0] SHLS_F_fir_hw_BB_2_5 = 4'd5;
parameter [3:0] SHLS_F_fir_hw_BB_2_6 = 4'd6;
parameter [3:0] SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7 = 4'd7;
parameter [3:0] SHLS_F_fir_hw_BB_4_8 = 4'd8;
parameter [3:0] SHLS_F_fir_hw_BB_4_9 = 4'd9;
parameter [3:0] SHLS_F_fir_hw_BB_5_10 = 4'd10;
parameter [3:0] SHLS_F_fir_hw_BB_5_11 = 4'd11;

input  clk;
input  reset;
input  start;
output reg  ready;
output reg  finish;
input [15:0] tlast_dnum;
input [7:0] smpl_rd_num;
input [15:0] tap_num_m1;
input [23:0] input_l;
output  input_l_ready;
input  input_l_valid;
input [23:0] input_r;
output  input_r_ready;
input  input_r_valid;
output reg [31:0] res_data;
input  res_ready;
output reg  res_valid;
output reg [7:0] res_last;
output reg [3:0] res_keep;
output reg  coeff_hw_clken;
output reg  coeff_hw_read_en_a;
output reg [8:0] coeff_hw_address_a;
input [31:0] coeff_hw_read_data_a;
output  coeff_hw_read_en_b;
output [8:0] coeff_hw_address_b;
input [31:0] coeff_hw_read_data_b;
reg [3:0] cur_state/* synthesis syn_encoding="onehot" */;
reg [3:0] next_state;
reg [15:0] tlast_dnum_reg;
reg [7:0] smpl_rd_num_reg;
reg [15:0] tap_num_m1_reg;
reg  fsm_stall;
reg [23:0] fir_hw_BB_0_fifoVal;
reg [8:0] fir_hw_BB_0_load;
reg [8:0] fir_hw_BB_0_load_reg;
reg [8:0] fir_hw_BB_0_bit_concat;
reg [`MEMORY_CONTROLLER_ADDR_SIZE-1:0] fir_hw_BB_0_addr;
reg [23:0] fir_hw_BB_0_fifoVal1;
reg [`MEMORY_CONTROLLER_ADDR_SIZE-1:0] fir_hw_BB_0_addr2;
reg [2:0] fir_hw_BB_0_load3;
reg [2:0] fir_hw_BB_0_add;
reg [2:0] fir_hw_BB_0_bit_concat4;
reg  fir_hw_BB_0_icmp;
reg  fir_hw_BB_0_icmp_reg;
reg [15:0] fir_hw_BB_1_bit_concat5;
reg [15:0] fir_hw_BB_1_bit_concat5_reg;
reg [15:0] fir_hw_BB_2_load6;
reg [15:0] fir_hw_BB_2_add7;
reg  fir_hw_BB_2_icmp8;
reg  fir_hw_BB_2_bit_concat10;
reg [15:0] fir_hw_BB_2_add11;
reg [15:0] fir_hw_BB_2_select;
reg  fir_hw_BB_2_icmp12;
reg  fir_hw_BB_2_icmp12_reg;
reg  fir_hw_BB_2_bit_concat13;
reg  fir_hw_BB_2_bit_concat13_reg;
reg [47:0] fir_hw_BB_3_phi;
reg [47:0] fir_hw_BB_3_phi_reg;
reg [47:0] fir_hw_BB_3_phi14;
reg [47:0] fir_hw_BB_3_phi14_reg;
reg [8:0] fir_hw_BB_3_bit_select17;
reg [8:0] fir_hw_BB_3_sub;
reg [8:0] fir_hw_BB_3_bit_concat18;
reg [`MEMORY_CONTROLLER_ADDR_SIZE-1:0] fir_hw_BB_3_addr19;
reg [23:0] fir_hw_BB_3_load20;
reg [10:0] fir_hw_BB_3_bit_select22;
reg [`MEMORY_CONTROLLER_ADDR_SIZE-1:0] fir_hw_BB_3_addr23;
reg [23:0] fir_hw_BB_3_load24;
reg [10:0] fir_hw_BB_3_bit_select25;
reg [`MEMORY_CONTROLLER_ADDR_SIZE-1:0] fir_hw_BB_3_addr26;
reg [31:0] fir_hw_BB_3_load27;
reg [14:0] fir_hw_BB_3_bit_select28;
reg [16:0] fir_hw_BB_3_bit_select30;
reg [12:0] fir_hw_BB_3_ashr;
reg [12:0] fir_hw_BB_3_bit_select31;
reg [16:0] fir_hw_BB_3_bit_concat32;
reg [16:0] fir_hw_BB_3_bit_concat35;
reg [33:0] fir_hw_BB_3_mul;
reg [16:0] fir_hw_BB_3_bit_concat37;
reg [26:0] fir_hw_BB_3_sext;
reg [31:0] fir_hw_BB_3_mul38;
reg [12:0] fir_hw_BB_3_sext39;
reg [16:0] fir_hw_BB_3_bit_concat40;
reg [29:0] fir_hw_BB_3_mul41;
reg [12:0] fir_hw_BB_3_sext42;
reg [14:0] fir_hw_BB_3_sext43;
reg [27:0] fir_hw_BB_3_mul44;
reg [29:0] fir_hw_BB_3_sext45;
reg [29:0] fir_hw_BB_3_bit_select46;
reg [46:0] fir_hw_BB_3_bit_concat47;
reg [31:0] fir_hw_BB_3_sext48;
reg [27:0] fir_hw_BB_3_sext49;
reg [27:0] fir_hw_BB_3_bit_select50;
reg [44:0] fir_hw_BB_3_bit_concat51;
reg [45:0] fir_hw_BB_3_add52;
reg [45:0] fir_hw_BB_3_bit_select53;
reg [50:0] fir_hw_BB_3_bit_concat54;
reg [46:0] fir_hw_BB_3_sext55;
reg [46:0] fir_hw_BB_3_bit_select56;
reg [63:0] fir_hw_BB_3_bit_concat57;
reg [64:0] fir_hw_BB_3_add58;
reg [64:0] fir_hw_BB_3_sext59;
reg [79:0] fir_hw_BB_3_bit_concat60;
reg [79:0] fir_hw_BB_3_add61;
reg [47:0] fir_hw_BB_3_bit_select62;
reg [47:0] fir_hw_BB_3_add63;
reg [31:0] fir_hw_BB_3_bit_select64;
reg [31:0] fir_hw_BB_3_bit_select64_reg;
reg [12:0] fir_hw_BB_3_ashr65;
reg [12:0] fir_hw_BB_3_bit_select66;
reg [16:0] fir_hw_BB_3_bit_concat67;
reg [33:0] fir_hw_BB_3_mul68;
reg [16:0] fir_hw_BB_3_bit_concat69;
reg [31:0] fir_hw_BB_3_mul70;
reg [12:0] fir_hw_BB_3_sext71;
reg [29:0] fir_hw_BB_3_mul72;
reg [12:0] fir_hw_BB_3_sext73;
reg [27:0] fir_hw_BB_3_mul74;
reg [29:0] fir_hw_BB_3_sext75;
reg [29:0] fir_hw_BB_3_bit_select76;
reg [46:0] fir_hw_BB_3_bit_concat77;
reg [31:0] fir_hw_BB_3_sext78;
reg [27:0] fir_hw_BB_3_sext79;
reg [27:0] fir_hw_BB_3_bit_select80;
reg [44:0] fir_hw_BB_3_bit_concat81;
reg [45:0] fir_hw_BB_3_add82;
reg [45:0] fir_hw_BB_3_bit_select83;
reg [50:0] fir_hw_BB_3_bit_concat84;
reg [46:0] fir_hw_BB_3_sext85;
reg [46:0] fir_hw_BB_3_bit_select86;
reg [63:0] fir_hw_BB_3_bit_concat87;
reg [64:0] fir_hw_BB_3_add88;
reg [64:0] fir_hw_BB_3_sext89;
reg [79:0] fir_hw_BB_3_bit_concat90;
reg [79:0] fir_hw_BB_3_add91;
reg [47:0] fir_hw_BB_3_bit_select;
reg [47:0] fir_hw_BB_3_add92;
reg [31:0] fir_hw_BB_3_bit_select93;
reg [31:0] fir_hw_BB_3_bit_select93_reg;
reg  fir_hw_BB_3_icmp95;
reg [8:0] fir_hw_BB_5_add96;
reg  fir_hw_buffer_left_clken;
reg [8:0] fir_hw_buffer_left_address_a;
reg  fir_hw_buffer_left_write_en_a;
reg [23:0] fir_hw_buffer_left_write_data_a;
wire [23:0] fir_hw_buffer_left_read_data_a;
reg  fir_hw_buffer_left_read_en_a;
reg  fir_hw_buffer_right_clken;
reg [8:0] fir_hw_buffer_right_address_a;
reg  fir_hw_buffer_right_write_en_a;
reg [23:0] fir_hw_buffer_right_write_data_a;
wire [23:0] fir_hw_buffer_right_read_data_a;
reg  fir_hw_buffer_right_read_en_a;
reg [8:0] fir_hw_write_idx_inferred_reg;
reg [15:0] fir_hw_cnt_inferred_reg;
reg [2:0] fir_hw_dec_cnt_inferred_reg;
reg  for_loop_src_fir_hw_cpp_35_9_valid_bit_0;
wire  for_loop_src_fir_hw_cpp_35_9_state_stall_0;
reg  for_loop_src_fir_hw_cpp_35_9_state_enable_0;
reg  for_loop_src_fir_hw_cpp_35_9_valid_bit_1;
wire  for_loop_src_fir_hw_cpp_35_9_state_stall_1;
reg  for_loop_src_fir_hw_cpp_35_9_state_enable_1;
reg  for_loop_src_fir_hw_cpp_35_9_valid_bit_2;
wire  for_loop_src_fir_hw_cpp_35_9_state_stall_2;
reg  for_loop_src_fir_hw_cpp_35_9_state_enable_2;
reg  for_loop_src_fir_hw_cpp_35_9_valid_bit_3;
wire  for_loop_src_fir_hw_cpp_35_9_state_stall_3;
reg  for_loop_src_fir_hw_cpp_35_9_state_enable_3;
reg [1:0] for_loop_src_fir_hw_cpp_35_9_II_counter;
reg  for_loop_src_fir_hw_cpp_35_9_start;
reg  for_loop_src_fir_hw_cpp_35_9_activate_pipeline;
reg [47:0] fir_hw_BB_3_phi_reg_stage1;
reg [47:0] fir_hw_BB_3_phi14_reg_stage1;
reg [44:0] fir_hw_BB_3_bit_concat51_reg_stage1;
reg [64:0] fir_hw_BB_3_sext59_reg_stage1;
reg [47:0] fir_hw_BB_3_add63_reg_stage2;
reg [44:0] fir_hw_BB_3_bit_concat81_reg_stage1;
reg [64:0] fir_hw_BB_3_sext89_reg_stage1;
reg [47:0] fir_hw_BB_3_add92_reg_stage2;
reg [31:0] for_loop_src_fir_hw_cpp_35_9_inductionVar_stage0;
reg  for_loop_src_fir_hw_cpp_35_9_pipeline_exit_cond;
reg  for_loop_src_fir_hw_cpp_35_9_active;
reg  for_loop_src_fir_hw_cpp_35_9_begin_pipeline;
reg  for_loop_src_fir_hw_cpp_35_9_epilogue;
reg  for_loop_src_fir_hw_cpp_35_9_pipeline_finish;
reg  for_loop_src_fir_hw_cpp_35_9_pipeline_finishing;
reg  for_loop_src_fir_hw_cpp_35_9_only_last_stage_enabled;
reg [2:0] for_loop_src_fir_hw_cpp_35_9_num_active_iterations;
reg  for_loop_src_fir_hw_cpp_35_9_inserting_new_iteration;
reg  for_loop_src_fir_hw_cpp_35_9_pipeline_finish_reg;
reg  for_loop_src_fir_hw_cpp_35_9_in_first_iteration_stage0;
reg  input_l_consumed_valid;
reg [23:0] input_l_consumed_data;
reg  input_l_consumed_taken;
wire [22:0] fir_hw_BB_0_bit_concat_bit_select_operand_0;
reg  fir_hw_buffer_left_clken_not_in_pipeline;
reg  fir_hw_buffer_left_clken_sequential_cond;
reg  input_r_consumed_valid;
reg [23:0] input_r_consumed_data;
reg  input_r_consumed_taken;
reg  fir_hw_buffer_right_clken_not_in_pipeline;
reg  fir_hw_buffer_right_clken_sequential_cond;
wire [4:0] fir_hw_BB_0_bit_concat4_bit_select_operand_0;
wire [15:0] fir_hw_BB_1_bit_concat5_bit_select_operand_0;
wire [6:0] fir_hw_BB_2_bit_concat10_bit_select_operand_0;
reg  res_data_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a;
reg  res_data_SHLS_F_fir_hw_BB_2_5_stalln_reg;
reg  res_data_SHLS_F_fir_hw_BB_2_5_enable_cond_a;
reg  res_last_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a;
reg  res_last_SHLS_F_fir_hw_BB_2_5_stalln_reg;
reg  res_last_SHLS_F_fir_hw_BB_2_5_enable_cond_a;
reg  res_keep_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a;
reg  res_keep_SHLS_F_fir_hw_BB_2_5_stalln_reg;
reg  res_keep_SHLS_F_fir_hw_BB_2_5_enable_cond_a;
wire [6:0] fir_hw_BB_2_bit_concat13_bit_select_operand_0;
reg  res_data_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a;
reg  res_data_SHLS_F_fir_hw_BB_2_6_stalln_reg;
reg  res_data_SHLS_F_fir_hw_BB_2_6_enable_cond_a;
reg  res_last_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a;
reg  res_last_SHLS_F_fir_hw_BB_2_6_stalln_reg;
reg  res_last_SHLS_F_fir_hw_BB_2_6_enable_cond_a;
reg  res_keep_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a;
reg  res_keep_SHLS_F_fir_hw_BB_2_6_stalln_reg;
reg  res_keep_SHLS_F_fir_hw_BB_2_6_enable_cond_a;
wire [22:0] fir_hw_BB_3_bit_concat18_bit_select_operand_0;
reg [23:0] fir_hw_buffer_left_read_data_wire_a;
reg  fir_hw_buffer_left_clken_pipeline_cond;
reg [23:0] fir_hw_buffer_right_read_data_wire_a;
reg  fir_hw_buffer_right_clken_pipeline_cond;
reg [31:0] coeff_hw_read_data_wire_a;
reg  coeff_hw_clken_pipeline_cond;
reg [13:0] fir_hw_BB_3_ashr_width_extended;
wire [16:0] fir_hw_BB_3_bit_concat32_bit_select_operand_0;
wire [5:0] fir_hw_BB_3_bit_concat32_bit_select_operand_4;
wire [16:0] fir_hw_BB_3_bit_concat35_bit_select_operand_0;
reg  legup_mult_unsigned_17_17_1_0_clock;
reg  legup_mult_unsigned_17_17_1_0_aclr;
reg  legup_mult_unsigned_17_17_1_0_clken;
reg [16:0] legup_mult_unsigned_17_17_1_0_dataa;
reg [16:0] legup_mult_unsigned_17_17_1_0_datab;
wire [33:0] legup_mult_unsigned_17_17_1_0_result;
reg [33:0] legup_mult_fir_hw_BB_3_mul_out_actual;
reg [33:0] legup_mult_fir_hw_BB_3_mul_out;
reg  legup_mult_fir_hw_BB_3_mul_en;
reg  legup_mult_fir_hw_BB_3_mul_en_pipeline_cond;
wire [15:0] fir_hw_BB_3_bit_concat37_bit_select_operand_0;
wire [5:0] fir_hw_BB_3_bit_concat37_bit_select_operand_4;
reg  legup_mult_unsigned_17_27_2_1_clock;
reg  legup_mult_unsigned_17_27_2_1_aclr;
reg  legup_mult_unsigned_17_27_2_1_clken;
reg [16:0] legup_mult_unsigned_17_27_2_1_dataa;
reg [26:0] legup_mult_unsigned_17_27_2_1_datab;
wire [43:0] legup_mult_unsigned_17_27_2_1_result;
reg [43:0] legup_mult_fir_hw_BB_3_mul38_out_actual;
reg [31:0] legup_mult_fir_hw_BB_3_mul38_out;
reg  legup_mult_fir_hw_BB_3_mul38_en;
reg  legup_mult_fir_hw_BB_3_mul38_en_pipeline_cond;
wire [14:0] fir_hw_BB_3_bit_concat40_bit_select_operand_0;
reg  legup_mult_signed_18_13_1_2_clock;
reg  legup_mult_signed_18_13_1_2_aclr;
reg  legup_mult_signed_18_13_1_2_clken;
reg [17:0] legup_mult_signed_18_13_1_2_dataa;
reg [12:0] legup_mult_signed_18_13_1_2_datab;
wire [30:0] legup_mult_signed_18_13_1_2_result;
reg [30:0] legup_mult_fir_hw_BB_3_mul41_out_actual;
reg [29:0] legup_mult_fir_hw_BB_3_mul41_out;
reg  legup_mult_fir_hw_BB_3_mul41_en;
reg  legup_mult_fir_hw_BB_3_mul41_en_pipeline_cond;
reg  legup_mult_signed_13_15_1_3_clock;
reg  legup_mult_signed_13_15_1_3_aclr;
reg  legup_mult_signed_13_15_1_3_clken;
reg [12:0] legup_mult_signed_13_15_1_3_dataa;
reg [14:0] legup_mult_signed_13_15_1_3_datab;
wire [27:0] legup_mult_signed_13_15_1_3_result;
reg [27:0] legup_mult_fir_hw_BB_3_mul44_out_actual;
reg [27:0] legup_mult_fir_hw_BB_3_mul44_out;
reg  legup_mult_fir_hw_BB_3_mul44_en;
reg  legup_mult_fir_hw_BB_3_mul44_en_pipeline_cond;
reg [32:0] fir_hw_BB_3_sext45_width_extended;
reg [32:0] fir_hw_BB_3_bit_select46_width_extended;
wire [16:0] fir_hw_BB_3_bit_concat47_bit_select_operand_2;
reg [29:0] fir_hw_BB_3_sext49_width_extended;
reg [29:0] fir_hw_BB_3_bit_select50_width_extended;
wire [16:0] fir_hw_BB_3_bit_concat51_bit_select_operand_2;
wire [16:0] fir_hw_BB_3_bit_concat54_bit_select_operand_0;
wire [16:0] fir_hw_BB_3_bit_concat54_bit_select_operand_4;
reg [50:0] fir_hw_BB_3_sext55_width_extended;
reg [50:0] fir_hw_BB_3_bit_select56_width_extended;
wire [16:0] fir_hw_BB_3_bit_concat57_bit_select_operand_2;
wire [33:0] fir_hw_BB_3_bit_concat60_bit_select_operand_2;
reg [13:0] fir_hw_BB_3_ashr65_width_extended;
wire [16:0] fir_hw_BB_3_bit_concat67_bit_select_operand_0;
wire [5:0] fir_hw_BB_3_bit_concat67_bit_select_operand_4;
reg  legup_mult_unsigned_17_17_1_4_clock;
reg  legup_mult_unsigned_17_17_1_4_aclr;
reg  legup_mult_unsigned_17_17_1_4_clken;
reg [16:0] legup_mult_unsigned_17_17_1_4_dataa;
reg [16:0] legup_mult_unsigned_17_17_1_4_datab;
wire [33:0] legup_mult_unsigned_17_17_1_4_result;
reg [33:0] legup_mult_fir_hw_BB_3_mul68_out_actual;
reg [33:0] legup_mult_fir_hw_BB_3_mul68_out;
reg  legup_mult_fir_hw_BB_3_mul68_en;
reg  legup_mult_fir_hw_BB_3_mul68_en_pipeline_cond;
wire [15:0] fir_hw_BB_3_bit_concat69_bit_select_operand_0;
wire [5:0] fir_hw_BB_3_bit_concat69_bit_select_operand_4;
reg  legup_mult_unsigned_17_27_2_5_clock;
reg  legup_mult_unsigned_17_27_2_5_aclr;
reg  legup_mult_unsigned_17_27_2_5_clken;
reg [16:0] legup_mult_unsigned_17_27_2_5_dataa;
reg [26:0] legup_mult_unsigned_17_27_2_5_datab;
wire [43:0] legup_mult_unsigned_17_27_2_5_result;
reg [43:0] legup_mult_fir_hw_BB_3_mul70_out_actual;
reg [31:0] legup_mult_fir_hw_BB_3_mul70_out;
reg  legup_mult_fir_hw_BB_3_mul70_en;
reg  legup_mult_fir_hw_BB_3_mul70_en_pipeline_cond;
reg  legup_mult_signed_18_13_1_6_clock;
reg  legup_mult_signed_18_13_1_6_aclr;
reg  legup_mult_signed_18_13_1_6_clken;
reg [17:0] legup_mult_signed_18_13_1_6_dataa;
reg [12:0] legup_mult_signed_18_13_1_6_datab;
wire [30:0] legup_mult_signed_18_13_1_6_result;
reg [30:0] legup_mult_fir_hw_BB_3_mul72_out_actual;
reg [29:0] legup_mult_fir_hw_BB_3_mul72_out;
reg  legup_mult_fir_hw_BB_3_mul72_en;
reg  legup_mult_fir_hw_BB_3_mul72_en_pipeline_cond;
reg  legup_mult_signed_13_15_1_7_clock;
reg  legup_mult_signed_13_15_1_7_aclr;
reg  legup_mult_signed_13_15_1_7_clken;
reg [12:0] legup_mult_signed_13_15_1_7_dataa;
reg [14:0] legup_mult_signed_13_15_1_7_datab;
wire [27:0] legup_mult_signed_13_15_1_7_result;
reg [27:0] legup_mult_fir_hw_BB_3_mul74_out_actual;
reg [27:0] legup_mult_fir_hw_BB_3_mul74_out;
reg  legup_mult_fir_hw_BB_3_mul74_en;
reg  legup_mult_fir_hw_BB_3_mul74_en_pipeline_cond;
reg [32:0] fir_hw_BB_3_sext75_width_extended;
reg [32:0] fir_hw_BB_3_bit_select76_width_extended;
wire [16:0] fir_hw_BB_3_bit_concat77_bit_select_operand_2;
reg [29:0] fir_hw_BB_3_sext79_width_extended;
reg [29:0] fir_hw_BB_3_bit_select80_width_extended;
wire [16:0] fir_hw_BB_3_bit_concat81_bit_select_operand_2;
wire [16:0] fir_hw_BB_3_bit_concat84_bit_select_operand_0;
wire [16:0] fir_hw_BB_3_bit_concat84_bit_select_operand_4;
reg [50:0] fir_hw_BB_3_sext85_width_extended;
reg [50:0] fir_hw_BB_3_bit_select86_width_extended;
wire [16:0] fir_hw_BB_3_bit_concat87_bit_select_operand_2;
wire [33:0] fir_hw_BB_3_bit_concat90_bit_select_operand_2;

/*   %mul = mul nuw i34 %bit_concat32, %bit_concat35, !dbg !11626, !MSB !11630, !LSB !11629, !ExtendFrom !11630, !legup.pipeline.avail_time !11163, !legup.pipeline.start_time !11291, !legup.pipeline.stage !11113*/
fir_hw_legup_mult legup_mult_unsigned_17_17_1_0 (
	.clock (legup_mult_unsigned_17_17_1_0_clock),
	.aclr (legup_mult_unsigned_17_17_1_0_aclr),
	.clken (legup_mult_unsigned_17_17_1_0_clken),
	.dataa (legup_mult_unsigned_17_17_1_0_dataa),
	.datab (legup_mult_unsigned_17_17_1_0_datab),
	.result (legup_mult_unsigned_17_17_1_0_result)
);

defparam
	legup_mult_unsigned_17_17_1_0.widtha = 17,
	legup_mult_unsigned_17_17_1_0.widthb = 17,
	legup_mult_unsigned_17_17_1_0.widthp = 34,
	legup_mult_unsigned_17_17_1_0.pipeline = 1,
	legup_mult_unsigned_17_17_1_0.representation = "UNSIGNED";

/*   %mul38 = mul nsw i33 %bit_concat37, %sext, !dbg !11626, !MSB !11632, !LSB !11629, !ExtendFrom !11293, !legup.pipeline.avail_time !11633, !legup.pipeline.start_time !11291, !legup.pipeline.stage !11113*/
fir_hw_legup_mult legup_mult_unsigned_17_27_2_1 (
	.clock (legup_mult_unsigned_17_27_2_1_clock),
	.aclr (legup_mult_unsigned_17_27_2_1_aclr),
	.clken (legup_mult_unsigned_17_27_2_1_clken),
	.dataa (legup_mult_unsigned_17_27_2_1_dataa),
	.datab (legup_mult_unsigned_17_27_2_1_datab),
	.result (legup_mult_unsigned_17_27_2_1_result)
);

defparam
	legup_mult_unsigned_17_27_2_1.widtha = 17,
	legup_mult_unsigned_17_27_2_1.widthb = 27,
	legup_mult_unsigned_17_27_2_1.widthp = 44,
	legup_mult_unsigned_17_27_2_1.pipeline = 2,
	legup_mult_unsigned_17_27_2_1.representation = "UNSIGNED";

/*   %mul41 = mul nsw i32 %bit_concat40, %sext39, !dbg !11626, !MSB !11293, !LSB !11113, !ExtendFrom !11634, !legup.pipeline.avail_time !11163, !legup.pipeline.start_time !11291, !legup.pipeline.stage !11113*/
fir_hw_legup_mult legup_mult_signed_18_13_1_2 (
	.clock (legup_mult_signed_18_13_1_2_clock),
	.aclr (legup_mult_signed_18_13_1_2_aclr),
	.clken (legup_mult_signed_18_13_1_2_clken),
	.dataa (legup_mult_signed_18_13_1_2_dataa),
	.datab (legup_mult_signed_18_13_1_2_datab),
	.result (legup_mult_signed_18_13_1_2_result)
);

defparam
	legup_mult_signed_18_13_1_2.widtha = 18,
	legup_mult_signed_18_13_1_2.widthb = 13,
	legup_mult_signed_18_13_1_2.widthp = 31,
	legup_mult_signed_18_13_1_2.pipeline = 1,
	legup_mult_signed_18_13_1_2.representation = "SIGNED";

/*   %mul44 = mul nsw i29 %sext42, %sext43, !dbg !11626, !MSB !11635, !LSB !11113, !ExtendFrom !11636, !legup.pipeline.avail_time !11163, !legup.pipeline.start_time !11291, !legup.pipeline.stage !11113*/
fir_hw_legup_mult legup_mult_signed_13_15_1_3 (
	.clock (legup_mult_signed_13_15_1_3_clock),
	.aclr (legup_mult_signed_13_15_1_3_aclr),
	.clken (legup_mult_signed_13_15_1_3_clken),
	.dataa (legup_mult_signed_13_15_1_3_dataa),
	.datab (legup_mult_signed_13_15_1_3_datab),
	.result (legup_mult_signed_13_15_1_3_result)
);

defparam
	legup_mult_signed_13_15_1_3.widtha = 13,
	legup_mult_signed_13_15_1_3.widthb = 15,
	legup_mult_signed_13_15_1_3.widthp = 28,
	legup_mult_signed_13_15_1_3.pipeline = 1,
	legup_mult_signed_13_15_1_3.representation = "SIGNED";

/*   %mul68 = mul nuw i34 %bit_concat67, %bit_concat35, !dbg !11678, !MSB !11630, !LSB !11629, !ExtendFrom !11630, !legup.pipeline.avail_time !11163, !legup.pipeline.start_time !11291, !legup.pipeline.stage !11113*/
fir_hw_legup_mult legup_mult_unsigned_17_17_1_4 (
	.clock (legup_mult_unsigned_17_17_1_4_clock),
	.aclr (legup_mult_unsigned_17_17_1_4_aclr),
	.clken (legup_mult_unsigned_17_17_1_4_clken),
	.dataa (legup_mult_unsigned_17_17_1_4_dataa),
	.datab (legup_mult_unsigned_17_17_1_4_datab),
	.result (legup_mult_unsigned_17_17_1_4_result)
);

defparam
	legup_mult_unsigned_17_17_1_4.widtha = 17,
	legup_mult_unsigned_17_17_1_4.widthb = 17,
	legup_mult_unsigned_17_17_1_4.widthp = 34,
	legup_mult_unsigned_17_17_1_4.pipeline = 1,
	legup_mult_unsigned_17_17_1_4.representation = "UNSIGNED";

/*   %mul70 = mul nsw i33 %bit_concat69, %sext, !dbg !11678, !MSB !11632, !LSB !11629, !ExtendFrom !11293, !legup.pipeline.avail_time !11633, !legup.pipeline.start_time !11291, !legup.pipeline.stage !11113*/
fir_hw_legup_mult legup_mult_unsigned_17_27_2_5 (
	.clock (legup_mult_unsigned_17_27_2_5_clock),
	.aclr (legup_mult_unsigned_17_27_2_5_aclr),
	.clken (legup_mult_unsigned_17_27_2_5_clken),
	.dataa (legup_mult_unsigned_17_27_2_5_dataa),
	.datab (legup_mult_unsigned_17_27_2_5_datab),
	.result (legup_mult_unsigned_17_27_2_5_result)
);

defparam
	legup_mult_unsigned_17_27_2_5.widtha = 17,
	legup_mult_unsigned_17_27_2_5.widthb = 27,
	legup_mult_unsigned_17_27_2_5.widthp = 44,
	legup_mult_unsigned_17_27_2_5.pipeline = 2,
	legup_mult_unsigned_17_27_2_5.representation = "UNSIGNED";

/*   %mul72 = mul nsw i32 %bit_concat40, %sext71, !dbg !11678, !MSB !11293, !LSB !11113, !ExtendFrom !11634, !legup.pipeline.avail_time !11163, !legup.pipeline.start_time !11291, !legup.pipeline.stage !11113*/
fir_hw_legup_mult legup_mult_signed_18_13_1_6 (
	.clock (legup_mult_signed_18_13_1_6_clock),
	.aclr (legup_mult_signed_18_13_1_6_aclr),
	.clken (legup_mult_signed_18_13_1_6_clken),
	.dataa (legup_mult_signed_18_13_1_6_dataa),
	.datab (legup_mult_signed_18_13_1_6_datab),
	.result (legup_mult_signed_18_13_1_6_result)
);

defparam
	legup_mult_signed_18_13_1_6.widtha = 18,
	legup_mult_signed_18_13_1_6.widthb = 13,
	legup_mult_signed_18_13_1_6.widthp = 31,
	legup_mult_signed_18_13_1_6.pipeline = 1,
	legup_mult_signed_18_13_1_6.representation = "SIGNED";

/*   %mul74 = mul nsw i29 %sext73, %sext43, !dbg !11678, !MSB !11635, !LSB !11113, !ExtendFrom !11636, !legup.pipeline.avail_time !11163, !legup.pipeline.start_time !11291, !legup.pipeline.stage !11113*/
fir_hw_legup_mult legup_mult_signed_13_15_1_7 (
	.clock (legup_mult_signed_13_15_1_7_clock),
	.aclr (legup_mult_signed_13_15_1_7_aclr),
	.clken (legup_mult_signed_13_15_1_7_clken),
	.dataa (legup_mult_signed_13_15_1_7_dataa),
	.datab (legup_mult_signed_13_15_1_7_datab),
	.result (legup_mult_signed_13_15_1_7_result)
);

defparam
	legup_mult_signed_13_15_1_7.widtha = 13,
	legup_mult_signed_13_15_1_7.widthb = 15,
	legup_mult_signed_13_15_1_7.widthp = 28,
	legup_mult_signed_13_15_1_7.pipeline = 1,
	legup_mult_signed_13_15_1_7.representation = "SIGNED";



// @_ZZ6fir_hwN3hls7ap_uintILj16EEENS0_ILj8EEES1_PNS_8ap_fixptILj32ELi1ELNS_19AP_FIXPT_QUANT_MODEE0ELNS_18AP_FIXPT_OVER_MODEE0EEERNS_4FIFOINS3_ILj24ELi1ELS4_0ELS5_0EEELb0EEESB_RNS8_I11axis_packetLb0EEEE1...
fir_hw_ram_single_port fir_hw_buffer_left (
	.clk( clk ),
	.clken( fir_hw_buffer_left_clken ),
	.address_a( fir_hw_buffer_left_address_a ),
	.write_en_a( fir_hw_buffer_left_write_en_a ),
	.write_data_a( fir_hw_buffer_left_write_data_a ),
	.read_data_a( fir_hw_buffer_left_read_data_a )
);
defparam fir_hw_buffer_left.width_a = 24;
defparam fir_hw_buffer_left.widthad_a = 9;
defparam fir_hw_buffer_left.width_be_a = 3;
defparam fir_hw_buffer_left.numwords_a = 512;
defparam fir_hw_buffer_left.latency = 1;
defparam fir_hw_buffer_left.fpga_device = "PolarFireSoC";
defparam fir_hw_buffer_left.init_file = {`MEM_INIT_DIR, "fir_hw_buffer_left.mem"};



// @_ZZ6fir_hwN3hls7ap_uintILj16EEENS0_ILj8EEES1_PNS_8ap_fixptILj32ELi1ELNS_19AP_FIXPT_QUANT_MODEE0ELNS_18AP_FIXPT_OVER_MODEE0EEERNS_4FIFOINS3_ILj24ELi1ELS4_0ELS5_0EEELb0EEESB_RNS8_I11axis_packetLb0EEEE1...
fir_hw_ram_single_port fir_hw_buffer_right (
	.clk( clk ),
	.clken( fir_hw_buffer_right_clken ),
	.address_a( fir_hw_buffer_right_address_a ),
	.write_en_a( fir_hw_buffer_right_write_en_a ),
	.write_data_a( fir_hw_buffer_right_write_data_a ),
	.read_data_a( fir_hw_buffer_right_read_data_a )
);
defparam fir_hw_buffer_right.width_a = 24;
defparam fir_hw_buffer_right.widthad_a = 9;
defparam fir_hw_buffer_right.width_be_a = 3;
defparam fir_hw_buffer_right.numwords_a = 512;
defparam fir_hw_buffer_right.latency = 1;
defparam fir_hw_buffer_right.fpga_device = "PolarFireSoC";
defparam fir_hw_buffer_right.init_file = {`MEM_INIT_DIR, "fir_hw_buffer_right.mem"};


always @(posedge clk) begin
if (reset == 1'b1)
	cur_state <= SHLS_0;
else if (!fsm_stall)
	cur_state <= next_state;
end

always @(*)
begin
next_state = cur_state;
case(cur_state)  /* synthesis parallel_case */
SHLS_0:
	if ((start == 1'd1))
		next_state = SHLS_F_fir_hw_BB_0_1;
SHLS_F_fir_hw_BB_0_1:
		next_state = SHLS_F_fir_hw_BB_0_2;
SHLS_F_fir_hw_BB_0_2:
	if ((fir_hw_BB_0_icmp_reg == 1'd1))
		next_state = SHLS_F_fir_hw_BB_5_10;
	else
		next_state = SHLS_F_fir_hw_BB_1_3;
SHLS_F_fir_hw_BB_1_3:
		next_state = SHLS_F_fir_hw_BB_1_4;
SHLS_F_fir_hw_BB_1_4:
		next_state = SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7;
SHLS_F_fir_hw_BB_2_5:
		next_state = SHLS_F_fir_hw_BB_2_6;
SHLS_F_fir_hw_BB_2_6:
	if ((fir_hw_BB_2_icmp12_reg == 1'd1))
		next_state = SHLS_F_fir_hw_BB_4_8;
	else
		next_state = SHLS_F_fir_hw_BB_5_10;
SHLS_F_fir_hw_BB_4_8:
		next_state = SHLS_F_fir_hw_BB_4_9;
SHLS_F_fir_hw_BB_4_9:
		next_state = SHLS_F_fir_hw_BB_5_10;
SHLS_F_fir_hw_BB_5_10:
		next_state = SHLS_F_fir_hw_BB_5_11;
SHLS_F_fir_hw_BB_5_11:
		next_state = SHLS_0;
SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7:
	if ((for_loop_src_fir_hw_cpp_35_9_pipeline_finish == 1'd1))
		next_state = SHLS_F_fir_hw_BB_2_5;
default:
	next_state = 4'bX;
endcase

end
always @(posedge clk) begin
	if ((start & ready)) begin
		tlast_dnum_reg <= tlast_dnum;
	end
end
always @(posedge clk) begin
	if ((start & ready)) begin
		smpl_rd_num_reg <= smpl_rd_num;
	end
end
always @(posedge clk) begin
	if ((start & ready)) begin
		tap_num_m1_reg <= tap_num_m1;
	end
end
always @(*) begin
	fsm_stall = 1'd0;
	if (((cur_state == SHLS_F_fir_hw_BB_0_1) & ~(input_l_consumed_valid))) begin
		fsm_stall = 1'd1;
	end
	if (((cur_state == SHLS_F_fir_hw_BB_0_1) & ~(input_r_consumed_valid))) begin
		fsm_stall = 1'd1;
	end
	if ((((cur_state == SHLS_F_fir_hw_BB_2_5) & ~(res_ready)) & (res_data_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a | res_data_SHLS_F_fir_hw_BB_2_5_stalln_reg))) begin
		fsm_stall = 1'd1;
	end
	if ((((cur_state == SHLS_F_fir_hw_BB_2_5) & ~(res_ready)) & (res_last_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a | res_last_SHLS_F_fir_hw_BB_2_5_stalln_reg))) begin
		fsm_stall = 1'd1;
	end
	if ((((cur_state == SHLS_F_fir_hw_BB_2_5) & ~(res_ready)) & (res_keep_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a | res_keep_SHLS_F_fir_hw_BB_2_5_stalln_reg))) begin
		fsm_stall = 1'd1;
	end
	if ((((cur_state == SHLS_F_fir_hw_BB_2_6) & ~(res_ready)) & (res_data_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a | res_data_SHLS_F_fir_hw_BB_2_6_stalln_reg))) begin
		fsm_stall = 1'd1;
	end
	if ((((cur_state == SHLS_F_fir_hw_BB_2_6) & ~(res_ready)) & (res_last_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a | res_last_SHLS_F_fir_hw_BB_2_6_stalln_reg))) begin
		fsm_stall = 1'd1;
	end
	if ((((cur_state == SHLS_F_fir_hw_BB_2_6) & ~(res_ready)) & (res_keep_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a | res_keep_SHLS_F_fir_hw_BB_2_6_stalln_reg))) begin
		fsm_stall = 1'd1;
	end
end
always @(*) begin
	fir_hw_BB_0_fifoVal = input_l_consumed_data;
end
always @(*) begin
		fir_hw_BB_0_load = fir_hw_write_idx_inferred_reg;
end
always @(posedge clk) begin
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		fir_hw_BB_0_load_reg <= fir_hw_BB_0_load;
	end
end
always @(*) begin
		fir_hw_BB_0_bit_concat = {fir_hw_BB_0_bit_concat_bit_select_operand_0[22:0], fir_hw_BB_0_load[8:0]};
end
always @(*) begin
		fir_hw_BB_0_addr = (1'd0 + (4 * {23'd0,fir_hw_BB_0_bit_concat}));
end
always @(*) begin
	fir_hw_BB_0_fifoVal1 = input_r_consumed_data;
end
always @(*) begin
		fir_hw_BB_0_addr2 = (1'd0 + (4 * {23'd0,fir_hw_BB_0_bit_concat}));
end
always @(*) begin
		fir_hw_BB_0_load3 = fir_hw_dec_cnt_inferred_reg;
end
always @(*) begin
		fir_hw_BB_0_add = (fir_hw_BB_0_load3 + 3'd1);
end
always @(*) begin
		fir_hw_BB_0_bit_concat4 = {fir_hw_BB_0_bit_concat4_bit_select_operand_0[4:0], fir_hw_BB_0_add[2:0]};
end
always @(*) begin
		fir_hw_BB_0_icmp = ({5'd0,fir_hw_BB_0_bit_concat4} < smpl_rd_num_reg);
end
always @(posedge clk) begin
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		fir_hw_BB_0_icmp_reg <= fir_hw_BB_0_icmp;
	end
end
always @(*) begin
		fir_hw_BB_1_bit_concat5 = {fir_hw_BB_1_bit_concat5_bit_select_operand_0[15:0], tap_num_m1_reg[15:0]};
end
always @(posedge clk) begin
	if ((cur_state == SHLS_F_fir_hw_BB_1_3)) begin
		fir_hw_BB_1_bit_concat5_reg <= fir_hw_BB_1_bit_concat5;
	end
end
always @(*) begin
		fir_hw_BB_2_load6 = fir_hw_cnt_inferred_reg;
end
always @(*) begin
		fir_hw_BB_2_add7 = (fir_hw_BB_2_load6 + 16'd1);
end
always @(*) begin
		fir_hw_BB_2_icmp8 = (fir_hw_BB_2_add7 == tlast_dnum_reg);
end
always @(*) begin
		fir_hw_BB_2_bit_concat10 = {fir_hw_BB_2_bit_concat10_bit_select_operand_0[6:0], fir_hw_BB_2_icmp8};
end
always @(*) begin
		fir_hw_BB_2_add11 = (fir_hw_BB_2_load6 + 16'd2);
end
always @(*) begin
		fir_hw_BB_2_select = (fir_hw_BB_2_icmp8 ? 16'd1 : fir_hw_BB_2_add11);
end
always @(*) begin
		fir_hw_BB_2_icmp12 = (fir_hw_BB_2_select == tlast_dnum_reg);
end
always @(posedge clk) begin
	if ((cur_state == SHLS_F_fir_hw_BB_2_5)) begin
		fir_hw_BB_2_icmp12_reg <= fir_hw_BB_2_icmp12;
	end
end
always @(*) begin
		fir_hw_BB_2_bit_concat13 = {fir_hw_BB_2_bit_concat13_bit_select_operand_0[6:0], fir_hw_BB_2_icmp12};
end
always @(posedge clk) begin
	if ((cur_state == SHLS_F_fir_hw_BB_2_5)) begin
		fir_hw_BB_2_bit_concat13_reg <= fir_hw_BB_2_bit_concat13;
	end
end
always @(*) begin
	if ((for_loop_src_fir_hw_cpp_35_9_valid_bit_1 & for_loop_src_fir_hw_cpp_35_9_in_first_iteration_stage0)) begin
		fir_hw_BB_3_phi = fir_hw_BB_3_phi_reg;
	end
	else if (((for_loop_src_fir_hw_cpp_35_9_valid_bit_1 & ~(for_loop_src_fir_hw_cpp_35_9_in_first_iteration_stage0)) & for_loop_src_fir_hw_cpp_35_9_valid_bit_3)) begin
		fir_hw_BB_3_phi = fir_hw_BB_3_add63;
	end
	else if (((for_loop_src_fir_hw_cpp_35_9_valid_bit_1 & ~(for_loop_src_fir_hw_cpp_35_9_in_first_iteration_stage0)) & ~(for_loop_src_fir_hw_cpp_35_9_valid_bit_3))) begin
		fir_hw_BB_3_phi = fir_hw_BB_3_add63_reg_stage2;
	end
	else /* if (((cur_state == SHLS_F_fir_hw_BB_1_4) & (fsm_stall == 1'd0))) */  begin
		fir_hw_BB_3_phi = 48'd0;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_1) begin
		fir_hw_BB_3_phi_reg <= fir_hw_BB_3_phi;
	end
	if (((cur_state == SHLS_F_fir_hw_BB_1_4) & (fsm_stall == 1'd0))) begin
		fir_hw_BB_3_phi_reg <= fir_hw_BB_3_phi;
	end
end
always @(*) begin
	if ((for_loop_src_fir_hw_cpp_35_9_valid_bit_1 & for_loop_src_fir_hw_cpp_35_9_in_first_iteration_stage0)) begin
		fir_hw_BB_3_phi14 = fir_hw_BB_3_phi14_reg;
	end
	else if (((for_loop_src_fir_hw_cpp_35_9_valid_bit_1 & ~(for_loop_src_fir_hw_cpp_35_9_in_first_iteration_stage0)) & for_loop_src_fir_hw_cpp_35_9_valid_bit_3)) begin
		fir_hw_BB_3_phi14 = fir_hw_BB_3_add92;
	end
	else if (((for_loop_src_fir_hw_cpp_35_9_valid_bit_1 & ~(for_loop_src_fir_hw_cpp_35_9_in_first_iteration_stage0)) & ~(for_loop_src_fir_hw_cpp_35_9_valid_bit_3))) begin
		fir_hw_BB_3_phi14 = fir_hw_BB_3_add92_reg_stage2;
	end
	else /* if (((cur_state == SHLS_F_fir_hw_BB_1_4) & (fsm_stall == 1'd0))) */  begin
		fir_hw_BB_3_phi14 = 48'd0;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_1) begin
		fir_hw_BB_3_phi14_reg <= fir_hw_BB_3_phi14;
	end
	if (((cur_state == SHLS_F_fir_hw_BB_1_4) & (fsm_stall == 1'd0))) begin
		fir_hw_BB_3_phi14_reg <= fir_hw_BB_3_phi14;
	end
end
always @(*) begin
		fir_hw_BB_3_bit_select17 = for_loop_src_fir_hw_cpp_35_9_inductionVar_stage0[8:0];
end
always @(*) begin
		fir_hw_BB_3_sub = (fir_hw_BB_0_load_reg - fir_hw_BB_3_bit_select17);
end
always @(*) begin
		fir_hw_BB_3_bit_concat18 = {fir_hw_BB_3_bit_concat18_bit_select_operand_0[22:0], fir_hw_BB_3_sub[8:0]};
end
always @(*) begin
		fir_hw_BB_3_addr19 = (1'd0 + (4 * {23'd0,fir_hw_BB_3_bit_concat18}));
end
always @(*) begin
		fir_hw_BB_3_load20 = fir_hw_buffer_left_read_data_wire_a;
end
always @(*) begin
		fir_hw_BB_3_bit_select22 = fir_hw_BB_3_load20[10:0];
end
always @(*) begin
		fir_hw_BB_3_addr23 = (1'd0 + (4 * {23'd0,fir_hw_BB_3_bit_concat18}));
end
always @(*) begin
		fir_hw_BB_3_load24 = fir_hw_buffer_right_read_data_wire_a;
end
always @(*) begin
		fir_hw_BB_3_bit_select25 = fir_hw_BB_3_load24[10:0];
end
always @(*) begin
		fir_hw_BB_3_addr26 = (0 + (4 * for_loop_src_fir_hw_cpp_35_9_inductionVar_stage0));
end
always @(*) begin
		fir_hw_BB_3_load27 = coeff_hw_read_data_wire_a;
end
always @(*) begin
		fir_hw_BB_3_bit_select28 = fir_hw_BB_3_load27[31:17];
end
always @(*) begin
		fir_hw_BB_3_bit_select30 = fir_hw_BB_3_load27[16:0];
end
always @(*) begin
		fir_hw_BB_3_ashr = ($signed(fir_hw_BB_3_load20) >>> 24'd11);
end
always @(*) begin
		fir_hw_BB_3_bit_select31 = fir_hw_BB_3_ashr_width_extended[13:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat32 = {{fir_hw_BB_3_bit_concat32_bit_select_operand_0[16:0], fir_hw_BB_3_bit_select22[10:0]}, fir_hw_BB_3_bit_concat32_bit_select_operand_4[5:0]};
end
always @(*) begin
		fir_hw_BB_3_bit_concat35 = {fir_hw_BB_3_bit_concat35_bit_select_operand_0[16:0], fir_hw_BB_3_bit_select30[16:0]};
end
always @(*) begin
	fir_hw_BB_3_mul = legup_mult_fir_hw_BB_3_mul_out;
end
always @(*) begin
		fir_hw_BB_3_bit_concat37 = {{fir_hw_BB_3_bit_concat37_bit_select_operand_0[15:0], fir_hw_BB_3_bit_select22[10:0]}, fir_hw_BB_3_bit_concat37_bit_select_operand_4[5:0]};
end
always @(*) begin
		fir_hw_BB_3_sext = $signed(fir_hw_BB_3_bit_select28);
end
always @(*) begin
	fir_hw_BB_3_mul38 = legup_mult_fir_hw_BB_3_mul38_out;
end
always @(*) begin
		fir_hw_BB_3_sext39 = $signed({{1{fir_hw_BB_3_bit_select31[12]}},fir_hw_BB_3_bit_select31});
end
always @(*) begin
		fir_hw_BB_3_bit_concat40 = {fir_hw_BB_3_bit_concat40_bit_select_operand_0[14:0], fir_hw_BB_3_bit_select30[16:0]};
end
always @(*) begin
	fir_hw_BB_3_mul41 = legup_mult_fir_hw_BB_3_mul41_out;
end
always @(*) begin
		fir_hw_BB_3_sext42 = $signed({{1{fir_hw_BB_3_bit_select31[12]}},fir_hw_BB_3_bit_select31});
end
always @(*) begin
		fir_hw_BB_3_sext43 = $signed(fir_hw_BB_3_bit_select28);
end
always @(*) begin
	fir_hw_BB_3_mul44 = legup_mult_fir_hw_BB_3_mul44_out;
end
always @(*) begin
		fir_hw_BB_3_sext45 = $signed({{2{fir_hw_BB_3_mul41[29]}},fir_hw_BB_3_mul41});
end
always @(*) begin
		fir_hw_BB_3_bit_select46 = fir_hw_BB_3_sext45_width_extended[32:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat47 = {fir_hw_BB_3_bit_select46_width_extended[32:0], fir_hw_BB_3_bit_concat47_bit_select_operand_2[16:0]};
end
always @(*) begin
		fir_hw_BB_3_sext48 = $signed({{1{fir_hw_BB_3_mul38[31]}},fir_hw_BB_3_mul38});
end
always @(*) begin
		fir_hw_BB_3_sext49 = $signed({{1{fir_hw_BB_3_mul44[27]}},fir_hw_BB_3_mul44});
end
always @(*) begin
		fir_hw_BB_3_bit_select50 = fir_hw_BB_3_sext49_width_extended[29:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat51 = {fir_hw_BB_3_bit_select50_width_extended[29:0], fir_hw_BB_3_bit_concat51_bit_select_operand_2[16:0]};
end
always @(*) begin
		fir_hw_BB_3_add52 = ($signed({{1{fir_hw_BB_3_bit_concat51_reg_stage1[44]}},fir_hw_BB_3_bit_concat51_reg_stage1}) + $signed({{14{fir_hw_BB_3_sext48[31]}},fir_hw_BB_3_sext48}));
end
always @(*) begin
		fir_hw_BB_3_bit_select53 = fir_hw_BB_3_add52[45:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat54 = {{fir_hw_BB_3_bit_concat54_bit_select_operand_0[16:0], fir_hw_BB_3_mul[33:0]}, fir_hw_BB_3_bit_concat54_bit_select_operand_4[16:0]};
end
always @(*) begin
		fir_hw_BB_3_sext55 = $signed({{3{fir_hw_BB_3_bit_concat47[46]}},fir_hw_BB_3_bit_concat47});
end
always @(*) begin
		fir_hw_BB_3_bit_select56 = fir_hw_BB_3_sext55_width_extended[50:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat57 = {fir_hw_BB_3_bit_select56_width_extended[50:0], fir_hw_BB_3_bit_concat57_bit_select_operand_2[16:0]};
end
always @(*) begin
		fir_hw_BB_3_add58 = ($signed({{1{fir_hw_BB_3_bit_concat57[63]}},fir_hw_BB_3_bit_concat57}) + {14'd0,fir_hw_BB_3_bit_concat54});
end
always @(*) begin
		fir_hw_BB_3_sext59 = $signed({{3{fir_hw_BB_3_add58[64]}},fir_hw_BB_3_add58});
end
always @(*) begin
		fir_hw_BB_3_bit_concat60 = {fir_hw_BB_3_bit_select53[45:0], fir_hw_BB_3_bit_concat60_bit_select_operand_2[33:0]};
end
always @(*) begin
		fir_hw_BB_3_add61 = (fir_hw_BB_3_bit_concat60 + $signed({{15{fir_hw_BB_3_sext59_reg_stage1[64]}},fir_hw_BB_3_sext59_reg_stage1}));
end
always @(*) begin
		fir_hw_BB_3_bit_select62 = fir_hw_BB_3_add61[78:31];
end
always @(*) begin
		fir_hw_BB_3_add63 = (fir_hw_BB_3_phi_reg_stage1 + fir_hw_BB_3_bit_select62);
end
always @(*) begin
		fir_hw_BB_3_bit_select64 = fir_hw_BB_3_add63[46:15];
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_3) begin
		fir_hw_BB_3_bit_select64_reg <= fir_hw_BB_3_bit_select64;
	end
end
always @(*) begin
		fir_hw_BB_3_ashr65 = ($signed(fir_hw_BB_3_load24) >>> 24'd11);
end
always @(*) begin
		fir_hw_BB_3_bit_select66 = fir_hw_BB_3_ashr65_width_extended[13:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat67 = {{fir_hw_BB_3_bit_concat67_bit_select_operand_0[16:0], fir_hw_BB_3_bit_select25[10:0]}, fir_hw_BB_3_bit_concat67_bit_select_operand_4[5:0]};
end
always @(*) begin
	fir_hw_BB_3_mul68 = legup_mult_fir_hw_BB_3_mul68_out;
end
always @(*) begin
		fir_hw_BB_3_bit_concat69 = {{fir_hw_BB_3_bit_concat69_bit_select_operand_0[15:0], fir_hw_BB_3_bit_select25[10:0]}, fir_hw_BB_3_bit_concat69_bit_select_operand_4[5:0]};
end
always @(*) begin
	fir_hw_BB_3_mul70 = legup_mult_fir_hw_BB_3_mul70_out;
end
always @(*) begin
		fir_hw_BB_3_sext71 = $signed({{1{fir_hw_BB_3_bit_select66[12]}},fir_hw_BB_3_bit_select66});
end
always @(*) begin
	fir_hw_BB_3_mul72 = legup_mult_fir_hw_BB_3_mul72_out;
end
always @(*) begin
		fir_hw_BB_3_sext73 = $signed({{1{fir_hw_BB_3_bit_select66[12]}},fir_hw_BB_3_bit_select66});
end
always @(*) begin
	fir_hw_BB_3_mul74 = legup_mult_fir_hw_BB_3_mul74_out;
end
always @(*) begin
		fir_hw_BB_3_sext75 = $signed({{2{fir_hw_BB_3_mul72[29]}},fir_hw_BB_3_mul72});
end
always @(*) begin
		fir_hw_BB_3_bit_select76 = fir_hw_BB_3_sext75_width_extended[32:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat77 = {fir_hw_BB_3_bit_select76_width_extended[32:0], fir_hw_BB_3_bit_concat77_bit_select_operand_2[16:0]};
end
always @(*) begin
		fir_hw_BB_3_sext78 = $signed({{1{fir_hw_BB_3_mul70[31]}},fir_hw_BB_3_mul70});
end
always @(*) begin
		fir_hw_BB_3_sext79 = $signed({{1{fir_hw_BB_3_mul74[27]}},fir_hw_BB_3_mul74});
end
always @(*) begin
		fir_hw_BB_3_bit_select80 = fir_hw_BB_3_sext79_width_extended[29:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat81 = {fir_hw_BB_3_bit_select80_width_extended[29:0], fir_hw_BB_3_bit_concat81_bit_select_operand_2[16:0]};
end
always @(*) begin
		fir_hw_BB_3_add82 = ($signed({{1{fir_hw_BB_3_bit_concat81_reg_stage1[44]}},fir_hw_BB_3_bit_concat81_reg_stage1}) + $signed({{14{fir_hw_BB_3_sext78[31]}},fir_hw_BB_3_sext78}));
end
always @(*) begin
		fir_hw_BB_3_bit_select83 = fir_hw_BB_3_add82[45:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat84 = {{fir_hw_BB_3_bit_concat84_bit_select_operand_0[16:0], fir_hw_BB_3_mul68[33:0]}, fir_hw_BB_3_bit_concat84_bit_select_operand_4[16:0]};
end
always @(*) begin
		fir_hw_BB_3_sext85 = $signed({{3{fir_hw_BB_3_bit_concat77[46]}},fir_hw_BB_3_bit_concat77});
end
always @(*) begin
		fir_hw_BB_3_bit_select86 = fir_hw_BB_3_sext85_width_extended[50:0];
end
always @(*) begin
		fir_hw_BB_3_bit_concat87 = {fir_hw_BB_3_bit_select86_width_extended[50:0], fir_hw_BB_3_bit_concat87_bit_select_operand_2[16:0]};
end
always @(*) begin
		fir_hw_BB_3_add88 = ($signed({{1{fir_hw_BB_3_bit_concat87[63]}},fir_hw_BB_3_bit_concat87}) + {14'd0,fir_hw_BB_3_bit_concat84});
end
always @(*) begin
		fir_hw_BB_3_sext89 = $signed({{3{fir_hw_BB_3_add88[64]}},fir_hw_BB_3_add88});
end
always @(*) begin
		fir_hw_BB_3_bit_concat90 = {fir_hw_BB_3_bit_select83[45:0], fir_hw_BB_3_bit_concat90_bit_select_operand_2[33:0]};
end
always @(*) begin
		fir_hw_BB_3_add91 = (fir_hw_BB_3_bit_concat90 + $signed({{15{fir_hw_BB_3_sext89_reg_stage1[64]}},fir_hw_BB_3_sext89_reg_stage1}));
end
always @(*) begin
		fir_hw_BB_3_bit_select = fir_hw_BB_3_add91[78:31];
end
always @(*) begin
		fir_hw_BB_3_add92 = (fir_hw_BB_3_phi14_reg_stage1 + fir_hw_BB_3_bit_select);
end
always @(*) begin
		fir_hw_BB_3_bit_select93 = fir_hw_BB_3_add92[46:15];
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_3) begin
		fir_hw_BB_3_bit_select93_reg <= fir_hw_BB_3_bit_select93;
	end
end
always @(*) begin
		fir_hw_BB_3_icmp95 = (for_loop_src_fir_hw_cpp_35_9_inductionVar_stage0 == {16'd0,fir_hw_BB_1_bit_concat5_reg});
end
always @(*) begin
		fir_hw_BB_5_add96 = (fir_hw_BB_0_load_reg + 9'd1);
end
always @(*) begin
	fir_hw_buffer_left_clken = (fir_hw_buffer_left_clken_pipeline_cond | fir_hw_buffer_left_clken_sequential_cond);
end
always @(*) begin
	fir_hw_buffer_left_address_a = 'dx;
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		fir_hw_buffer_left_address_a = (fir_hw_BB_0_addr >> 2'd2);
	end
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_0) begin
		fir_hw_buffer_left_address_a = (fir_hw_BB_3_addr19 >> 2'd2);
	end
end
always @(*) begin
	fir_hw_buffer_left_write_en_a = 'd0;
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		fir_hw_buffer_left_write_en_a = 1'd1;
	end
end
always @(*) begin
	fir_hw_buffer_left_write_data_a = 'dx;
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		fir_hw_buffer_left_write_data_a = fir_hw_BB_0_fifoVal;
	end
end
always @(*) begin
	fir_hw_buffer_left_read_en_a = 'd0;
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_0) begin
		fir_hw_buffer_left_read_en_a = 1'd1;
	end
end
always @(*) begin
	fir_hw_buffer_right_clken = (fir_hw_buffer_right_clken_pipeline_cond | fir_hw_buffer_right_clken_sequential_cond);
end
always @(*) begin
	fir_hw_buffer_right_address_a = 'dx;
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		fir_hw_buffer_right_address_a = (fir_hw_BB_0_addr2 >> 2'd2);
	end
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_0) begin
		fir_hw_buffer_right_address_a = (fir_hw_BB_3_addr23 >> 2'd2);
	end
end
always @(*) begin
	fir_hw_buffer_right_write_en_a = 'd0;
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		fir_hw_buffer_right_write_en_a = 1'd1;
	end
end
always @(*) begin
	fir_hw_buffer_right_write_data_a = 'dx;
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		fir_hw_buffer_right_write_data_a = fir_hw_BB_0_fifoVal1;
	end
end
always @(*) begin
	fir_hw_buffer_right_read_en_a = 'd0;
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_0) begin
		fir_hw_buffer_right_read_en_a = 1'd1;
	end
end
always @(posedge clk) begin
	if (reset)
		fir_hw_write_idx_inferred_reg <= 9'd0;
	else	if ((cur_state == SHLS_F_fir_hw_BB_5_10)) begin
		fir_hw_write_idx_inferred_reg <= fir_hw_BB_5_add96;
	end
end
always @(posedge clk) begin
	if (reset)
		fir_hw_cnt_inferred_reg <= 16'd0;
	else begin
	if (((cur_state == SHLS_F_fir_hw_BB_2_5) & (fsm_stall == 1'd0))) begin
		fir_hw_cnt_inferred_reg <= fir_hw_BB_2_select;
	end
	if ((cur_state == SHLS_F_fir_hw_BB_4_8)) begin
		fir_hw_cnt_inferred_reg <= 16'd0;
	end
	end
end
always @(posedge clk) begin
	if (reset)
		fir_hw_dec_cnt_inferred_reg <= 3'd0;
	else begin
	if (((cur_state == SHLS_F_fir_hw_BB_0_1) & (fsm_stall == 1'd0))) begin
		fir_hw_dec_cnt_inferred_reg <= fir_hw_BB_0_add;
	end
	if ((cur_state == SHLS_F_fir_hw_BB_1_3)) begin
		fir_hw_dec_cnt_inferred_reg <= 3'd0;
	end
	end
end
always @(posedge clk) begin
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_valid_bit_0 <= 1'd0;
	else	if (~(for_loop_src_fir_hw_cpp_35_9_state_stall_0)) begin
		for_loop_src_fir_hw_cpp_35_9_valid_bit_0 <= (for_loop_src_fir_hw_cpp_35_9_II_counter[1] & for_loop_src_fir_hw_cpp_35_9_start);
	end
end
assign for_loop_src_fir_hw_cpp_35_9_state_stall_0 = 1'd0;
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_state_enable_0 = (for_loop_src_fir_hw_cpp_35_9_valid_bit_0 & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_0));
end
always @(posedge clk) begin
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_valid_bit_1 <= 1'd0;
	else	if (~(for_loop_src_fir_hw_cpp_35_9_state_stall_1)) begin
		for_loop_src_fir_hw_cpp_35_9_valid_bit_1 <= for_loop_src_fir_hw_cpp_35_9_state_enable_0;
	end
end
assign for_loop_src_fir_hw_cpp_35_9_state_stall_1 = 1'd0;
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_state_enable_1 = (for_loop_src_fir_hw_cpp_35_9_valid_bit_1 & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_1));
end
always @(posedge clk) begin
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_valid_bit_2 <= 1'd0;
	else	if (~(for_loop_src_fir_hw_cpp_35_9_state_stall_2)) begin
		for_loop_src_fir_hw_cpp_35_9_valid_bit_2 <= for_loop_src_fir_hw_cpp_35_9_state_enable_1;
	end
end
assign for_loop_src_fir_hw_cpp_35_9_state_stall_2 = 1'd0;
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_state_enable_2 = (for_loop_src_fir_hw_cpp_35_9_valid_bit_2 & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_2));
end
always @(posedge clk) begin
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_valid_bit_3 <= 1'd0;
	else	if (~(for_loop_src_fir_hw_cpp_35_9_state_stall_3)) begin
		for_loop_src_fir_hw_cpp_35_9_valid_bit_3 <= for_loop_src_fir_hw_cpp_35_9_state_enable_2;
	end
end
assign for_loop_src_fir_hw_cpp_35_9_state_stall_3 = 1'd0;
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_state_enable_3 = (for_loop_src_fir_hw_cpp_35_9_valid_bit_3 & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_3));
end
always @(posedge clk) begin
	for_loop_src_fir_hw_cpp_35_9_II_counter <= {for_loop_src_fir_hw_cpp_35_9_II_counter[0], for_loop_src_fir_hw_cpp_35_9_II_counter[1]};
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_II_counter <= 2'd1;
end
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_start = (for_loop_src_fir_hw_cpp_35_9_activate_pipeline | ((for_loop_src_fir_hw_cpp_35_9_active & ~(for_loop_src_fir_hw_cpp_35_9_epilogue)) & ~(for_loop_src_fir_hw_cpp_35_9_pipeline_exit_cond)));
	if (reset) begin
		for_loop_src_fir_hw_cpp_35_9_start = 1'd0;
	end
end
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_activate_pipeline = ((((fsm_stall == 1'd0) & for_loop_src_fir_hw_cpp_35_9_begin_pipeline) & ~(for_loop_src_fir_hw_cpp_35_9_active)) & ~(reset));
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_1) begin
		fir_hw_BB_3_phi_reg_stage1 <= fir_hw_BB_3_phi;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_1) begin
		fir_hw_BB_3_phi14_reg_stage1 <= fir_hw_BB_3_phi14;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_2) begin
		fir_hw_BB_3_bit_concat51_reg_stage1 <= fir_hw_BB_3_bit_concat51;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_2) begin
		fir_hw_BB_3_sext59_reg_stage1 <= fir_hw_BB_3_sext59;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_3) begin
		fir_hw_BB_3_add63_reg_stage2 <= fir_hw_BB_3_add63;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_2) begin
		fir_hw_BB_3_bit_concat81_reg_stage1 <= fir_hw_BB_3_bit_concat81;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_2) begin
		fir_hw_BB_3_sext89_reg_stage1 <= fir_hw_BB_3_sext89;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_3) begin
		fir_hw_BB_3_add92_reg_stage2 <= fir_hw_BB_3_add92;
	end
end
always @(posedge clk) begin
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_inductionVar_stage0 <= 0;
	else begin
	if (for_loop_src_fir_hw_cpp_35_9_activate_pipeline) begin
		for_loop_src_fir_hw_cpp_35_9_inductionVar_stage0 <= 0;
	end
	if ((for_loop_src_fir_hw_cpp_35_9_II_counter[1] & for_loop_src_fir_hw_cpp_35_9_state_enable_1)) begin
		for_loop_src_fir_hw_cpp_35_9_inductionVar_stage0 <= (for_loop_src_fir_hw_cpp_35_9_inductionVar_stage0 + 1);
	end
	end
end
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_pipeline_exit_cond = (for_loop_src_fir_hw_cpp_35_9_state_enable_0 & fir_hw_BB_3_icmp95);
end
always @(posedge clk) begin
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_active <= 1'd0;
	else begin
	if (for_loop_src_fir_hw_cpp_35_9_activate_pipeline) begin
		for_loop_src_fir_hw_cpp_35_9_active <= 1'd1;
	end
	if (for_loop_src_fir_hw_cpp_35_9_pipeline_finishing) begin
		for_loop_src_fir_hw_cpp_35_9_active <= 1'd0;
	end
	end
end
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_begin_pipeline = 1'd0;
	if (reset) begin
		for_loop_src_fir_hw_cpp_35_9_begin_pipeline = 1'd0;
	end
	if (((cur_state == SHLS_F_fir_hw_BB_1_4) & (fsm_stall == 1'd0))) begin
		for_loop_src_fir_hw_cpp_35_9_begin_pipeline = 1'd1;
	end
end
always @(posedge clk) begin
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_epilogue <= 1'd0;
	else begin
	if ((for_loop_src_fir_hw_cpp_35_9_pipeline_exit_cond & for_loop_src_fir_hw_cpp_35_9_active)) begin
		for_loop_src_fir_hw_cpp_35_9_epilogue <= 1'd1;
	end
	if (for_loop_src_fir_hw_cpp_35_9_pipeline_finishing) begin
		for_loop_src_fir_hw_cpp_35_9_epilogue <= 1'd0;
	end
	end
end
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_pipeline_finish = (for_loop_src_fir_hw_cpp_35_9_pipeline_finishing | for_loop_src_fir_hw_cpp_35_9_pipeline_finish_reg);
end
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_pipeline_finishing = ((for_loop_src_fir_hw_cpp_35_9_epilogue | for_loop_src_fir_hw_cpp_35_9_pipeline_exit_cond) & for_loop_src_fir_hw_cpp_35_9_only_last_stage_enabled);
end
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_only_last_stage_enabled = ((for_loop_src_fir_hw_cpp_35_9_num_active_iterations == 1'd1) & for_loop_src_fir_hw_cpp_35_9_state_enable_3);
end
always @(posedge clk) begin
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_num_active_iterations <= 1'd0;
	else begin
	if ((for_loop_src_fir_hw_cpp_35_9_inserting_new_iteration & ~(for_loop_src_fir_hw_cpp_35_9_state_enable_3))) begin
		for_loop_src_fir_hw_cpp_35_9_num_active_iterations <= (for_loop_src_fir_hw_cpp_35_9_num_active_iterations + 1'd1);
	end
	if ((~(for_loop_src_fir_hw_cpp_35_9_inserting_new_iteration) & for_loop_src_fir_hw_cpp_35_9_state_enable_3)) begin
		for_loop_src_fir_hw_cpp_35_9_num_active_iterations <= (for_loop_src_fir_hw_cpp_35_9_num_active_iterations - 1'd1);
	end
	end
end
always @(*) begin
	for_loop_src_fir_hw_cpp_35_9_inserting_new_iteration = ((~(for_loop_src_fir_hw_cpp_35_9_state_stall_0) & for_loop_src_fir_hw_cpp_35_9_II_counter[1]) & for_loop_src_fir_hw_cpp_35_9_start);
end
always @(posedge clk) begin
	for_loop_src_fir_hw_cpp_35_9_pipeline_finish_reg <= for_loop_src_fir_hw_cpp_35_9_pipeline_finish;
	if (reset)
		for_loop_src_fir_hw_cpp_35_9_pipeline_finish_reg <= 1'd0;
	else	if (for_loop_src_fir_hw_cpp_35_9_activate_pipeline) begin
		for_loop_src_fir_hw_cpp_35_9_pipeline_finish_reg <= 1'd0;
	end
end
always @(posedge clk) begin
	if (for_loop_src_fir_hw_cpp_35_9_activate_pipeline) begin
		for_loop_src_fir_hw_cpp_35_9_in_first_iteration_stage0 <= 1'd1;
	end
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_1) begin
		for_loop_src_fir_hw_cpp_35_9_in_first_iteration_stage0 <= 1'd0;
	end
end
always @(posedge clk) begin
	if (reset)
		input_l_consumed_valid <= 1'd0;
	else begin
	if (input_l_consumed_taken) begin
		input_l_consumed_valid <= 1'd0;
	end
	if ((input_l_ready & input_l_valid)) begin
		input_l_consumed_valid <= 1'd1;
	end
	end
end
always @(posedge clk) begin
	if ((input_l_ready & input_l_valid)) begin
		input_l_consumed_data <= input_l;
	end
end
always @(*) begin
	input_l_consumed_taken = 1'd0;
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		input_l_consumed_taken = ~(fsm_stall);
	end
end
assign fir_hw_BB_0_bit_concat_bit_select_operand_0 = 23'd0;
always @(*) begin
	fir_hw_buffer_left_clken_not_in_pipeline = (1'd1 & ~((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7)));
end
always @(*) begin
	fir_hw_buffer_left_clken_sequential_cond = ((fir_hw_buffer_left_clken_not_in_pipeline & (cur_state != SHLS_0)) & ~(fsm_stall));
end
always @(posedge clk) begin
	if (reset)
		input_r_consumed_valid <= 1'd0;
	else begin
	if (input_r_consumed_taken) begin
		input_r_consumed_valid <= 1'd0;
	end
	if ((input_r_ready & input_r_valid)) begin
		input_r_consumed_valid <= 1'd1;
	end
	end
end
always @(posedge clk) begin
	if ((input_r_ready & input_r_valid)) begin
		input_r_consumed_data <= input_r;
	end
end
always @(*) begin
	input_r_consumed_taken = 1'd0;
	if ((cur_state == SHLS_F_fir_hw_BB_0_1)) begin
		input_r_consumed_taken = ~(fsm_stall);
	end
end
always @(*) begin
	fir_hw_buffer_right_clken_not_in_pipeline = (1'd1 & ~((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7)));
end
always @(*) begin
	fir_hw_buffer_right_clken_sequential_cond = ((fir_hw_buffer_right_clken_not_in_pipeline & (cur_state != SHLS_0)) & ~(fsm_stall));
end
assign fir_hw_BB_0_bit_concat4_bit_select_operand_0 = 5'd0;
assign fir_hw_BB_1_bit_concat5_bit_select_operand_0 = 16'd0;
assign fir_hw_BB_2_bit_concat10_bit_select_operand_0 = 7'd0;
always @(posedge clk) begin
	res_data_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a <= ((fsm_stall & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_data_SHLS_F_fir_hw_BB_2_5_stalln_reg <= ~(fsm_stall);
end
always @(*) begin
	res_data_SHLS_F_fir_hw_BB_2_5_enable_cond_a = ((cur_state == SHLS_F_fir_hw_BB_2_5) & (res_data_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a | res_data_SHLS_F_fir_hw_BB_2_5_stalln_reg));
end
always @(posedge clk) begin
	res_last_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a <= ((fsm_stall & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_last_SHLS_F_fir_hw_BB_2_5_stalln_reg <= ~(fsm_stall);
end
always @(*) begin
	res_last_SHLS_F_fir_hw_BB_2_5_enable_cond_a = ((cur_state == SHLS_F_fir_hw_BB_2_5) & (res_last_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a | res_last_SHLS_F_fir_hw_BB_2_5_stalln_reg));
end
always @(posedge clk) begin
	res_keep_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a <= ((fsm_stall & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_keep_SHLS_F_fir_hw_BB_2_5_stalln_reg <= ~(fsm_stall);
end
always @(*) begin
	res_keep_SHLS_F_fir_hw_BB_2_5_enable_cond_a = ((cur_state == SHLS_F_fir_hw_BB_2_5) & (res_keep_SHLS_F_fir_hw_BB_2_5_not_accessed_due_to_stall_a | res_keep_SHLS_F_fir_hw_BB_2_5_stalln_reg));
end
assign fir_hw_BB_2_bit_concat13_bit_select_operand_0 = 7'd0;
always @(posedge clk) begin
	res_data_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a <= ((fsm_stall & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_data_SHLS_F_fir_hw_BB_2_6_stalln_reg <= ~(fsm_stall);
end
always @(*) begin
	res_data_SHLS_F_fir_hw_BB_2_6_enable_cond_a = ((cur_state == SHLS_F_fir_hw_BB_2_6) & (res_data_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a | res_data_SHLS_F_fir_hw_BB_2_6_stalln_reg));
end
always @(posedge clk) begin
	res_last_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a <= ((fsm_stall & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_last_SHLS_F_fir_hw_BB_2_6_stalln_reg <= ~(fsm_stall);
end
always @(*) begin
	res_last_SHLS_F_fir_hw_BB_2_6_enable_cond_a = ((cur_state == SHLS_F_fir_hw_BB_2_6) & (res_last_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a | res_last_SHLS_F_fir_hw_BB_2_6_stalln_reg));
end
always @(posedge clk) begin
	res_keep_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a <= ((fsm_stall & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_keep_SHLS_F_fir_hw_BB_2_6_stalln_reg <= ~(fsm_stall);
end
always @(*) begin
	res_keep_SHLS_F_fir_hw_BB_2_6_enable_cond_a = ((cur_state == SHLS_F_fir_hw_BB_2_6) & (res_keep_SHLS_F_fir_hw_BB_2_6_not_accessed_due_to_stall_a | res_keep_SHLS_F_fir_hw_BB_2_6_stalln_reg));
end
assign fir_hw_BB_3_bit_concat18_bit_select_operand_0 = 23'd0;
always @(*) begin
	fir_hw_buffer_left_read_data_wire_a = fir_hw_buffer_left_read_data_a;
end
always @(*) begin
	fir_hw_buffer_left_clken_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_1));
end
always @(*) begin
	fir_hw_buffer_right_read_data_wire_a = fir_hw_buffer_right_read_data_a;
end
always @(*) begin
	fir_hw_buffer_right_clken_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_1));
end
always @(*) begin
	coeff_hw_read_data_wire_a = coeff_hw_read_data_a;
end
always @(*) begin
	coeff_hw_clken_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_1));
end
always @(*) begin
	fir_hw_BB_3_ashr_width_extended = {{1{fir_hw_BB_3_ashr[12]}},fir_hw_BB_3_ashr};
end
assign fir_hw_BB_3_bit_concat32_bit_select_operand_0 = 17'd0;
assign fir_hw_BB_3_bit_concat32_bit_select_operand_4 = 6'd0;
assign fir_hw_BB_3_bit_concat35_bit_select_operand_0 = 17'd0;
always @(*) begin
	legup_mult_unsigned_17_17_1_0_clock = clk;
end
always @(*) begin
	legup_mult_unsigned_17_17_1_0_aclr = reset;
end
always @(*) begin
	legup_mult_unsigned_17_17_1_0_clken = legup_mult_fir_hw_BB_3_mul_en;
end
always @(*) begin
	legup_mult_unsigned_17_17_1_0_dataa = fir_hw_BB_3_bit_concat32;
end
always @(*) begin
	legup_mult_unsigned_17_17_1_0_datab = fir_hw_BB_3_bit_concat35;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul_out_actual = legup_mult_unsigned_17_17_1_0_result;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul_out = $signed(legup_mult_fir_hw_BB_3_mul_out_actual);
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul_en = legup_mult_fir_hw_BB_3_mul_en_pipeline_cond;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul_en_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_2));
end
assign fir_hw_BB_3_bit_concat37_bit_select_operand_0 = 16'd0;
assign fir_hw_BB_3_bit_concat37_bit_select_operand_4 = 6'd0;
always @(*) begin
	legup_mult_unsigned_17_27_2_1_clock = clk;
end
always @(*) begin
	legup_mult_unsigned_17_27_2_1_aclr = reset;
end
always @(*) begin
	legup_mult_unsigned_17_27_2_1_clken = legup_mult_fir_hw_BB_3_mul38_en;
end
always @(*) begin
	legup_mult_unsigned_17_27_2_1_dataa = fir_hw_BB_3_bit_concat37;
end
always @(*) begin
	legup_mult_unsigned_17_27_2_1_datab = fir_hw_BB_3_sext;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul38_out_actual = legup_mult_unsigned_17_27_2_1_result;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul38_out = legup_mult_fir_hw_BB_3_mul38_out_actual[31:0];
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul38_en = legup_mult_fir_hw_BB_3_mul38_en_pipeline_cond;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul38_en_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_3));
end
assign fir_hw_BB_3_bit_concat40_bit_select_operand_0 = 15'd0;
always @(*) begin
	legup_mult_signed_18_13_1_2_clock = clk;
end
always @(*) begin
	legup_mult_signed_18_13_1_2_aclr = reset;
end
always @(*) begin
	legup_mult_signed_18_13_1_2_clken = legup_mult_fir_hw_BB_3_mul41_en;
end
always @(*) begin
	legup_mult_signed_18_13_1_2_dataa = {1'd0,fir_hw_BB_3_bit_concat40};
end
always @(*) begin
	legup_mult_signed_18_13_1_2_datab = fir_hw_BB_3_sext39;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul41_out_actual = legup_mult_signed_18_13_1_2_result;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul41_out = legup_mult_fir_hw_BB_3_mul41_out_actual[29:0];
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul41_en = legup_mult_fir_hw_BB_3_mul41_en_pipeline_cond;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul41_en_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_2));
end
always @(*) begin
	legup_mult_signed_13_15_1_3_clock = clk;
end
always @(*) begin
	legup_mult_signed_13_15_1_3_aclr = reset;
end
always @(*) begin
	legup_mult_signed_13_15_1_3_clken = legup_mult_fir_hw_BB_3_mul44_en;
end
always @(*) begin
	legup_mult_signed_13_15_1_3_dataa = fir_hw_BB_3_sext42;
end
always @(*) begin
	legup_mult_signed_13_15_1_3_datab = fir_hw_BB_3_sext43;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul44_out_actual = legup_mult_signed_13_15_1_3_result;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul44_out = $signed(legup_mult_fir_hw_BB_3_mul44_out_actual);
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul44_en = legup_mult_fir_hw_BB_3_mul44_en_pipeline_cond;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul44_en_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_2));
end
always @(*) begin
	fir_hw_BB_3_sext45_width_extended = {{3{fir_hw_BB_3_sext45[29]}},fir_hw_BB_3_sext45};
end
always @(*) begin
	fir_hw_BB_3_bit_select46_width_extended = {{3{fir_hw_BB_3_bit_select46[29]}},fir_hw_BB_3_bit_select46};
end
assign fir_hw_BB_3_bit_concat47_bit_select_operand_2 = 17'd0;
always @(*) begin
	fir_hw_BB_3_sext49_width_extended = {{2{fir_hw_BB_3_sext49[27]}},fir_hw_BB_3_sext49};
end
always @(*) begin
	fir_hw_BB_3_bit_select50_width_extended = {{2{fir_hw_BB_3_bit_select50[27]}},fir_hw_BB_3_bit_select50};
end
assign fir_hw_BB_3_bit_concat51_bit_select_operand_2 = 17'd0;
assign fir_hw_BB_3_bit_concat54_bit_select_operand_0 = 17'd0;
assign fir_hw_BB_3_bit_concat54_bit_select_operand_4 = 17'd0;
always @(*) begin
	fir_hw_BB_3_sext55_width_extended = {{4{fir_hw_BB_3_sext55[46]}},fir_hw_BB_3_sext55};
end
always @(*) begin
	fir_hw_BB_3_bit_select56_width_extended = {{4{fir_hw_BB_3_bit_select56[46]}},fir_hw_BB_3_bit_select56};
end
assign fir_hw_BB_3_bit_concat57_bit_select_operand_2 = 17'd0;
assign fir_hw_BB_3_bit_concat60_bit_select_operand_2 = 34'd0;
always @(*) begin
	fir_hw_BB_3_ashr65_width_extended = {{1{fir_hw_BB_3_ashr65[12]}},fir_hw_BB_3_ashr65};
end
assign fir_hw_BB_3_bit_concat67_bit_select_operand_0 = 17'd0;
assign fir_hw_BB_3_bit_concat67_bit_select_operand_4 = 6'd0;
always @(*) begin
	legup_mult_unsigned_17_17_1_4_clock = clk;
end
always @(*) begin
	legup_mult_unsigned_17_17_1_4_aclr = reset;
end
always @(*) begin
	legup_mult_unsigned_17_17_1_4_clken = legup_mult_fir_hw_BB_3_mul68_en;
end
always @(*) begin
	legup_mult_unsigned_17_17_1_4_dataa = fir_hw_BB_3_bit_concat67;
end
always @(*) begin
	legup_mult_unsigned_17_17_1_4_datab = fir_hw_BB_3_bit_concat35;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul68_out_actual = legup_mult_unsigned_17_17_1_4_result;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul68_out = $signed(legup_mult_fir_hw_BB_3_mul68_out_actual);
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul68_en = legup_mult_fir_hw_BB_3_mul68_en_pipeline_cond;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul68_en_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_2));
end
assign fir_hw_BB_3_bit_concat69_bit_select_operand_0 = 16'd0;
assign fir_hw_BB_3_bit_concat69_bit_select_operand_4 = 6'd0;
always @(*) begin
	legup_mult_unsigned_17_27_2_5_clock = clk;
end
always @(*) begin
	legup_mult_unsigned_17_27_2_5_aclr = reset;
end
always @(*) begin
	legup_mult_unsigned_17_27_2_5_clken = legup_mult_fir_hw_BB_3_mul70_en;
end
always @(*) begin
	legup_mult_unsigned_17_27_2_5_dataa = fir_hw_BB_3_bit_concat69;
end
always @(*) begin
	legup_mult_unsigned_17_27_2_5_datab = fir_hw_BB_3_sext;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul70_out_actual = legup_mult_unsigned_17_27_2_5_result;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul70_out = legup_mult_fir_hw_BB_3_mul70_out_actual[31:0];
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul70_en = legup_mult_fir_hw_BB_3_mul70_en_pipeline_cond;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul70_en_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_3));
end
always @(*) begin
	legup_mult_signed_18_13_1_6_clock = clk;
end
always @(*) begin
	legup_mult_signed_18_13_1_6_aclr = reset;
end
always @(*) begin
	legup_mult_signed_18_13_1_6_clken = legup_mult_fir_hw_BB_3_mul72_en;
end
always @(*) begin
	legup_mult_signed_18_13_1_6_dataa = {1'd0,fir_hw_BB_3_bit_concat40};
end
always @(*) begin
	legup_mult_signed_18_13_1_6_datab = fir_hw_BB_3_sext71;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul72_out_actual = legup_mult_signed_18_13_1_6_result;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul72_out = legup_mult_fir_hw_BB_3_mul72_out_actual[29:0];
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul72_en = legup_mult_fir_hw_BB_3_mul72_en_pipeline_cond;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul72_en_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_2));
end
always @(*) begin
	legup_mult_signed_13_15_1_7_clock = clk;
end
always @(*) begin
	legup_mult_signed_13_15_1_7_aclr = reset;
end
always @(*) begin
	legup_mult_signed_13_15_1_7_clken = legup_mult_fir_hw_BB_3_mul74_en;
end
always @(*) begin
	legup_mult_signed_13_15_1_7_dataa = fir_hw_BB_3_sext73;
end
always @(*) begin
	legup_mult_signed_13_15_1_7_datab = fir_hw_BB_3_sext43;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul74_out_actual = legup_mult_signed_13_15_1_7_result;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul74_out = $signed(legup_mult_fir_hw_BB_3_mul74_out_actual);
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul74_en = legup_mult_fir_hw_BB_3_mul74_en_pipeline_cond;
end
always @(*) begin
	legup_mult_fir_hw_BB_3_mul74_en_pipeline_cond = ((cur_state == SHLS_pipeline_wait_for_loop_src_fir_hw_cpp_35_9_7) & ~(for_loop_src_fir_hw_cpp_35_9_state_stall_2));
end
always @(*) begin
	fir_hw_BB_3_sext75_width_extended = {{3{fir_hw_BB_3_sext75[29]}},fir_hw_BB_3_sext75};
end
always @(*) begin
	fir_hw_BB_3_bit_select76_width_extended = {{3{fir_hw_BB_3_bit_select76[29]}},fir_hw_BB_3_bit_select76};
end
assign fir_hw_BB_3_bit_concat77_bit_select_operand_2 = 17'd0;
always @(*) begin
	fir_hw_BB_3_sext79_width_extended = {{2{fir_hw_BB_3_sext79[27]}},fir_hw_BB_3_sext79};
end
always @(*) begin
	fir_hw_BB_3_bit_select80_width_extended = {{2{fir_hw_BB_3_bit_select80[27]}},fir_hw_BB_3_bit_select80};
end
assign fir_hw_BB_3_bit_concat81_bit_select_operand_2 = 17'd0;
assign fir_hw_BB_3_bit_concat84_bit_select_operand_0 = 17'd0;
assign fir_hw_BB_3_bit_concat84_bit_select_operand_4 = 17'd0;
always @(*) begin
	fir_hw_BB_3_sext85_width_extended = {{4{fir_hw_BB_3_sext85[46]}},fir_hw_BB_3_sext85};
end
always @(*) begin
	fir_hw_BB_3_bit_select86_width_extended = {{4{fir_hw_BB_3_bit_select86[46]}},fir_hw_BB_3_bit_select86};
end
assign fir_hw_BB_3_bit_concat87_bit_select_operand_2 = 17'd0;
assign fir_hw_BB_3_bit_concat90_bit_select_operand_2 = 34'd0;
always @(*) begin
	ready = (cur_state == SHLS_0);
end
always @(posedge clk) begin
	if ((cur_state == SHLS_0)) begin
		finish <= 1'd0;
	end
	if ((cur_state == SHLS_F_fir_hw_BB_5_11)) begin
		finish <= (fsm_stall == 1'd0);
	end
end
assign input_l_ready = (~(reset) & (~(input_l_consumed_valid) | input_l_consumed_taken));
assign input_r_ready = (~(reset) & (~(input_r_consumed_valid) | input_r_consumed_taken));
always @(*) begin
	res_data = 0;
	if ((cur_state == SHLS_F_fir_hw_BB_2_5)) begin
		res_data = fir_hw_BB_3_bit_select64_reg;
	end
	if ((cur_state == SHLS_F_fir_hw_BB_2_6)) begin
		res_data = fir_hw_BB_3_bit_select93_reg;
	end
end
always @(*) begin
	res_valid = 1'd0;
	if (res_data_SHLS_F_fir_hw_BB_2_5_enable_cond_a) begin
		res_valid = 1'd1;
	end
	if (res_last_SHLS_F_fir_hw_BB_2_5_enable_cond_a) begin
		res_valid = 1'd1;
	end
	if (res_keep_SHLS_F_fir_hw_BB_2_5_enable_cond_a) begin
		res_valid = 1'd1;
	end
	if (res_data_SHLS_F_fir_hw_BB_2_6_enable_cond_a) begin
		res_valid = 1'd1;
	end
	if (res_last_SHLS_F_fir_hw_BB_2_6_enable_cond_a) begin
		res_valid = 1'd1;
	end
	if (res_keep_SHLS_F_fir_hw_BB_2_6_enable_cond_a) begin
		res_valid = 1'd1;
	end
end
always @(*) begin
	res_last = 8'd0;
	if ((cur_state == SHLS_F_fir_hw_BB_2_5)) begin
		res_last = fir_hw_BB_2_bit_concat10;
	end
	if ((cur_state == SHLS_F_fir_hw_BB_2_6)) begin
		res_last = fir_hw_BB_2_bit_concat13_reg;
	end
end
always @(*) begin
	res_keep = 4'd0;
	if ((cur_state == SHLS_F_fir_hw_BB_2_5)) begin
		res_keep = -4'd1;
	end
	if ((cur_state == SHLS_F_fir_hw_BB_2_6)) begin
		res_keep = -4'd1;
	end
end
always @(*) begin
	coeff_hw_clken = coeff_hw_clken_pipeline_cond;
end
always @(*) begin
	coeff_hw_read_en_a = 1'd0;
	if (for_loop_src_fir_hw_cpp_35_9_state_enable_0) begin
		coeff_hw_read_en_a = 1'd1;
	end
end
always @(*) begin
	coeff_hw_address_a = 9'd0;
	if (for_loop_src_fir_hw_cpp_35_9_valid_bit_0) begin
		coeff_hw_address_a = (fir_hw_BB_3_addr26 >> 2'd2);
	end
end
assign coeff_hw_read_en_b = 1'd0;
assign coeff_hw_address_b = 9'd0;

endmodule



// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

module fir_hw_axi4slv #(
  parameter ADDR_WIDTH = 8,
  parameter AXI_DATA_WIDTH = 64,
  parameter AXI_ID_WIDTH = 5,
  parameter RAM_DATA_WIDTH = 64,
  parameter ENABLE_ACCEL_CTRL = 1,
  parameter NUM_RAM = 4,
  parameter READ_LATENCY = 1,
  localparam AXI_WSTRB_WIDTH = AXI_DATA_WIDTH/8,
  localparam RAM_WSTRB_WIDTH = RAM_DATA_WIDTH/8,
  parameter [3 * NUM_RAM - 1:0] RAM_DATA_SIZES = 0,
  localparam RAM_CONFIG_WIDTH = 2,
  parameter [NUM_RAM * ADDR_WIDTH       - 1:0] RAM_ADDR_OFFSET = 0,
  parameter [NUM_RAM * ADDR_WIDTH       - 1:0] RAM_ADDR_RANGE = 0,
  parameter [NUM_RAM * RAM_CONFIG_WIDTH - 1:0] RAM_CONFIG = 0,
  parameter NUM_ARG_WORDS = 4,
  parameter [NUM_RAM - 1:0] USES_BYTE_ENABLES = 0,
  parameter [NUM_RAM - 1:0] COALESCE_SAME_WORD_WRITES = 0,
  parameter [NUM_RAM - 1:0] USES_ACTGENO = 0,
  parameter RD_DATA_FIFO_DEPTH  = 8,
  parameter AXI_RRESP_ALWAYS_ZERO = 0
) (
  input                          clk,
  input                          reset,

  output                         axi4target_arready,
  input                          axi4target_arvalid,
  input  [ADDR_WIDTH      - 1:0] axi4target_araddr,
  input  [AXI_ID_WIDTH    - 1:0] axi4target_arid,
  input  [1:0]                   axi4target_arburst,
  input  [7:0]                   axi4target_arlen,
  input  [2:0]                   axi4target_arsize,
  input  [3:0]                   axi4target_arcache,   // Ignore.
  input  [1:0]                   axi4target_arlock,    // Ignore.
  input  [2:0]                   axi4target_arprot,    // Ignore.
  input  [3:0]                   axi4target_arqos,     // Ignore.
  input  [3:0]                   axi4target_arregion,  // Ignore.
  input  [0:0]                   axi4target_aruser,    // Ignore.

  input                          axi4target_rready,
  output                         axi4target_rvalid,
  output [AXI_DATA_WIDTH  - 1:0] axi4target_rdata,
  output [AXI_ID_WIDTH    - 1:0] axi4target_rid,
  output                         axi4target_rlast,
  output [1:0]                   axi4target_rresp,
  output [0:0]                   axi4target_ruser,

  output                         axi4target_awready,
  input                          axi4target_awvalid,
  input  [ADDR_WIDTH     - 1:0]  axi4target_awaddr,
  input  [AXI_ID_WIDTH   - 1:0]  axi4target_awid,
  input  [1:0]                   axi4target_awburst,
  input  [7:0]                   axi4target_awlen,
  input  [2:0]                   axi4target_awsize,
  input  [3:0]                   axi4target_awcache,   // Ignore.
  input  [1:0]                   axi4target_awlock,    // Ignore.
  input  [2:0]                   axi4target_awprot,    // Ignore.
  input  [3:0]                   axi4target_awqos,     // Ignore.
  input  [3:0]                   axi4target_awregion,  // Ignore.
  input  [0:0]                   axi4target_awuser,    // Ignore.

  output                         axi4target_wready,
  input                          axi4target_wvalid,
  input  [AXI_DATA_WIDTH  - 1:0] axi4target_wdata,
  input                          axi4target_wlast,
  input  [AXI_WSTRB_WIDTH - 1:0] axi4target_wstrb,
  input  [0:0]                   axi4target_wuser,     // Ignore.

  output                         axi4target_bvalid,
  input                          axi4target_bready,
  output [AXI_ID_WIDTH - 1:0]    axi4target_bid,
  output [1:0]                   axi4target_bresp,
  output [0:0]                   axi4target_buser,

  // Accelerator side interface.
  output                                    start,
  input                                     finish,
  output [NUM_ARG_WORDS * 32 - 1:0]         arguments,
  input  [63:0]                             return_val,
  input                                     accel_active,
  input  [NUM_RAM                   - 1:0]  accel_clken,
  input  [NUM_RAM * ADDR_WIDTH      - 1:0]  accel_address_a,
  input  [NUM_RAM * ADDR_WIDTH      - 1:0]  accel_address_b,
  input  [NUM_RAM                   - 1:0]  accel_read_en_a,
  input  [NUM_RAM                   - 1:0]  accel_read_en_b,
  input  [NUM_RAM                   - 1:0]  accel_write_en_a,
  input  [NUM_RAM                   - 1:0]  accel_write_en_b,
  input  [NUM_RAM * RAM_WSTRB_WIDTH - 1:0]  accel_byte_en_a,
  input  [NUM_RAM * RAM_WSTRB_WIDTH - 1:0]  accel_byte_en_b,
  input  [NUM_RAM * RAM_DATA_WIDTH  - 1:0]  accel_write_data_a,
  input  [NUM_RAM * RAM_DATA_WIDTH  - 1:0]  accel_write_data_b,
  output [NUM_RAM * RAM_DATA_WIDTH  - 1:0]  accel_read_data_a,
  output [NUM_RAM * RAM_DATA_WIDTH  - 1:0]  accel_read_data_b,
  output [NUM_RAM                   - 1:0]  accel_sb_correct_a,
  output [NUM_RAM                   - 1:0]  accel_sb_correct_b,
  output [NUM_RAM                   - 1:0]  accel_db_detect_a,
  output [NUM_RAM                   - 1:0]  accel_db_detect_b
);

  // True if we need to instantiate the accel_ctrl module, that is when the
  // accelerator's start/finish CSR or any argument is accessed via AXI slave.
  localparam NEEDS_ACCEL_CTRL = ENABLE_ACCEL_CTRL || (NUM_ARG_WORDS > 0);

  // There's a case where we need the accel controller, but don't have axi4t
  // control. In this scenario we don't have the control registers.
  localparam NUM_CTRL_WORDS = ENABLE_ACCEL_CTRL ? 3 : 0;

  // The width required to address the accel controller ram. This value must be at
  // least 1 due to the accel controller not being set up to handle the case where
  // an address is not necessary.
  localparam ACCEL_CTRL_ADDR_WIDTH = NUM_ARG_WORDS + NUM_CTRL_WORDS > 1 ? $clog2(NUM_ARG_WORDS + NUM_CTRL_WORDS) : 1; 

  // Update RAM related parameters to include the accelerator controller, which
  // handles start, finish, return value and arguments.
  localparam NUM_RAM_INTF = NUM_RAM + (NEEDS_ACCEL_CTRL ? 1 : 0);
  localparam [ADDR_WIDTH - 1:0] ACCEL_CTRL_RANGE = (NUM_CTRL_WORDS + NUM_ARG_WORDS) * 4;

  // Accelerator Controller (@ index 0) is a 32b module, hence it's data size is 2
  localparam [3 * NUM_RAM_INTF - 1:0] LOCAL_RAM_DATA_SIZES = NEEDS_ACCEL_CTRL ? {RAM_DATA_SIZES, 3'd2} : RAM_DATA_SIZES;

  localparam [NUM_RAM_INTF * ADDR_WIDTH - 1:0] LOCAL_RAM_ADDR_OFFSET = NEEDS_ACCEL_CTRL ? {RAM_ADDR_OFFSET, {ADDR_WIDTH{1'b0}}} : RAM_ADDR_OFFSET;
  localparam [NUM_RAM_INTF * ADDR_WIDTH - 1:0] LOCAL_RAM_ADDR_RANGE  = NEEDS_ACCEL_CTRL ? {RAM_ADDR_RANGE, ACCEL_CTRL_RANGE} : RAM_ADDR_RANGE;

  wire                        rd_req_last;
  wire [ADDR_WIDTH     - 1:0] rd_req_addr;
  wire [NUM_RAM_INTF   - 1:0] rd_req_valid;

  wire [RAM_DATA_WIDTH - 1:0] rd_resp_data;
  wire [NUM_RAM_INTF   - 1:0] rd_resp_last;
  wire [NUM_RAM_INTF   - 1:0] rd_resp_valid;

  wire [ADDR_WIDTH      - 1:0] wr_req_addr;
  wire [RAM_DATA_WIDTH  - 1:0] wr_req_data;
  wire [RAM_WSTRB_WIDTH - 1:0] wr_req_strb;
  wire [NUM_RAM_INTF   - 1:0]  wr_req_valid;

  fir_hw_axi4slv_read_controller #(
    .READ_LATENCY     (READ_LATENCY),
    .AXI_ADDR_WIDTH   (ADDR_WIDTH),
    .AXI_DATA_WIDTH   (AXI_DATA_WIDTH),
    .AXI_ID_WIDTH     (AXI_ID_WIDTH),
    .NUM_RAM_INTF     (NUM_RAM_INTF),
    .RAM_ADDR_OFFSET  (LOCAL_RAM_ADDR_OFFSET),
    .RAM_ADDR_RANGE   (LOCAL_RAM_ADDR_RANGE),
    .RAM_DATA_WIDTH   (RAM_DATA_WIDTH),
    .RAM_DATA_SIZES   (LOCAL_RAM_DATA_SIZES),
    .RD_DATA_FIFO_DEPTH(RD_DATA_FIFO_DEPTH),
    .AXI_RRESP_ALWAYS_ZERO(AXI_RRESP_ALWAYS_ZERO)
  ) rd_controller (
    .i_clk            (clk),
    .i_rst            (reset),

    .o_axi_arready    (axi4target_arready),
    .i_axi_arvalid    (axi4target_arvalid),
    .i_axi_araddr     (axi4target_araddr),
    .i_axi_arid       (axi4target_arid),
    .i_axi_arburst    (axi4target_arburst),
    .i_axi_arlen      (axi4target_arlen),
    .i_axi_arsize     (axi4target_arsize),
    .i_axi_arcache    (axi4target_arcache),
    .i_axi_arlock     (axi4target_arlock),
    .i_axi_arprot     (axi4target_arprot),
    .i_axi_arqos      (axi4target_arqos),
    .i_axi_arregion   (axi4target_arregion),
    .i_axi_aruser     (axi4target_aruser),

    .i_axi_rready     (axi4target_rready),
    .o_axi_rvalid     (axi4target_rvalid),
    .o_axi_rdata      (axi4target_rdata),
    .o_axi_rid        (axi4target_rid),
    .o_axi_rlast      (axi4target_rlast),
    .o_axi_rresp      (axi4target_rresp),
    .o_axi_ruser      (axi4target_ruser),
    .o_rd_valid       (rd_req_valid),
    .o_rd_last        (rd_req_last),
    .o_rd_addr        (rd_req_addr),
    .i_rd_data        (rd_resp_data),
    .i_rd_data_valid  (rd_resp_valid),
    .i_rd_data_last   (rd_resp_last)
  );

  fir_hw_axi4slv_write_controller #(
    .AXI_ADDR_WIDTH   (ADDR_WIDTH),
    .AXI_DATA_WIDTH   (AXI_DATA_WIDTH),
    .AXI_ID_WIDTH     (AXI_ID_WIDTH),
    .NUM_RAM_INTF     (NUM_RAM_INTF),
    .RAM_ADDR_OFFSET  (LOCAL_RAM_ADDR_OFFSET),
    .RAM_ADDR_RANGE   (LOCAL_RAM_ADDR_RANGE),
    .RAM_DATA_WIDTH   (RAM_DATA_WIDTH),
    .RAM_DATA_SIZES   (LOCAL_RAM_DATA_SIZES)
  ) wr_controller (
    .i_clk            (clk),
    .i_rst            (reset),

    .o_axi_awready    (axi4target_awready),
    .i_axi_awvalid    (axi4target_awvalid),
    .i_axi_awaddr     (axi4target_awaddr),
    .i_axi_awid       (axi4target_awid),
    .i_axi_awburst    (axi4target_awburst),
    .i_axi_awlen      (axi4target_awlen),
    .i_axi_awsize     (axi4target_awsize),
    .i_axi_awcache    (axi4target_awcache),
    .i_axi_awlock     (axi4target_awlock),
    .i_axi_awprot     (axi4target_awprot),
    .i_axi_awqos      (axi4target_awqos),
    .i_axi_awregion   (axi4target_awregion),
    .i_axi_awuser     (axi4target_awuser),

    .o_axi_wready     (axi4target_wready),
    .i_axi_wvalid     (axi4target_wvalid),
    .i_axi_wdata      (axi4target_wdata),
    .i_axi_wlast      (axi4target_wlast),
    .i_axi_wstrb      (axi4target_wstrb),
    .i_axi_wuser      (axi4target_wuser),

    .i_axi_bready     (axi4target_bready),
    .o_axi_bvalid     (axi4target_bvalid),
    .o_axi_bid        (axi4target_bid),
    .o_axi_bresp      (axi4target_bresp),
    .o_axi_buser      (axi4target_buser),

    .o_wr_valid       (wr_req_valid),
    .o_wr_addr        (wr_req_addr),
    .o_wr_data        (wr_req_data),
    .o_wr_strb        (wr_req_strb)
  );

  wire [NUM_RAM_INTF                   - 1:0] ram_rd = rd_req_valid;
  wire [NUM_RAM_INTF * ADDR_WIDTH      - 1:0] ram_rd_addr = {NUM_RAM_INTF{rd_req_addr}};
  wire [NUM_RAM_INTF * RAM_DATA_WIDTH  - 1:0] ram_rd_data;

  wire [NUM_RAM_INTF                   - 1:0] ram_wr = wr_req_valid;
  wire [NUM_RAM_INTF * ADDR_WIDTH      - 1:0] ram_wr_addr = {NUM_RAM_INTF{wr_req_addr}};
  wire [NUM_RAM_INTF * RAM_DATA_WIDTH  - 1:0] ram_wr_data = {NUM_RAM_INTF{wr_req_data}};
  wire [NUM_RAM_INTF * RAM_WSTRB_WIDTH - 1:0] ram_wr_strb = {NUM_RAM_INTF{wr_req_strb}};

  generate
    if (NEEDS_ACCEL_CTRL) begin: genAccelCtrl
      fir_hw_axi4slv_accel_ctrl #(
        .ENABLE_ACCEL_CTRL    (ENABLE_ACCEL_CTRL),
        .READ_LATENCY         (READ_LATENCY),
        .NUM_ARG_WORDS        (NUM_ARG_WORDS),
        .ADDR_WIDTH           (ACCEL_CTRL_ADDR_WIDTH)
      ) accel_controller (
        .i_clk                (clk),
        .i_reset              (reset),

        .i_ram_rd             (ram_rd[0]),
        .i_ram_rd_last        (rd_req_last),
        .i_ram_rd_addr        (ram_rd_addr[2 +: ACCEL_CTRL_ADDR_WIDTH]),

        .o_ram_rd_data        (ram_rd_data[0 +: 32]),
        .o_ram_rd_data_valid  (rd_resp_valid[0]),
        .o_ram_rd_data_last   (rd_resp_last[0]),

        .i_ram_wr             (ram_wr[0]),
        .i_ram_wr_addr        (ram_wr_addr[2 +: ACCEL_CTRL_ADDR_WIDTH]),
        .i_ram_wr_data        (ram_wr_data[0 +: 32]),
        .i_ram_wr_strb        (ram_wr_strb[0 +: 4]),

        .o_start              (start),
        .i_finish             (finish),
        .o_arguments          (arguments),
        .i_return_val         (return_val),
        .i_accel_active       (accel_active)
      );

    if (RAM_DATA_WIDTH > 32)
      assign ram_rd_data[RAM_DATA_WIDTH - 1 : 32] = 0;
    end

  endgenerate

  reg [RAM_DATA_WIDTH-1:0] tmp;
  always @(*) begin
    tmp = 0;
    for(integer j=0; j<NUM_RAM_INTF;j++) begin
      tmp = tmp | ({RAM_DATA_WIDTH{rd_resp_valid[j]}} & ram_rd_data[j*RAM_DATA_WIDTH +: RAM_DATA_WIDTH]);
    end
  end
  assign rd_resp_data = tmp;

  // Instantiate Actgeno RAMs.
  

  genvar i; 
  generate
    for (i = (NEEDS_ACCEL_CTRL ? 1 : 0); i < NUM_RAM_INTF; i = i + 1) begin: genRamLoop
      localparam ADDR_RANGE  = LOCAL_RAM_ADDR_RANGE[i * ADDR_WIDTH +: ADDR_WIDTH];
      // There's a specific case (one RAM only, power-of-2 bytes large) where
      // the ADDR_RANGE will overflow ADDR_WIDTH bits. In this case ADDR_RANGE
      // will be 0, but the RAM size will actually be 1 << ADDR_WIDTH.
      if (ADDR_RANGE == 0) begin
        // synthesis translate_off
        if (NUM_RAM_INTF != 1)
          $fatal(1, "ADDR_RANGE cannot be 0 with multiple interfaces.");
        // synthesis translate_on
      end
      localparam RAM_SIZE_IN_BYTES = (ADDR_RANGE)? ADDR_RANGE : 1 << ADDR_WIDTH;
      localparam RAM_DATA_SIZE      = LOCAL_RAM_DATA_SIZES[i * 3 +: 3];
      localparam RAM_BASE_ADDR      = LOCAL_RAM_ADDR_OFFSET[i * ADDR_WIDTH +: ADDR_WIDTH];
      localparam ram_data_width     = 1 << (RAM_DATA_SIZE + 3);
      localparam ram_wstrb_width    = 1 << RAM_DATA_SIZE;
      localparam NUM_WORDS          = RAM_SIZE_IN_BYTES >> RAM_DATA_SIZE;
      localparam addr_width         = ($clog2(NUM_WORDS) > 0) ? $clog2(NUM_WORDS) : 1;

      localparam DEDICATED_READ_WRITE_PORT = 0;
      localparam n = NEEDS_ACCEL_CTRL ? i - 1 : i;
      localparam uses_byte_enables  = USES_BYTE_ENABLES[n];
      localparam coalesce_same_word_writes = COALESCE_SAME_WORD_WRITES[n];
      localparam uses_actgeno  = USES_ACTGENO[n];

      wire [addr_width - 1 : 0] ram_rd_addr_i = (NUM_WORDS == 1) ? 0 : ram_rd_addr[i * ADDR_WIDTH + RAM_DATA_SIZE +: addr_width] - RAM_BASE_ADDR[RAM_DATA_SIZE +: addr_width];
      wire [addr_width - 1 : 0] ram_wr_addr_i = (NUM_WORDS == 1) ? 0 : ram_wr_addr[i * ADDR_WIDTH + RAM_DATA_SIZE +: addr_width] - RAM_BASE_ADDR[RAM_DATA_SIZE +: addr_width];

      if (NUM_WORDS == 1) begin: genReg
        fir_hw_axi4slv_register #(
          .READ_LATENCY       (READ_LATENCY),
          .DATA_WIDTH         (ram_data_width),
          .USES_BYTE_ENABLES  (uses_byte_enables)
        ) ram (
          .clk                (clk),
          .reset              (reset),
          .accel_active       (accel_active),

          .ram_rd             (ram_rd[i]),
          .ram_rd_last        (rd_req_last),
          .ram_rd_data        (ram_rd_data[i * RAM_DATA_WIDTH +: ram_data_width]),
          .ram_rd_data_valid  (rd_resp_valid[i]),
          .ram_rd_data_last   (rd_resp_last[i]),

          .ram_wr             (ram_wr[i]),
          .ram_wr_data        (ram_wr_data[i * RAM_DATA_WIDTH +: ram_data_width]),
          .ram_wr_strb        (ram_wr_strb[i * RAM_WSTRB_WIDTH +: ram_wstrb_width]),

          .accel_clken        (accel_clken[n]),
          .accel_write_en_a   (accel_write_en_a[n]),
          .accel_write_en_b   (accel_write_en_b[n]),
          .accel_byte_en_a    (accel_byte_en_a[n * RAM_WSTRB_WIDTH +: ram_wstrb_width]),
          .accel_byte_en_b    (accel_byte_en_b[n * RAM_WSTRB_WIDTH +: ram_wstrb_width]),
          .accel_write_data_a (accel_write_data_a[n * RAM_DATA_WIDTH +: ram_data_width]),
          .accel_write_data_b (accel_write_data_b[n * RAM_DATA_WIDTH +: ram_data_width]),
          .accel_read_data_a  (accel_read_data_a[n * RAM_DATA_WIDTH +: ram_data_width]),
          .accel_read_data_b  (accel_read_data_b[n * RAM_DATA_WIDTH +: ram_data_width])
        );
        assign accel_sb_correct_a[n] = 0;
        assign accel_sb_correct_b[n] = 0;
        assign accel_db_detect_a[n] = 0;
        assign accel_db_detect_b[n] = 0;
      end else if (uses_actgeno == 1) begin: skipActgeno

      end else if (RAM_CONFIG[n * RAM_CONFIG_WIDTH +: RAM_CONFIG_WIDTH] == DEDICATED_READ_WRITE_PORT) begin: genRam
        fir_hw_axi4slv_ram_dual_port_drwp #(
          .READ_LATENCY       (READ_LATENCY),
          .DATA_WIDTH         (ram_data_width),
          .NUM_WORDS          (NUM_WORDS),
          .USES_BYTE_ENABLES  (uses_byte_enables),
          .COALESCE_SAME_WORD_WRITES (coalesce_same_word_writes)
        ) ram (
          .clk                (clk),
          .reset              (reset),
          .accel_active       (accel_active),

          .ram_rd             (ram_rd[i]),
          .ram_rd_last        (rd_req_last),
          .ram_rd_addr        (ram_rd_addr_i),
          .ram_rd_data        (ram_rd_data[i * RAM_DATA_WIDTH +: ram_data_width]),
          .ram_rd_data_valid  (rd_resp_valid[i]),
          .ram_rd_data_last   (rd_resp_last[i]),

          .ram_wr             (ram_wr[i]),
          .ram_wr_addr        (ram_wr_addr_i),
          .ram_wr_data        (ram_wr_data[i * RAM_DATA_WIDTH +: ram_data_width]),
          .ram_wr_strb        (ram_wr_strb[i * RAM_WSTRB_WIDTH +: ram_wstrb_width]),

          .accel_clken        (accel_clken[n]),
          .accel_address_a    (accel_address_a[n * ADDR_WIDTH +: addr_width]),
          .accel_address_b    (accel_address_b[n * ADDR_WIDTH +: addr_width]),
          .accel_write_en_a   (accel_write_en_a[n]),
          .accel_write_en_b   (accel_write_en_b[n]),
          .accel_byte_en_a    (accel_byte_en_a[n * RAM_WSTRB_WIDTH +: ram_wstrb_width]),
          .accel_byte_en_b    (accel_byte_en_b[n * RAM_WSTRB_WIDTH +: ram_wstrb_width]),
          .accel_write_data_a (accel_write_data_a[n * RAM_DATA_WIDTH +: ram_data_width]),
          .accel_write_data_b (accel_write_data_b[n * RAM_DATA_WIDTH +: ram_data_width]),
          .accel_read_data_a  (accel_read_data_a[n * RAM_DATA_WIDTH +: ram_data_width]),
          .accel_read_data_b  (accel_read_data_b[n * RAM_DATA_WIDTH +: ram_data_width])
        );
        assign accel_sb_correct_a[n] = 0;
        assign accel_sb_correct_b[n] = 0;
        assign accel_db_detect_a[n] = 0;
        assign accel_db_detect_b[n] = 0;
      end
      // synthesis translate_off
      else begin
        always @ (*) $fatal(1, "Unknown RAM config.");
      end
      // synthesis translate_on

      if (RAM_DATA_WIDTH > ram_data_width) begin
        assign ram_rd_data[(i + 1) * RAM_DATA_WIDTH - 1 : i * RAM_DATA_WIDTH + ram_data_width] = 0;
        assign accel_read_data_a[(n + 1) * RAM_DATA_WIDTH - 1 : n * RAM_DATA_WIDTH + ram_data_width] = 0;
        assign accel_read_data_b[(n + 1) * RAM_DATA_WIDTH - 1 : n * RAM_DATA_WIDTH + ram_data_width] = 0;
      end
    end
  endgenerate

endmodule

// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

module fir_hw_axi4slv_accel_ctrl #(
  parameter   ENABLE_ACCEL_CTRL     = 1,
  parameter   NUM_ARG_WORDS         = 4,  // Each word is 4 bytes.
  parameter   READ_LATENCY          = 1,
  parameter   ADDR_WIDTH            = $clog2(NUM_ARG_WORDS + 3*ENABLE_ACCEL_CTRL),
  localparam  DATA_WIDTH            = 32,
  localparam  WSTRB_WIDTH           = DATA_WIDTH / 8
) (
  input                             i_clk,
  input                             i_reset,

  input                             i_ram_rd,
  input                             i_ram_rd_last,
  input      [ADDR_WIDTH - 1:0]     i_ram_rd_addr,
  output reg [DATA_WIDTH - 1:0]     o_ram_rd_data,
  output reg                        o_ram_rd_data_valid,
  output reg                        o_ram_rd_data_last,

  input                             i_ram_wr,
  input      [ADDR_WIDTH  - 1:0]    i_ram_wr_addr,
  input      [DATA_WIDTH  - 1:0]    i_ram_wr_data,
  input      [WSTRB_WIDTH - 1:0]    i_ram_wr_strb,

  // Interface to accelerator.
  output                            o_start,
  input                             i_finish,
  output reg [NUM_ARG_WORDS*32-1:0] o_arguments,
  input [63:0]                      i_return_val,

  // Indicate if the accelerator is active.
  input                             i_accel_active
);

  localparam RETURN_VAL_ADDR_L = 0;
  localparam RETURN_VAL_ADDR_U = 1;
  localparam START_STATUS_ADDR = 2;  // Reading this register will return status.
  localparam ARGUMENT_BASE_ADDR = ENABLE_ACCEL_CTRL ? 3 : 0;

  reg [DATA_WIDTH - 1:0] ram_rd_data_int = 0;
  reg                    ram_rd_data_valid_int = 0;
  reg                    ram_rd_data_last_int = 0;

  genvar i;

  //==========
  // Write side.
  //

  // Create masks to implement write strobe.
  wire [DATA_WIDTH - 1:0] update_mask;
  wire [DATA_WIDTH - 1:0] retain_mask = ~update_mask;
  generate
  for (i = 0; i < WSTRB_WIDTH; i = i + 1)
    assign update_mask[i * 8 +: 8] = {8{i_ram_wr_strb[i]}};
  endgenerate

  generate
  for (i = 0; i < NUM_ARG_WORDS; i = i + 1) begin
    always @ (posedge i_clk) begin
      if (i_reset)
        o_arguments[i * DATA_WIDTH +: DATA_WIDTH] <= 0;
      else if (i_ram_wr && (i_ram_wr_addr == ARGUMENT_BASE_ADDR + i))
        o_arguments[i * DATA_WIDTH +: DATA_WIDTH] <=
          (retain_mask & o_arguments[i * DATA_WIDTH +: DATA_WIDTH]) |
          (update_mask & i_ram_wr_data);
    end
  end
  endgenerate

  // Write to o_start.
  assign o_start = i_ram_wr & (i_ram_wr_addr == START_STATUS_ADDR) & i_ram_wr_strb[0];

  //==========
  // Read side.
  //
  always @ (posedge i_clk) begin
    if (i_reset) begin
      ram_rd_data_valid_int <= 0;
      ram_rd_data_last_int <= 0;
    end else begin
      ram_rd_data_valid_int <= i_ram_rd;
      ram_rd_data_last_int <= i_ram_rd_last;
    end
  end

  reg [63:0] return_val_reg;
  generate
  if (ENABLE_ACCEL_CTRL) begin
    always @ (posedge i_clk) begin
      if (i_reset) begin
        ram_rd_data_int <= 0;
      end else begin
        if (i_ram_rd) begin
          case (i_ram_rd_addr)
            RETURN_VAL_ADDR_L:
              ram_rd_data_int <= return_val_reg[31:0];
            RETURN_VAL_ADDR_U:
              ram_rd_data_int <= return_val_reg[63:32];
            START_STATUS_ADDR:
              ram_rd_data_int <= {31'b0, i_accel_active};
            default:
              if (NUM_ARG_WORDS != 0) begin
                ram_rd_data_int <= (o_arguments >> (32 * (i_ram_rd_addr - ARGUMENT_BASE_ADDR)));
              end else begin
                ram_rd_data_int <= 0;
              end
          endcase
        end
      end
    end
  end else begin  // No accelerator start/finish control.
    always @ (posedge i_clk) begin
      if (i_reset) begin
        ram_rd_data_int <= 0;
      end else if (i_ram_rd) begin
        if (NUM_ARG_WORDS != 0) begin
          ram_rd_data_int <= (o_arguments >> (32 * (i_ram_rd_addr - ARGUMENT_BASE_ADDR)));
        end else begin
          ram_rd_data_int <= 0;
        end
      end
    end
  end
  endgenerate

  fir_hw_shift_reg #(
    .DEPTH  (READ_LATENCY-1),
    .WIDTH  (1+1+DATA_WIDTH)
  )
  sr1 (
    .i_clk  (i_clk),
    .i_rst  (i_reset),
    .i_en   (1'b1),
    .i_data ({  ram_rd_data_valid_int,  // 1b
                ram_rd_data_last_int,   // 1b
                ram_rd_data_int }),     // DATA_WIDTH
    .o_data ({  o_ram_rd_data_valid,
                o_ram_rd_data_last,
                o_ram_rd_data })
  );

  always @ (posedge i_clk) begin
    if (i_reset)       return_val_reg <= 0;
    else if (i_finish) return_val_reg <= i_return_val;
  end
endmodule


// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

/*
  Dedicated read and write ports.
*/
  
module fir_hw_axi4slv_ram_dual_port_drwp #(
  parameter DATA_WIDTH = 64,
  parameter NUM_WORDS = 1,
  parameter READ_LATENCY = 1,
  parameter ADDR_WIDTH = ($clog2(NUM_WORDS) > 0) ? $clog2(NUM_WORDS) : 1,
  parameter WSTRB_WIDTH = DATA_WIDTH/8,
  parameter USES_BYTE_ENABLES = 0,
  parameter COALESCE_SAME_WORD_WRITES = 0
) (
  input          clk,
  input          reset,

  input          accel_active,

  input                     ram_rd,
  input                     ram_rd_last,
  input  [ADDR_WIDTH - 1:0] ram_rd_addr,
  output [DATA_WIDTH - 1:0] ram_rd_data,
  output                    ram_rd_data_last,
  output                    ram_rd_data_valid,

  input                      ram_wr,
  input  [ADDR_WIDTH  - 1:0] ram_wr_addr,
  input  [DATA_WIDTH  - 1:0] ram_wr_data,
  input  [WSTRB_WIDTH - 1:0] ram_wr_strb,

  // Accelerator side interface.
  input                      accel_clken,
  input  [ADDR_WIDTH  - 1:0] accel_address_a,
  input  [ADDR_WIDTH  - 1:0] accel_address_b,
  input                      accel_write_en_a,
  input                      accel_write_en_b,
  input  [WSTRB_WIDTH - 1:0] accel_byte_en_a,
  input  [WSTRB_WIDTH - 1:0] accel_byte_en_b,
  input  [DATA_WIDTH  - 1:0] accel_write_data_a,
  input  [DATA_WIDTH  - 1:0] accel_write_data_b,
  output [DATA_WIDTH  - 1:0] accel_read_data_a,
  output [DATA_WIDTH  - 1:0] accel_read_data_b
);

wire [DATA_WIDTH  - 1:0] read_data_a, read_data_b;

fir_hw_ram_dual_port ram_dual_port_inst (
  .clk                    (clk),
  .clken                  (accel_active ? accel_clken                 : 1'b1               ),

  .address_a              (accel_active ? accel_address_a             : ram_rd_addr        ),
  .write_en_a             (accel_active ? accel_write_en_a            : 1'b0               ),
  .write_data_a           (accel_active ? accel_write_data_a          : {DATA_WIDTH{1'b0}} ),
  .byte_en_a              (accel_active ? accel_byte_en_a             : {WSTRB_WIDTH{1'b0}}),
  .read_data_a            (read_data_a                                                     ),

  .address_b              (accel_active ? accel_address_b             : ram_wr_addr        ),
  .write_en_b             (accel_active ? accel_write_en_b            : ram_wr             ),
  .write_data_b           (accel_active ? accel_write_data_b          : ram_wr_data        ),
  .byte_en_b              (accel_active ? accel_byte_en_b             : ram_wr_strb        ),
  .read_data_b            (read_data_b                                                     )
);
defparam
  ram_dual_port_inst.width_a                   = DATA_WIDTH,
  ram_dual_port_inst.widthad_a                 = ADDR_WIDTH,
  ram_dual_port_inst.width_be_a                = WSTRB_WIDTH,
  ram_dual_port_inst.numwords_a                = NUM_WORDS,
  ram_dual_port_inst.width_b                   = DATA_WIDTH,
  ram_dual_port_inst.widthad_b                 = ADDR_WIDTH,
  ram_dual_port_inst.width_be_b                = WSTRB_WIDTH,
  ram_dual_port_inst.numwords_b                = NUM_WORDS,
  ram_dual_port_inst.latency                   = READ_LATENCY,
  ram_dual_port_inst.uses_byte_enables         = USES_BYTE_ENABLES,
  ram_dual_port_inst.coalesce_same_word_writes = COALESCE_SAME_WORD_WRITES;


assign ram_rd_data = read_data_a;
assign accel_read_data_a = read_data_a;
assign accel_read_data_b = read_data_b;

fir_hw_shift_reg #(READ_LATENCY, 1+1) sr1 (
  .i_clk  (clk), 
  .i_rst  (reset), 
  .i_en   (1'b1),
  .i_data ({  (ram_rd & !accel_active),   // 1b
              ram_rd_last}),              // 1b
  .o_data ({  ram_rd_data_valid,
              ram_rd_data_last})
);

endmodule


// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

/* 

TODO:
  1)  Add register pipe stages to improve timing. There are many things happening in one cycle.

*/
module fir_hw_axi4slv_read_controller #(
  // The READ_LATENCY parameter is used to match the RAM latency as the data read must be aligned 
  // with its metadata (AXI id, addr and size) taken from the read request.
  parameter READ_LATENCY = 1,
  // AXI parameters
  parameter AXI_ADDR_WIDTH = 8,
  parameter AXI_DATA_WIDTH = 64,
  parameter AXI_ID_WIDTH = 5,
  // RAM parameters
  parameter NUM_RAM_INTF = 4,
  parameter RAM_DATA_WIDTH = 64, 
  // The address offset of each RAM/RegFile in ascending order.
  parameter [NUM_RAM_INTF * AXI_ADDR_WIDTH - 1:0] RAM_ADDR_OFFSET = 0,
  parameter [NUM_RAM_INTF * AXI_ADDR_WIDTH - 1:0] RAM_ADDR_RANGE = 0,
  // Memory [i] is 2^RAM_DATA_SIZES[i] Bytes wide.  With 3 bits per memory size, the 
  // max value is 2^7 bytes, i.e. 128byte*8[bits/byte]=1024 bits wide per entry.
  parameter [3 * NUM_RAM_INTF - 1:0] RAM_DATA_SIZES = 0,
  // Having a FIFO on the read data path helps to absorb pushbacks from downstream. This may be
  // particularly important if the AXI interconnect gets really busy. 
  // It is recommended to always have the fifo, however, the instantiation can be disabled by
  // setting RD_DATA_FIFO_DEPTH = 0
  parameter RD_DATA_FIFO_DEPTH  = 8,
  // AXI_RRESP_ALWAYS_ZERO=1 forces the module to send an AXI RRESP=0 (no error) even if there was an actual
  // address decoding error. You want to enable this to be able to do memory read dumps over the 
  // address space of the accelerator and not hang the CPU or trigger any exception interrupt/signals. This 
  // feature may be useful for debugging, however, ignoring address decoding errors could mask a real software 
  // bug where reading an invalid address will return 0s.
  // By default this is disabled.
  parameter AXI_RRESP_ALWAYS_ZERO = 0
) (
  input                           i_clk,
  input                           i_rst,
  // AXI Address Read interface
  output                          o_axi_arready,
  input                           i_axi_arvalid,
  input   [AXI_ADDR_WIDTH - 1:0]  i_axi_araddr,
  input   [AXI_ID_WIDTH   - 1:0]  i_axi_arid,
  input   [1:0]                   i_axi_arburst,
  input   [7:0]                   i_axi_arlen,
  input   [2:0]                   i_axi_arsize,
  input   [3:0]                   i_axi_arcache,   // Ignored
  input   [1:0]                   i_axi_arlock,    // Ignored
  input   [2:0]                   i_axi_arprot,    // Ignored
  input   [3:0]                   i_axi_arqos,     // Ignored
  input   [3:0]                   i_axi_arregion,  // Ignored
  input   [0:0]                   i_axi_aruser,    // Ignored
  // AXI Read data interface
  input                           i_axi_rready,
  output                          o_axi_rvalid,
  output  [AXI_DATA_WIDTH - 1:0]  o_axi_rdata,
  output  [AXI_ID_WIDTH   - 1:0]  o_axi_rid,
  output                          o_axi_rlast,
  output  [1:0]                   o_axi_rresp,
  output  [0:0]                   o_axi_ruser,
  // Simple read address interface downstream
  output  [NUM_RAM_INTF   - 1:0]  o_rd_valid,
  output                          o_rd_last,
  output  [AXI_ADDR_WIDTH - 1:0]  o_rd_addr,

  // simple read data response interface 
  input   [RAM_DATA_WIDTH - 1:0]  i_rd_data,
  input   [NUM_RAM_INTF   - 1:0]  i_rd_data_last,
  input   [NUM_RAM_INTF   - 1:0]  i_rd_data_valid
);

localparam AXI_DATA_SIZE = $clog2(AXI_DATA_WIDTH / 8);

function integer max (input integer A, B);
  max = (A > B) ? A : B;
endfunction

//----------------------------------------------------
//                   Address path 
//----------------------------------------------------

// A signal indicating ready to take a new AR request, which is asserted when
// idle or returning the last read beat.
reg                       arready;
// A register indicating a rd request has been accepted and we are processing it.
// In other words, a sticky register of ar_handshake that is cleared when the read is done.
reg                       arvalid;  

reg   [2:0]               axi_arsize_r = 0;
reg   [AXI_ID_WIDTH- 1:0] rd_id = 0;
wire  [AXI_ID_WIDTH- 1:0] rd_id_delayed;
reg   [AXI_ID_WIDTH- 1:0] rd_id_delayed_r = 0;
wire  invalid_addr;
wire  invalid_addr_delayed;
reg   invalid_addr_delayed_r = 0;
wire  invalid_last;
wire  invalid_last_delayed;

wire  [NUM_RAM_INTF-1:0]  mem_select;
reg   [NUM_RAM_INTF-1:0]  mem_select_r = 0;
reg   [2:0]               mem_size;
reg   [2:0]               mem_size_r = 0;

reg                       fsm_cs = 0, fsm_ns; // current and next FSM states

// Total number of RAM-side read requests counter
reg   [14:0]              rd_req_cnt = 0; // 2^15 = 32768 bytes (MAX AXI transaction)
// Number of RAM-side read requests per AXI beat. Used only during upscaling. 
reg [2:0] rd_per_beat;

reg [AXI_ADDR_WIDTH-1:0]  rd_addr = 0;
wire addr_decode_error;

genvar i; generate
  if (RAM_ADDR_RANGE == 0) begin
    // synthesis translate_off
    always @(*) if (NUM_RAM_INTF != 1)
        $fatal(1, "RAM_ADDR_RANGE cannot be 0 with multiple interfaces.");
    // synthesis translate_on
    assign mem_select[0] = 1;  // Always selected.
  end else begin
    for (i = 0; i < NUM_RAM_INTF; i = i + 1) begin
      localparam [AXI_ADDR_WIDTH - 1:0] OFFSET = RAM_ADDR_OFFSET[i * AXI_ADDR_WIDTH +: AXI_ADDR_WIDTH];
      localparam [AXI_ADDR_WIDTH - 1:0] RANGE  = RAM_ADDR_RANGE [i * AXI_ADDR_WIDTH +: AXI_ADDR_WIDTH];
      localparam [AXI_ADDR_WIDTH    :0] LIMIT  = OFFSET + RANGE;
      assign mem_select[i] = (i_axi_araddr >= OFFSET) && (i_axi_araddr < LIMIT);
    end
  end
endgenerate

integer j;
always @(*) begin
  mem_size = 0;
  for (j = 0; j < NUM_RAM_INTF; j = j + 1) begin
    if (mem_select[j])
      mem_size = RAM_DATA_SIZES[j * 3 +: 3];
  end

  // synthesis translate_off
  // At the moment, either with the hard RISC-V in the MSS or with the 32b softcore 
  // Mi-V processor, the AXI bus data width is physically 64b wide (i.e. AXI_DATA_SIZE=3). 
  // That's why we can still have RAMs up to 64b (i.e. up to mem_size=3). 
  // If a single 32b AXI transaction is issued by the Mi-V CPU then AxSIZE=2 (i.e. 32b),
  // if a burst is issued by the Mi-V CPU/DMA then AxSIZE=3 (64b). Either way the
  // bus width is always 64b (AXI_DATA_SIZE=3).
  // 
  // At the moment, RAMs wider than 64b (e.g. 128b, mem_size=4) are NOT supported.
  //
  if (mem_size > AXI_DATA_SIZE ) begin
    $error("Currently when RAM size > AXI_DATA_SIZE is not a supported case.\n"); 
    $stop;
  end
  // synthesis translate_on
end

// TODO: Insert pipe stage here to improve timing -------

wire ar_handshake = i_axi_arvalid & o_axi_arready;

always @(posedge i_clk)
  if (i_rst) arvalid <= 0;
  else if (o_axi_arready) arvalid <= i_axi_arvalid;

assign o_axi_arready = arready | ~arvalid;

wire need_downscale = (i_axi_arsize > mem_size);
wire [2:0] scale_factor = need_downscale  ? (i_axi_arsize - mem_size) 
                                          : (mem_size - i_axi_arsize);
reg [2:0] scale_factor_r;
reg need_downscale_r;

always @(posedge i_clk) begin
  if (arvalid)
    rd_per_beat <= rd_per_beat - 1;

  if (ar_handshake) begin
    rd_per_beat <= (1 << scale_factor) - 1;
    scale_factor_r <= scale_factor;
    need_downscale_r <= need_downscale;
  end else if (rd_per_beat == 0) begin
    rd_per_beat <= (1 << scale_factor_r) - 1;
  end
end

// AxLEN is zero-based, where 0 means 1 beat.
wire [8:0] num_axi_beats = i_axi_arlen + 1'b1;

// When need_downscale = 1, the total number of RAM read requests is the number
// of AXI beats (considering the AXI burst length) multiplied by some scale factor, 
// which determines the number of RAM read requests per AXI beat. In other words, 
// we need to read more times from the RAM to return the amount of data as requested 
// by the AXI transaction. 
// A typical example of this is when we read 128b worth of data with ARSIZE=3 (64b),
// ARLEN=1 (2 beats) and ram_size=2 (32b). In this case we need 4 RAM read requests 
// to the 32b RAM to return the 128b worth of data to the AXI interface.  Once the 
// data is back from the RAM, it is necessary to aggregate two RAM words to return a 
// single AXI word.
// On the other hand, if need_downscale = 0, in theory we need less read requests 
// to the RAM to return the same amount of data if the ram_size is wider than the ARSIZE.
// However, to keep the logic simple, we just read the RAM as many times as AXI beats
// required and when the data is back from the RAM the bytes are just steered (shifted)
// in the way the AXI interface is expecting.
wire [14:0] num_rd_req = need_downscale ? (num_axi_beats << scale_factor)
                                        : num_axi_beats;

always @(posedge i_clk ) begin
  if (ar_handshake) begin
    mem_size_r    <= mem_size;
    mem_select_r  <= mem_select;
    axi_arsize_r  <= i_axi_arsize;
    rd_addr       <= i_axi_araddr;
    rd_id         <= i_axi_arid;
    rd_req_cnt    <= num_rd_req;
  end else begin
    if ((rd_per_beat == 0) | need_downscale_r) begin
      rd_addr     <= rd_addr + (1 << mem_size_r);
    end
    rd_req_cnt    <= rd_req_cnt - 1;
  end
end

// FSM sync
always @(posedge i_clk ) fsm_cs <= i_rst ? 0 : fsm_ns;
// FSM comb
always @(*) begin
  fsm_ns      = fsm_cs;
  arready     = 1;
  case(fsm_cs)  
    // First data read request to the RAM
    0:  if (arvalid) begin 
          if (rd_req_cnt != 1) begin
            arready = 0; 
            fsm_ns = 1;
          end
        end

    // Keep requesting data from the RAM as necessary
    1:  if (rd_req_cnt == 1) fsm_ns = 0; // last request
        else arready = 0;
  endcase
end
assign invalid_addr = ~|(mem_select_r) & arvalid;
assign invalid_last = o_rd_last;

assign o_rd_last  = arvalid & (rd_req_cnt == 1);
assign o_rd_valid = {NUM_RAM_INTF{arvalid}} & mem_select_r;
assign o_rd_addr  = rd_addr;

//----------------------------------------------------
//                Read data path
//----------------------------------------------------
wire [AXI_DATA_WIDTH - 1:0] rd_data_int;
reg  [AXI_DATA_WIDTH - 1:0] rd_data_packed;
reg [2:0]                   mem_rd_size;
reg [2:0]                   mem_rd_size_r = 0;
// wire                        or_data_valid = |i_rd_data_valid;
// wire                        or_data_last = |(i_rd_data_last & i_rd_data_valid);  
wire                        or_data_valid = |({i_rd_data_valid,invalid_addr_delayed});
wire                        or_data_last = |({(i_rd_data_last & i_rd_data_valid),(invalid_last_delayed & invalid_addr_delayed)});
reg [7:0]                   n_reads_per_beat = 0;
reg [7:0]                   rd_cnt;

reg [RAM_DATA_WIDTH - 1:0]  rd_data;
reg                         rd_data_last;
reg                         rd_data_valid;
wire [AXI_ADDR_WIDTH-1:0]   rd_addr_delayed;
wire [2:0]                  axi_arsize_r_delayed;
wire                        full;
wire                        empty;
wire                        wr_en;

reg                         backpressure_error;

always @(*) begin
  mem_rd_size = 0;
  for (j = 0; j < NUM_RAM_INTF; j = j + 1)
    if (i_rd_data_valid[j])
      mem_rd_size = RAM_DATA_SIZES[j * 3 +: 3];
end

// Detect the first word of an AXI transaction. This is used as reset to the
// counters used for the next transaction.
fir_hw_first_word fw ( 
  .i_clk            ( i_clk ), 
  .i_rst            ( i_rst ),
  .i_valid          ( or_data_valid ),
  .i_ready          ( axi_rready ),
  .i_last           ( or_data_last ),
  .o_first_wd       ( first_wd )
);

// Shift register to match the RAM latencies
fir_hw_shift_reg #( 
  .DEPTH( READ_LATENCY ), 
  .WIDTH( AXI_ADDR_WIDTH + AXI_ID_WIDTH + 5)) 
sr1 (
  .i_clk  (i_clk),
  .i_rst  (1'b0), 
  .i_en   (axi_rready),
  .i_data ({rd_addr          , rd_id          , axi_arsize_r        , invalid_addr        , invalid_last}), 
  .o_data ({rd_addr_delayed  , rd_id_delayed  , axi_arsize_r_delayed, invalid_addr_delayed, invalid_last_delayed})
);

// Upscale here means the xfer read more bytes than available in a single RAM word. E.g. read 64b from a 32b RAM
wire rd_need_upscale = (axi_arsize_r_delayed > mem_rd_size);
wire [2:0] rd_scale_factor = rd_need_upscale  ? (axi_arsize_r_delayed - mem_rd_size) 
                                              : (AXI_DATA_SIZE - axi_arsize_r_delayed);

reg [9:0] down_convert_shift_dist; // Widest AXI width is 1024-bits.
reg [9:0] down_convert_shift_dist_comb;
reg [9:0] down_convert_shift_dist_reg = 0;
always @(*) begin
  // We want to set down_convert_shift_dist = {rd_addr_delayed[max(mem_rd_size,
  // AXI_DATA_SIZE - 1):mem_rd_size], (3+mem_rd_size)'b0]}. However we need to properly handle
  // the cases where (1) the AXI_ADDR_WIDTH is less than mem_rd_size can be,
  // and (2) AXI_DATA_SIZE > mem_rd_size (so that previous expression would be
  // >10 bits wide. We can do this by:
  //   1. Extract only the bottom max(mem_rd_size, AXI_DATA_SIZE-1)+1 bits from
  //       rd_addr_delayed.
  //   2. Clear the bottom mem_rd_size bits
  //   3. Shift up by 3
  down_convert_shift_dist = rd_addr_delayed;
  down_convert_shift_dist &= ((1 << (max(mem_rd_size, AXI_DATA_SIZE - 1)) + 1) - 1);
  down_convert_shift_dist &= ~((1 << mem_rd_size) - 1);
  down_convert_shift_dist <<= 3;
end

always @(*) begin
  down_convert_shift_dist_comb = 0;
  if (rd_scale_factor != 0) begin
    down_convert_shift_dist_comb = down_convert_shift_dist;
  end

  if ( AXI_DATA_SIZE == mem_rd_size ) begin
    down_convert_shift_dist_comb = 0;
  end

  // if ( ( axi_arsize_r_delayed < mem_rd_size ) && (rd_scale_factor != 0)  ) begin
  //   down_convert_shift_dist_comb <= 0;
  // end
end

assign axi_rready = ~full | ~rd_data_valid;
always @(posedge i_clk) begin
  if (axi_rready) begin
    if (first_wd) begin
        n_reads_per_beat  <= (1 << (rd_scale_factor)) - 1;
        mem_rd_size_r     <= mem_rd_size;
    end

    // down_convert_shift_dist_reg <= rd_scale_factor != 0 ? down_convert_shift_dist : 0;

    down_convert_shift_dist_reg <= down_convert_shift_dist_comb;
    rd_data_valid               <= or_data_valid;
    rd_data_last                <= or_data_last;
    rd_id_delayed_r             <= rd_id_delayed;
    invalid_addr_delayed_r      <= invalid_addr_delayed;
    rd_data                     <= i_rd_data;
  end

  if (i_rst) begin // are these resets really necessary?
    down_convert_shift_dist_reg <= 0;
    rd_data_valid               <= 0;
    rd_data_last                <= 0;
    rd_id_delayed_r             <= 0;
    invalid_addr_delayed_r      <= 0;
    rd_data                     <= 0;
  end
end  

assign rd_data_int = rd_data_packed | (rd_data << down_convert_shift_dist_reg);

wire clear = i_rst | first_wd | (rd_data_last & rd_data_valid) | (rd_cnt == n_reads_per_beat);

always @(posedge i_clk)
  if ( clear ) rd_cnt <= 0;
  else if (rd_data_valid) rd_cnt <= rd_cnt + 1'b1;

always @(posedge i_clk)
  if ( clear | ~rd_need_upscale ) rd_data_packed <= 0;
  else rd_data_packed <= rd_data_int;

// TODO: Connect this backpressure error flag to the CPU
always @(posedge i_clk) begin
  backpressure_error <= i_rst ? 0 : backpressure_error | full;
  // synthesis translate_off
  if (full) begin
     $display("Detected backpressure_error.\n");
     $stop;
  end
  // synthesis translate_on
end

// Data is sent downstream when it's valid and
//  1) a full AXI word has been packed, or
//  2) a partial AXI word has been packed the last data from memory has been received
assign wr_en = rd_data_valid & ( rd_cnt == n_reads_per_beat | rd_data_last | ~rd_need_upscale);

generate 
  if (RD_DATA_FIFO_DEPTH > 0) begin:gen_fifo
    fir_hw_fwft_fifo #(
      .width                    ( 1 + AXI_ID_WIDTH + 1 + AXI_DATA_WIDTH ),
      .widthad                  ( $clog2(RD_DATA_FIFO_DEPTH) ),
      .depth                    ( RD_DATA_FIFO_DEPTH ),
      .almost_empty_value       ( 1 ),
      .almost_full_value        ( 1 ),
      .name                     ( "rddataff" ),
      .ramstyle                 ( "usram" ), // not "block" style
      .disable_full_empty_check (  0 )
    ) rdataff (
      .reset                    ( i_rst ),
      .clk                      ( i_clk ),
      .clken                    ( 1'b1  ),
      .full                     ( full  ),
      .almost_full              ( ),
      .write_en                 ( wr_en ),
      .write_data               ( {invalid_addr_delayed_r, rd_id_delayed_r,  rd_data_last, rd_data_int[0+:AXI_DATA_WIDTH]} ),
      .read_data                ( {addr_decode_error, o_axi_rid, o_axi_rlast,  o_axi_rdata} ),
      .read_en                  ( i_axi_rready ),
      .empty                    ( empty ),
      .almost_empty             ( ),
      .usedw                    ( )
    );
    assign o_axi_rvalid = ~empty;
  end else begin:gen_no_fifo
    // When there is no FIFO there can be no pushbacks from downstream, otherwise it would be an error.
    assign full         = o_axi_rvalid & ~i_axi_rready;
    assign o_axi_rdata  = rd_data_int;
    assign o_axi_rlast  = rd_data_last;
    assign o_axi_rvalid = wr_en;
  end
endgenerate

assign o_axi_rresp  = ((addr_decode_error == 0) || (AXI_RRESP_ALWAYS_ZERO == 1)) ? 2'b0 : /*SLVERR=*/2'b10;
assign o_axi_ruser  = 0;
endmodule


// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

// AXI slave side can read and write anytime for single element memory implemented as register.
`timescale 1 ns / 1 ns
module fir_hw_axi4slv_register # (
  parameter DATA_WIDTH = 64,
  parameter READ_LATENCY = 1,
  parameter WSTRB_WIDTH = DATA_WIDTH/8,
  parameter USES_BYTE_ENABLES = 0
) (
  input          clk,
  input          reset,

  input          accel_active,

  input                     ram_rd,
  input                     ram_rd_last,
  output [DATA_WIDTH - 1:0] ram_rd_data,
  output                    ram_rd_data_last,
  output                    ram_rd_data_valid,

  input                      ram_wr,
  input  [DATA_WIDTH  - 1:0] ram_wr_data,
  input  [WSTRB_WIDTH - 1:0] ram_wr_strb,

  // Accelerator side interface.
  input                      accel_clken,
  input                      accel_write_en_a,
  input                      accel_write_en_b,
  input  [WSTRB_WIDTH - 1:0] accel_byte_en_a,
  input  [WSTRB_WIDTH - 1:0] accel_byte_en_b,
  input  [DATA_WIDTH  - 1:0] accel_write_data_a,
  input  [DATA_WIDTH  - 1:0] accel_write_data_b,
  output [DATA_WIDTH  - 1:0] accel_read_data_a,
  output [DATA_WIDTH  - 1:0] accel_read_data_b
);

reg [DATA_WIDTH - 1:0] register [0:0];

// Write side logic.
wire accel_write_en = (accel_clken & accel_active & (accel_write_en_a | accel_write_en_b));
reg  [WSTRB_WIDTH - 1:0] write_strb;
wire  [DATA_WIDTH - 1:0] write_strb_mask;
reg  [DATA_WIDTH - 1:0] write_data;

always @ (*) begin
    if (accel_write_en) begin  // Accelerator write takes priority.
        write_strb = accel_write_en_a ?  accel_byte_en_a : accel_byte_en_b;
        write_data = accel_write_en_a ?  accel_write_data_a : accel_write_data_b;
    end else begin
        write_strb = ram_wr_strb;
        write_data = ram_wr_data;
    end
end

genvar i;
generate
    for (i = 0; i < DATA_WIDTH / 8; i++) begin
        assign write_strb_mask[i * 8 +: 8] = {8{write_strb[i]}};
    end
endgenerate

always @ (posedge clk) begin
    if (ram_wr | accel_write_en)
        register[0] <= (write_data & write_strb_mask) | (register[0] & ~write_strb_mask);
end

fir_hw_shift_reg #(READ_LATENCY, 1 + 1 + DATA_WIDTH) sr1 (
  .i_clk  (clk),
  .i_rst  (reset),
  .i_en   (1'b1),
  .i_data ({  ram_rd,
              ram_rd_last,
              register[0]}),
  .o_data ({  ram_rd_data_valid,
              ram_rd_data_last,
              ram_rd_data})
);

assign accel_read_data_a = ram_rd_data;
assign accel_read_data_b = ram_rd_data;

endmodule


// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

/* 
Notes:
  1)  As per AXI4 standard, the largest transaction is 256 beats (i.e. AxLEN=255) * 128 bytes/beat
      (i.e. AxSIZE=7). That's a total of 32768 Bytes/transaction

Some examples:

  1) Down scaling: from 64b (awsize=3) down to 16b (ram_size=1), 2 burst transactions, 2 beats/transaction, 

    Input:
      awlen       _[                      1|__[                      1]_
      awaddr      _[                    256]__[                 256+16]_ <-- 2beats * 8bytes = 16bytes
      axi_awvalid _/^^^^^^^^^^^^^^^^^^^^^^^\__/^^^^^^^^^^^^^^^^^^^^^^^\_
      axi_awready ______________________/^^\_______________________/^^\_
      wlast       ______________________/^^\_______________________/^^\_
      wdata       _[          a|          b]__[          c|          d]_  <-- 64b
      wvalid      _/^^^^^^^^^^^^^^^^^^^^^^^\__/^^^^^^^^^^^^^^^^^^^^^^^\_
      wready      __________/^^\________/^^\___________/^^\________/^^\_

    Output: 
      o_wr_addr   _[0 | 2| 4| 6| 8|10|12|14]__[16|18|20|22|24|26|28|30]_
      o_wr_data   _[a0|a1|a2|a3|b0|b1|b2|b3]__[c0|c1|c2|c3|d0|d1|d2|d3]_  <-- 16b
      o_wr_valid  _/^^^^^^^^^^^^^^^^^^^^^^^\__/^^^^^^^^^^^^^^^^^^^^^^^\_

  2) Up scaling: 2 burst transactions, 4 beats/transaction, from 32b (awsize=2) up to 64b (ram_size=3):

    Input:
      awlen       _[          3|__[          3]_ 
      awaddr      _[          0]__[         16]_
      awvalid     _/^^^^^^^^^^^\__/^^^^^^^^^^^\_
      awready     __________/^^\___________/^^\_
      wlast       __________/^^\___________/^^\_
      wdata       _[a0|a1|a2|a3]__[b0|b1|b2|b3]_ <-- 32b
      wvalid      _/^^^^^^^^^^^\__/^^^^^^^^^^^\_
      wready      _/^^^^^^^^^^^\__/^^^^^^^^^^^\_

    Output: 
      o_wr_addr   ___[    0|    8]__[   16|   24]__
      o_wr_strb   ___[0f|f0|0f|f0]__[0f|f0|0f|f0]__ <-- hex
      o_wr_data   ___[  |a1|  |a3]__[  |b1|  |b3]__ <--\_ _ 64b
                  ___[a0|a0|a2|a2]__[b0|b0|b2|b2]__ <--/
      o_wr_valid  ___/^^^^^^^^^^^\__/^^^^^^^^^^^\__

*/
module fir_hw_axi4slv_write_controller #(
  parameter AXI_ADDR_WIDTH = 8,
  parameter AXI_DATA_WIDTH = 64,
  parameter AXI_ID_WIDTH = 5,
  parameter NUM_RAM_INTF = 4,
  // The address offset of each RAM/RegFile in ascending order.
  parameter RAM_DATA_WIDTH = 64, 
  parameter [NUM_RAM_INTF * AXI_ADDR_WIDTH - 1:0] RAM_ADDR_OFFSET = 0,
  parameter [NUM_RAM_INTF * AXI_ADDR_WIDTH - 1:0] RAM_ADDR_RANGE = 0,
  // Memory [i] is 2^RAM_DATA_SIZES[i] Bytes wide.  With 3 bits per memory, the 
  // max value is 2^7 bytes, i.e. 128bytes*8bits/bytes=1024 bits wide.
  parameter [3 * NUM_RAM_INTF - 1:0] RAM_DATA_SIZES = 0 
) (
  input                         i_clk,
  input                         i_rst,
  // AXI address write interface
  output                        o_axi_awready,
  input                         i_axi_awvalid,
  input  [AXI_ADDR_WIDTH - 1:0] i_axi_awaddr,
  input  [AXI_ID_WIDTH   - 1:0] i_axi_awid,
  input  [1:0]                  i_axi_awburst,
  input  [7:0]                  i_axi_awlen,
  input  [2:0]                  i_axi_awsize,
  input  [3:0]                  i_axi_awcache,   // Ignored
  input  [1:0]                  i_axi_awlock,    // Ignored
  input  [2:0]                  i_axi_awprot,    // Ignored
  input  [3:0]                  i_axi_awqos,     // Ignored
  input  [3:0]                  i_axi_awregion,  // Ignored
  input  [0:0]                  i_axi_awuser,    // Ignored
  // AXI write data interface
  output                        o_axi_wready,
  input                         i_axi_wvalid,
  input  [AXI_DATA_WIDTH/8-1:0] i_axi_wstrb,
  input  [AXI_DATA_WIDTH - 1:0] i_axi_wdata,
  input  [0:0]                  i_axi_wuser,
  input                         i_axi_wlast,
// AXI write response interface
  input                         i_axi_bready,
  output                        o_axi_bvalid,
  output [AXI_ID_WIDTH   - 1:0] o_axi_bid,
  output [1:0]                  o_axi_bresp,
  output [0:0]                  o_axi_buser,
  // Simple write address interface downstream
  output [NUM_RAM_INTF   - 1:0] o_wr_valid,
  output [AXI_ADDR_WIDTH - 1:0] o_wr_addr,
  output [RAM_DATA_WIDTH - 1:0] o_wr_data,
  output [RAM_DATA_WIDTH/8-1:0] o_wr_strb
);

localparam AXI_DATA_SIZE = $clog2(AXI_DATA_WIDTH / 8);

function integer max;
  input integer A;
  input integer B;
  begin
    max = (A > B) ? A : B;
  end
endfunction

reg   [AXI_ADDR_WIDTH - 1:0]    axi_awaddr;
reg   [2:0]                     axi_awsize;
reg   [AXI_ID_WIDTH   - 1:0]    axi_awid;

reg                             axi_awvalid;
wire                            axi_awready;

reg   [AXI_DATA_WIDTH/8-1:0]    axi_wstrb;
reg   [AXI_DATA_WIDTH - 1:0]    axi_wdata;
reg                             axi_wlast;
reg                             axi_wvalid;
reg                             axi_wready;

reg                             axi_bvalid;


reg   [RAM_DATA_WIDTH-1:0]      ram_wdata;
reg   [RAM_DATA_WIDTH/8-1:0]    ram_wstrb;
reg                             ram_wvalid;
wire                            ram_wlast;
reg   [AXI_ADDR_WIDTH-1:0]      ram_waddr;

wire  [8:0]                     num_axi_beats;
reg   [14:0]                    n_wr_per_beat = 0; // 2^15 = 32768 bytes (MAX AXI transaction)
reg   [14:0]                    wr_req_cnt = 0; // 2^15 = 32768 bytes (MAX AXI transaction)
reg   [7:0]                     wr_cnt = 0;  // count the #. RAM writes done within an AXI beat

wire                            need_downscale;
reg                             need_downscale_d;
reg   [6:0]                     down_convert_shift_dist; // Widest AXI width is 128 bytes.

wire  [NUM_RAM_INTF-1:0]        mem_select;
reg   [NUM_RAM_INTF-1:0]        mem_select_d = 0;
reg   [2:0]                     mem_size;
reg   [2:0]                     mem_size_d = 0;

reg   [1:0]                     fsm_cs = 0, fsm_ns; // current and next FSM states

assign o_axi_bvalid = axi_bvalid;
assign o_axi_bid    = axi_awid;
assign o_axi_bresp  = 0;
assign o_axi_buser  = 0;


genvar i; 
generate
  if (RAM_ADDR_RANGE == 0) begin
    // synthesis translate_off
    always @(*) if (NUM_RAM_INTF != 1)
        $fatal(1, "RAM_ADDR_RANGE cannot be 0 with multiple interfaces.");
    // synthesis translate_on
    assign mem_select[0] = 1;  // Always selected.
  end else begin
    for (i = 0; i < NUM_RAM_INTF; i = i + 1) begin
      localparam [AXI_ADDR_WIDTH - 1:0] OFFSET = RAM_ADDR_OFFSET[i * AXI_ADDR_WIDTH +: AXI_ADDR_WIDTH];
      localparam [AXI_ADDR_WIDTH - 1:0] RANGE  = RAM_ADDR_RANGE [i * AXI_ADDR_WIDTH +: AXI_ADDR_WIDTH];
      localparam [AXI_ADDR_WIDTH    :0] LIMIT  = OFFSET + RANGE;
      assign mem_select[i] = (i_axi_awaddr >= OFFSET) && (i_axi_awaddr < LIMIT);
    end
  end
endgenerate

integer j;
always @(*) begin
  mem_size = 0;
  for (j = 0; j < NUM_RAM_INTF; j = j + 1)
    if (mem_select[j]) 
      mem_size    = RAM_DATA_SIZES[j * 3 +: 3];
  // synthesis translate_off
  // At the moment, either with the hard RISC-V in the MSS or with the 32b softcore 
  // Mi-V processor, the AXI bus data width is physically 64b wide (i.e. AXI_DATA_SIZE=3). 
  // That's why we can still have RAMs up to 64b (i.e. up to mem_size=3). 
  // If a single 32b AXI transaction is issued by the Mi-V CPU then AxSIZE=2 (i.e. 32b),
  // if a burst is issued by the Mi-V CPU/DMA then AxSIZE=3 (64b). Either way the
  // bus width is always 64b (AXI_DATA_SIZE=3).
  // 
  // At the moment, RAMs wider than 64b (e.g. 128b, mem_size=4) are NOT supported.
  //
  if (mem_size > AXI_DATA_SIZE ) begin
    $error("Currently when RAM size > AXI_DATA_SIZE is not a supported case.\n"); 
    $stop;
  end
  // synthesis translate_on
end

assign need_downscale = (i_axi_awsize > mem_size) ? 1 : 0;
wire [2:0] scale_factor = need_downscale  ? (i_axi_awsize - mem_size) 
                                          : (mem_size - i_axi_awsize);

assign num_axi_beats = i_axi_awlen + 1'b1;

wire [14:0] num_wr_req = need_downscale ? (num_axi_beats << scale_factor) 
                                        : num_axi_beats;

// AW handshake register control
always @(posedge i_clk) begin
  if (o_axi_awready) axi_awvalid <= i_axi_awvalid;
  if (i_rst) axi_awvalid <= 0;  
end
assign o_axi_awready = axi_awready | ~axi_awvalid;

// register the AW inputs
always @(posedge i_clk ) begin
  if (i_rst) begin
      mem_size_d        <= 0;
      mem_select_d      <= 0;
      axi_awsize        <= 0;
      need_downscale_d  <= 0; 
      n_wr_per_beat     <= 0;
  end else begin
    if (i_axi_awvalid && o_axi_awready) begin
      mem_size_d        <= mem_size;
      mem_select_d      <= mem_select;
      axi_awsize        <= i_axi_awsize;
      axi_awaddr        <= i_axi_awaddr;
      axi_awid          <= i_axi_awid;
      need_downscale_d  <= need_downscale; 
      n_wr_per_beat     <= (1 << (scale_factor)) - 1;
    end 
  end
end

// W register
always @(posedge i_clk) begin
  if (o_axi_wready) begin
    axi_wvalid <= i_axi_wvalid;
    if (i_axi_wvalid) begin
      axi_wlast <= i_axi_wlast;
      axi_wdata <= i_axi_wdata;
      axi_wstrb <= i_axi_wstrb;      
    end
  end
  if (i_rst) axi_wvalid <= 0;
end
assign o_axi_wready = axi_wready | ~axi_wvalid;

always @(posedge i_clk)
  if (i_rst) begin
    wr_req_cnt <= 0;
  end else begin
    if (i_axi_awvalid && o_axi_awready) wr_req_cnt <= num_wr_req;
    else if (ram_wvalid) wr_req_cnt <= wr_req_cnt - 1;
  end

assign ram_wlast = (wr_req_cnt == 1) & ram_wvalid;

// Dequeue the AXI AW word on the last write to the RAM 
assign axi_awready = ram_wlast;

wire clear = i_rst | axi_awready | (wr_cnt == n_wr_per_beat);

always @(posedge i_clk)
  if ( clear ) wr_cnt <= 0;
  else if(ram_wvalid) wr_cnt <= wr_cnt + 1'b1;

// FSM sync
always @(posedge i_clk ) fsm_cs <= i_rst ? 0 : fsm_ns;
// FSM comb
always @(*) begin
  // FSM default values
  fsm_ns          = fsm_cs;
  axi_wready  = 0;
  ram_wvalid  = 0;
  axi_bvalid  = 0;
  case(fsm_cs)  
    0:  begin // First transfer
      if (axi_awvalid && axi_wvalid) begin // sync AW and W channels
        ram_wvalid = 1;
        if (wr_req_cnt == 1) begin // only one write to RAM is required
          axi_wready = 1;
          axi_bvalid = 1;
          fsm_ns = i_axi_bready ? 0 : 2;
        end else begin  // more than one write is required
          fsm_ns = 1;
          axi_wready = (wr_cnt == n_wr_per_beat);
        end
      end
    end 

    1: begin // Keep writing until the last write request to the RAM
      if (axi_wvalid) begin
        ram_wvalid = 1;
        axi_wready = (wr_cnt == n_wr_per_beat);
        if (wr_req_cnt == 1) begin
          axi_bvalid = 1;
          fsm_ns = i_axi_bready ? 0 : 2;
        end
      end
    end

    2: begin // wait for the handshake
      axi_bvalid = 1;
      fsm_ns = i_axi_bready ? 0 : 2;
    end 
  endcase
end

always @(posedge i_clk)
  if (i_axi_awvalid && o_axi_awready) ram_waddr <= i_axi_awaddr;
  else if (ram_wvalid) ram_waddr <= ram_waddr + (1 << mem_size_d);

always @(*) begin
  // We want to write down_convert_shift_dist = {ram_waddr[max(mem_size_d,
  // AXI_DATA_SIZE-1):mem_size_d], (mem_size_d)'b0}
  down_convert_shift_dist = ram_waddr;
  // First, get ram_waddr[max(mem_size_d, AXI_DATA_SIZE-1) : 0]
  down_convert_shift_dist &= ((1 << (max(mem_size_d, AXI_DATA_SIZE - 1)) + 1) - 1);
  // Then clear the lower mem_size_d bits
  down_convert_shift_dist &= ~((1 << mem_size_d) - 1);
end

// Shift write data to the correct byte lanes in up-conversion case.
reg [$clog2(RAM_DATA_WIDTH) - 1:0] up_convert_shift_dist;
reg [6:0] byte_offset_in_ram_addr;

always @(*) begin
  // We want to set byte_offset_in_ram_addr = ram_waddr[mem_size_d-1:0], with
  // proper handling of cases where ram_waddr width is less than 7 and where
  // mem_size_d is 0 (in this case set result to 0. Do this by clearing the
  // upper (7 - mem_size_d) bits.
  byte_offset_in_ram_addr = ram_waddr & ((1 << mem_size_d) - 1);
  up_convert_shift_dist = ((byte_offset_in_ram_addr >> AXI_DATA_SIZE) << AXI_DATA_SIZE);
end

always @(*) begin
  if (AXI_DATA_SIZE > mem_size_d) begin  // Using always AXI_DATA_SIZE, not AWSIZE
    // The RAM downstream will discard the extra bytes beyond its width
    ram_wdata = axi_wdata >> (8 * down_convert_shift_dist);
    ram_wstrb = axi_wstrb >> down_convert_shift_dist;
  end else begin
    // This shifting relies on the strobes being connected to the RAM's byte enable signals
    ram_wdata = axi_wdata << (8 * up_convert_shift_dist);
    ram_wstrb = axi_wstrb << up_convert_shift_dist;
  end
end

assign o_wr_addr  = ram_waddr;
assign o_wr_data  = ram_wdata;
assign o_wr_strb  = ram_wstrb;
assign o_wr_valid = {NUM_RAM_INTF{ram_wvalid}} & mem_select_d;

endmodule


// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

/*
  This module detects the first word in an AXI transaction.
  
  o_first_wd        : asserted high as long as the first word is valid
  o_first_wd_pulse  : asserted high for a single cycle when a valid first word
                      is being acknowledged by i_ready
*/
module fir_hw_first_word (
    input   i_clk,
    input   i_rst,
    input   i_valid,
    input   i_ready,
    input   i_last,
    output  o_first_wd,
    output  o_first_wd_pulse
);

reg first_wd_flag;

always @(posedge i_clk) begin
  if (i_valid && i_ready && ~first_wd_flag) first_wd_flag <= 1;
  if (i_valid && i_ready && i_last) first_wd_flag <= 0;
  if (i_rst) first_wd_flag <= 0;
end

assign o_first_wd = i_valid & ~first_wd_flag;
assign o_first_wd_pulse = i_valid & i_ready & ~first_wd_flag;

endmodule

// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

/*
  A simple shift register of DEPTH elements deep and WIDTH bits wide.
*/
module fir_hw_shift_reg # (
  parameter DEPTH     = 1, // DEPTH=0 means no registers, just wires
  parameter WIDTH     = 1
) (
  input               i_clk,
  input               i_rst,
  input reg           i_en,
  input   [WIDTH-1:0] i_data,
  output  [WIDTH-1:0] o_data
);

  reg [WIDTH-1:0] shiftreg[DEPTH-1:0];

  generate 
    if (DEPTH==0) begin
      assign o_data = i_data;
    end else begin
      always @(posedge i_clk) begin
        if (i_rst) shiftreg<='{default:{WIDTH{1'b0}}};
        else begin
          if (i_en) begin
            shiftreg[0] <= i_data;
            for(integer i=0;i<DEPTH-1;i=i+1)
              shiftreg[i+1] <= shiftreg[i];
          end
        end
      end
      assign o_data = shiftreg[DEPTH-1];
    end
  endgenerate
endmodule

`timescale 1ns / 1ns
// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

module fir_hw_ram_dual_port (
	clk,
	clken,
	address_a,
	read_en_a,
	write_en_a,
	write_data_a,
	byte_en_a,
	read_data_a,
	address_b,
	read_en_b,
	write_en_b,
	write_data_b,
	byte_en_b,
	read_data_b
);

parameter  width_a = 1'd1;
parameter  widthad_a = 1'd1;
parameter  numwords_a = 1'd1;
parameter  width_be_a = 1'd1;
parameter  width_b = 1'd1;
parameter  widthad_b = 1'd1;
parameter  numwords_b = 1'd1;
parameter  width_be_b = 1'd1;
parameter  init_file = "";
parameter  latency = 1;
parameter  fpga_device = "";
parameter  uses_byte_enables = 1'd0;
parameter  coalesce_same_word_writes = 1'd0;  // for byte-enable access
parameter  synthesis_ram_style = "";

input  clk;
input  clken;
input [(widthad_a-1):0] address_a;
output wire [(width_a-1):0] read_data_a;
wire [(width_a-1):0] read_data_a_wire;
input  read_en_a;
input  write_en_a;
input [(width_a-1):0] write_data_a;
input [width_be_a-1:0] byte_en_a;
input [(widthad_b-1):0] address_b;
output wire [(width_b-1):0] read_data_b;
wire [(width_b-1):0] read_data_b_wire;
input  read_en_b;
input  write_en_b;
input [(width_b-1):0] write_data_b;
input [width_be_b-1:0] byte_en_b;

localparam input_latency = ((latency - 1) >> 1);
localparam output_latency = (latency - 1) - input_latency;
localparam output_latency_inner_module = ((output_latency >= 1) ? 1 : 0);
localparam output_latency_wrapper = output_latency - output_latency_inner_module;
integer latency_num;

// additional input registers if needed
reg [(widthad_a-1):0] address_a_reg[input_latency:0];
reg  write_en_a_reg[input_latency:0];
reg [(width_a-1):0] write_data_a_reg[input_latency:0];
reg [(width_be_a-1):0] byte_en_a_reg[input_latency:0];
reg [(widthad_b-1):0] address_b_reg[input_latency:0];
reg  write_en_b_reg[input_latency:0];
reg [(width_b-1):0] write_data_b_reg[input_latency:0];
reg [(width_be_b-1):0] byte_en_b_reg[input_latency:0];

always @(*) begin
    address_a_reg[0] = address_a;
    write_en_a_reg[0] = write_en_a;
    write_data_a_reg[0] = write_data_a;
    byte_en_a_reg[0] = byte_en_a;
    address_b_reg[0] = address_b;
    write_en_b_reg[0] = write_en_b;
    write_data_b_reg[0] = write_data_b;
    byte_en_b_reg[0] = byte_en_b;
end

always @(posedge clk)
if (clken) begin
    for (latency_num = 0; latency_num < input_latency; latency_num = latency_num + 1) begin
        address_a_reg[latency_num + 1] <= address_a_reg[latency_num];
        write_en_a_reg[latency_num + 1] <= write_en_a_reg[latency_num];
        write_data_a_reg[latency_num + 1] <= write_data_a_reg[latency_num];
        byte_en_a_reg[latency_num + 1] <= byte_en_a_reg[latency_num];
        address_b_reg[latency_num + 1] <= address_b_reg[latency_num];
        write_en_b_reg[latency_num + 1] <= write_en_b_reg[latency_num];
        write_data_b_reg[latency_num + 1] <= write_data_b_reg[latency_num];
        byte_en_b_reg[latency_num + 1] <= byte_en_b_reg[latency_num];
    end
end

generate
if (uses_byte_enables == 1) begin : byte_enabled

    wire [(width_a-1):0]    byte_enabled_write_data_a;
    wire [width_be_a-1:0]   byte_enabled_byte_en_a;

    wire                    byte_enabled_write_en_b;

    if (coalesce_same_word_writes == 1) begin : enable_coalescing

        //-------------------------------------------------------
        // When both ports are writing to the same word in memory,
        // both writes will be dynamically coalesced/combined
        // together and issued through port A. Implementation
        // is based on the assumption that no same byte in the
        // word will be attempted to be written by both ports.
        //
        // Depends on the implementation decision taken by the
        // synthesis tools, issue writes to the same word
        // (but different bytes) in both ports could be illegal.
        //-------------------------------------------------------

        wire                    coalesce;

        assign coalesce = ( write_en_a_reg[input_latency] & write_en_b_reg[input_latency] ) &&
                          ( address_a_reg[input_latency] == address_b_reg[input_latency] );

        genvar bank;
        for( bank=0; bank < width_be_a; bank = bank + 1 ) begin
            assign byte_enabled_write_data_a[bank*8 +: 8] = ( coalesce & byte_en_b_reg[input_latency][bank] )?
                                                            write_data_b_reg[input_latency][bank*8 +: 8] :
                                                            write_data_a_reg[input_latency][bank*8 +: 8];
        end

        assign byte_enabled_byte_en_a    = ( {width_be_a{coalesce}} & byte_en_b_reg[input_latency] ) | byte_en_a_reg[input_latency];

        assign byte_enabled_write_en_b   = ~coalesce & write_en_b_reg[input_latency];

    end else begin : no_coalescing

        assign byte_enabled_write_data_a = write_data_a_reg[input_latency];
        assign byte_enabled_byte_en_a    = byte_en_a_reg[input_latency];

        assign byte_enabled_write_en_b   = write_en_b_reg[input_latency];

    end

    // instantiate byte-enabled RAM
    fir_hw_ram_dual_port_byte_enabled ram_dual_port_byte_enabled_inst(
        .clk         ( clk                             ),
        .clken       ( clken                           ),
        .address_a   ( address_a_reg[input_latency]    ),
        .read_en_a   (                                 ),
        .write_en_a  ( write_en_a_reg[input_latency]   ),
        .write_data_a( byte_enabled_write_data_a       ),
        .byte_en_a   ( byte_enabled_byte_en_a          ),
        .read_data_a ( read_data_a_wire                ),
        .address_b   ( address_b_reg[input_latency]    ),
        .read_en_b   (                                 ),
        .write_en_b  ( byte_enabled_write_en_b         ),
        .write_data_b( write_data_b_reg[input_latency] ),
        .byte_en_b   ( byte_en_b_reg[input_latency]    ),
        .read_data_b ( read_data_b_wire                )
    );
    defparam
        ram_dual_port_byte_enabled_inst.width_a             = width_a,
        ram_dual_port_byte_enabled_inst.width_be_a          = width_be_a,
        ram_dual_port_byte_enabled_inst.widthad_a           = widthad_a,
        ram_dual_port_byte_enabled_inst.numwords_a          = numwords_a,
        ram_dual_port_byte_enabled_inst.width_b             = width_b,
        ram_dual_port_byte_enabled_inst.width_be_b          = width_be_b,
        ram_dual_port_byte_enabled_inst.widthad_b           = widthad_b,
        ram_dual_port_byte_enabled_inst.numwords_b          = numwords_b,
        ram_dual_port_byte_enabled_inst.use_output_reg      = output_latency_inner_module,
        ram_dual_port_byte_enabled_inst.fpga_device         = fpga_device,
        ram_dual_port_byte_enabled_inst.synthesis_ram_style = synthesis_ram_style,
        ram_dual_port_byte_enabled_inst.init_file           = init_file;

end else begin : regular

    // instantiate non-byte-enabled RAM
    fir_hw_ram_dual_port_regular ram_dual_port_regular_inst(
        .clk(clk),
        .clken(clken),
        .address_a(address_a_reg[input_latency]),
        .read_en_a(),
        .write_en_a(write_en_a_reg[input_latency]),
        .write_data_a(write_data_a_reg[input_latency]),        
        .read_data_a(read_data_a_wire),
        .address_b(address_b_reg[input_latency]),
        .read_en_b(),
        .write_en_b(write_en_b_reg[input_latency]),
        .write_data_b(write_data_b_reg[input_latency]),        
        .read_data_b(read_data_b_wire)
    );
    defparam
        ram_dual_port_regular_inst.width_a = width_a,        
        ram_dual_port_regular_inst.widthad_a = widthad_a,
        ram_dual_port_regular_inst.numwords_a = numwords_a,
        ram_dual_port_regular_inst.width_b = width_b,        
        ram_dual_port_regular_inst.widthad_b = widthad_b,
        ram_dual_port_regular_inst.numwords_b = numwords_b,
        ram_dual_port_regular_inst.use_output_reg = output_latency_inner_module,
        ram_dual_port_regular_inst.fpga_device = fpga_device,
        ram_dual_port_regular_inst.synthesis_ram_style = synthesis_ram_style,
        ram_dual_port_regular_inst.init_file = init_file;
   
end
endgenerate

// additional output registers if needed
reg [(width_a-1):0] read_data_a_reg[output_latency_wrapper:0];

always @(*) begin
   read_data_a_reg[0] <= read_data_a_wire;
end

always @(posedge clk)
if (clken) begin
    for (latency_num = 0; latency_num < output_latency_wrapper; latency_num = latency_num + 1) begin
       read_data_a_reg[latency_num + 1] <= read_data_a_reg[latency_num];
    end
end

assign read_data_a = read_data_a_reg[output_latency_wrapper];

reg [(width_b-1):0] read_data_b_reg[output_latency_wrapper:0];

always @(*) begin
    read_data_b_reg[0] <= read_data_b_wire;
end

always @(posedge clk)
if (clken) begin
    for (latency_num = 0; latency_num < output_latency_wrapper; latency_num = latency_num + 1) begin
        read_data_b_reg[latency_num + 1] <= read_data_b_reg[latency_num];
    end
end

assign read_data_b = read_data_b_reg[output_latency_wrapper];

endmodule

// define all the logic that will be used multiple times in different modules

`define SHLS_RAM_DUAL_PORT_INITIALIZATION      \
    initial begin                              \
        if (init_file != "")                   \
            $readmemb(init_file, ram);         \
    end

`define SHLS_RAM_DUAL_PORT_BYTE_ENABLE_LOGIC                                                                                        \
    always @ (posedge clk) begin                                                                                                    \
        if (clken) begin                                                                                                            \
            read_data_a_wire <= ram[address_a];                                                                                     \
            if (write_en_a) begin                                                                                                   \
                for(bank_num = 0; bank_num < width_be_a; bank_num = bank_num + 1) begin                                             \
                    if (byte_en_a[bank_num]) begin                                                                                  \
                        ram[address_a][bank_num * byte_width +: byte_width] <= write_data_a[bank_num * byte_width +: byte_width];   \
                    end                                                                                                             \
                end                                                                                                                 \
            end                                                                                                                     \
        end                                                                                                                         \
        if (clken) begin                                                                                                            \
            read_data_b_wire <= ram[address_b];                                                                                     \
            if (write_en_b) begin                                                                                                   \
                for(bank_num = 0; bank_num < width_be_b; bank_num = bank_num + 1) begin                                             \
                    if (byte_en_b[bank_num]) begin                                                                                  \
                        ram[address_b][bank_num * byte_width +: byte_width] <= write_data_b[bank_num * byte_width +: byte_width];   \
                    end                                                                                                             \
                end                                                                                                                 \
            end                                                                                                                     \
        end                                                                                                                         \
    end

`define SHLS_RAM_DUAL_PORT_LOGIC                        \
    always @ (posedge clk) begin                        \
        if (clken) begin                                \
            read_data_a_wire <= ram[address_a];         \
            if (write_en_a) begin                       \
                ram[address_a] <= write_data_a;         \
            end                                         \
        end                                             \
        if (clken) begin                                \
            read_data_b_wire <= ram[address_b];         \
            if (write_en_b) begin                       \
                ram[address_b] <= write_data_b;         \
            end                                         \
        end                                             \
    end 

`define SHLS_RAM_DUAL_PORT_LOGIC_OUTPUT_REG(DST_A, DST_B)                           \
    reg [(width_a-1):0] read_data_a_reg/* synthesis syn_allow_retiming = 0 */;      \
    always @(posedge clk)                                                           \
    if (clken) begin                                                                \
        read_data_a_reg <= read_data_a_wire;                                        \
    end                                                                             \
    assign DST_A = read_data_a_reg;                                                 \
    reg [(width_b-1):0] read_data_b_reg/* synthesis syn_allow_retiming = 0 */;      \
    always @(posedge clk)                                                           \
    if (clken) begin                                                                \
        read_data_b_reg <= read_data_b_wire;                                        \
    end                                                                             \
    assign DST_B = read_data_b_reg;

module fir_hw_ram_dual_port_byte_enabled (
	clk,
	clken,
	address_a,
	read_en_a,
	write_en_a,
	write_data_a,
	byte_en_a,
	read_data_a,
	address_b,
	read_en_b,
	write_en_b,
	write_data_b,
	byte_en_b,
	read_data_b
);

parameter  width_a = 1'd1;
parameter  widthad_a = 1'd1;
parameter  numwords_a = 1'd1;
parameter  width_be_a = 1'd1;
parameter  width_b = 1'd1;
parameter  widthad_b = 1'd1;
parameter  numwords_b = 1'd1;
parameter  width_be_b = 1'd1;
parameter  init_file = "";
parameter  use_output_reg = 0;
parameter  fpga_device = "";
parameter  synthesis_ram_style = "";
parameter  suppress_warning = 1; // recommend to turn it ON at RTL simulation when debugging post-synthesis problem
localparam  byte_width = 8;
integer bank_num;

input  clk;
input  clken;
input [(widthad_a-1):0] address_a;
output wire [(width_a-1):0] read_data_a;
reg [(width_a-1):0] read_data_a_wire;
input  read_en_a;
input  write_en_a;
input [(width_a-1):0] write_data_a;
input [width_be_a-1:0] byte_en_a;
input [(widthad_b-1):0] address_b;
output wire [(width_b-1):0] read_data_b;
reg [(width_b-1):0] read_data_b_wire;
input  read_en_b;
input  write_en_b;
input [(width_b-1):0] write_data_b;
input [width_be_b-1:0] byte_en_b;

generate
if (synthesis_ram_style == "registers" || (fpga_device == "SmartFusion2" && init_file != "") ) begin

    reg [width_a-1:0] ram [numwords_a-1:0] /* synthesis syn_ramstyle = "registers" */;
    `SHLS_RAM_DUAL_PORT_INITIALIZATION
    `SHLS_RAM_DUAL_PORT_BYTE_ENABLE_LOGIC

end else begin : ram

    reg [width_a-1:0] ram [numwords_a-1:0];
    `SHLS_RAM_DUAL_PORT_INITIALIZATION
    `SHLS_RAM_DUAL_PORT_BYTE_ENABLE_LOGIC

end
endgenerate

generate
if (use_output_reg == 1) begin

    // if using output registers
    `SHLS_RAM_DUAL_PORT_LOGIC_OUTPUT_REG(read_data_a,read_data_b)

end else begin

    // if not using output registers
    assign read_data_a = read_data_a_wire;
    assign read_data_b = read_data_b_wire;

end
endgenerate

    // Write collision check done at RTL simulation

    /* synthesis translate_off */
    always @(posedge clk) begin
       if( clken & write_en_a & write_en_b && (address_a == address_b) & |byte_en_a & |byte_en_b ) begin
	  if( |( byte_en_a & byte_en_b ) ) begin
	     $fatal(1, "Write conflict occurs at address %h (byte_en_a: 'b%b, byte_en_b: 'b%b)\n", address_a, byte_en_a, byte_en_b );
	  end
	  else if ( suppress_warning == 0 ) begin
	     $warning("Write conflict may occur at address %h depends on RTL synthesis results in later stage (byte_en_a: 'b%b, byte_en_b: 'b%b)\n", address_a, byte_en_a, byte_en_b);
	  end
       end
    end
    /* synthesis translate_on */

endmodule

module fir_hw_ram_dual_port_regular (
	clk,
	clken,
	address_a,
	read_en_a,
	write_en_a,
	write_data_a,
	read_data_a,
	address_b,
	read_en_b,
	write_en_b,
	write_data_b,
	read_data_b
);

parameter  width_a = 1'd1;
parameter  widthad_a = 1'd1;
parameter  numwords_a = 1'd1;
parameter  width_b = 1'd1;
parameter  widthad_b = 1'd1;
parameter  numwords_b = 1'd1;
parameter  init_file = "";
parameter  use_output_reg = 0;
parameter  fpga_device = "";
parameter  synthesis_ram_style = "";

input  clk;
input  clken;
input [(widthad_a-1):0] address_a;
output wire [(width_a-1):0] read_data_a;
reg [(width_a-1):0] read_data_a_wire;
input  read_en_a;
input  write_en_a;
input [(width_a-1):0] write_data_a;
input [(widthad_b-1):0] address_b;
output wire [(width_b-1):0] read_data_b;
reg [(width_b-1):0] read_data_b_wire;
input  read_en_b;
input  write_en_b;
input [(width_b-1):0] write_data_b;

generate
if (synthesis_ram_style == "registers" || (fpga_device == "SmartFusion2" && init_file != "") ) begin

    reg [width_a-1:0] ram [numwords_a-1:0] /* synthesis syn_ramstyle = "registers" */;
    `SHLS_RAM_DUAL_PORT_INITIALIZATION
    `SHLS_RAM_DUAL_PORT_LOGIC

end else begin : ram

    reg [width_a-1:0] ram [numwords_a-1:0];
    `SHLS_RAM_DUAL_PORT_INITIALIZATION
    `SHLS_RAM_DUAL_PORT_LOGIC

end
endgenerate

// read_data_{a,b}_int is the same net as read_data_{a,b}
wire [(width_a-1):0] read_data_a_int;
wire [(width_b-1):0] read_data_b_int;

generate
if (use_output_reg == 1) begin

    // if using output registers
    `SHLS_RAM_DUAL_PORT_LOGIC_OUTPUT_REG(read_data_a_int,read_data_b_int)

end else begin

    // if not using output registers
    assign read_data_a_int = read_data_a_wire;
    assign read_data_b_int = read_data_b_wire;

end

// To avoid inferring two port RAM when initialization is needed
// - It's observed that an inferred two RAM that requires initialized
//   content will miss the initialization configuration in the
//   synthesized circuit. To workaround this problem, we avoid
//   two port RAM to be inferred when initial content is required
//   by keeping read_data from both ports.
if ( init_file == "" || synthesis_ram_style == "registers" ||
     ( fpga_device != "" && fpga_device != "PolarFire" && fpga_device != "PolarFireSoC" ) ) begin
    assign read_data_a = read_data_a_int;
    assign read_data_b = read_data_b_int;
end
else begin
    wire [(width_a-1):0] read_data_a_int_keep /* synthesis syn_keep = 1 */;
    wire [(width_b-1):0] read_data_b_int_keep /* synthesis syn_keep = 1 */;

    assign read_data_a_int_keep = read_data_a_int;
    assign read_data_b_int_keep = read_data_b_int;

    assign read_data_a = read_data_a_int_keep;
    assign read_data_b = read_data_b_int_keep;
end

endgenerate
        
endmodule

`timescale 1 ns / 1 ns
// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

module fir_hw_fwft_fifo # (
    parameter width = 32,
    parameter widthad = 3,
    parameter depth = 8,
    parameter almost_empty_value = 1,
    parameter almost_full_value = depth - 1,
    parameter name = "",
    parameter ramstyle = "",
    parameter disable_full_empty_check = 0
) (
    input reset,
    input clk,
    input clken,
    // Interface to source.
    output full,
    output almost_full,
    input write_en,
    input [width-1:0] write_data,
    // Interface to sink.
    output empty,
    output almost_empty,
    input read_en,
    output [width-1:0] read_data,
    // Number of words stored in the FIFO.
    output [widthad:0] usedw
);

generate
if (depth == 0) begin
	assign full = !read_en;
	assign almost_full = 1'b1;
	assign empty = !write_en;
	assign almost_empty = 1'b1;
	assign read_data = write_data;
end else if (ramstyle == "block" || ramstyle == "") begin
    fir_hw_fwft_fifo_bram # (
      .width (width),
      .widthad (widthad),
      .depth (depth),
      .almost_empty_value (almost_empty_value),
      .almost_full_value (almost_full_value),
      .name (name),
      .ramstyle (ramstyle),
      .disable_full_empty_check (disable_full_empty_check)
    ) fwft_fifo_bram_inst (
      .reset (reset),
      .clk (clk),
      .clken (clken),
      .full (full),
      .almost_full (almost_full),
      .write_en (write_en),
      .write_data (write_data),
      .empty (empty),
      .almost_empty (almost_empty),
      .read_en (read_en),
      .read_data (read_data),
      .usedw (usedw)
    );
end else begin // if (ramstyle == distributed || ramstyle == registers)
    fir_hw_fwft_fifo_lutram # (
      .width (width),
      .widthad (widthad),
      .depth (depth),
      .almost_empty_value (almost_empty_value),
      .almost_full_value (almost_full_value),
      .name (name),
      .ramstyle (ramstyle),
      .disable_full_empty_check (disable_full_empty_check)
    ) fwft_fifo_lutram_inst (
      .reset (reset),
      .clk (clk),
      .clken (clken),
      .full (full),
      .almost_full (almost_full),
      .write_en (write_en),
      .write_data (write_data),
      .empty (empty),
      .almost_empty (almost_empty),
      .read_en (read_en),
      .read_data (read_data),
      .usedw (usedw)
    );
end
endgenerate

/* synthesis translate_off */

localparam NUM_CYCLES_BETWEEN_STALL_WARNINGS = 1000000;
integer num_empty_stall_cycles = 0;
integer num_full_stall_cycles = 0;
integer num_full_cycles = 0;

always @ (posedge clk) begin
    if (num_empty_stall_cycles == NUM_CYCLES_BETWEEN_STALL_WARNINGS) begin
        num_empty_stall_cycles = 0;
        if (name == "")
            $display("Warning: fifo_read() has been stalled for %d cycles due to FIFO being empty.", NUM_CYCLES_BETWEEN_STALL_WARNINGS);
        else
            $display("Warning: fifo_read() from %s has been stalled for %d cycles due to FIFO being empty.", name, NUM_CYCLES_BETWEEN_STALL_WARNINGS);
    end else if (empty & read_en)
        num_empty_stall_cycles = num_empty_stall_cycles + 1;
    else
        num_empty_stall_cycles = 0;


    if (num_full_stall_cycles == NUM_CYCLES_BETWEEN_STALL_WARNINGS) begin
        num_full_stall_cycles = 0;
        if (name == "")
            $display("Warning: fifo_write() has been stalled for %d cycles due to FIFO being full.", NUM_CYCLES_BETWEEN_STALL_WARNINGS);
        else
            $display("Warning: fifo_write() to %s has been stalled for %d cycles due to FIFO being full.", name, NUM_CYCLES_BETWEEN_STALL_WARNINGS);
    end else if (full & write_en)
        num_full_stall_cycles = num_full_stall_cycles + 1;
    else
        num_full_stall_cycles = 0;


    if (num_full_cycles == NUM_CYCLES_BETWEEN_STALL_WARNINGS) begin
        num_full_cycles = 0;
        $display("Warning: FIFO %s has been full for %d cycles. The circuit may have been stalled with no progress.", name, NUM_CYCLES_BETWEEN_STALL_WARNINGS);
        $display("         Please examine the simulation waveform and increase the corresponding FIFO depth if necessary.");
    end else if (full)
        num_full_cycles = num_full_cycles + 1;
    else
        num_full_cycles = 0;
end

/* synthesis translate_on */


endmodule

//--------------------------------------------
// Block-RAM-based FWFT FIFO implementation.
//--------------------------------------------

module fir_hw_fwft_fifo_bram # (
    parameter width = 32,
    parameter widthad = 4,
    parameter depth = 16,
    parameter almost_empty_value = 2,
    parameter almost_full_value = 2,
    parameter name = "",
    parameter ramstyle = "block",
    parameter disable_full_empty_check = 0
) (
    input reset,
    input clk,
    input clken,
    // Interface to source.
    output reg full,
    output almost_full,
    input write_en,
    input [width-1:0] write_data,
    // Interface to sink.
    output reg empty,
    output almost_empty,
    input read_en,
    output [width-1:0] read_data,
    // Number of words stored in the FIFO.
    output reg [widthad:0] usedw
);


// The output data from RAM.
wire [width-1:0] ram_data;
// An extra register to either sample fifo output or write_data.
reg [width-1:0] sample_data;
// Use a mealy FSM with 4 states to handle the special cases.
localparam [1:0] EMPTY = 2'd0;
localparam [1:0] FALL_THRU = 2'd1;
localparam [1:0] LEFT_OVER = 2'd2;
localparam [1:0] STEADY = 2'd3;
reg [1:0] state;

always @ (posedge clk) begin
    if (reset) begin
        state <= EMPTY;
        sample_data <= {width{1'b0}};
    end else begin
        case (state)
            EMPTY:
                if (write_en) begin
                    state <= FALL_THRU;
                    sample_data <= write_data;
                end else begin
                    state <= EMPTY;
                    sample_data <= {width{1'bX}};
                end
            FALL_THRU:  // usedw must be 1.
                if (write_en & ~read_en) begin
                    state <= STEADY;
                    sample_data <= {width{1'bX}};
                end else if (~write_en & read_en) begin
                    state <= EMPTY;
                    sample_data <= {width{1'bX}};
                end else if (~write_en & ~read_en) begin
                    state <= STEADY;
                    sample_data <= {width{1'bX}};
                end else begin // write_en & read_en
                    state <= FALL_THRU;
                    sample_data <= write_data;
                end
            LEFT_OVER:  // usedw must be > 1.
                if (usedw == 1 & read_en & ~write_en) begin
                    state <= EMPTY;
                    sample_data <= {width{1'bX}};
                end else if (usedw == 1 & read_en & write_en) begin
                    state <= FALL_THRU;
                    sample_data <= write_data;
                end else if (read_en) begin
                    state <= STEADY;
                    sample_data <= {width{1'bX}};
                end else begin // ~read_en
                    state <= LEFT_OVER;
                    sample_data <= sample_data;
                end
            STEADY:
                if (usedw == 1 & read_en & ~write_en) begin
                    state <= EMPTY;
                    sample_data <= {width{1'bX}};
                end else if (usedw == 1 & read_en & write_en) begin
                    state <= FALL_THRU;
                    sample_data <= write_data;
                end else if (~read_en) begin
                    state <= LEFT_OVER; // Only transition to LEFT_OVER.
                    sample_data <= ram_data;
                end else begin
                    state <= STEADY;
                    sample_data <= {width{1'bX}};
                end
            default: begin
                 state <= EMPTY;
                 sample_data <= {width{1'b0}};
            end
        endcase
    end
end

assign read_data = (state == LEFT_OVER || state == FALL_THRU) ? sample_data
                                                              : ram_data;

wire write_handshake = (write_en & ~full);
wire read_handshake = (read_en & ~empty);

// Full and empty.
generate
if (disable_full_empty_check) begin
    always @ (posedge clk) begin full <= 0; empty <= 0; end
end else begin
    always @ (posedge clk) begin
      if (reset) begin
        full <= 0;
        empty <= 1;
      end else begin
        full <= (full & ~read_handshake) | ((usedw == depth - 1) & (write_handshake & ~read_handshake));
        empty <= (empty & ~write_handshake) | ((usedw == 1) & (read_handshake & ~write_handshake));
      end
    end
end
endgenerate

// FIXME: may want to make almost_full/empty registers too.
assign almost_full = (usedw >= almost_full_value);
assign almost_empty= (usedw <= almost_empty_value);

// Read/Write port addresses.
reg [widthad-1:0] write_address = 0;
reg [widthad-1:0] read_address = 0;

function [widthad-1:0] increment;
    input [widthad-1:0] address;
    input integer depth;
    increment = (address == depth - 1) ? 0 : address + 1;
endfunction

always @ (posedge clk) begin
    if (reset) begin
        write_address <= 0;
        read_address <= 0;
    end else begin
        if (write_en & ~full)
            write_address <= increment(write_address, depth);
        if ((read_en & ~empty & ~(usedw==1)) | (state == FALL_THRU))
            read_address <= increment(read_address, depth);
    end
end

// Usedw.
always @ (posedge clk) begin
    if (reset) begin
        usedw <= 0;
    end else begin
        if (write_handshake & read_handshake)
            usedw <= usedw;
        else if (write_handshake)
            usedw <= usedw + 1;
        else if (read_handshake)
            usedw <= usedw - 1;
        else
            usedw <= usedw;
    end
end

/* synthesis translate_off */
initial
if ( widthad < $clog2(depth) ) begin
    $display("Error: Invalid FIFO parameter, widthad=%d, depth=%d.",
             widthad, depth);
    $finish;
end

always @ (posedge clk) begin
    if ( (state == EMPTY &&
            (usedw != 0 || read_address != write_address)) ||
         (state == FALL_THRU &&
            ((read_address + usedw) % depth != write_address)) ||
         (state == STEADY &&
            ((read_address + usedw - 1) % depth != write_address)) ||
         (state == LEFT_OVER &&
            ((read_address + usedw - 1) % depth != write_address)) ) begin
        $display("Error: FIFO read/write address mismatch with usedw.");
        $display("\t rd_addr=%d, wr_addr=%d, usedw=%d, state=%d.",
                    read_address, write_address, usedw, state);
        $finish;
    end
    if (usedw > depth) begin
        $display("Error: usedw goes out of range.");
        $finish;
    end
end

/* synthesis translate_on */

/// Instantiation of inferred ram.
fir_hw_simple_ram_dual_port_fifo ram_dual_port_inst (
  .clk( clk ),
  // Write port, i.e., interface to source.
  .waddr( write_address ),
  .wr_en( write_en & ~full ),
  .din( write_data ),
  // Read port, i.e., interface to sink.
  .raddr( read_address ),
  .dout( ram_data )
);
defparam ram_dual_port_inst.width = width;
defparam ram_dual_port_inst.widthad = widthad;
defparam ram_dual_port_inst.numwords = depth;

endmodule

//--------------------------------------------
// LUT-RAM-based FWFT FIFO implementation.
//--------------------------------------------

module fir_hw_fwft_fifo_lutram # (
    parameter width = 32,
    parameter widthad = 4,
    parameter depth = 16,
    parameter almost_empty_value = 2,
    parameter almost_full_value = 2,
    parameter name = "",
    parameter ramstyle = "",
    parameter disable_full_empty_check = 0
) (
    input reset,
    input clk,
    input clken,
    // Interface to source.
    output reg full,
    output almost_full,
    input write_en,
    input [width-1:0] write_data,
    // Interface to sink.
    output reg empty,
    output almost_empty,
    input read_en,
    output [width-1:0] read_data,
    // Number of words stored in the FIFO.
    output reg [widthad:0] usedw
);

wire write_handshake = (write_en & ~full);
wire read_handshake = (read_en & ~empty);

// Full and empty.
generate
if (disable_full_empty_check) begin
    always @ (posedge clk) begin full <= 0; empty <= 0; end
end else begin
    always @ (posedge clk) begin
      if (reset) begin
        full <= 0;
        empty <= 1;
      end else begin
        full <= (full & ~read_handshake) | ((usedw == depth - 1) & (write_handshake & ~read_handshake));
        empty <= (empty & ~write_handshake) | ((usedw == 1) & (read_handshake & ~write_handshake));
      end
    end
end
endgenerate

// FIXME: may want to make almost_full/empty registers too.
assign almost_full = (usedw >= almost_full_value);
assign almost_empty= (usedw <= almost_empty_value);

// Read/Write port addresses.
reg [widthad-1:0] write_address = 0;
reg [widthad-1:0] read_address = 0;

function [widthad-1:0] increment;
    input [widthad-1:0] address;
    input integer depth;
    increment = (address == depth - 1) ? 0 : address + 1;
endfunction

// The following 2 synchronous logic always blocks, for 'write_address'
// and 'read_address' respectively, were combined into 1 always block
// before. They are splitted to potentially make the RTL synthesis job
// easier, since we encountered a test case benefited from this change!
always @ (posedge clk) begin
    if (reset) begin
        write_address <= 0;
    end else if (write_en & ~full) begin
        write_address <= increment(write_address, depth);
    end
end

always @ (posedge clk) begin
    if (reset) begin
        read_address <= 0;
    end else if (read_en & ~empty) begin
        read_address <= increment(read_address, depth);
    end
end

// Usedw.
always @ (posedge clk) begin
    if (reset) begin
        usedw <= 0;
    end else begin
        if (write_handshake & read_handshake)
            usedw <= usedw;
        else if (write_handshake)
            usedw <= usedw + 1;
        else if (read_handshake)
            usedw <= usedw - 1;
        else
            usedw <= usedw;
    end
end

/* synthesis translate_off */
initial
if ( widthad < $clog2(depth) ) begin
    $display("Error: Invalid FIFO parameter, widthad=%d, depth=%d.",
             widthad, depth);
    $finish;
end

always @ (posedge clk) begin
    if ((read_address + usedw) % depth != write_address) begin
        $display("Error: FIFO read/write address mismatch with usedw.");
        $display("\t rd_addr=%d, wr_addr=%d, usedw=%d.",
                    read_address, write_address, usedw);
        $finish;
    end
    if (usedw > depth) begin
        $display("Error: usedw goes out of range.");
        $finish;
    end
end

/* synthesis translate_on */

/// Instantiation of inferred ram.
fir_hw_lutram_dual_port_fifo lutram_dual_port_inst (
	.clk( clk ),
	.clken( clken ),
    // Write port, i.e., interface to source.
	.address_a( write_address ),
	.wren_a( write_en & ~full ),
    .data_a( write_data ),
    // Read port, i.e., interface to sink.
	.address_b( read_address ),
	.q_b( read_data )
);
defparam lutram_dual_port_inst.width = width;
defparam lutram_dual_port_inst.widthad = widthad;
defparam lutram_dual_port_inst.numwords = depth;
defparam lutram_dual_port_inst.ramstyle = ramstyle;

endmodule


`timescale 1 ns / 1 ns
// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

// Adapted from Example 5 in:
// Inferring Microchip PolarFire RAM Blocks
// Synopsys® Application Note, April 2021
module fir_hw_simple_ram_dual_port_fifo # (
  parameter  width    = 1'd0,
  parameter  widthad  = 1'd0,
  parameter  numwords = 1'd0
) (
  input clk,
  input [(width-1):0] din,
  input wr_en,
  input [(widthad-1):0] waddr, raddr,
  output [(width-1):0] dout
);
  reg [(widthad-1):0] raddr_reg;
  reg [(width-1):0] mem [(numwords-1):0];

  assign dout = mem[raddr_reg];

  always @ (posedge clk) begin
    raddr_reg <= raddr;
    if (wr_en) begin
      mem[waddr] <= din;
    end
  end

endmodule

// Zero-cycle read latency and One-cycle write latency.
// Port A is for write, Port B is for read.
module fir_hw_lutram_dual_port_fifo # (
    parameter  width = 1'd0,
    parameter  widthad = 1'd0,
    parameter  numwords = 1'd0,
    parameter  ramstyle = ""
) (
    input  clk,
    input  clken,
    input [widthad - 1:0] address_a,
    input  wren_a,
    input [width - 1:0] data_a,
    input [widthad - 1:0] address_b,
    output [width - 1:0] q_b
);

generate
if (ramstyle == "registers") begin: _M
   (* ramstyle = ramstyle, ram_style = ramstyle *) reg [width - 1:0] ram [numwords - 1:0] /* synthesis syn_ramstyle = "registers" */;
end else begin: _M
   (* ramstyle = ramstyle, ram_style = ramstyle *) reg [width - 1:0] ram [numwords - 1:0] /* synthesis syn_ramstyle = "distributed" */;
end
endgenerate

assign q_b = _M.ram[address_b];

always @ (posedge clk) begin
  if (clken & wren_a) _M.ram[address_a] <= data_a;
end

endmodule


// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

`timescale 1ns / 1ns
module fir_hw_legup_mult # (
  parameter widtha = 32,
  parameter widthb = 32,
  parameter widthp = 64,
  parameter pipeline = 3,
  parameter representation = "UNSIGNED",
  parameter pipeline_stallable = 0 
) (
  input clock,
  input aclr,
  input clken,
  input [widtha-1:0] dataa,
  input [widthb-1:0] datab,
  output [widthp-1:0] result
);

generate 
if (pipeline == 0) begin
  // If the number of pipeline stages is 0, 
  // instantiate the combinational multiplier
  fir_hw_legup_mult_core legup_mult_core_inst(
      .dataa(dataa),
      .datab(datab),
      .result(result) 
  );
  defparam legup_mult_core_inst.widtha = widtha;
  defparam legup_mult_core_inst.widthb = widthb;
  defparam legup_mult_core_inst.widthp = widthp;
  defparam legup_mult_core_inst.representation = representation;

end else if (pipeline_stallable == 0) begin
  // If the datapath that uses the multiplier is not a pipeline or 
  // is a pipeline but is not stallable, or if the number of pipeline stages
  // is 1 or less,
  // simply instantiate the normal multiplier
  fir_hw_legup_mult_pipelined legup_mult_pipelined_inst(
      .clock(clock),
      .aclr(aclr),
      .clken(clken),
      .dataa(dataa),
      .datab(datab),
      .result(result) 
  );
  defparam legup_mult_pipelined_inst.widtha = widtha;
  defparam legup_mult_pipelined_inst.widthb = widthb;
  defparam legup_mult_pipelined_inst.widthp = widthp;
  defparam legup_mult_pipelined_inst.pipeline = pipeline;
  defparam legup_mult_pipelined_inst.representation = representation;

end 
endgenerate

endmodule


// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

// combinational generic multiplier
`timescale 1ns / 1ns

module fir_hw_legup_mult_core(
    dataa,
    datab,
    result  
);

parameter widtha = 32;
parameter widthb = 32;
parameter widthp = 64;
parameter representation = "UNSIGNED";

input [widtha-1:0] dataa;
input [widthb-1:0] datab;
output [widthp-1:0] result;

generate
if (representation == "UNSIGNED")
begin

    wire [widtha-1:0] dataa_in = dataa;
    wire [widthb-1:0] datab_in = datab;
    assign result = dataa_in * datab_in;

end else begin

    wire signed [widtha-1:0] dataa_in = dataa;
    wire signed [widthb-1:0] datab_in = datab;
    assign result = dataa_in * datab_in;

end
endgenerate

endmodule

// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

// generic multiplier with parameterizable pipeline stages
`timescale 1ns / 1ns
module fir_hw_legup_mult_pipelined(
    clock,
    aclr,
    clken, 
    dataa,
    datab,
    result  
);

parameter widtha = 32;
parameter widthb = 32;
parameter widthp = 64;
parameter pipeline = 3;
parameter representation = "UNSIGNED";
localparam num_input_pipelines = pipeline >> 1;
localparam num_output_pipelines = pipeline - num_input_pipelines;

input clock;
input aclr;
input clken; 

input [widtha-1:0] dataa;
input [widthb-1:0] datab;
output [widthp-1:0] result;

`define PIPELINED_MULTIPLIER_CORE                                                                                \
    integer input_stage;                                                                                         \
    always @(*)                                                                                                  \
    begin                                                                                                        \
      dataa_reg[0] <= dataa;                                                                                     \
      datab_reg[0] <= datab;                                                                                     \
    end                                                                                                          \
    always @(posedge clock)                                                                                      \
    begin                                                                                                        \
      for (input_stage=0; input_stage<num_input_pipelines; input_stage=input_stage+1) begin                      \
        if (aclr) begin                                                                                          \
          dataa_reg[input_stage+1] <= 'd0;                                                                       \
          datab_reg[input_stage+1] <= 'd0;                                                                       \
        end else if (clken) begin                                                                                \
          dataa_reg[input_stage+1] <= dataa_reg[input_stage];                                                    \
          datab_reg[input_stage+1] <= datab_reg[input_stage];                                                    \
        end                                                                                                      \
      end                                                                                                        \
    end                                                                                                          \
    integer output_stage;                                                                                        \
    always @(*)                                                                                                  \
    begin                                                                                                        \
      result_reg[0] <= dataa_reg[num_input_pipelines] * datab_reg[num_input_pipelines];                          \
    end                                                                                                          \
    always @(posedge clock)                                                                                      \
    begin                                                                                                        \
      for (output_stage=0; output_stage<num_output_pipelines; output_stage=output_stage+1) begin                 \
        if (aclr) begin                                                                                          \
           result_reg[output_stage+1] <= 'd0;                                                                    \
        end else if (clken) begin                                                                                \
           result_reg[output_stage+1] <= result_reg[output_stage];                                               \
        end                                                                                                      \
      end                                                                                                        \
    end                                                                                                          \
    assign result = result_reg[num_output_pipelines];

generate
if (representation == "UNSIGNED")
begin
    reg [widtha-1:0] dataa_reg [num_input_pipelines:0];
    reg [widthb-1:0] datab_reg [num_input_pipelines:0];
    reg [widthp-1:0] result_reg [num_output_pipelines:0];

    `PIPELINED_MULTIPLIER_CORE

end else begin

    reg signed [widtha-1:0] dataa_reg [num_input_pipelines:0];
    reg signed [widthb-1:0] datab_reg [num_input_pipelines:0];
    reg signed [widthp-1:0] result_reg [num_output_pipelines:0];

    `PIPELINED_MULTIPLIER_CORE

end
endgenerate

endmodule

`timescale 1 ns / 1 ns
// ©2022 Microchip Technology Inc. and its subsidiaries
//
// Subject to your compliance with these terms, you may use this Microchip
// software and any derivatives exclusively with Microchip products. You are
// responsible for complying with third party license terms applicable to your
// use of third party software (including open source software) that may
// accompany this Microchip software. SOFTWARE IS “AS IS.” NO WARRANTIES,
// WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING
// ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR
// A PARTICULAR PURPOSE. IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY
// INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST
// OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED,
// EVEN IF MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE
// FORESEEABLE.  TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP’S TOTAL
// LIABILITY ON ALL CLAIMS LATED TO THE SOFTWARE WILL NOT EXCEED AMOUNT OF
// FEES, IF ANY, YOU PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE. MICROCHIP
// OFFERS NO SUPPORT FOR THE SOFTWARE. YOU MAY CONTACT MICROCHIP AT
// https://www.microchip.com/en-us/support-and-training/design-help/client-support-services
// TO INQUIRE ABOUT SUPPORT SERVICES AND APPLICABLE FEES, IF AVAILABLE.

module fir_hw_ram_single_port
(
    clk,
    clken,
    read_en_a,
    write_en_a,
    address_a,
    byte_en_a,
    write_data_a,
    read_data_a
);
 
parameter  width_a = 1'd0;
parameter  widthad_a = 1'd0;
parameter  width_be_a = 1'd0;
parameter  numwords_a = 1'd0;
parameter  init_file = "";
parameter  latency = 1;
parameter  fpga_device = "";
parameter  synthesis_ram_style = "";
parameter  uses_byte_enables = 1'd0;
parameter  byte_width = 8;
parameter [width_a-1:0] init_value = 0; //only relevant if numwords_a == 1

input clk, clken, write_en_a, read_en_a;
input [widthad_a-1:0] address_a;
input [width_a-1:0] write_data_a;
input [width_be_a-1:0] byte_en_a;
output [width_a-1:0] read_data_a;
reg [(width_a-1):0] read_data_a_wire;

localparam output_latency = ((latency - 1) >> 1);
localparam input_latency = (latency - 1) - output_latency;
integer bank_num;
integer latency_num;

reg [(widthad_a-1):0] address_a_reg[input_latency:0];
reg  write_en_a_reg[input_latency:0];
reg [(width_a-1):0] write_data_a_reg[input_latency:0];
reg [(width_be_a-1):0] byte_en_a_reg[input_latency:0];

wire [widthad_a-1:0] wr_address_a;

//--------------------------------------------------------------------
// Temporary work around of Synplify problem
// - https://jira.microchip.com/browse/FPGASWOKR-3412
// - NOTE: Will not work, and also no solution if
//         (fpga_device == "PF2X" && init_file != "" && width_a ==1)
//---------------------------------------------------------------------
wire [width_a-1:0]         write_data_a_int;

generate
if      (fpga_device != "PF2X" || init_file == "" || width_a == 1) begin
    assign write_data_a_int   = write_data_a;
end
else if (width_a == 2) begin
    wire [1:0]             write_data_a_l  /* synthesis syn_keep = 1 */;

    assign write_data_a_l     = write_data_a[1:0];
    assign write_data_a_int   = write_data_a_l;
end
else begin
    wire [1:0]              write_data_a_l  /* synthesis syn_keep = 1 */;

    assign write_data_a_l     = write_data_a[1:0];
    assign write_data_a_int   = { write_data_a[width_a-1:2], write_data_a_l };
end
endgenerate

`ifdef RAM_SINGLE_PORT_SAME_RW_ADDRESS
assign wr_address_a = address_a_reg[input_latency];
`else
assign wr_address_a = write_en_a_reg[input_latency] ? address_a_reg[input_latency] : 0;
`endif

always @(*) begin
    address_a_reg[0] = address_a;
    write_en_a_reg[0] = write_en_a;
    write_data_a_reg[0] = write_data_a_int;
    byte_en_a_reg[0] = byte_en_a;
end

always @(posedge clk) begin
    if (clken) begin
        for (latency_num = 0; latency_num < input_latency; latency_num=latency_num+1) begin
            address_a_reg[latency_num+1] <= address_a_reg[latency_num];
            write_en_a_reg[latency_num+1] <= write_en_a_reg[latency_num];
            write_data_a_reg[latency_num+1] <= write_data_a_reg[latency_num];
            byte_en_a_reg[latency_num + 1] <= byte_en_a_reg[latency_num];
        end
    end
end


/***********************************************************************************************************/
/* This part is replicated many times depending on the `synthesis_ram_style`, so let's make a macro for it */
/***********************************************************************************************************/
`define RAM_SINGLE_PORT_POWER_UP_INITIALIZATION                                                                                                         \
    initial begin                                                                                                                                       \
        if (init_file != "")                                                                                                                            \
            $readmemb(init_file, ram);                                                                                                                  \
    end

`define RAM_SINGLE_PORT_READ_AND_WRITE_LOGIC                                                                                                            \
    if(uses_byte_enables == 1) begin                                                                                                                    \
        if (clken) begin                                                                                                                                \
            read_data_a_wire <= ram[address_a_reg[input_latency]];                                                                                      \
            if (write_en_a_reg[input_latency]) begin                                                                                                    \
                for(bank_num=0; bank_num < width_be_a; bank_num = bank_num + 1) begin                                                                   \
                    if (byte_en_a_reg[input_latency][bank_num])                                                                                         \
                        ram[wr_address_a][bank_num * byte_width +: byte_width] <= write_data_a_reg[input_latency][bank_num * byte_width +: byte_width]; \
                end                                                                                                                                     \
            end                                                                                                                                         \
        end                                                                                                                                             \
    end                                                                                                                                                 \
    else begin                                                                                                                                          \
        if (clken) begin                                                                                                                                \
            read_data_a_wire <= ram[address_a_reg[input_latency]];                                                                                      \
            if (write_en_a_reg[input_latency])                                                                                                          \
                ram[wr_address_a] <= write_data_a_reg[input_latency];                                                                                   \
        end                                                                                                                                             \
    end
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/


generate
if (synthesis_ram_style == "registers" || (fpga_device == "SmartFusion2" && init_file != "") ) begin
    /* SmartFusion2 LSRAM doesn't have support for mem init, but due to a Synplify limitation, Synplify
     * can actually map a logical RAM with mem init to a LSRAM. This is a functional issue.
     * To get around this issue, we need to force Synplify to use only LUT in this case
     */
    reg [width_a-1:0] ram [numwords_a-1:0] /* synthesis syn_ramstyle = "registers" */;
    `RAM_SINGLE_PORT_POWER_UP_INITIALIZATION
    always @ (posedge clk) begin
        `RAM_SINGLE_PORT_READ_AND_WRITE_LOGIC
    end
end
else if (synthesis_ram_style == "lsram") begin
    reg [width_a-1:0] ram [numwords_a-1:0] /* synthesis syn_ramstyle = "lsram" */;
    `RAM_SINGLE_PORT_POWER_UP_INITIALIZATION
    always @ (posedge clk) begin
        `RAM_SINGLE_PORT_READ_AND_WRITE_LOGIC
    end
end
else if (synthesis_ram_style == "uram") begin
    reg [width_a-1:0] ram [numwords_a-1:0] /* synthesis syn_ramstyle = "uram" */;
    `RAM_SINGLE_PORT_POWER_UP_INITIALIZATION
    always @ (posedge clk) begin
        `RAM_SINGLE_PORT_READ_AND_WRITE_LOGIC
    end
end
else begin
    reg [width_a-1:0] ram [numwords_a-1:0];
    `RAM_SINGLE_PORT_POWER_UP_INITIALIZATION
    always @ (posedge clk) begin
        `RAM_SINGLE_PORT_READ_AND_WRITE_LOGIC
    end
end
endgenerate


reg [(width_a-1):0] read_data_a_reg[output_latency:0];

always @(*) begin
   read_data_a_reg[0] <= read_data_a_wire;
end

always @(posedge clk) begin
    if (clken) begin
        for (latency_num = 0; latency_num < output_latency; latency_num=latency_num+1) begin
            read_data_a_reg[latency_num+1] <= read_data_a_reg[latency_num];
        end
    end
end

assign read_data_a = read_data_a_reg[output_latency];


endmodule

