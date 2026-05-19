#!/bin/bash
# =====================================================
# Testbench: CDR Wrapper
# Run from project root: ./tb/wrappers/cdr/run_cdr_tb.sh
# =====================================================

source config/config_RTL

set -euo pipefail

vdel -all -lib lib_rtl_cdr 2>/dev/null || true
vlib lib_rtl_cdr
vmap lib_rtl lib_rtl_cdr

# compile necessary RTL
vlog -sv rtl/cdr/*.sv -work lib_rtl_cdr
vlog -sv rtl/top/wrappers/cdr_wrapper.sv -work lib_rtl_cdr
vlog -sv tb/wrappers/cdr/tb_cdr_wrapper.sv -work lib_rtl_cdr

# run
n=lib_rtl_cdr.tb_cdr_wrapper
vsim -c ${n} -do "tb/wrappers/cdr/cdr.do"
