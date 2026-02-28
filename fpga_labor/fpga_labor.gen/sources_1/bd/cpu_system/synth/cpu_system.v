//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Sat Feb 28 16:33:00 2026
//Host        : pc running 64-bit major release  (build 9200)
//Command     : generate_target cpu_system.bd
//Design      : cpu_system
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "cpu_system,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=cpu_system,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=9,numReposBlks=9,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_zynq_ultra_ps_e_cnt=1,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "cpu_system.hwdef" *) 
module cpu_system
   (btn_tri_i,
    led_tri_o);
  (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 btn TRI_I" *) (* X_INTERFACE_MODE = "Master" *) input [3:0]btn_tri_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 led TRI_O" *) (* X_INTERFACE_MODE = "Master" *) output [3:0]led_tri_o;

  (* CONN_BUS_INFO = "axi_dma_0_M_AXIS_MM2S xilinx.com:interface:axis:1.0 None TDATA" *) (* DONT_TOUCH *) wire [31:0]axi_dma_0_M_AXIS_MM2S_TDATA;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXIS_MM2S xilinx.com:interface:axis:1.0 None TKEEP" *) (* DONT_TOUCH *) wire [3:0]axi_dma_0_M_AXIS_MM2S_TKEEP;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXIS_MM2S xilinx.com:interface:axis:1.0 None TLAST" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXIS_MM2S_TLAST;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXIS_MM2S xilinx.com:interface:axis:1.0 None TREADY" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXIS_MM2S_TREADY;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXIS_MM2S xilinx.com:interface:axis:1.0 None TVALID" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXIS_MM2S_TVALID;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 ARADDR" *) (* DONT_TOUCH *) wire [31:0]axi_dma_0_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_dma_0_M_AXI_MM2S_ARBURST;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 ARCACHE" *) (* DONT_TOUCH *) wire [3:0]axi_dma_0_M_AXI_MM2S_ARCACHE;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 ARLEN" *) (* DONT_TOUCH *) wire [7:0]axi_dma_0_M_AXI_MM2S_ARLEN;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 ARPROT" *) (* DONT_TOUCH *) wire [2:0]axi_dma_0_M_AXI_MM2S_ARPROT;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 ARREADY" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_MM2S_ARREADY;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 ARSIZE" *) (* DONT_TOUCH *) wire [2:0]axi_dma_0_M_AXI_MM2S_ARSIZE;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 ARVALID" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_MM2S_ARVALID;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 RDATA" *) (* DONT_TOUCH *) wire [31:0]axi_dma_0_M_AXI_MM2S_RDATA;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 RLAST" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_MM2S_RLAST;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 RREADY" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_MM2S_RREADY;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 RRESP" *) (* DONT_TOUCH *) wire [1:0]axi_dma_0_M_AXI_MM2S_RRESP;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_MM2S xilinx.com:interface:aximm:1.0 AXI4 RVALID" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_MM2S_RVALID;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 AWADDR" *) (* DONT_TOUCH *) wire [31:0]axi_dma_0_M_AXI_S2MM_AWADDR;
  wire [1:0]axi_dma_0_M_AXI_S2MM_AWBURST;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 AWCACHE" *) (* DONT_TOUCH *) wire [3:0]axi_dma_0_M_AXI_S2MM_AWCACHE;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 AWLEN" *) (* DONT_TOUCH *) wire [7:0]axi_dma_0_M_AXI_S2MM_AWLEN;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 AWPROT" *) (* DONT_TOUCH *) wire [2:0]axi_dma_0_M_AXI_S2MM_AWPROT;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 AWREADY" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_S2MM_AWREADY;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 AWSIZE" *) (* DONT_TOUCH *) wire [2:0]axi_dma_0_M_AXI_S2MM_AWSIZE;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 AWVALID" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_S2MM_AWVALID;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 BREADY" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_S2MM_BREADY;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 BRESP" *) (* DONT_TOUCH *) wire [1:0]axi_dma_0_M_AXI_S2MM_BRESP;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 BVALID" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_S2MM_BVALID;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 WDATA" *) (* DONT_TOUCH *) wire [31:0]axi_dma_0_M_AXI_S2MM_WDATA;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 WLAST" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_S2MM_WLAST;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 WREADY" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_S2MM_WREADY;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 WSTRB" *) (* DONT_TOUCH *) wire [3:0]axi_dma_0_M_AXI_S2MM_WSTRB;
  (* CONN_BUS_INFO = "axi_dma_0_M_AXI_S2MM xilinx.com:interface:aximm:1.0 AXI4 WVALID" *) (* DONT_TOUCH *) wire axi_dma_0_M_AXI_S2MM_WVALID;
  wire axi_dma_0_mm2s_introut;
  wire axi_dma_0_s2mm_introut;
  wire [3:0]btn_tri_i;
  (* CONN_BUS_INFO = "fifo_generator_0_M_AXIS xilinx.com:interface:axis:1.0 None TDATA" *) (* DONT_TOUCH *) wire [31:0]fifo_generator_0_M_AXIS_TDATA;
  (* CONN_BUS_INFO = "fifo_generator_0_M_AXIS xilinx.com:interface:axis:1.0 None TLAST" *) (* DONT_TOUCH *) wire fifo_generator_0_M_AXIS_TLAST;
  (* CONN_BUS_INFO = "fifo_generator_0_M_AXIS xilinx.com:interface:axis:1.0 None TREADY" *) (* DONT_TOUCH *) wire fifo_generator_0_M_AXIS_TREADY;
  (* CONN_BUS_INFO = "fifo_generator_0_M_AXIS xilinx.com:interface:axis:1.0 None TVALID" *) (* DONT_TOUCH *) wire fifo_generator_0_M_AXIS_TVALID;
  wire [3:0]led_tri_o;
  wire [0:0]proc_sys_reset_0_interconnect_aresetn;
  wire [0:0]proc_sys_reset_0_peripheral_aresetn;
  wire [8:0]smartconnect_0_M00_AXI_ARADDR;
  wire smartconnect_0_M00_AXI_ARREADY;
  wire smartconnect_0_M00_AXI_ARVALID;
  wire [8:0]smartconnect_0_M00_AXI_AWADDR;
  wire smartconnect_0_M00_AXI_AWREADY;
  wire smartconnect_0_M00_AXI_AWVALID;
  wire smartconnect_0_M00_AXI_BREADY;
  wire [1:0]smartconnect_0_M00_AXI_BRESP;
  wire smartconnect_0_M00_AXI_BVALID;
  wire [31:0]smartconnect_0_M00_AXI_RDATA;
  wire smartconnect_0_M00_AXI_RREADY;
  wire [1:0]smartconnect_0_M00_AXI_RRESP;
  wire smartconnect_0_M00_AXI_RVALID;
  wire [31:0]smartconnect_0_M00_AXI_WDATA;
  wire smartconnect_0_M00_AXI_WREADY;
  wire [3:0]smartconnect_0_M00_AXI_WSTRB;
  wire smartconnect_0_M00_AXI_WVALID;
  wire [9:0]smartconnect_0_M01_AXI_ARADDR;
  wire smartconnect_0_M01_AXI_ARREADY;
  wire smartconnect_0_M01_AXI_ARVALID;
  wire [9:0]smartconnect_0_M01_AXI_AWADDR;
  wire smartconnect_0_M01_AXI_AWREADY;
  wire smartconnect_0_M01_AXI_AWVALID;
  wire smartconnect_0_M01_AXI_BREADY;
  wire [1:0]smartconnect_0_M01_AXI_BRESP;
  wire smartconnect_0_M01_AXI_BVALID;
  wire [31:0]smartconnect_0_M01_AXI_RDATA;
  wire smartconnect_0_M01_AXI_RREADY;
  wire [1:0]smartconnect_0_M01_AXI_RRESP;
  wire smartconnect_0_M01_AXI_RVALID;
  wire [31:0]smartconnect_0_M01_AXI_WDATA;
  wire smartconnect_0_M01_AXI_WREADY;
  wire smartconnect_0_M01_AXI_WVALID;
  wire [48:0]smartconnect_1_M00_AXI_ARADDR;
  wire [1:0]smartconnect_1_M00_AXI_ARBURST;
  wire [3:0]smartconnect_1_M00_AXI_ARCACHE;
  wire [7:0]smartconnect_1_M00_AXI_ARLEN;
  wire [0:0]smartconnect_1_M00_AXI_ARLOCK;
  wire [2:0]smartconnect_1_M00_AXI_ARPROT;
  wire [3:0]smartconnect_1_M00_AXI_ARQOS;
  wire smartconnect_1_M00_AXI_ARREADY;
  wire [2:0]smartconnect_1_M00_AXI_ARSIZE;
  wire smartconnect_1_M00_AXI_ARVALID;
  wire [48:0]smartconnect_1_M00_AXI_AWADDR;
  wire [1:0]smartconnect_1_M00_AXI_AWBURST;
  wire [3:0]smartconnect_1_M00_AXI_AWCACHE;
  wire [7:0]smartconnect_1_M00_AXI_AWLEN;
  wire [0:0]smartconnect_1_M00_AXI_AWLOCK;
  wire [2:0]smartconnect_1_M00_AXI_AWPROT;
  wire [3:0]smartconnect_1_M00_AXI_AWQOS;
  wire smartconnect_1_M00_AXI_AWREADY;
  wire [2:0]smartconnect_1_M00_AXI_AWSIZE;
  wire smartconnect_1_M00_AXI_AWVALID;
  wire smartconnect_1_M00_AXI_BREADY;
  wire [1:0]smartconnect_1_M00_AXI_BRESP;
  wire smartconnect_1_M00_AXI_BVALID;
  wire [127:0]smartconnect_1_M00_AXI_RDATA;
  wire smartconnect_1_M00_AXI_RLAST;
  wire smartconnect_1_M00_AXI_RREADY;
  wire [1:0]smartconnect_1_M00_AXI_RRESP;
  wire smartconnect_1_M00_AXI_RVALID;
  wire [127:0]smartconnect_1_M00_AXI_WDATA;
  wire smartconnect_1_M00_AXI_WLAST;
  wire smartconnect_1_M00_AXI_WREADY;
  wire [15:0]smartconnect_1_M00_AXI_WSTRB;
  wire smartconnect_1_M00_AXI_WVALID;
  wire [1:0]xlconcat_0_dout;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARUSER;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWUSER;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID;
  wire [127:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID;
  wire [127:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID;
  wire zynq_ultra_ps_e_0_pl_clk0;
  wire zynq_ultra_ps_e_0_pl_resetn0;

  cpu_system_axi_dma_0_0 axi_dma_0
       (.axi_resetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axi_mm2s_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .m_axi_mm2s_araddr(axi_dma_0_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_dma_0_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_dma_0_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_arlen(axi_dma_0_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_dma_0_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_dma_0_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_dma_0_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_arvalid(axi_dma_0_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_dma_0_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_dma_0_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_dma_0_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_dma_0_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_dma_0_M_AXI_MM2S_RVALID),
        .m_axi_s2mm_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .m_axi_s2mm_awaddr(axi_dma_0_M_AXI_S2MM_AWADDR),
        .m_axi_s2mm_awburst(axi_dma_0_M_AXI_S2MM_AWBURST),
        .m_axi_s2mm_awcache(axi_dma_0_M_AXI_S2MM_AWCACHE),
        .m_axi_s2mm_awlen(axi_dma_0_M_AXI_S2MM_AWLEN),
        .m_axi_s2mm_awprot(axi_dma_0_M_AXI_S2MM_AWPROT),
        .m_axi_s2mm_awready(axi_dma_0_M_AXI_S2MM_AWREADY),
        .m_axi_s2mm_awsize(axi_dma_0_M_AXI_S2MM_AWSIZE),
        .m_axi_s2mm_awvalid(axi_dma_0_M_AXI_S2MM_AWVALID),
        .m_axi_s2mm_bready(axi_dma_0_M_AXI_S2MM_BREADY),
        .m_axi_s2mm_bresp(axi_dma_0_M_AXI_S2MM_BRESP),
        .m_axi_s2mm_bvalid(axi_dma_0_M_AXI_S2MM_BVALID),
        .m_axi_s2mm_wdata(axi_dma_0_M_AXI_S2MM_WDATA),
        .m_axi_s2mm_wlast(axi_dma_0_M_AXI_S2MM_WLAST),
        .m_axi_s2mm_wready(axi_dma_0_M_AXI_S2MM_WREADY),
        .m_axi_s2mm_wstrb(axi_dma_0_M_AXI_S2MM_WSTRB),
        .m_axi_s2mm_wvalid(axi_dma_0_M_AXI_S2MM_WVALID),
        .m_axis_mm2s_tdata(axi_dma_0_M_AXIS_MM2S_TDATA),
        .m_axis_mm2s_tkeep(axi_dma_0_M_AXIS_MM2S_TKEEP),
        .m_axis_mm2s_tlast(axi_dma_0_M_AXIS_MM2S_TLAST),
        .m_axis_mm2s_tready(axi_dma_0_M_AXIS_MM2S_TREADY),
        .m_axis_mm2s_tvalid(axi_dma_0_M_AXIS_MM2S_TVALID),
        .mm2s_introut(axi_dma_0_mm2s_introut),
        .s2mm_introut(axi_dma_0_s2mm_introut),
        .s_axi_lite_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_lite_araddr(smartconnect_0_M01_AXI_ARADDR),
        .s_axi_lite_arready(smartconnect_0_M01_AXI_ARREADY),
        .s_axi_lite_arvalid(smartconnect_0_M01_AXI_ARVALID),
        .s_axi_lite_awaddr(smartconnect_0_M01_AXI_AWADDR),
        .s_axi_lite_awready(smartconnect_0_M01_AXI_AWREADY),
        .s_axi_lite_awvalid(smartconnect_0_M01_AXI_AWVALID),
        .s_axi_lite_bready(smartconnect_0_M01_AXI_BREADY),
        .s_axi_lite_bresp(smartconnect_0_M01_AXI_BRESP),
        .s_axi_lite_bvalid(smartconnect_0_M01_AXI_BVALID),
        .s_axi_lite_rdata(smartconnect_0_M01_AXI_RDATA),
        .s_axi_lite_rready(smartconnect_0_M01_AXI_RREADY),
        .s_axi_lite_rresp(smartconnect_0_M01_AXI_RRESP),
        .s_axi_lite_rvalid(smartconnect_0_M01_AXI_RVALID),
        .s_axi_lite_wdata(smartconnect_0_M01_AXI_WDATA),
        .s_axi_lite_wready(smartconnect_0_M01_AXI_WREADY),
        .s_axi_lite_wvalid(smartconnect_0_M01_AXI_WVALID),
        .s_axis_s2mm_tdata(fifo_generator_0_M_AXIS_TDATA),
        .s_axis_s2mm_tkeep({1'b1,1'b1,1'b1,1'b1}),
        .s_axis_s2mm_tlast(fifo_generator_0_M_AXIS_TLAST),
        .s_axis_s2mm_tready(fifo_generator_0_M_AXIS_TREADY),
        .s_axis_s2mm_tvalid(fifo_generator_0_M_AXIS_TVALID));
  cpu_system_axi_gpio_0_0 axi_gpio_0
       (.gpio2_io_i(btn_tri_i),
        .gpio_io_o(led_tri_o),
        .s_axi_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_araddr(smartconnect_0_M00_AXI_ARADDR),
        .s_axi_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .s_axi_arready(smartconnect_0_M00_AXI_ARREADY),
        .s_axi_arvalid(smartconnect_0_M00_AXI_ARVALID),
        .s_axi_awaddr(smartconnect_0_M00_AXI_AWADDR),
        .s_axi_awready(smartconnect_0_M00_AXI_AWREADY),
        .s_axi_awvalid(smartconnect_0_M00_AXI_AWVALID),
        .s_axi_bready(smartconnect_0_M00_AXI_BREADY),
        .s_axi_bresp(smartconnect_0_M00_AXI_BRESP),
        .s_axi_bvalid(smartconnect_0_M00_AXI_BVALID),
        .s_axi_rdata(smartconnect_0_M00_AXI_RDATA),
        .s_axi_rready(smartconnect_0_M00_AXI_RREADY),
        .s_axi_rresp(smartconnect_0_M00_AXI_RRESP),
        .s_axi_rvalid(smartconnect_0_M00_AXI_RVALID),
        .s_axi_wdata(smartconnect_0_M00_AXI_WDATA),
        .s_axi_wready(smartconnect_0_M00_AXI_WREADY),
        .s_axi_wstrb(smartconnect_0_M00_AXI_WSTRB),
        .s_axi_wvalid(smartconnect_0_M00_AXI_WVALID));
  cpu_system_fifo_generator_0_0 fifo_generator_0
       (.m_axis_tdata(fifo_generator_0_M_AXIS_TDATA),
        .m_axis_tlast(fifo_generator_0_M_AXIS_TLAST),
        .m_axis_tready(fifo_generator_0_M_AXIS_TREADY),
        .m_axis_tvalid(fifo_generator_0_M_AXIS_TVALID),
        .s_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .s_axis_tdata(axi_dma_0_M_AXIS_MM2S_TDATA),
        .s_axis_tlast(axi_dma_0_M_AXIS_MM2S_TLAST),
        .s_axis_tready(axi_dma_0_M_AXIS_MM2S_TREADY),
        .s_axis_tvalid(axi_dma_0_M_AXIS_MM2S_TVALID));
  cpu_system_proc_sys_reset_0_0 proc_sys_reset_0
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(zynq_ultra_ps_e_0_pl_resetn0),
        .interconnect_aresetn(proc_sys_reset_0_interconnect_aresetn),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .slowest_sync_clk(zynq_ultra_ps_e_0_pl_clk0));
  cpu_system_smartconnect_0_0 smartconnect_0
       (.M00_AXI_araddr(smartconnect_0_M00_AXI_ARADDR),
        .M00_AXI_arready(smartconnect_0_M00_AXI_ARREADY),
        .M00_AXI_arvalid(smartconnect_0_M00_AXI_ARVALID),
        .M00_AXI_awaddr(smartconnect_0_M00_AXI_AWADDR),
        .M00_AXI_awready(smartconnect_0_M00_AXI_AWREADY),
        .M00_AXI_awvalid(smartconnect_0_M00_AXI_AWVALID),
        .M00_AXI_bready(smartconnect_0_M00_AXI_BREADY),
        .M00_AXI_bresp(smartconnect_0_M00_AXI_BRESP),
        .M00_AXI_bvalid(smartconnect_0_M00_AXI_BVALID),
        .M00_AXI_rdata(smartconnect_0_M00_AXI_RDATA),
        .M00_AXI_rready(smartconnect_0_M00_AXI_RREADY),
        .M00_AXI_rresp(smartconnect_0_M00_AXI_RRESP),
        .M00_AXI_rvalid(smartconnect_0_M00_AXI_RVALID),
        .M00_AXI_wdata(smartconnect_0_M00_AXI_WDATA),
        .M00_AXI_wready(smartconnect_0_M00_AXI_WREADY),
        .M00_AXI_wstrb(smartconnect_0_M00_AXI_WSTRB),
        .M00_AXI_wvalid(smartconnect_0_M00_AXI_WVALID),
        .M01_AXI_araddr(smartconnect_0_M01_AXI_ARADDR),
        .M01_AXI_arready(smartconnect_0_M01_AXI_ARREADY),
        .M01_AXI_arvalid(smartconnect_0_M01_AXI_ARVALID),
        .M01_AXI_awaddr(smartconnect_0_M01_AXI_AWADDR),
        .M01_AXI_awready(smartconnect_0_M01_AXI_AWREADY),
        .M01_AXI_awvalid(smartconnect_0_M01_AXI_AWVALID),
        .M01_AXI_bready(smartconnect_0_M01_AXI_BREADY),
        .M01_AXI_bresp(smartconnect_0_M01_AXI_BRESP),
        .M01_AXI_bvalid(smartconnect_0_M01_AXI_BVALID),
        .M01_AXI_rdata(smartconnect_0_M01_AXI_RDATA),
        .M01_AXI_rready(smartconnect_0_M01_AXI_RREADY),
        .M01_AXI_rresp(smartconnect_0_M01_AXI_RRESP),
        .M01_AXI_rvalid(smartconnect_0_M01_AXI_RVALID),
        .M01_AXI_wdata(smartconnect_0_M01_AXI_WDATA),
        .M01_AXI_wready(smartconnect_0_M01_AXI_WREADY),
        .M01_AXI_wvalid(smartconnect_0_M01_AXI_WVALID),
        .S00_AXI_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR),
        .S00_AXI_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .S00_AXI_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .S00_AXI_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .S00_AXI_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .S00_AXI_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .S00_AXI_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .S00_AXI_arqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARQOS),
        .S00_AXI_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .S00_AXI_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .S00_AXI_aruser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARUSER),
        .S00_AXI_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .S00_AXI_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR),
        .S00_AXI_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .S00_AXI_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .S00_AXI_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .S00_AXI_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .S00_AXI_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .S00_AXI_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .S00_AXI_awqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWQOS),
        .S00_AXI_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .S00_AXI_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .S00_AXI_awuser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWUSER),
        .S00_AXI_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .S00_AXI_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .S00_AXI_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .S00_AXI_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .S00_AXI_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .S00_AXI_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .S00_AXI_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .S00_AXI_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .S00_AXI_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .S00_AXI_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .S00_AXI_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .S00_AXI_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .S00_AXI_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .S00_AXI_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .S00_AXI_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .S00_AXI_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID),
        .aclk(zynq_ultra_ps_e_0_pl_clk0),
        .aresetn(proc_sys_reset_0_interconnect_aresetn));
  cpu_system_smartconnect_1_0 smartconnect_1
       (.M00_AXI_araddr(smartconnect_1_M00_AXI_ARADDR),
        .M00_AXI_arburst(smartconnect_1_M00_AXI_ARBURST),
        .M00_AXI_arcache(smartconnect_1_M00_AXI_ARCACHE),
        .M00_AXI_arlen(smartconnect_1_M00_AXI_ARLEN),
        .M00_AXI_arlock(smartconnect_1_M00_AXI_ARLOCK),
        .M00_AXI_arprot(smartconnect_1_M00_AXI_ARPROT),
        .M00_AXI_arqos(smartconnect_1_M00_AXI_ARQOS),
        .M00_AXI_arready(smartconnect_1_M00_AXI_ARREADY),
        .M00_AXI_arsize(smartconnect_1_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(smartconnect_1_M00_AXI_ARVALID),
        .M00_AXI_awaddr(smartconnect_1_M00_AXI_AWADDR),
        .M00_AXI_awburst(smartconnect_1_M00_AXI_AWBURST),
        .M00_AXI_awcache(smartconnect_1_M00_AXI_AWCACHE),
        .M00_AXI_awlen(smartconnect_1_M00_AXI_AWLEN),
        .M00_AXI_awlock(smartconnect_1_M00_AXI_AWLOCK),
        .M00_AXI_awprot(smartconnect_1_M00_AXI_AWPROT),
        .M00_AXI_awqos(smartconnect_1_M00_AXI_AWQOS),
        .M00_AXI_awready(smartconnect_1_M00_AXI_AWREADY),
        .M00_AXI_awsize(smartconnect_1_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(smartconnect_1_M00_AXI_AWVALID),
        .M00_AXI_bready(smartconnect_1_M00_AXI_BREADY),
        .M00_AXI_bresp(smartconnect_1_M00_AXI_BRESP),
        .M00_AXI_bvalid(smartconnect_1_M00_AXI_BVALID),
        .M00_AXI_rdata(smartconnect_1_M00_AXI_RDATA),
        .M00_AXI_rlast(smartconnect_1_M00_AXI_RLAST),
        .M00_AXI_rready(smartconnect_1_M00_AXI_RREADY),
        .M00_AXI_rresp(smartconnect_1_M00_AXI_RRESP),
        .M00_AXI_rvalid(smartconnect_1_M00_AXI_RVALID),
        .M00_AXI_wdata(smartconnect_1_M00_AXI_WDATA),
        .M00_AXI_wlast(smartconnect_1_M00_AXI_WLAST),
        .M00_AXI_wready(smartconnect_1_M00_AXI_WREADY),
        .M00_AXI_wstrb(smartconnect_1_M00_AXI_WSTRB),
        .M00_AXI_wvalid(smartconnect_1_M00_AXI_WVALID),
        .S00_AXI_araddr(axi_dma_0_M_AXI_MM2S_ARADDR),
        .S00_AXI_arburst(axi_dma_0_M_AXI_MM2S_ARBURST),
        .S00_AXI_arcache(axi_dma_0_M_AXI_MM2S_ARCACHE),
        .S00_AXI_arlen(axi_dma_0_M_AXI_MM2S_ARLEN),
        .S00_AXI_arlock(1'b0),
        .S00_AXI_arprot(axi_dma_0_M_AXI_MM2S_ARPROT),
        .S00_AXI_arqos({1'b0,1'b0,1'b0,1'b0}),
        .S00_AXI_arready(axi_dma_0_M_AXI_MM2S_ARREADY),
        .S00_AXI_arsize(axi_dma_0_M_AXI_MM2S_ARSIZE),
        .S00_AXI_arvalid(axi_dma_0_M_AXI_MM2S_ARVALID),
        .S00_AXI_rdata(axi_dma_0_M_AXI_MM2S_RDATA),
        .S00_AXI_rlast(axi_dma_0_M_AXI_MM2S_RLAST),
        .S00_AXI_rready(axi_dma_0_M_AXI_MM2S_RREADY),
        .S00_AXI_rresp(axi_dma_0_M_AXI_MM2S_RRESP),
        .S00_AXI_rvalid(axi_dma_0_M_AXI_MM2S_RVALID),
        .S01_AXI_awaddr(axi_dma_0_M_AXI_S2MM_AWADDR),
        .S01_AXI_awburst(axi_dma_0_M_AXI_S2MM_AWBURST),
        .S01_AXI_awcache(axi_dma_0_M_AXI_S2MM_AWCACHE),
        .S01_AXI_awlen(axi_dma_0_M_AXI_S2MM_AWLEN),
        .S01_AXI_awlock(1'b0),
        .S01_AXI_awprot(axi_dma_0_M_AXI_S2MM_AWPROT),
        .S01_AXI_awqos({1'b0,1'b0,1'b0,1'b0}),
        .S01_AXI_awready(axi_dma_0_M_AXI_S2MM_AWREADY),
        .S01_AXI_awsize(axi_dma_0_M_AXI_S2MM_AWSIZE),
        .S01_AXI_awvalid(axi_dma_0_M_AXI_S2MM_AWVALID),
        .S01_AXI_bready(axi_dma_0_M_AXI_S2MM_BREADY),
        .S01_AXI_bresp(axi_dma_0_M_AXI_S2MM_BRESP),
        .S01_AXI_bvalid(axi_dma_0_M_AXI_S2MM_BVALID),
        .S01_AXI_wdata(axi_dma_0_M_AXI_S2MM_WDATA),
        .S01_AXI_wlast(axi_dma_0_M_AXI_S2MM_WLAST),
        .S01_AXI_wready(axi_dma_0_M_AXI_S2MM_WREADY),
        .S01_AXI_wstrb(axi_dma_0_M_AXI_S2MM_WSTRB),
        .S01_AXI_wvalid(axi_dma_0_M_AXI_S2MM_WVALID),
        .aclk(zynq_ultra_ps_e_0_pl_clk0),
        .aresetn(proc_sys_reset_0_interconnect_aresetn));
  cpu_system_system_ila_0_0 system_ila_0
       (.SLOT_0_AXI_araddr(axi_dma_0_M_AXI_MM2S_ARADDR),
        .SLOT_0_AXI_arcache(axi_dma_0_M_AXI_MM2S_ARCACHE),
        .SLOT_0_AXI_arlen(axi_dma_0_M_AXI_MM2S_ARLEN),
        .SLOT_0_AXI_arprot(axi_dma_0_M_AXI_MM2S_ARPROT),
        .SLOT_0_AXI_arready(axi_dma_0_M_AXI_MM2S_ARREADY),
        .SLOT_0_AXI_arsize(axi_dma_0_M_AXI_MM2S_ARSIZE),
        .SLOT_0_AXI_arvalid(axi_dma_0_M_AXI_MM2S_ARVALID),
        .SLOT_0_AXI_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .SLOT_0_AXI_awcache({1'b0,1'b0,1'b1,1'b1}),
        .SLOT_0_AXI_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .SLOT_0_AXI_awprot({1'b0,1'b0,1'b0}),
        .SLOT_0_AXI_awready(1'b0),
        .SLOT_0_AXI_awsize({1'b0,1'b1,1'b0}),
        .SLOT_0_AXI_awvalid(1'b0),
        .SLOT_0_AXI_bready(1'b0),
        .SLOT_0_AXI_bvalid(1'b0),
        .SLOT_0_AXI_rdata(axi_dma_0_M_AXI_MM2S_RDATA),
        .SLOT_0_AXI_rlast(axi_dma_0_M_AXI_MM2S_RLAST),
        .SLOT_0_AXI_rready(axi_dma_0_M_AXI_MM2S_RREADY),
        .SLOT_0_AXI_rresp(axi_dma_0_M_AXI_MM2S_RRESP),
        .SLOT_0_AXI_rvalid(axi_dma_0_M_AXI_MM2S_RVALID),
        .SLOT_0_AXI_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .SLOT_0_AXI_wlast(1'b0),
        .SLOT_0_AXI_wready(1'b0),
        .SLOT_0_AXI_wvalid(1'b0),
        .SLOT_1_AXI_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .SLOT_1_AXI_arcache({1'b0,1'b0,1'b1,1'b1}),
        .SLOT_1_AXI_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .SLOT_1_AXI_arprot({1'b0,1'b0,1'b0}),
        .SLOT_1_AXI_arready(1'b0),
        .SLOT_1_AXI_arsize({1'b0,1'b1,1'b0}),
        .SLOT_1_AXI_arvalid(1'b0),
        .SLOT_1_AXI_awaddr(axi_dma_0_M_AXI_S2MM_AWADDR),
        .SLOT_1_AXI_awcache(axi_dma_0_M_AXI_S2MM_AWCACHE),
        .SLOT_1_AXI_awlen(axi_dma_0_M_AXI_S2MM_AWLEN),
        .SLOT_1_AXI_awprot(axi_dma_0_M_AXI_S2MM_AWPROT),
        .SLOT_1_AXI_awready(axi_dma_0_M_AXI_S2MM_AWREADY),
        .SLOT_1_AXI_awsize(axi_dma_0_M_AXI_S2MM_AWSIZE),
        .SLOT_1_AXI_awvalid(axi_dma_0_M_AXI_S2MM_AWVALID),
        .SLOT_1_AXI_bready(axi_dma_0_M_AXI_S2MM_BREADY),
        .SLOT_1_AXI_bresp(axi_dma_0_M_AXI_S2MM_BRESP),
        .SLOT_1_AXI_bvalid(axi_dma_0_M_AXI_S2MM_BVALID),
        .SLOT_1_AXI_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .SLOT_1_AXI_rlast(1'b0),
        .SLOT_1_AXI_rready(1'b0),
        .SLOT_1_AXI_rvalid(1'b0),
        .SLOT_1_AXI_wdata(axi_dma_0_M_AXI_S2MM_WDATA),
        .SLOT_1_AXI_wlast(axi_dma_0_M_AXI_S2MM_WLAST),
        .SLOT_1_AXI_wready(axi_dma_0_M_AXI_S2MM_WREADY),
        .SLOT_1_AXI_wstrb(axi_dma_0_M_AXI_S2MM_WSTRB),
        .SLOT_1_AXI_wvalid(axi_dma_0_M_AXI_S2MM_WVALID),
        .SLOT_2_AXIS_tdata(axi_dma_0_M_AXIS_MM2S_TDATA),
        .SLOT_2_AXIS_tkeep(axi_dma_0_M_AXIS_MM2S_TKEEP),
        .SLOT_2_AXIS_tlast(axi_dma_0_M_AXIS_MM2S_TLAST),
        .SLOT_2_AXIS_tready(axi_dma_0_M_AXIS_MM2S_TREADY),
        .SLOT_2_AXIS_tvalid(axi_dma_0_M_AXIS_MM2S_TVALID),
        .SLOT_3_AXIS_tdata(fifo_generator_0_M_AXIS_TDATA),
        .SLOT_3_AXIS_tlast(fifo_generator_0_M_AXIS_TLAST),
        .SLOT_3_AXIS_tready(fifo_generator_0_M_AXIS_TREADY),
        .SLOT_3_AXIS_tvalid(fifo_generator_0_M_AXIS_TVALID),
        .clk(zynq_ultra_ps_e_0_pl_clk0),
        .resetn(proc_sys_reset_0_peripheral_aresetn));
  cpu_system_xlconcat_0_0 xlconcat_0
       (.In0(axi_dma_0_mm2s_introut),
        .In1(axi_dma_0_s2mm_introut),
        .dout(xlconcat_0_dout));
  cpu_system_zynq_ultra_ps_e_0_0 zynq_ultra_ps_e_0
       (.maxigp0_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR),
        .maxigp0_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .maxigp0_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .maxigp0_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .maxigp0_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .maxigp0_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .maxigp0_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .maxigp0_arqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARQOS),
        .maxigp0_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .maxigp0_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .maxigp0_aruser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARUSER),
        .maxigp0_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .maxigp0_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR),
        .maxigp0_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .maxigp0_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .maxigp0_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .maxigp0_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .maxigp0_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .maxigp0_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .maxigp0_awqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWQOS),
        .maxigp0_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .maxigp0_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .maxigp0_awuser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWUSER),
        .maxigp0_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .maxigp0_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .maxigp0_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .maxigp0_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .maxigp0_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .maxigp0_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .maxigp0_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .maxigp0_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .maxigp0_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .maxigp0_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .maxigp0_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .maxigp0_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .maxigp0_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .maxigp0_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .maxigp0_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .maxigp0_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID),
        .maxihpm0_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .pl_clk0(zynq_ultra_ps_e_0_pl_clk0),
        .pl_ps_irq0(xlconcat_0_dout),
        .pl_resetn0(zynq_ultra_ps_e_0_pl_resetn0),
        .saxigp0_araddr(smartconnect_1_M00_AXI_ARADDR),
        .saxigp0_arburst(smartconnect_1_M00_AXI_ARBURST),
        .saxigp0_arcache(smartconnect_1_M00_AXI_ARCACHE),
        .saxigp0_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp0_arlen(smartconnect_1_M00_AXI_ARLEN),
        .saxigp0_arlock(smartconnect_1_M00_AXI_ARLOCK),
        .saxigp0_arprot(smartconnect_1_M00_AXI_ARPROT),
        .saxigp0_arqos(smartconnect_1_M00_AXI_ARQOS),
        .saxigp0_arready(smartconnect_1_M00_AXI_ARREADY),
        .saxigp0_arsize(smartconnect_1_M00_AXI_ARSIZE),
        .saxigp0_aruser(1'b0),
        .saxigp0_arvalid(smartconnect_1_M00_AXI_ARVALID),
        .saxigp0_awaddr(smartconnect_1_M00_AXI_AWADDR),
        .saxigp0_awburst(smartconnect_1_M00_AXI_AWBURST),
        .saxigp0_awcache(smartconnect_1_M00_AXI_AWCACHE),
        .saxigp0_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp0_awlen(smartconnect_1_M00_AXI_AWLEN),
        .saxigp0_awlock(smartconnect_1_M00_AXI_AWLOCK),
        .saxigp0_awprot(smartconnect_1_M00_AXI_AWPROT),
        .saxigp0_awqos(smartconnect_1_M00_AXI_AWQOS),
        .saxigp0_awready(smartconnect_1_M00_AXI_AWREADY),
        .saxigp0_awsize(smartconnect_1_M00_AXI_AWSIZE),
        .saxigp0_awuser(1'b0),
        .saxigp0_awvalid(smartconnect_1_M00_AXI_AWVALID),
        .saxigp0_bready(smartconnect_1_M00_AXI_BREADY),
        .saxigp0_bresp(smartconnect_1_M00_AXI_BRESP),
        .saxigp0_bvalid(smartconnect_1_M00_AXI_BVALID),
        .saxigp0_rdata(smartconnect_1_M00_AXI_RDATA),
        .saxigp0_rlast(smartconnect_1_M00_AXI_RLAST),
        .saxigp0_rready(smartconnect_1_M00_AXI_RREADY),
        .saxigp0_rresp(smartconnect_1_M00_AXI_RRESP),
        .saxigp0_rvalid(smartconnect_1_M00_AXI_RVALID),
        .saxigp0_wdata(smartconnect_1_M00_AXI_WDATA),
        .saxigp0_wlast(smartconnect_1_M00_AXI_WLAST),
        .saxigp0_wready(smartconnect_1_M00_AXI_WREADY),
        .saxigp0_wstrb(smartconnect_1_M00_AXI_WSTRB),
        .saxigp0_wvalid(smartconnect_1_M00_AXI_WVALID),
        .saxihpc0_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0));
endmodule
