#=============================================================================
# Genus Synthesis + DFT Insertion Script
# Design: uart_top (8N1 UART — RX + TX)
# Tool: Cadence Genus Synthesis Solution
# Library: 90nm (slow.lib)
#
# This script performs:
#   1. Library setup  (90nm foundry  — same path as mips_easy reference)
#   2. RTL read & elaborate  (uart_rx.v  uart_tx.v  uart_top.v)
#   3. Constraints application (SDC)
#   4. Synthesis (generic + mapped)
#   5. DFT scan chain insertion  (muxed_scan, single chain)
#   6. Incremental optimisation post-DFT
#   7. Netlist export (pre-DFT and post-DFT) + Modus ATPG files
#=============================================================================

puts "============================================================"
puts "  Genus Synthesis + DFT Script for uart_top"
puts "  Technology: 90nm"
puts "============================================================"

#---------------------------------------------------------------------
# Step 1: Setup 90nm Library Paths
#         (same FOUNDRY path used in mips_easy reference)
#---------------------------------------------------------------------
set_db init_lib_search_path /home/install/FOUNDRY/digital/90nm/dig/lib/
set_db library slow.lib

#---------------------------------------------------------------------
# Step 2: Read HDL source files
#---------------------------------------------------------------------
puts "\n>>> Reading RTL Design..."
read_hdl ./uart_rx.v
read_hdl ./uart_tx.v
read_hdl ./uart_top.v

#---------------------------------------------------------------------
# Step 3: Elaborate the design
#---------------------------------------------------------------------
puts "\n>>> Elaborating Design..."
set_db hdl_unconnected_value 0
elaborate uart_top
check_design -unresolved

#---------------------------------------------------------------------
# Step 4: Read timing constraints (SDC)
#---------------------------------------------------------------------
puts "\n>>> Reading SDC Constraints..."
read_sdc ./uart_top.sdc

#---------------------------------------------------------------------
# Step 5: Power optimisation goals
#---------------------------------------------------------------------
set_max_leakage_power 0.0
set_max_dynamic_power 0.0

#---------------------------------------------------------------------
# Step 5b: Pre-Synthesis DFT Definitions
#          muxed_scan style — matches mips_easy methodology
#---------------------------------------------------------------------
set_db dft_scan_style muxed_scan
set_db dft_prefix     DFT_

define_dft shift_enable -name scan_en_sig -active high scan_en
define_dft test_clock   -name clk_test    -period 20000 clk

#---------------------------------------------------------------------
# Step 6: Synthesise to generic gates
#---------------------------------------------------------------------
puts "\n>>> Synthesising to Generic Gates..."
set_db syn_generic_effort high
syn_generic

#---------------------------------------------------------------------
# Step 7: Synthesise to mapped (technology) gates
#---------------------------------------------------------------------
puts "\n>>> Mapping to 90nm Technology Library..."
set_db syn_map_effort high
syn_map

#---------------------------------------------------------------------
# Step 8: Incremental Optimisation
#---------------------------------------------------------------------
puts "\n>>> Running Incremental Optimisation..."
set_db syn_opt_effort high
syn_opt

#---------------------------------------------------------------------
# Step 9: Pre-DFT Reports
#---------------------------------------------------------------------
puts "\n>>> Generating Pre-DFT Reports..."
report timing > ./pre_dft_timing.rpt
report area   > ./pre_dft_area.rpt
report power  > ./pre_dft_power.rpt
report gates  > ./pre_dft_gates.rpt

#---------------------------------------------------------------------
# Step 10: Write Pre-DFT Netlist
#---------------------------------------------------------------------
puts "\n>>> Writing Pre-DFT Netlist..."
write_hdl > ./uart_top_pre_dft.v
write_sdc > ./uart_top_pre_dft.sdc

#---------------------------------------------------------------------
# Step 11: Check DFT Rules & Insert Scan Chains
#---------------------------------------------------------------------
puts "\n>>> Checking DFT Rules..."
check_dft_rules > ./dft_rules_check.rpt

puts "\n>>> Replacing Flip-Flops with Scan FFs..."
replace_scan

puts "\n>>> Connecting Scan Chains..."
# Single scan chain  — scan_in / scan_out match uart_top port names
define_scan_chain -name chain1 -sdi scan_in -sdo scan_out -non_shared_output
connect_scan_chains

#---------------------------------------------------------------------
# Step 12: Post-DFT Optimisation
#---------------------------------------------------------------------
puts "\n>>> Post-DFT Incremental Optimisation..."
syn_opt -incr

#---------------------------------------------------------------------
# Step 13: Post-DFT Reports
#---------------------------------------------------------------------
puts "\n>>> Generating Post-DFT Reports..."
report timing     > ./post_dft_timing.rpt
report area       > ./post_dft_area.rpt
report power      > ./post_dft_power.rpt
report gates      > ./post_dft_gates.rpt
report dft_setup  > ./dft_setup.rpt
report dft_chains > ./scan_chains.rpt
check_dft_rules   > ./post_dft_rules.rpt

#---------------------------------------------------------------------
# Step 14: Write Post-DFT Netlist, SDC, SDF, and scandef
#---------------------------------------------------------------------
puts "\n>>> Writing Post-DFT Netlist..."
write_hdl > ./uart_top_post_dft.v
write_sdf > ./uart_top_post_dft.sdf
write_sdc > ./uart_top_post_dft.sdc
write_scandef > ./uart_top.scandef

#---------------------------------------------------------------------
# Step 15: Write DFT/ATPG files for Modus
#          Generates: test_netlist.v  .pinassign  test.modedef  test.exclude
#          All written to working directory (picked up by Modus script)
#---------------------------------------------------------------------
puts "\n>>> Writing DFT Protocol for Modus..."
write_dft_atpg -library ./uart_top_post_dft.v \
               -directory ./

puts "\n============================================================"
puts "  Genus Synthesis + DFT Complete! (90nm)  —  uart_top"
puts "  Check current directory for all reports and netlists"
puts "  Check current directory for Modus ATPG input files"
puts "============================================================"

gui_show
