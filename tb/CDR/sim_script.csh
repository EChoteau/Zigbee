#!/usr/bin/csh
vdel -all -lib work
vlib work
vmap work work
set test_bench_dir=test_bench
set rtl_dir="."
vlog -sv $rtl_dir/*.sv -define $2 -define behaviour_model
vlog -sv $test_bench_dir/*.sv
vsim -voptargs=+acc work.$1 -L c35_CORELIB -sdfmax /tb_cdr/dut=dc/netlist/alexander.sdf -sdfnoerror -sdfnowarn

