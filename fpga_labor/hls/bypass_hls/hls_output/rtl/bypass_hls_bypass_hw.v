// ----------------------------------------------------------------------------
// Smart High-Level Synthesis Tool Version 2025.2
// Copyright (c) 2015-2025 Microchip Technology Inc. All Rights Reserved.
// For support, please visit https://onlinedocs.microchip.com/v2/keyword-lookup?keyword=techsupport&redirect=true&version=latest.
// Date: Fri May 29 17:57:38 2026
// ----------------------------------------------------------------------------
`define MEMORY_CONTROLLER_ADDR_SIZE 32
//
// NOTE:// If you take this code outside the SmartHLS directory structure
// into your own, then you should adjust this constant accordingly.
// E.g. for simulation on Modelsim:
//		vlog +define+MEM_INIT_DIR=/path/to/rtl/mem_init/ bypass_hls.v  ...
//
`ifndef MEM_INIT_DIR
`define MEM_INIT_DIR "../hdl/"
`endif


`timescale 1 ns / 1 ns


module bypass_hw_top
(
  input  clk,
  input  reset,

  output                          axi4target_arready,
  input                           axi4target_arvalid,
  input  [2 - 1:0] axi4target_araddr,
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
  input  [2 - 1:0] axi4target_awaddr,
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
  output reg [31:0] res_data,
  input  res_ready,
  output reg  res_valid,
  output reg [7:0] res_last,
  input [23:0] input_r,
  output reg  input_r_ready,
  input  input_r_valid
);


localparam ADDR_WIDTH = 2;
localparam AXI_DATA_WIDTH = 64;
localparam AXI_ID_WIDTH = 1;
localparam RAM_DATA_WIDTH = 32;
localparam NUM_RAM = 0;
localparam NUM_ARG_WORDS = 1;
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


bypass_hw_axi4slv # (
  .ENABLE_ACCEL_CTRL (0),
  .ADDR_WIDTH (ADDR_WIDTH),
  .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
  .AXI_ID_WIDTH (AXI_ID_WIDTH),
  .RAM_DATA_WIDTH (RAM_DATA_WIDTH),
  .NUM_RAM (NUM_RAM),
  .READ_LATENCY (1),
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

bypass_hw_hw_top bypass_hw_inst (
  .clk (clk),
  .reset (reset),
  .tlast_dnum (arguments[0 +: 16]),
  .start (start),
  .ready (ready),
  .finish (finish),
  .input_l (input_l),
  .input_l_ready (input_l_ready),
  .input_l_valid (input_l_valid),
  .res_data (res_data),
  .res_ready (res_ready),
  .res_valid (res_valid),
  .res_last (res_last),
  .input_r (input_r),
  .input_r_ready (input_r_ready),
  .input_r_valid (input_r_valid)
);

endmodule


`timescale 1 ns / 1 ns
module bypass_hw_hw_top
(
	clk,
	reset,
	start,
	ready,
	finish,
	tlast_dnum,
	input_l,
	input_l_ready,
	input_l_valid,
	res_data,
	res_ready,
	res_valid,
	res_last,
	input_r,
	input_r_ready,
	input_r_valid
);

input  clk;
input  reset;
input  start;
output reg  ready;
output reg  finish;
input [15:0] tlast_dnum;
input [23:0] input_l;
output reg  input_l_ready;
input  input_l_valid;
output reg [31:0] res_data;
input  res_ready;
output reg  res_valid;
output reg [7:0] res_last;
input [23:0] input_r;
output reg  input_r_ready;
input  input_r_valid;
reg  bypass_hw_inst_clk;
reg  bypass_hw_inst_reset;
reg  bypass_hw_inst_start;
wire  bypass_hw_inst_ready;
wire  bypass_hw_inst_finish;
reg [15:0] bypass_hw_inst_tlast_dnum;
reg [23:0] bypass_hw_inst_input_l;
wire  bypass_hw_inst_input_l_ready;
reg  bypass_hw_inst_input_l_valid;
wire [31:0] bypass_hw_inst_res_data;
reg  bypass_hw_inst_res_ready;
wire  bypass_hw_inst_res_valid;
wire [7:0] bypass_hw_inst_res_last;
reg [23:0] bypass_hw_inst_input_r;
wire  bypass_hw_inst_input_r_ready;
reg  bypass_hw_inst_input_r_valid;
reg  bypass_hw_inst_finish_reg;


