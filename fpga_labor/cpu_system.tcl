# Creating SmartDesign "cpu_system"
set sd_name {cpu_system}
create_smartdesign -sd_name ${sd_name}

# Disable auto promotion of pins of type 'pad'
auto_promote_pad_pins -promote_all 0

# Create top level Scalar Ports
sd_create_scalar_port -sd_name ${sd_name} -port_name {MMUART_1_RXD} -port_direction {IN} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {REFCLK_N} -port_direction {IN} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {REFCLK} -port_direction {IN} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {REF_CLK_0} -port_direction {IN}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_CD} -port_direction {IN} -port_is_pad {1}

sd_create_scalar_port -sd_name ${sd_name} -port_name {ACT_N} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {BG0} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {CAS_N} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {CK0_N} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {CK0} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {CKE0} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {CS0_N} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {MMUART_1_TXD} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {ODT0} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {RAS_N} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {RESET_N} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_CLK} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_VOLT_CMD_DIR} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_VOLT_DIR_0} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_VOLT_DIR_1_3} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_VOLT_EN} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_VOLT_SEL} -port_direction {OUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {WE_N} -port_direction {OUT} -port_is_pad {1}

sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_CMD} -port_direction {INOUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_DATA0} -port_direction {INOUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_DATA1} -port_direction {INOUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_DATA2} -port_direction {INOUT} -port_is_pad {1}
sd_create_scalar_port -sd_name ${sd_name} -port_name {SD_DATA3} -port_direction {INOUT} -port_is_pad {1}

# Create top level Bus Ports
sd_create_bus_port -sd_name ${sd_name} -port_name {btn} -port_direction {IN} -port_range {[3:0]}

sd_create_bus_port -sd_name ${sd_name} -port_name {A} -port_direction {OUT} -port_range {[13:0]} -port_is_pad {1}
sd_create_bus_port -sd_name ${sd_name} -port_name {BA} -port_direction {OUT} -port_range {[1:0]} -port_is_pad {1}
sd_create_bus_port -sd_name ${sd_name} -port_name {DM} -port_direction {OUT} -port_range {[1:0]} -port_is_pad {1}
sd_create_bus_port -sd_name ${sd_name} -port_name {led} -port_direction {OUT} -port_range {[3:0]}

sd_create_bus_port -sd_name ${sd_name} -port_name {DQS_N} -port_direction {INOUT} -port_range {[1:0]} -port_is_pad {1}
sd_create_bus_port -sd_name ${sd_name} -port_name {DQS} -port_direction {INOUT} -port_range {[1:0]} -port_is_pad {1}
sd_create_bus_port -sd_name ${sd_name} -port_name {DQ} -port_direction {INOUT} -port_range {[15:0]} -port_is_pad {1}

# Add CoreAPB3_C0_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {CoreAPB3_C0} -instance_name {CoreAPB3_C0_0}



# Add COREAXI4INTERCONNECT_C0_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {COREAXI4INTERCONNECT_C0} -instance_name {COREAXI4INTERCONNECT_C0_0}



# Add COREAXI4INTERCONNECT_C1_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {COREAXI4INTERCONNECT_C1} -instance_name {COREAXI4INTERCONNECT_C1_0}



