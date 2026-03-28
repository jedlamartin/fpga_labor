set_component PF_CCC_C0_PF_CCC_C0_0_PF_CCC
# Microchip Technology Inc.
# Date: 2026-Mar-27 19:12:13
#

# Base clock for PLL #0
create_clock -period 20 [ get_pins { pll_inst_0/REF_CLK_0 } ]
create_generated_clock -multiply_by 2 -source [ get_pins { pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { pll_inst_0/OUT0 } ]
