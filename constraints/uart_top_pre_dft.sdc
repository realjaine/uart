# ####################################################################

#  Created by Genus(TM) Synthesis Solution 20.11-s111_1 on Mon Apr 13 19:04:02 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design uart_top

create_clock -name "clk" -period 20.0 -waveform {0.0 10.0} [get_ports clk]
set_clock_transition 0.2 [get_clocks clk]
set_load -pin_load 0.05 [get_ports scan_out]
set_load -pin_load 0.05 [get_ports {rx_data[7]}]
set_load -pin_load 0.05 [get_ports {rx_data[6]}]
set_load -pin_load 0.05 [get_ports {rx_data[5]}]
set_load -pin_load 0.05 [get_ports {rx_data[4]}]
set_load -pin_load 0.05 [get_ports {rx_data[3]}]
set_load -pin_load 0.05 [get_ports {rx_data[2]}]
set_load -pin_load 0.05 [get_ports {rx_data[1]}]
set_load -pin_load 0.05 [get_ports {rx_data[0]}]
set_load -pin_load 0.05 [get_ports rx_valid]
set_load -pin_load 0.05 [get_ports tx]
set_load -pin_load 0.05 [get_ports tx_busy]
set_false_path -from [list \
  [get_ports scan_en]  \
  [get_ports scan_in] ]
set_false_path -to [get_ports scan_out]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports rx]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {tx_data[7]}]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {tx_data[6]}]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {tx_data[5]}]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {tx_data[4]}]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {tx_data[3]}]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {tx_data[2]}]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {tx_data[1]}]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {tx_data[0]}]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports tx_start]
set_input_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports rst_n]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports tx]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {rx_data[7]}]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {rx_data[6]}]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {rx_data[5]}]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {rx_data[4]}]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {rx_data[3]}]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {rx_data[2]}]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {rx_data[1]}]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports {rx_data[0]}]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports rx_valid]
set_output_delay -clock [get_clocks clk] -add_delay 5.0 [get_ports tx_busy]
set_max_fanout 20.000 [current_design]
set_max_transition 0.5 [current_design]
set_max_leakage_power 0.0
set_max_dynamic_power 0.0
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold 0.5 [get_clocks clk]
