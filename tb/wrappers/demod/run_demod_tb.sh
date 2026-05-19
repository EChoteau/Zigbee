#!/bin/bash
# =====================================================
# Testbench: DEMOD Wrapper
# Run from project root: ./tb/wrappers/demod/run_demod_tb.sh
# =====================================================

source config/config_RTL

set -u

vdel -all -lib lib_rtl 2>/dev/null || true
vlib lib_rtl
vmap lib_rtl lib_rtl

# compile necessary RTL
vlog -sv rtl/demod/FIR/*.sv -work lib_rtl
vlog -sv rtl/demod/WAVE/*.sv -work lib_rtl
vlog -sv rtl/demod/*.sv -work lib_rtl
vlog -sv rtl/top/wrappers/demod_wrapper.sv -work lib_rtl
vlog -sv tb/wrappers/demod/tb_demod_wrapper.sv -work lib_rtl

# run
n=lib_rtl.tb_demod_wrapper
vsim -c ${n} -do "tb/wrappers/demod/demod.do"
