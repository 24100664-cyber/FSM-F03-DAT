###############################################################################
# Created by write_sdc
###############################################################################
current_design f03_lock_scaffold_explicit
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 10.0000 [get_ports {clk}]
set_propagated_clock [get_clocks {clk}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {digit[0]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {digit[1]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {digit[2]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {digit[3]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {digit_valid}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {rst_n}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {locked}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {unlock}]
###############################################################################
# Environment
###############################################################################
###############################################################################
# Design Rules
###############################################################################
