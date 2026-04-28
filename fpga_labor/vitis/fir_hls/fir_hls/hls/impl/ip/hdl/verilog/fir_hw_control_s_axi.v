// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *) module fir_hw_control_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 12,
    C_S_AXI_DATA_WIDTH = 32
)(
    input  wire                          ACLK,
    input  wire                          ARESET,
    input  wire                          ACLK_EN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire                          AWVALID,
    output wire                          AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
    input  wire                          WVALID,
    output wire                          WREADY,
    output wire [1:0]                    BRESP,
    output wire                          BVALID,
    input  wire                          BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                          ARVALID,
    output wire                          ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
    output wire [1:0]                    RRESP,
    output wire                          RVALID,
    input  wire                          RREADY,
    output wire [15:0]                   tlast_dnum,
    output wire [2:0]                    smpl_rd_num,
    output wire [8:0]                    tap_num_m1,
    input  wire [8:0]                    coeff_hw_address0,
    input  wire                          coeff_hw_ce0,
    output wire [31:0]                   coeff_hw_q0
);
//------------------------Address Info-------------------
// Protocol Used: ap_ctrl_none
//
// 0x000 : reserved
// 0x004 : reserved
// 0x008 : reserved
// 0x00c : reserved
// 0x010 : Data signal of tlast_dnum
//         bit 15~0 - tlast_dnum[15:0] (Read/Write)
//         others   - reserved
// 0x014 : reserved
// 0x018 : Data signal of smpl_rd_num
//         bit 2~0 - smpl_rd_num[2:0] (Read/Write)
//         others  - reserved
// 0x01c : reserved
// 0x020 : Data signal of tap_num_m1
//         bit 8~0 - tap_num_m1[8:0] (Read/Write)
//         others  - reserved
// 0x024 : reserved
// 0x800 ~
// 0xfff : Memory 'coeff_hw' (512 * 32b)
//         Word n : bit [31:0] - coeff_hw[n]
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    ADDR_TLAST_DNUM_DATA_0  = 12'h010,
    ADDR_TLAST_DNUM_CTRL    = 12'h014,
    ADDR_SMPL_RD_NUM_DATA_0 = 12'h018,
    ADDR_SMPL_RD_NUM_CTRL   = 12'h01c,
    ADDR_TAP_NUM_M1_DATA_0  = 12'h020,
    ADDR_TAP_NUM_M1_CTRL    = 12'h024,
    ADDR_COEFF_HW_BASE      = 12'h800,
    ADDR_COEFF_HW_HIGH      = 12'hfff,
    WRIDLE                  = 2'd0,
    WRDATA                  = 2'd1,
    WRRESP                  = 2'd2,
    WRRESET                 = 2'd3,
    RDIDLE                  = 2'd0,
    RDDATA                  = 2'd1,
    RDRESET                 = 2'd2,
    ADDR_BITS                = 12;

//------------------------Local signal-------------------
    reg  [1:0]                    wstate = WRRESET;
    reg  [1:0]                    wnext;
    reg  [ADDR_BITS-1:0]          waddr;
    wire [C_S_AXI_DATA_WIDTH-1:0] wmask;
    wire                          aw_hs;
    wire                          w_hs;
    reg  [1:0]                    rstate = RDRESET;
    reg  [1:0]                    rnext;
    reg  [C_S_AXI_DATA_WIDTH-1:0] rdata;
    wire                          ar_hs;
    wire [ADDR_BITS-1:0]          raddr;
    // internal registers
    reg  [15:0]                   int_tlast_dnum = 'b0;
    reg  [2:0]                    int_smpl_rd_num = 'b0;
    reg  [8:0]                    int_tap_num_m1 = 'b0;
    // memory signals
    wire [8:0]                    int_coeff_hw_address0;
    wire                          int_coeff_hw_ce0;
    wire [31:0]                   int_coeff_hw_q0;
    wire [8:0]                    int_coeff_hw_address1;
    wire                          int_coeff_hw_ce1;
    wire [3:0]                    int_coeff_hw_be1;
    wire                          int_coeff_hw_we1;
    wire [31:0]                   int_coeff_hw_d1;
    wire [31:0]                   int_coeff_hw_q1;
    reg                           int_coeff_hw_read;
    reg                           int_coeff_hw_write;