# Add COREAXI4PROTOCONV_C0_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {COREAXI4PROTOCONV_C0} -instance_name {COREAXI4PROTOCONV_C0_0}
sd_create_pin_slices -sd_name ${sd_name} -pin_name {COREAXI4PROTOCONV_C0_0:I_AXI4S_TDEST} -pin_slices {[0:1]}
sd_show_bif_pins -sd_name ${sd_name} -bif_pin_name {COREAXI4PROTOCONV_C0_0:MM2S_AXI4S_INITR} -pin_names {COREAXI4PROTOCONV_C0_0:I_AXI4S_TVALID}
sd_show_bif_pins -sd_name ${sd_name} -bif_pin_name {COREAXI4PROTOCONV_C0_0:MM2S_AXI4S_INITR} -pin_names {COREAXI4PROTOCONV_C0_0:I_AXI4S_TDATA}
sd_show_bif_pins -sd_name ${sd_name} -bif_pin_name {COREAXI4PROTOCONV_C0_0:MM2S_AXI4S_INITR} -pin_names {COREAXI4PROTOCONV_C0_0:I_AXI4S_TKEEP}
sd_show_bif_pins -sd_name ${sd_name} -bif_pin_name {COREAXI4PROTOCONV_C0_0:MM2S_AXI4S_INITR} -pin_names {COREAXI4PROTOCONV_C0_0:I_AXI4S_TLAST}
sd_show_bif_pins -sd_name ${sd_name} -bif_pin_name {COREAXI4PROTOCONV_C0_0:MM2S_AXI4S_INITR} -pin_names {COREAXI4PROTOCONV_C0_0:I_AXI4S_TID}
sd_show_bif_pins -sd_name ${sd_name} -bif_pin_name {COREAXI4PROTOCONV_C0_0:MM2S_AXI4S_INITR} -pin_names {COREAXI4PROTOCONV_C0_0:I_AXI4S_TDEST}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {COREAXI4PROTOCONV_C0_0:S2MM_ERR_INT}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {COREAXI4PROTOCONV_C0_0:MM2S_ERR_INT}



# Add CoreAXI4SInterconnect_C0_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {CoreAXI4SInterconnect_C0} -instance_name {CoreAXI4SInterconnect_C0_0}



# Add CoreGPIO_C0_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {CoreGPIO_C0} -instance_name {CoreGPIO_C0_0}
sd_create_pin_slices -sd_name ${sd_name} -pin_name {CoreGPIO_C0_0:GPIO_IN} -pin_slices {[0:3]}
sd_create_pin_slices -sd_name ${sd_name} -pin_name {CoreGPIO_C0_0:GPIO_IN} -pin_slices {[4:7]}
sd_connect_pins_to_constant -sd_name ${sd_name} -pin_names {CoreGPIO_C0_0:GPIO_IN[4:7]} -value {GND}
sd_create_pin_slices -sd_name ${sd_name} -pin_name {CoreGPIO_C0_0:GPIO_OUT} -pin_slices {[0:3]}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {CoreGPIO_C0_0:GPIO_OUT[0:3]}
sd_create_pin_slices -sd_name ${sd_name} -pin_name {CoreGPIO_C0_0:GPIO_OUT} -pin_slices {[4:7]}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {CoreGPIO_C0_0:INT}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {CoreGPIO_C0_0:GPIO_OE}



# Add CORERESET_PF_C0_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {CORERESET_PF_C0} -instance_name {CORERESET_PF_C0_0}
sd_connect_pins_to_constant -sd_name ${sd_name} -pin_names {CORERESET_PF_C0_0:BANK_x_VDDI_STATUS} -value {VCC}
sd_connect_pins_to_constant -sd_name ${sd_name} -pin_names {CORERESET_PF_C0_0:BANK_y_VDDI_STATUS} -value {VCC}
sd_connect_pins_to_constant -sd_name ${sd_name} -pin_names {CORERESET_PF_C0_0:SS_BUSY} -value {GND}
sd_connect_pins_to_constant -sd_name ${sd_name} -pin_names {CORERESET_PF_C0_0:FF_US_RESTORE} -value {GND}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {CORERESET_PF_C0_0:PLL_POWERDOWN_B}



# Add MPFS_DISCOVERY_KIT_MSS_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {MPFS_DISCOVERY_KIT_MSS} -instance_name {MPFS_DISCOVERY_KIT_MSS_0}
sd_create_pin_slices -sd_name ${sd_name} -pin_name {MPFS_DISCOVERY_KIT_MSS_0:MSS_INT_F2M} -pin_slices {[0:0]}
sd_create_pin_slices -sd_name ${sd_name} -pin_name {MPFS_DISCOVERY_KIT_MSS_0:MSS_INT_F2M} -pin_slices {[1:1]}
sd_create_pin_slices -sd_name ${sd_name} -pin_name {MPFS_DISCOVERY_KIT_MSS_0:MSS_INT_F2M} -pin_slices {[2:63]}
sd_connect_pins_to_constant -sd_name ${sd_name} -pin_names {MPFS_DISCOVERY_KIT_MSS_0:MSS_INT_F2M[2:63]} -value {GND}
sd_connect_pins_to_constant -sd_name ${sd_name} -pin_names {MPFS_DISCOVERY_KIT_MSS_0:MSS_RESET_N_F2M} -value {VCC}



