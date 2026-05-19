#!/bin/bash
# =====================================================
# Testbench: MSK Wrapper
# Run from project root: ./tb/wrappers/msk/run_msk_tb.sh
# =====================================================

source config/config_RTL

set -u

# work library
vdel -all -lib lib_rtl 2>/dev/null || true
vlib lib_rtl
vmap lib_rtl lib_rtl

# compile RTL and TB
vlog -sv rtl/msk/*.sv -work lib_rtl
vlog -sv rtl/top/wrappers/msk_wrapper.sv -work lib_rtl
vlog -sv tb/wrappers/msk/tb_msk_wrapper.sv -work lib_rtl

# run
n=lib_rtl.tb_msk_wrapper
vsim -c ${n} -do "tb/wrappers/msk/msk.do"
