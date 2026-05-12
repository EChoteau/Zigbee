#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

vdel -all -lib lib_rtl_cordic 2>/dev/null || true
vlib lib_rtl_cordic
vmap lib_rtl lib_rtl_cordic

# compile necessary RTL
vlog -sv ../../../rtl/cordic/*.sv -work lib_rtl_cordic
vlog -sv ../../../rtl/top/wrappers/cordic_wrapper.sv -work lib_rtl_cordic
vlog -sv tb_cordic_wrapper.sv -work lib_rtl_cordic

# run
n=lib_rtl_cordic.tb_cordic_wrapper
vsim -c ${n} -do "cordic.do"