# Add PF_CCC_C0_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {PF_CCC_C0} -instance_name {PF_CCC_C0_0}
sd_connect_pins_to_constant -sd_name ${sd_name} -pin_names {PF_CCC_C0_0:PLL_POWERDOWN_N_0} -value {VCC}



# Add PFSOC_INIT_MONITOR_C0_0 instance
sd_instantiate_component -sd_name ${sd_name} -component_name {PFSOC_INIT_MONITOR_C0} -instance_name {PFSOC_INIT_MONITOR_C0_0}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:PCIE_INIT_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:USRAM_INIT_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:SRAM_INIT_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:XCVR_INIT_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:USRAM_INIT_FROM_SNVM_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:USRAM_INIT_FROM_UPROM_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:USRAM_INIT_FROM_SPI_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:SRAM_INIT_FROM_SNVM_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:SRAM_INIT_FROM_UPROM_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:SRAM_INIT_FROM_SPI_DONE}
sd_mark_pins_unused -sd_name ${sd_name} -pin_names {PFSOC_INIT_MONITOR_C0_0:AUTOCALIB_DONE}



# Add scalar net connections
sd_connect_pins -sd_name ${sd_name} -pin_names {"ACT_N" "MPFS_DISCOVERY_KIT_MSS_0:ACT_N" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"BG0" "MPFS_DISCOVERY_KIT_MSS_0:BG0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CAS_N" "MPFS_DISCOVERY_KIT_MSS_0:CAS_N" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CK0" "MPFS_DISCOVERY_KIT_MSS_0:CK0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CK0_N" "MPFS_DISCOVERY_KIT_MSS_0:CK0_N" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CKE0" "MPFS_DISCOVERY_KIT_MSS_0:CKE0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4INTERCONNECT_C0_0:ACLK" "COREAXI4INTERCONNECT_C1_0:ACLK" "COREAXI4PROTOCONV_C0_0:ACLK" "CORERESET_PF_C0_0:CLK" "CoreAXI4SInterconnect_C0_0:AXI4S_I0CLK" "CoreGPIO_C0_0:PCLK" "MPFS_DISCOVERY_KIT_MSS_0:FIC_0_ACLK" "MPFS_DISCOVERY_KIT_MSS_0:FIC_1_ACLK" "MPFS_DISCOVERY_KIT_MSS_0:FIC_3_PCLK" "PF_CCC_C0_0:OUT0_FABCLK_0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4INTERCONNECT_C0_0:ARESETN" "COREAXI4INTERCONNECT_C1_0:ARESETN" "COREAXI4PROTOCONV_C0_0:RESETN" "CORERESET_PF_C0_0:FABRIC_RESET_N" "CoreAXI4SInterconnect_C0_0:AXI4S_I0RESETN" "CoreGPIO_C0_0:PRESETN" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4PROTOCONV_C0_0:MM2S_INT" "MPFS_DISCOVERY_KIT_MSS_0:MSS_INT_F2M[0:0]" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4PROTOCONV_C0_0:S2MM_INT" "MPFS_DISCOVERY_KIT_MSS_0:MSS_INT_F2M[1:1]" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CORERESET_PF_C0_0:EXT_RST_N" "MPFS_DISCOVERY_KIT_MSS_0:MSS_RESET_N_M2F" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CORERESET_PF_C0_0:FPGA_POR_N" "PFSOC_INIT_MONITOR_C0_0:FABRIC_POR_N" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CORERESET_PF_C0_0:INIT_DONE" "PFSOC_INIT_MONITOR_C0_0:DEVICE_INIT_DONE" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CORERESET_PF_C0_0:PLL_LOCK" "PF_CCC_C0_0:PLL_LOCK_0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CS0_N" "MPFS_DISCOVERY_KIT_MSS_0:CS0_N" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MMUART_1_RXD" "MPFS_DISCOVERY_KIT_MSS_0:MMUART_1_RXD" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MMUART_1_TXD" "MPFS_DISCOVERY_KIT_MSS_0:MMUART_1_TXD" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:ODT0" "ODT0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:RAS_N" "RAS_N" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:REFCLK" "REFCLK" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:REFCLK_N" "REFCLK_N" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:RESET_N" "RESET_N" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_CD" "SD_CD" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_CLK" "SD_CLK" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_CMD" "SD_CMD" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_DATA0" "SD_DATA0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_DATA1" "SD_DATA1" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_DATA2" "SD_DATA2" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_DATA3" "SD_DATA3" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_VOLT_CMD_DIR" "SD_VOLT_CMD_DIR" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_VOLT_DIR_0" "SD_VOLT_DIR_0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_VOLT_DIR_1_3" "SD_VOLT_DIR_1_3" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_VOLT_EN" "SD_VOLT_EN" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:SD_VOLT_SEL" "SD_VOLT_SEL" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"MPFS_DISCOVERY_KIT_MSS_0:WE_N" "WE_N" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"PF_CCC_C0_0:REF_CLK_0" "REF_CLK_0" }

