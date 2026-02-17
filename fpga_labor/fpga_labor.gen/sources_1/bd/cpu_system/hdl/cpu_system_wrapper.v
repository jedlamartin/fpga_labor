//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
//Date        : Tue Feb 17 09:52:37 2026
//Host        : fpgalab running 64-bit Ubuntu 24.04.4 LTS
//Command     : generate_target cpu_system_wrapper.bd
//Design      : cpu_system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module cpu_system_wrapper
   (btn_tri_i,
    led_tri_o);
  input [3:0]btn_tri_i;
  output [3:0]led_tri_o;

  wire [3:0]btn_tri_i;
  wire [3:0]led_tri_o;

  cpu_system cpu_system_i
       (.btn_tri_i(btn_tri_i),
        .led_tri_o(led_tri_o));
endmodule
