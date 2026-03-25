set_component CoreAXI4SInterconnect_C0
set_false_path -from [ get_cells { */genblk*.genblk1.axi4s_tcdc/U_COREFIFO_AXI4_S_IF/genblk*.tlast_en_wr/u_pulse_gen/toggle*}]          -to [ get_cells { */genblk*.genblk1.axi4s_tcdc/U_COREFIFO_AXI4_S_IF/genblk*.tlast_en_wr/u_pulse_cdc_sync/sync_ff[0]}]
set_false_path -from [ get_cells { */genblk*.genblk1.axi4s_tcdc/U_COREFIFO_AXI4_S_IF/genblk*.cur_rd_trans_done_rd/u_pulse_gen/toggle*}] -to [ get_cells { */genblk*.genblk1.axi4s_tcdc/U_COREFIFO_AXI4_S_IF/genblk*.cur_rd_trans_done_rd/u_pulse_cdc_sync/sync_ff[0]}]
set_false_path -from [ get_cells { */genblk*.genblk1.axi4s_tcdc/genblk1.U_CDCFIFO/wgrey*}]
set_false_path -from [ get_cells { */genblk*.genblk1.axi4s_tcdc/genblk1.U_CDCFIFO/rgrey*}]
