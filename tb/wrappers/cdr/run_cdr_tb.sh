#!/bin/bash
# =====================================================
# Testbench: CDR Wrapper
# Run from project root: ./tb/wrappers/cdr/run_cdr_tb.sh
# =====================================================

source config/config_RTL

set -u

vdel -all -lib lib_rtl 2>/dev/null || true
vlib lib_rtl
vmap lib_rtl lib_rtl

# compile necessary RTL
vlog -sv rtl/cdr/*.sv -work lib_rtl
vlog -sv rtl/top/wrappers/cdr_wrapper.sv -work lib_rtl
vlog -sv tb/wrappers/cdr/tb_cdr_wrapper.sv -work lib_rtl

# run
n=lib_rtl.tb_cdr_wrapper
vsim -c ${n} -do "tb/wrappers/cdr/cdr.do"
