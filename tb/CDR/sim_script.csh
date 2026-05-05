#!/usr/bin/csh
vdel -all -lib work
vlib work
vmap work work
set test_bench_dir=../../tb/CDR
set rtl_dir="."
vlog -sv $rtl_dir/*.sv -define $2 -define behaviour_model
vlog -sv $test_bench_dir/*.sv
vlog -sv $rtl_dir/../top/wrappers/cdr_wrapper.sv
vsim -voptargs=+acc work.$1 -L c35_CORELIB #-sdfmax /tb_cdr/dut=dc/netlist/alexander.sdf -sdfnoerror -sdfnowarn

