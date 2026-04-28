set SynModuleInfo {
  {SRCNAME fir_hw_Pipeline_VITIS_LOOP_32_1 MODELNAME fir_hw_Pipeline_VITIS_LOOP_32_1 RTLNAME fir_hw_fir_hw_Pipeline_VITIS_LOOP_32_1
    SUBMODULES {
      {MODELNAME fir_hw_mul_47s_32s_79_1_1 RTLNAME fir_hw_mul_47s_32s_79_1_1 BINDTYPE op TYPE mul IMPL auto LATENCY 0 ALLOW_PRAGMA 1}
      {MODELNAME fir_hw_flow_control_loop_pipe_sequential_init RTLNAME fir_hw_flow_control_loop_pipe_sequential_init BINDTYPE interface TYPE internal_upc_flow_control INSTNAME fir_hw_flow_control_loop_pipe_sequential_init_U}
    }
  }
  {SRCNAME fir_hw MODELNAME fir_hw RTLNAME fir_hw IS_TOP 1
    SUBMODULES {
      {MODELNAME fir_hw_buffer_left_RAM_AUTO_1R1W RTLNAME fir_hw_buffer_left_RAM_AUTO_1R1W BINDTYPE storage TYPE ram IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME fir_hw_control_s_axi RTLNAME fir_hw_control_s_axi BINDTYPE interface TYPE interface_s_axilite}
      {MODELNAME fir_hw_regslice_both RTLNAME fir_hw_regslice_both BINDTYPE interface TYPE adapter IMPL reg_slice}
    }
  }
}
