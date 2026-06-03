set SynModuleInfo {
  {SRCNAME bypass_hw MODELNAME bypass_hw RTLNAME bypass_hw IS_TOP 1
    SUBMODULES {
      {MODELNAME bypass_hw_control_s_axi RTLNAME bypass_hw_control_s_axi BINDTYPE interface TYPE interface_s_axilite}
      {MODELNAME bypass_hw_regslice_both RTLNAME bypass_hw_regslice_both BINDTYPE interface TYPE adapter IMPL reg_slice}
    }
  }
}