# Add bus net connections
sd_create_bus_net -sd_name ${sd_name} -net_name {GPIO_IN} -net_range {[3:0]}
sd_connect_net_to_pins -sd_name ${sd_name} -net_name {GPIO_IN} -pin_names {"CoreGPIO_C0_0:GPIO_IN[0:3]" "btn" }

sd_connect_pins -sd_name ${sd_name} -pin_names {"A" "MPFS_DISCOVERY_KIT_MSS_0:A" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"BA" "MPFS_DISCOVERY_KIT_MSS_0:BA" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CoreGPIO_C0_0:GPIO_OUT[4:7]" "led" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"DM" "MPFS_DISCOVERY_KIT_MSS_0:DM" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"DQ" "MPFS_DISCOVERY_KIT_MSS_0:DQ" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"DQS" "MPFS_DISCOVERY_KIT_MSS_0:DQS" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"DQS_N" "MPFS_DISCOVERY_KIT_MSS_0:DQS_N" }

# Add bus interface net connections
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4INTERCONNECT_C0_0:AXI4mmaster0" "MPFS_DISCOVERY_KIT_MSS_0:FIC_1_AXI4_INITIATOR" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4INTERCONNECT_C0_0:AXI4mslave0" "COREAXI4PROTOCONV_C0_0:AXI4L_TRGT" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4INTERCONNECT_C1_0:AXI4mmaster0" "COREAXI4PROTOCONV_C0_0:S2MM_AXI4MM_INITR" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4INTERCONNECT_C1_0:AXI4mmaster1" "COREAXI4PROTOCONV_C0_0:MM2S_AXI4MM_INITR" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4INTERCONNECT_C1_0:AXI4mslave0" "MPFS_DISCOVERY_KIT_MSS_0:FIC_0_AXI4_TARGET" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4PROTOCONV_C0_0:MM2S_AXI4S_INITR" "CoreAXI4SInterconnect_C0_0:AXI4S_TARGET0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"COREAXI4PROTOCONV_C0_0:S2MM_AXI4S_TRGT" "CoreAXI4SInterconnect_C0_0:AXI4S_INITIATOR0" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CoreAPB3_C0_0:APB3mmaster" "MPFS_DISCOVERY_KIT_MSS_0:FIC_3_APB_INITIATOR" }
sd_connect_pins -sd_name ${sd_name} -pin_names {"CoreAPB3_C0_0:APBmslave0" "CoreGPIO_C0_0:APB_bif" }

# Re-enable auto promotion of pins of type 'pad'
auto_promote_pad_pins -promote_all 1
# Save the SmartDesign 
save_smartdesign -sd_name ${sd_name}
# Generate SmartDesign "cpu_system"
generate_component -component_name ${sd_name}
