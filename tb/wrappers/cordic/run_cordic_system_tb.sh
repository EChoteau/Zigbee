#!/bin/bash
set -euo pipefail

# work library
vdel -all -lib lib_rtl 2>/dev/null || true
vlib lib_rtl
vmap lib_rtl lib_rtl

# compile RTL and TB (must be run from project root)
vlog -sv rtl/cordic/*.sv -work lib_rtl
vlog -sv rtl/top/wrappers/cordic_system_wrapper.sv -work lib_rtl
vlog -sv tb/wrappers/cordic/tb_cordic_system_wrapper.sv -work lib_rtl


vlog -incr -sv -work lib_RTL +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc tb/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/cordic/tb_cordic_system_wrapper.sv
vlog -incr -sv -work lib_RTL +acc rtl/top/wrappers/cordic_system_wrapper.sv

# run
n=lib_RTL.cordic_system_wrapper_tb 
vsim -c ${n} -do "cordic_system.do"

