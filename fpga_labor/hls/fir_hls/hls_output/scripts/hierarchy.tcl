add wave -hex -group "fir_hw_hw_top" -group "ports"  {*}[lsort [find nets -ports [lindex [find instances -bydu fir_hw_hw_top] 0]/*]]
add wave -hex -group "fir_hw_hw_top" -group "fir_hw" -group "ports"  {*}[lsort [find nets -ports [lindex [find instances -r /fir_hw_inst] 0]/*]]
