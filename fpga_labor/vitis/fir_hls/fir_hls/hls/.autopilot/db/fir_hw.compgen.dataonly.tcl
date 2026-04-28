# This script segment is generated automatically by AutoPilot

set axilite_register_dict [dict create]
set port_control {
tlast_dnum { 
	dir I
	width 16
	depth 1
	mode ap_none
	offset 16
	offset_end 23
}
smpl_rd_num { 
	dir I
	width 3
	depth 1
	mode ap_none
	offset 24
	offset_end 31
}
tap_num_m1 { 
	dir I
	width 9
	depth 1
	mode ap_none
	offset 32
	offset_end 39
}
coeff_hw { 
	dir I
	width 32
	depth 512
	mode ap_memory
	offset 2048
	offset_end 4095
	core_op ram_1p
	core_impl auto
	core_latency 1
	byte_write 0
}
}
dict set axilite_register_dict control $port_control


