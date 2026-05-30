add wave -hex -group "bypass_hw_hw_top" -group "ports"  {*}[lsort [find nets -ports [lindex [find instances -bydu bypass_hw_hw_top] 0]/*]]
add wave -hex -group "bypass_hw_hw_top" -group "bypass_hw" -group "ports"  {*}[lsort [find nets -ports [lindex [find instances -r /bypass_hw_inst] 0]/*]]