//------------------------Instantiation------------------
// int_coeff_hw
fir_hw_control_s_axi_ram #(
    .MEM_STYLE  ( "auto" ),
    .MEM_TYPE   ( "2P" ),
    .BYTE_WIDTH ( 8 ),
    .WIDTH      ( 32 ),
    .BYTES      ( 4 ),
    .DEPTH      ( 512 )
) int_coeff_hw (
    .clk0       ( ACLK ),
    .address0   ( int_coeff_hw_address0 ),
    .ce0        ( int_coeff_hw_ce0 ),
    .we0        ( {4{1'b0}} ),
    .d0         ( {32{1'b0}} ),
    .q0         ( int_coeff_hw_q0 ),
    .clk1       ( ACLK ),
    .address1   ( int_coeff_hw_address1 ),
    .ce1        ( int_coeff_hw_ce1 ),
    .we1        ( int_coeff_hw_be1 ),
    .d1         ( int_coeff_hw_d1 ),
    .q1         ( int_coeff_hw_q1 )
);


//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA) && (!ar_hs);
assign BVALID  = (wstate == WRRESP);
assign BRESP   = 2'b00;  // OKAY
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
    if (ARESET)
        wstate <= WRRESET;
    else if (ACLK_EN)
        wstate <= wnext;
end

// wnext
always @(*) begin
    case (wstate)
        WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
        WRDATA:
            if (w_hs)
                wnext = WRRESP;
            else
                wnext = WRDATA;
        WRRESP:
            if (BREADY & BVALID)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
        default:
            wnext = WRIDLE;
    endcase
end

// waddr
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (aw_hs)
            waddr <= {AWADDR[ADDR_BITS-1:2], {2{1'b0}}};
    end
end

//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA) & !int_coeff_hw_read;
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
    if (ARESET)
        rstate <= RDRESET;
    else if (ACLK_EN)
        rstate <= rnext;
end

// rnext
always @(*) begin
    case (rstate)
        RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
        RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
        default:
            rnext = RDIDLE;
    endcase
end

// rdata
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (ar_hs) begin
            rdata <= 'b0;
            case (raddr)
                ADDR_TLAST_DNUM_DATA_0: begin
                    rdata <= int_tlast_dnum[15:0];
                end
                ADDR_SMPL_RD_NUM_DATA_0: begin
                    rdata <= int_smpl_rd_num[2:0];
                end
                ADDR_TAP_NUM_M1_DATA_0: begin
                    rdata <= int_tap_num_m1[8:0];
                end
            endcase
        end
        else if (int_coeff_hw_read) begin
            rdata <= int_coeff_hw_q1;
        end
    end
end


//------------------------Register logic-----------------
assign tlast_dnum  = int_tlast_dnum;
assign smpl_rd_num = int_smpl_rd_num;
assign tap_num_m1  = int_tap_num_m1;
// int_tlast_dnum[15:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_tlast_dnum[15:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_TLAST_DNUM_DATA_0)
            int_tlast_dnum[15:0] <= (WDATA[31:0] & wmask) | (int_tlast_dnum[15:0] & ~wmask);
    end
end

// int_smpl_rd_num[2:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_smpl_rd_num[2:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_SMPL_RD_NUM_DATA_0)
            int_smpl_rd_num[2:0] <= (WDATA[31:0] & wmask) | (int_smpl_rd_num[2:0] & ~wmask);
    end
end

// int_tap_num_m1[8:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_tap_num_m1[8:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_TAP_NUM_M1_DATA_0)
            int_tap_num_m1[8:0] <= (WDATA[31:0] & wmask) | (int_tap_num_m1[8:0] & ~wmask);
    end
end


//------------------------Memory logic-------------------
// coeff_hw
assign int_coeff_hw_address0 = coeff_hw_address0;
assign int_coeff_hw_ce0      = coeff_hw_ce0;
assign coeff_hw_q0           = int_coeff_hw_q0;
assign int_coeff_hw_address1 = ar_hs ? raddr[10:2] : waddr[10:2];
assign int_coeff_hw_ce1      = ar_hs | (int_coeff_hw_write & WVALID);
assign int_coeff_hw_we1      = int_coeff_hw_write & w_hs;
assign int_coeff_hw_be1      = int_coeff_hw_we1 ? WSTRB : 4'd0;
assign int_coeff_hw_d1       = WDATA;
// int_coeff_hw_read
always @(posedge ACLK) begin
    if (ARESET)
        int_coeff_hw_read <= 1'b0;
    else if (ACLK_EN) begin
        if (ar_hs && raddr >= ADDR_COEFF_HW_BASE && raddr <= ADDR_COEFF_HW_HIGH)
            int_coeff_hw_read <= 1'b1;
        else
            int_coeff_hw_read <= 1'b0;
    end
end

// int_coeff_hw_write
always @(posedge ACLK) begin
    if (ARESET)
        int_coeff_hw_write <= 1'b0;
    else if (ACLK_EN) begin
        if (aw_hs && AWADDR[ADDR_BITS-1:0] >= ADDR_COEFF_HW_BASE && AWADDR[ADDR_BITS-1:0] <= ADDR_COEFF_HW_HIGH)
            int_coeff_hw_write <= 1'b1;
        else if (w_hs)
            int_coeff_hw_write <= 1'b0;
    end
end


endmodule


`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings="yes" *)
module fir_hw_control_s_axi_ram
#(parameter
    MEM_STYLE  = "auto",
    MEM_TYPE   = "S2P",
    BYTE_WIDTH = 8,
    WIDTH  = 32,
    DEPTH  = 256,
    BYTES  = 4,
    AWIDTH = log2(DEPTH)
) (
    input  wire              clk0,
    input  wire [AWIDTH-1:0] address0,
    input  wire              ce0,
    input  wire [BYTES-1:0]  we0,
    input  wire [WIDTH-1:0]  d0,
    output reg  [WIDTH-1:0]  q0,
    input  wire              clk1,
    input  wire [AWIDTH-1:0] address1,
    input  wire              ce1,
    input  wire [BYTES-1:0]  we1,
    input  wire [WIDTH-1:0]  d1,
    output reg  [WIDTH-1:0]  q1
);
//------------------------ Parameters -------------------
localparam
    PORT0 = (MEM_TYPE == "S2P") ? "WO" : ((MEM_TYPE == "2P") ? "RO" : "RW"),
    PORT1 = (MEM_TYPE == "S2P") ? "RO" : "RW";
//------------------------Local signal-------------------
(* ram_style = MEM_STYLE*)
reg  [WIDTH-1:0] mem[0:DEPTH-1];
wire re0, re1;
//------------------------Task and function--------------
function integer log2;
    input integer x;
    integer n, m;
begin
    n = 1;
    m = 2;
    while (m < x) begin
        n = n + 1;
        m = m * 2;
    end
    log2 = n;
end
endfunction
//------------------------Body---------------------------
generate
    if (MEM_STYLE == "hls_ultra" && PORT0 == "RW") begin
        assign re0 = ce0 & ~|we0;
    end else begin
        assign re0 = ce0;
    end
endgenerate

generate
    if (MEM_STYLE == "hls_ultra" && PORT1 == "RW") begin
        assign re1 = ce1 & ~|we1;
    end else begin
        assign re1 = ce1;
    end
endgenerate

// read port 0
generate if (PORT0 != "WO") begin
    always @(posedge clk0) begin
        if (re0) q0 <= mem[address0];
    end
end
endgenerate

// read port 1
generate if (PORT1 != "WO") begin
    always @(posedge clk1) begin
        if (re1) q1 <= mem[address1];
    end
end
endgenerate

integer i;
// write port 0
generate if (PORT0 != "RO") begin
    always @(posedge clk0) begin
        if (ce0)
        for (i = 0; i < BYTES; i = i + 1)
            if (we0[i])
                mem[address0][i*BYTE_WIDTH +: BYTE_WIDTH] <= d0[i*BYTE_WIDTH +: BYTE_WIDTH];
    end
end
endgenerate

// write port 1
generate if (PORT1 != "RO") begin
    always @(posedge clk1) begin
        if (ce1)
        for (i = 0; i < BYTES; i = i + 1)
            if (we1[i])
                mem[address1][i*BYTE_WIDTH +: BYTE_WIDTH] <= d1[i*BYTE_WIDTH +: BYTE_WIDTH];
    end
end
endgenerate

endmodule

