#!/usr/bin/csh
vdel -all -lib work
vlib work
vmap work work
<<<<<<< HEAD:tb/CDR/sim_script.csh
set test_bench_dir=test_bench
=======
set test_bench_dir=../../tb/cdr
>>>>>>> e3a47fc (renamed files and modules : CDR --> cdr):tb/cdr/sim_script.csh
set rtl_dir="."
vlog -sv $rtl_dir/*.sv -define $2 -define behaviour_model
vlog -sv $test_bench_dir/*.sv
vsim -voptargs=+acc work.$1 -L c35_CORELIB -sdfmax /tb_cdr/dut=dc/netlist/alexander.sdf -sdfnoerror -sdfnowarn

