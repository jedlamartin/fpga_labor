vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_vip_v1_1_22
vlib questa_lib/msim/zynq_ultra_ps_e_vip_v1_0_22
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/proc_sys_reset_v5_0_17
vlib questa_lib/msim/smartconnect_v1_0
vlib questa_lib/msim/axi_register_slice_v2_1_36
vlib questa_lib/msim/axi_lite_ipif_v3_0_4
vlib questa_lib/msim/interrupt_control_v3_1_5
vlib questa_lib/msim/axi_gpio_v2_0_37
vlib questa_lib/msim/gigantic_mux
vlib questa_lib/msim/xlconcat_v2_1_7

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_22 questa_lib/msim/axi_vip_v1_1_22
vmap zynq_ultra_ps_e_vip_v1_0_22 questa_lib/msim/zynq_ultra_ps_e_vip_v1_0_22
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap proc_sys_reset_v5_0_17 questa_lib/msim/proc_sys_reset_v5_0_17
vmap smartconnect_v1_0 questa_lib/msim/smartconnect_v1_0
vmap axi_register_slice_v2_1_36 questa_lib/msim/axi_register_slice_v2_1_36
vmap axi_lite_ipif_v3_0_4 questa_lib/msim/axi_lite_ipif_v3_0_4
vmap interrupt_control_v3_1_5 questa_lib/msim/interrupt_control_v3_1_5
vmap axi_gpio_v2_0_37 questa_lib/msim/axi_gpio_v2_0_37
vmap gigantic_mux questa_lib/msim/gigantic_mux
vmap xlconcat_v2_1_7 questa_lib/msim/xlconcat_v2_1_7

vlog -work xilinx_vip -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"/xilinx/2025.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/xilinx/2025.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/xilinx/2025.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/xilinx/2025.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/xilinx/2025.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/xilinx/2025.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/xilinx/2025.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/xilinx/2025.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/xilinx/2025.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"/xilinx/2025.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/xilinx/2025.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/xilinx/2025.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/xilinx/2025.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr -mfcu  "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_22 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/b16a/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work zynq_ultra_ps_e_vip_v1_0_22 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_zynq_ultra_ps_e_0_0/sim/cpu_system_zynq_ultra_ps_e_0_0_vip_wrapper.v" \

vcom -work proc_sys_reset_v5_0_17 -64 -93  \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/cpu_system/ip/cpu_system_proc_sys_reset_0_0/sim/cpu_system_proc_sys_reset_0_0.vhd" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_1/sim/bd_7c56_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3d9a/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_2/sim/bd_7c56_s00mmu_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/7785/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_3/sim/bd_7c56_s00tr_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3051/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_4/sim/bd_7c56_s00sic_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/852f/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_5/sim/bd_7c56_s00a2s_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_6/sim/bd_7c56_sarn_0.sv" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_7/sim/bd_7c56_srn_0.sv" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_8/sim/bd_7c56_sawn_0.sv" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_9/sim/bd_7c56_swn_0.sv" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_10/sim/bd_7c56_sbn_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/fca9/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_11/sim/bd_7c56_m00s2a_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/e44a/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/ip/ip_12/sim/bd_7c56_m00e_0.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/bd_0/sim/bd_7c56.v" \

vcom -work smartconnect_v1_0 -64 -93  \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/cb42/hdl/sc_ultralite_v1_0_rfs.vhd" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/cb42/hdl/sc_ultralite_v1_0_rfs.sv" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0848/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work axi_register_slice_v2_1_36 -64 -incr -mfcu  "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/bc4b/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L zynq_ultra_ps_e_vip_v1_0_22 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_smartconnect_0_0/sim/cpu_system_smartconnect_0_0.sv" \

vcom -work axi_lite_ipif_v3_0_4 -64 -93  \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work interrupt_control_v3_1_5 -64 -93  \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/d8cc/hdl/interrupt_control_v3_1_vh_rfs.vhd" \

vcom -work axi_gpio_v2_0_37 -64 -93  \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0271/hdl/axi_gpio_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/cpu_system/ip/cpu_system_axi_gpio_0_0/sim/cpu_system_axi_gpio_0_0.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_0/sim/bd_38aa_ila_lib_0.v" \

vlog -work gigantic_mux -64 -incr -mfcu  "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/b2b0/hdl/gigantic_mux_v1_0_cntr.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_1/bd_38aa_g_inst_0_gigantic_mux.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_1/sim/bd_38aa_g_inst_0.v" \

vlog -work xlconcat_v2_1_7 -64 -incr -mfcu  "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/9c1a/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/ec67/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/a0fe/hdl" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../xilinx/2025.2/data/rsb/busdef" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/5431/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/4e08/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/0568/hdl/verilog" "+incdir+../../../../fpga_labor.gen/sources_1/bd/cpu_system/ipshared/3556/hdl/verilog" "+incdir+/xilinx/2025.2/data/xilinx_vip/include" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_2/sim/bd_38aa_slot_0_aw_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_3/sim/bd_38aa_slot_0_w_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_4/sim/bd_38aa_slot_0_b_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_5/sim/bd_38aa_slot_0_ar_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_6/sim/bd_38aa_slot_0_r_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_7/sim/bd_38aa_slot_1_aw_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_8/sim/bd_38aa_slot_1_w_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_9/sim/bd_38aa_slot_1_b_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_10/sim/bd_38aa_slot_1_ar_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/ip/ip_11/sim/bd_38aa_slot_1_r_0.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/bd_0/sim/bd_38aa.v" \
"../../../bd/cpu_system/ip/cpu_system_system_ila_0_0/sim/cpu_system_system_ila_0_0.v" \
"../../../bd/cpu_system/sim/cpu_system.v" \

vlog -work xil_defaultlib \
"glbl.v"

