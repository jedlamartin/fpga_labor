

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "4", "5"],
		"CDFG" : "bypass_hw",
		"Protocol" : "ap_ctrl_none",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "0", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "2", "EstimateLatencyMax" : "2",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "tlast_dnum", "Type" : "None", "Direction" : "I"},
			{"Name" : "input_l", "Type" : "HS", "Direction" : "I",
				"BlockSignal" : [
					{"Name" : "input_l_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "input_r", "Type" : "HS", "Direction" : "I",
				"BlockSignal" : [
					{"Name" : "input_r_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "res_V_data_V", "Type" : "Axis", "Direction" : "O", "BaseName" : "res",
				"BlockSignal" : [
					{"Name" : "res_TDATA_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "res_V_keep_V", "Type" : "Axis", "Direction" : "O", "BaseName" : "res"},
			{"Name" : "res_V_strb_V", "Type" : "Axis", "Direction" : "O", "BaseName" : "res"},
			{"Name" : "res_V_last_V", "Type" : "Axis", "Direction" : "O", "BaseName" : "res"},
			{"Name" : "cnt", "Type" : "OVld", "Direction" : "IO"}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.control_s_axi_U", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_res_V_data_V_U", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_res_V_keep_V_U", "Parent" : "0"},
	{"ID" : "4", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_res_V_strb_V_U", "Parent" : "0"},
	{"ID" : "5", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_res_V_last_V_U", "Parent" : "0"}]}