bypass_hw_bypass_hw bypass_hw_inst (
	.clk (bypass_hw_inst_clk),
	.reset (bypass_hw_inst_reset),
	.start (bypass_hw_inst_start),
	.ready (bypass_hw_inst_ready),
	.finish (bypass_hw_inst_finish),
	.tlast_dnum (bypass_hw_inst_tlast_dnum),
	.input_l (bypass_hw_inst_input_l),
	.input_l_ready (bypass_hw_inst_input_l_ready),
	.input_l_valid (bypass_hw_inst_input_l_valid),
	.res_data (bypass_hw_inst_res_data),
	.res_ready (bypass_hw_inst_res_ready),
	.res_valid (bypass_hw_inst_res_valid),
	.res_last (bypass_hw_inst_res_last),
	.input_r (bypass_hw_inst_input_r),
	.input_r_ready (bypass_hw_inst_input_r_ready),
	.input_r_valid (bypass_hw_inst_input_r_valid)
);



always @(*) begin
	bypass_hw_inst_clk = clk;
end
always @(*) begin
	bypass_hw_inst_reset = reset;
end
always @(*) begin
	bypass_hw_inst_start = start;
end
always @(*) begin
	bypass_hw_inst_tlast_dnum = tlast_dnum;
end
always @(*) begin
	bypass_hw_inst_input_l = input_l;
end
always @(*) begin
	bypass_hw_inst_input_l_valid = input_l_valid;
end
always @(*) begin
	bypass_hw_inst_res_ready = res_ready;
end
always @(*) begin
	bypass_hw_inst_input_r = input_r;
end
always @(*) begin
	bypass_hw_inst_input_r_valid = input_r_valid;
end
always @(posedge clk) begin
	if ((reset | bypass_hw_inst_start)) begin
		bypass_hw_inst_finish_reg <= 1'd0;
	end
	if (bypass_hw_inst_finish) begin
		bypass_hw_inst_finish_reg <= 1'd1;
	end
end
always @(*) begin
	ready = bypass_hw_inst_ready;
end
always @(*) begin
	finish = bypass_hw_inst_finish;
end
always @(*) begin
	input_l_ready = bypass_hw_inst_input_l_ready;
end
always @(*) begin
	res_data = bypass_hw_inst_res_data;
end
always @(*) begin
	res_valid = bypass_hw_inst_res_valid;
end
always @(*) begin
	res_last = bypass_hw_inst_res_last;
end
always @(*) begin
	input_r_ready = bypass_hw_inst_input_r_ready;
end

endmodule

