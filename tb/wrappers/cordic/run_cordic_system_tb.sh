#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

# work library
vdel -all -lib lib_rtl_cordic_system 2>/dev/null || true
vlib lib_rtl_cordic_system
vmap lib_rtl lib_rtl_cordic_system

# compile RTL and TB
vlog -sv ../../../rtl/cordic/*.sv -work lib_rtl_cordic_system
vlog -sv ../../../rtl/top/wrappers/cordic_system_wrapper.sv -work lib_rtl_cordic_system
vlog -sv ./tb_cordic_system_wrapper.sv -work lib_rtl_cordic_system


vlog -incr -sv -work lib_RTL +acc ../../../rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc ../../../tb/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/cordic/cordic_system_wrapper_tb.sv
vlog -incr -sv -work lib_RTL +acc rtl/top/wrappers/cordic_system_wrapper.sv

# run
n=lib_RTL.cordic_system_wrapper_tb 
vsim -c ${n} -do "cordic_system.do"

