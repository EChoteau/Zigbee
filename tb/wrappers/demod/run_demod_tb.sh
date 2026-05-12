#!/bin/bash
set -euo pipefail

vdel -all -lib lib_rtl_demod 2>/dev/null || true
vlib lib_rtl_demod
vmap lib_rtl lib_rtl_demod

# compile necessary RTL (root-relative paths)
vlog -sv rtl/demod/FIR/*.sv -work lib_rtl_demod
vlog -sv rtl/demod/WAVE/*.sv -work lib_rtl_demod
vlog -sv rtl/demod/*.sv -work lib_rtl_demod
vlog -sv rtl/top/wrappers/demod_wrapper.sv -work lib_rtl_demod
vlog -sv tb/wrappers/demod/tb_demod_wrapper.sv -work lib_rtl_demod

# run
n=lib_rtl_demod.tb_demod_wrapper
vsim -c ${n} -do "tb/wrappers/demod/demod.do"