`timescale 1 ns / 1 ns
module bypass_hw_bypass_hw
(
	clk,
	reset,
	start,
	ready,
	finish,
	tlast_dnum,
	input_l,
	input_l_ready,
	input_l_valid,
	res_data,
	res_ready,
	res_valid,
	res_last,
	input_r,
	input_r_ready,
	input_r_valid
);

input  clk;
input  reset;
input  start;
output reg  ready;
output reg  finish;
input [15:0] tlast_dnum;
input [23:0] input_l;
output  input_l_ready;
input  input_l_valid;
output reg [31:0] res_data;
input  res_ready;
output reg  res_valid;
output reg [7:0] res_last;
input [23:0] input_r;
output  input_r_ready;
input  input_r_valid;
reg [15:0] tlast_dnum_reg;
reg [15:0] bypass_hw_BB_0_load;
reg [15:0] bypass_hw_BB_0_add;
reg [23:0] bypass_hw_BB_0_fifoVal;
reg [31:0] bypass_hw_BB_0_bit_concat2;
reg  bypass_hw_BB_0_icmp;
reg  bypass_hw_BB_0_bit_concat3;
reg [15:0] bypass_hw_BB_0_add4;
reg [15:0] bypass_hw_BB_0_select;
reg [23:0] bypass_hw_BB_0_fifoVal5;
reg [31:0] bypass_hw_BB_0_bit_concat6;
reg  bypass_hw_BB_0_icmp7;
reg  bypass_hw_BB_0_bit_concat;
reg [15:0] bypass_hw_BB_0_select8;
reg [15:0] bypass_hw_cnt_inferred_reg;
reg  bypass_hw_valid_bit_0;
reg  bypass_hw_state_stall_0;
reg  bypass_hw_state_enable_0;
reg  bypass_hw_state_stall_reg_0;
reg  bypass_hw_valid_bit_1;
reg  bypass_hw_state_stall_1;
reg  bypass_hw_state_enable_1;
reg  bypass_hw_state_stall_reg_1;
reg  bypass_hw_valid_bit_2;
reg  bypass_hw_state_stall_2;
reg  bypass_hw_state_enable_2;
reg  bypass_hw_state_stall_reg_2;
reg [1:0] bypass_hw_II_counter;
reg [31:0] bypass_hw_BB_0_bit_concat2_reg_stage0;
reg  bypass_hw_BB_0_bit_concat3_reg_stage0;
reg [31:0] bypass_hw_BB_0_bit_concat6_reg_stage0;
reg [31:0] bypass_hw_BB_0_bit_concat6_reg_stage1;
reg  bypass_hw_BB_0_bit_concat_reg_stage0;
reg  bypass_hw_BB_0_bit_concat_reg_stage1;
reg  input_l_consumed_valid;
reg [23:0] input_l_consumed_data;
reg  input_l_consumed_taken;
wire [7:0] bypass_hw_BB_0_bit_concat2_bit_select_operand_2;
wire [6:0] bypass_hw_BB_0_bit_concat3_bit_select_operand_0;
reg  res_data_bypass_hw_state_1_not_accessed_due_to_stall_a;
reg  res_data_bypass_hw_state_1_stalln_reg;
reg  res_data_bypass_hw_state_1_enable_cond_a;
reg  res_last_bypass_hw_state_1_not_accessed_due_to_stall_a;
reg  res_last_bypass_hw_state_1_stalln_reg;
reg  res_last_bypass_hw_state_1_enable_cond_a;
reg  input_r_consumed_valid;
reg [23:0] input_r_consumed_data;
reg  input_r_consumed_taken;
wire [7:0] bypass_hw_BB_0_bit_concat6_bit_select_operand_2;
wire [6:0] bypass_hw_BB_0_bit_concat_bit_select_operand_0;
reg  res_data_bypass_hw_state_2_not_accessed_due_to_stall_a;
reg  res_data_bypass_hw_state_2_stalln_reg;
reg  res_data_bypass_hw_state_2_enable_cond_a;
reg  res_last_bypass_hw_state_2_not_accessed_due_to_stall_a;
reg  res_last_bypass_hw_state_2_stalln_reg;
reg  res_last_bypass_hw_state_2_enable_cond_a;


always @(posedge clk) begin
	if ((start & ready)) begin
		tlast_dnum_reg <= tlast_dnum;
	end
end
always @(*) begin
		bypass_hw_BB_0_load = bypass_hw_cnt_inferred_reg;
end
always @(*) begin
		bypass_hw_BB_0_add = (bypass_hw_BB_0_load + 16'd1);
end
always @(*) begin
	bypass_hw_BB_0_fifoVal = input_l_consumed_data;
end
always @(*) begin
		bypass_hw_BB_0_bit_concat2 = {bypass_hw_BB_0_fifoVal[23:0], bypass_hw_BB_0_bit_concat2_bit_select_operand_2[7:0]};
end
always @(*) begin
		bypass_hw_BB_0_icmp = (bypass_hw_BB_0_add == tlast_dnum_reg);
end
always @(*) begin
		bypass_hw_BB_0_bit_concat3 = {bypass_hw_BB_0_bit_concat3_bit_select_operand_0[6:0], bypass_hw_BB_0_icmp};
end
always @(*) begin
		bypass_hw_BB_0_add4 = (bypass_hw_BB_0_load + 16'd2);
end
always @(*) begin
		bypass_hw_BB_0_select = (bypass_hw_BB_0_icmp ? 16'd1 : bypass_hw_BB_0_add4);
end
always @(*) begin
	bypass_hw_BB_0_fifoVal5 = input_r_consumed_data;
end
always @(*) begin
		bypass_hw_BB_0_bit_concat6 = {bypass_hw_BB_0_fifoVal5[23:0], bypass_hw_BB_0_bit_concat6_bit_select_operand_2[7:0]};
end
always @(*) begin
		bypass_hw_BB_0_icmp7 = (bypass_hw_BB_0_select == tlast_dnum_reg);
end
always @(*) begin
		bypass_hw_BB_0_bit_concat = {bypass_hw_BB_0_bit_concat_bit_select_operand_0[6:0], bypass_hw_BB_0_icmp7};
end
always @(*) begin
		bypass_hw_BB_0_select8 = (bypass_hw_BB_0_icmp7 ? 16'd0 : bypass_hw_BB_0_select);
end
always @(posedge clk) begin
	if (reset)
		bypass_hw_cnt_inferred_reg <= 16'd0;
	else	if (bypass_hw_state_enable_0) begin
		bypass_hw_cnt_inferred_reg <= bypass_hw_BB_0_select8;
	end
end
always @(posedge clk) begin
	if (reset)
		bypass_hw_valid_bit_0 <= 1'd0;
	else	if (~(bypass_hw_state_stall_0)) begin
		bypass_hw_valid_bit_0 <= (bypass_hw_II_counter[1] & start);
	end
end
always @(*) begin
	bypass_hw_state_stall_0 = 1'd0;
	if (bypass_hw_state_stall_1) begin
		bypass_hw_state_stall_0 = 1'd1;
	end
	if ((bypass_hw_state_stall_reg_0 & ~(bypass_hw_II_counter[0]))) begin
		bypass_hw_state_stall_0 = 1'd1;
	end
	if ((bypass_hw_valid_bit_0 & ~(input_l_consumed_valid))) begin
		bypass_hw_state_stall_0 = 1'd1;
	end
	if ((bypass_hw_valid_bit_0 & ~(input_r_consumed_valid))) begin
		bypass_hw_state_stall_0 = 1'd1;
	end
end
always @(*) begin
	bypass_hw_state_enable_0 = (bypass_hw_valid_bit_0 & ~(bypass_hw_state_stall_0));
end
always @(posedge clk) begin
	bypass_hw_state_stall_reg_0 <= bypass_hw_state_stall_0;
	if (reset)
		bypass_hw_state_stall_reg_0 <= 1'd0;
end
always @(posedge clk) begin
	if (reset)
		bypass_hw_valid_bit_1 <= 1'd0;
	else	if (~(bypass_hw_state_stall_1)) begin
		bypass_hw_valid_bit_1 <= bypass_hw_state_enable_0;
	end
end
always @(*) begin
	bypass_hw_state_stall_1 = 1'd0;
	if (bypass_hw_state_stall_2) begin
		bypass_hw_state_stall_1 = 1'd1;
	end
	if ((bypass_hw_state_stall_reg_1 & ~(bypass_hw_II_counter[1]))) begin
		bypass_hw_state_stall_1 = 1'd1;
	end
	if ((((bypass_hw_valid_bit_1 & res_valid) & ~(res_ready)) & (res_data_bypass_hw_state_1_not_accessed_due_to_stall_a | res_data_bypass_hw_state_1_stalln_reg))) begin
		bypass_hw_state_stall_1 = 1'd1;
	end
	if ((((bypass_hw_valid_bit_1 & res_valid) & ~(res_ready)) & (res_last_bypass_hw_state_1_not_accessed_due_to_stall_a | res_last_bypass_hw_state_1_stalln_reg))) begin
		bypass_hw_state_stall_1 = 1'd1;
	end
end
always @(*) begin
	bypass_hw_state_enable_1 = (bypass_hw_valid_bit_1 & ~(bypass_hw_state_stall_1));
end
always @(posedge clk) begin
	bypass_hw_state_stall_reg_1 <= bypass_hw_state_stall_1;
	if (reset)
		bypass_hw_state_stall_reg_1 <= 1'd0;
end
always @(posedge clk) begin
	if (reset)
		bypass_hw_valid_bit_2 <= 1'd0;
	else	if (~(bypass_hw_state_stall_2)) begin
		bypass_hw_valid_bit_2 <= bypass_hw_state_enable_1;
	end
end
always @(*) begin
	bypass_hw_state_stall_2 = 1'd0;
	if ((bypass_hw_state_stall_reg_2 & ~(bypass_hw_II_counter[0]))) begin
		bypass_hw_state_stall_2 = 1'd1;
	end
	if ((((bypass_hw_valid_bit_2 & res_valid) & ~(res_ready)) & (res_data_bypass_hw_state_2_not_accessed_due_to_stall_a | res_data_bypass_hw_state_2_stalln_reg))) begin
		bypass_hw_state_stall_2 = 1'd1;
	end
	if ((((bypass_hw_valid_bit_2 & res_valid) & ~(res_ready)) & (res_last_bypass_hw_state_2_not_accessed_due_to_stall_a | res_last_bypass_hw_state_2_stalln_reg))) begin
		bypass_hw_state_stall_2 = 1'd1;
	end
end
always @(*) begin
	bypass_hw_state_enable_2 = (bypass_hw_valid_bit_2 & ~(bypass_hw_state_stall_2));
end
always @(posedge clk) begin
	bypass_hw_state_stall_reg_2 <= bypass_hw_state_stall_2;
	if (reset)
		bypass_hw_state_stall_reg_2 <= 1'd0;
end
always @(posedge clk) begin
	bypass_hw_II_counter <= {bypass_hw_II_counter[0], bypass_hw_II_counter[1]};
	if (reset)
		bypass_hw_II_counter <= 2'd1;
end
always @(posedge clk) begin
	if (bypass_hw_state_enable_0) begin
		bypass_hw_BB_0_bit_concat2_reg_stage0 <= bypass_hw_BB_0_bit_concat2;
	end
end
always @(posedge clk) begin
	if (bypass_hw_state_enable_0) begin
		bypass_hw_BB_0_bit_concat3_reg_stage0 <= bypass_hw_BB_0_bit_concat3;
	end
end
always @(posedge clk) begin
	if (bypass_hw_state_enable_0) begin
		bypass_hw_BB_0_bit_concat6_reg_stage0 <= bypass_hw_BB_0_bit_concat6;
	end
end
always @(posedge clk) begin
	if (bypass_hw_state_enable_1) begin
		bypass_hw_BB_0_bit_concat6_reg_stage1 <= bypass_hw_BB_0_bit_concat6_reg_stage0;
	end
end
always @(posedge clk) begin
	if (bypass_hw_state_enable_0) begin
		bypass_hw_BB_0_bit_concat_reg_stage0 <= bypass_hw_BB_0_bit_concat;
	end
end
always @(posedge clk) begin
	if (bypass_hw_state_enable_1) begin
		bypass_hw_BB_0_bit_concat_reg_stage1 <= bypass_hw_BB_0_bit_concat_reg_stage0;
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
	if (bypass_hw_valid_bit_0) begin
		input_l_consumed_taken = ~(bypass_hw_state_stall_0);
	end
end
assign bypass_hw_BB_0_bit_concat2_bit_select_operand_2 = 8'd0;
assign bypass_hw_BB_0_bit_concat3_bit_select_operand_0 = 7'd0;
always @(posedge clk) begin
	res_data_bypass_hw_state_1_not_accessed_due_to_stall_a <= ((bypass_hw_state_stall_1 & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_data_bypass_hw_state_1_stalln_reg <= ~(bypass_hw_state_stall_1);
end
always @(*) begin
	res_data_bypass_hw_state_1_enable_cond_a = (bypass_hw_valid_bit_1 & (res_data_bypass_hw_state_1_not_accessed_due_to_stall_a | res_data_bypass_hw_state_1_stalln_reg));
end
always @(posedge clk) begin
	res_last_bypass_hw_state_1_not_accessed_due_to_stall_a <= ((bypass_hw_state_stall_1 & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_last_bypass_hw_state_1_stalln_reg <= ~(bypass_hw_state_stall_1);
end
always @(*) begin
	res_last_bypass_hw_state_1_enable_cond_a = (bypass_hw_valid_bit_1 & (res_last_bypass_hw_state_1_not_accessed_due_to_stall_a | res_last_bypass_hw_state_1_stalln_reg));
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
	if (bypass_hw_valid_bit_0) begin
		input_r_consumed_taken = ~(bypass_hw_state_stall_0);
	end
end
assign bypass_hw_BB_0_bit_concat6_bit_select_operand_2 = 8'd0;
assign bypass_hw_BB_0_bit_concat_bit_select_operand_0 = 7'd0;
always @(posedge clk) begin
	res_data_bypass_hw_state_2_not_accessed_due_to_stall_a <= ((bypass_hw_state_stall_2 & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_data_bypass_hw_state_2_stalln_reg <= ~(bypass_hw_state_stall_2);
end
always @(*) begin
	res_data_bypass_hw_state_2_enable_cond_a = (bypass_hw_valid_bit_2 & (res_data_bypass_hw_state_2_not_accessed_due_to_stall_a | res_data_bypass_hw_state_2_stalln_reg));
end
always @(posedge clk) begin
	res_last_bypass_hw_state_2_not_accessed_due_to_stall_a <= ((bypass_hw_state_stall_2 & res_valid) & ~(res_ready));
end
always @(posedge clk) begin
	res_last_bypass_hw_state_2_stalln_reg <= ~(bypass_hw_state_stall_2);
end
always @(*) begin
	res_last_bypass_hw_state_2_enable_cond_a = (bypass_hw_valid_bit_2 & (res_last_bypass_hw_state_2_not_accessed_due_to_stall_a | res_last_bypass_hw_state_2_stalln_reg));
end
always @(*) begin
	ready = (bypass_hw_II_counter[1] & ~(bypass_hw_state_stall_0));
end
always @(posedge clk) begin
	finish <= bypass_hw_state_enable_2;
end
assign input_l_ready = (~(reset) & (~(input_l_consumed_valid) | input_l_consumed_taken));
always @(*) begin
	if (bypass_hw_valid_bit_1) begin
		res_data = bypass_hw_BB_0_bit_concat2_reg_stage0;
	end
	else /* if (bypass_hw_valid_bit_2) */  begin
		res_data = bypass_hw_BB_0_bit_concat6_reg_stage1;
	end
end
always @(*) begin
	res_valid = 1'd0;
	if (res_data_bypass_hw_state_1_enable_cond_a) begin
		res_valid = 1'd1;
	end
	if (res_last_bypass_hw_state_1_enable_cond_a) begin
		res_valid = 1'd1;
	end
	if (res_data_bypass_hw_state_2_enable_cond_a) begin
		res_valid = 1'd1;
	end
	if (res_last_bypass_hw_state_2_enable_cond_a) begin
		res_valid = 1'd1;
	end
end
always @(*) begin
	if (bypass_hw_valid_bit_1) begin
		res_last = bypass_hw_BB_0_bit_concat3_reg_stage0;
	end
	else /* if (bypass_hw_valid_bit_2) */  begin
		res_last = bypass_hw_BB_0_bit_concat_reg_stage1;
	end
end
assign input_r_ready = (~(reset) & (~(input_r_consumed_valid) | input_r_consumed_taken));

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

module bypass_hw_axi4slv #(
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

  bypass_hw_axi4slv_read_controller #(
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

  bypass_hw_axi4slv_write_controller #(
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
      bypass_hw_axi4slv_accel_ctrl #(
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
        bypass_hw_axi4slv_register #(
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
        bypass_hw_axi4slv_ram_dual_port_drwp #(
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

module bypass_hw_axi4slv_accel_ctrl #(
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

  bypass_hw_shift_reg #(
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
  
module bypass_hw_axi4slv_ram_dual_port_drwp #(
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

bypass_hw_ram_dual_port ram_dual_port_inst (
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

bypass_hw_shift_reg #(READ_LATENCY, 1+1) sr1 (
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
module bypass_hw_axi4slv_read_controller #(
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
bypass_hw_first_word fw ( 
  .i_clk            ( i_clk ), 
  .i_rst            ( i_rst ),
  .i_valid          ( or_data_valid ),
  .i_ready          ( axi_rready ),
  .i_last           ( or_data_last ),
  .o_first_wd       ( first_wd )
);

// Shift register to match the RAM latencies
bypass_hw_shift_reg #( 
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
    bypass_hw_fwft_fifo #(
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
module bypass_hw_axi4slv_register # (
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

bypass_hw_shift_reg #(READ_LATENCY, 1 + 1 + DATA_WIDTH) sr1 (
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
module bypass_hw_axi4slv_write_controller #(
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
module bypass_hw_first_word (
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
module bypass_hw_shift_reg # (
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

module bypass_hw_ram_dual_port (
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
    bypass_hw_ram_dual_port_byte_enabled ram_dual_port_byte_enabled_inst(
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
    bypass_hw_ram_dual_port_regular ram_dual_port_regular_inst(
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

module bypass_hw_ram_dual_port_byte_enabled (
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

module bypass_hw_ram_dual_port_regular (
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

module bypass_hw_fwft_fifo # (
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
    bypass_hw_fwft_fifo_bram # (
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
    bypass_hw_fwft_fifo_lutram # (
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

module bypass_hw_fwft_fifo_bram # (
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
bypass_hw_simple_ram_dual_port_fifo ram_dual_port_inst (
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

module bypass_hw_fwft_fifo_lutram # (
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
bypass_hw_lutram_dual_port_fifo lutram_dual_port_inst (
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
module bypass_hw_simple_ram_dual_port_fifo # (
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
module bypass_hw_lutram_dual_port_fifo # (
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


