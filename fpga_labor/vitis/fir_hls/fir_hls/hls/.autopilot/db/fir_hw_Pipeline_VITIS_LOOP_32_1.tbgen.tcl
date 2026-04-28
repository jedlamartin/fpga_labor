set moduleName fir_hw_Pipeline_VITIS_LOOP_32_1
set isTopModule 0
set isCombinational 0
set isDatapathOnly 0
set isPipelined 1
set isPipelined_legacy 1
set pipeline_type loop_auto_rewind
set FunctionProtocol ap_ctrl_hs
set restart_counter_num 0
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set DLRegFirstOffset 0
set DLRegItemOffset 0
set svuvm_can_support 1
set cdfgNum 4
set C_modelName {fir_hw_Pipeline_VITIS_LOOP_32_1}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict coeff_hw { MEM_WIDTH 32 MEM_SIZE 2048 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict buffer_left { MEM_WIDTH 24 MEM_SIZE 1536 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict buffer_right { MEM_WIDTH 24 MEM_SIZE 1536 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
set C_modelArgList {
	{ add_ln32 int 10 regular  }
	{ write_idx_load int 9 regular  }
	{ coeff_hw int 32 regular {array 512 { 1 } 1 1 }  }
	{ out_data_data_out int 32 regular {pointer 1}  }
	{ out_data_data_1_out int 32 regular {pointer 1}  }
	{ buffer_left int 24 regular {array 512 { 1 3 } 1 1 } {global 0}  }
	{ buffer_right int 24 regular {array 512 { 1 3 } 1 1 } {global 0}  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "add_ln32", "interface" : "wire", "bitwidth" : 10, "direction" : "READONLY"} , 
 	{ "Name" : "write_idx_load", "interface" : "wire", "bitwidth" : 9, "direction" : "READONLY"} , 
 	{ "Name" : "coeff_hw", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "out_data_data_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "out_data_data_1_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "buffer_left", "interface" : "memory", "bitwidth" : 24, "direction" : "READONLY", "extern" : 0} , 
 	{ "Name" : "buffer_right", "interface" : "memory", "bitwidth" : 24, "direction" : "READONLY", "extern" : 0} ]}
# RTL Port declarations: 
set portNum 21
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ add_ln32 sc_in sc_lv 10 signal 0 } 
	{ write_idx_load sc_in sc_lv 9 signal 1 } 
	{ coeff_hw_address0 sc_out sc_lv 9 signal 2 } 
	{ coeff_hw_ce0 sc_out sc_logic 1 signal 2 } 
	{ coeff_hw_q0 sc_in sc_lv 32 signal 2 } 
	{ out_data_data_out sc_out sc_lv 32 signal 3 } 
	{ out_data_data_out_ap_vld sc_out sc_logic 1 outvld 3 } 
	{ out_data_data_1_out sc_out sc_lv 32 signal 4 } 
	{ out_data_data_1_out_ap_vld sc_out sc_logic 1 outvld 4 } 
	{ buffer_left_address0 sc_out sc_lv 9 signal 5 } 
	{ buffer_left_ce0 sc_out sc_logic 1 signal 5 } 
	{ buffer_left_q0 sc_in sc_lv 24 signal 5 } 
	{ buffer_right_address0 sc_out sc_lv 9 signal 6 } 
	{ buffer_right_ce0 sc_out sc_logic 1 signal 6 } 
	{ buffer_right_q0 sc_in sc_lv 24 signal 6 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "add_ln32", "direction": "in", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "add_ln32", "role": "default" }} , 
 	{ "name": "write_idx_load", "direction": "in", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "write_idx_load", "role": "default" }} , 
 	{ "name": "coeff_hw_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "coeff_hw", "role": "address0" }} , 
 	{ "name": "coeff_hw_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "coeff_hw", "role": "ce0" }} , 
 	{ "name": "coeff_hw_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "coeff_hw", "role": "q0" }} , 
 	{ "name": "out_data_data_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "out_data_data_out", "role": "default" }} , 
 	{ "name": "out_data_data_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "out_data_data_out", "role": "ap_vld" }} , 
 	{ "name": "out_data_data_1_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "out_data_data_1_out", "role": "default" }} , 
 	{ "name": "out_data_data_1_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "out_data_data_1_out", "role": "ap_vld" }} , 
 	{ "name": "buffer_left_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "buffer_left", "role": "address0" }} , 
 	{ "name": "buffer_left_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "buffer_left", "role": "ce0" }} , 
 	{ "name": "buffer_left_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":24, "type": "signal", "bundle":{"name": "buffer_left", "role": "q0" }} , 
 	{ "name": "buffer_right_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "buffer_right", "role": "address0" }} , 
 	{ "name": "buffer_right_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "buffer_right", "role": "ce0" }} , 
 	{ "name": "buffer_right_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":24, "type": "signal", "bundle":{"name": "buffer_right", "role": "q0" }}  ]}

set ArgLastReadFirstWriteLatency {
	fir_hw_Pipeline_VITIS_LOOP_32_1 {
		add_ln32 {Type I LastRead 0 FirstWrite -1}
		write_idx_load {Type I LastRead 0 FirstWrite -1}
		coeff_hw {Type I LastRead 0 FirstWrite -1}
		out_data_data_out {Type O LastRead -1 FirstWrite 0}
		out_data_data_1_out {Type O LastRead -1 FirstWrite 0}
		buffer_left {Type I LastRead 0 FirstWrite -1}
		buffer_right {Type I LastRead 0 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "258", "Max" : "1026"}
	, {"Name" : "Interval", "Min" : "257", "Max" : "1025"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	add_ln32 { ap_none {  { add_ln32 in_data 0 10 } } }
	write_idx_load { ap_none {  { write_idx_load in_data 0 9 } } }
	coeff_hw { ap_memory {  { coeff_hw_address0 mem_address 1 9 }  { coeff_hw_ce0 mem_ce 1 1 }  { coeff_hw_q0 mem_dout 0 32 } } }
	out_data_data_out { ap_vld {  { out_data_data_out out_data 1 32 }  { out_data_data_out_ap_vld out_vld 1 1 } } }
	out_data_data_1_out { ap_vld {  { out_data_data_1_out out_data 1 32 }  { out_data_data_1_out_ap_vld out_vld 1 1 } } }
	buffer_left { ap_memory {  { buffer_left_address0 mem_address 1 9 }  { buffer_left_ce0 mem_ce 1 1 }  { buffer_left_q0 mem_dout 0 24 } } }
	buffer_right { ap_memory {  { buffer_right_address0 mem_address 1 9 }  { buffer_right_ce0 mem_ce 1 1 }  { buffer_right_q0 mem_dout 0 24 } } }
}
