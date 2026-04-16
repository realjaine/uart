puts "\n============================================="
puts "Starting Modus Test Run Script for uart_top";
puts "=============================================\n"

set WORKDIR ./
set CELL uart_top

# 1. CREATE RESULTS DIRECTORY
set RESULTS_DIR $WORKDIR/results
puts ">>> Creating results directory at $RESULTS_DIR"
file mkdir $RESULTS_DIR

## Set netlist (post-DFT output from Genus)
set NETLIST $WORKDIR/uart_top_post_dft.v

## Dynamically locate 90nm Verilog library models
## (same FOUNDRY path as run_genus_dft_uart.tcl)
puts ">>> Actively Locating Library Models..."
set LIBRARY ""
catch {
    set raw_files [exec bash -c "find /home/install/FOUNDRY/digital/90nm/dig/ -type f | grep -E \"\\.v$|\\.v\\.gz$|\\.V$\""]
    set LIBRARY [split $raw_files "\n"]
}

## Test mode
set TESTMODE FULLSCAN

## Dynamically find pinassign and modedef written by Genus write_dft_atpg
set ASSIGNFILE ""
set MODEDEF ""
catch {
    set ASSIGNFILE [exec bash -c "find $WORKDIR -type f -name \"*.pinassign\" | head -n 1"]
    set MODEDEF    [exec bash -c "find $WORKDIR -type f -name \"*.modedef\"   | head -n 1"]
}

## Processing step flags  1=do  0=skip
set do_build_model 1;
set do_fault_model 1;

set do_build_testmode_FULLSCAN          1;
set do_report_test_structures_FULLSCAN  1;
set do_verify_test_structures_FULLSCAN  1;

set do_create_atpg_vectors 1;

#*************************************************
# BUILD MODEL
#*************************************************
if {$do_build_model} {
    puts "Building Test Model for $CELL"
    build_model  \
       -cell            $CELL        \
       -workdir         $WORKDIR     \
       -designsource    $NETLIST     \
       -TECHLIB         $LIBRARY     \
       -allowmissingmodules yes
}

#*************************************************
# BUILD TEST MODE FULLSCAN
#*************************************************
if {$do_build_testmode_FULLSCAN} {
    puts "Building Test Mode $TESTMODE"
    if {$MODEDEF ne ""} {
        build_testmode \
           -workdir   $WORKDIR     \
           -testmode  $TESTMODE    \
           -modedef   $MODEDEF     \
           -assignfile $ASSIGNFILE
    } else {
        build_testmode \
           -workdir    $WORKDIR    \
           -testmode   $TESTMODE   \
           -assignfile $ASSIGNFILE
    }
}

#*************************************************
# REPORT TEST STRUCTURES
#*************************************************
if {$do_report_test_structures_FULLSCAN} {
    puts "Report Test Structures $TESTMODE"
    report_test_structures \
       -workdir  $WORKDIR   \
       -testmode $TESTMODE > $RESULTS_DIR/test_structures.rpt
}

#*************************************************
# VERIFY TEST STRUCTURES
#*************************************************
if {$do_verify_test_structures_FULLSCAN} {
    puts "Verify Test Structures $TESTMODE"
    verify_test_structures \
       -workdir  $WORKDIR   \
       -testmode $TESTMODE > $RESULTS_DIR/verify_structures.rpt
}

#*************************************************
# BUILD FAULT MODEL
#*************************************************
if {$do_fault_model} {
    puts "Building Fault Model"
    build_faultmodel
}

#*************************************************
# CREATE ATPG VECTORS & GENERATE REPORTS
#*************************************************
if {$do_create_atpg_vectors} {
    puts "Generating Test Vectors..."

    redirect $RESULTS_DIR/test_coverage.rpt {
        create_logic_tests -experiment ex1 -testmode $TESTMODE
    }

    puts ">>> Writing Verilog Vectors..."
    write_vectors \
       -inexperiment   ex1          \
       -testmode       $TESTMODE    \
       -language       verilog      \
       -outputfilename $RESULTS_DIR/test_vectors.v
}

puts "\n============================================="
puts "Modus Run Complete  —  uart_top"
puts "All reports and vectors are saved in: $RESULTS_DIR"
puts "=============================================\n"
