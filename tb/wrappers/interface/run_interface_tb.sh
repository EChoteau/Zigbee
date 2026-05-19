#!/bin/bash
# =====================================================
# Testbench: Interface Wrapper
# Run from project root: ./tb/wrappers/interface/run_interface_tb.sh
# =====================================================

source config/config_RTL

set -u

# work library
vdel -all -lib lib_rtl 2>/dev/null || true
vlib lib_rtl
vmap lib_rtl lib_rtl

# compile RTL and TB
vlog -sv rtl/interface/*.sv -work lib_rtl
vlog -sv rtl/top/wrappers/interface_wrapper.sv -work lib_rtl
vlog -sv tb/wrappers/interface/tb_interface_wrapper.sv -work lib_rtl

# run
n=lib_rtl.tb_interface_wrapper
vsim -c ${n} -do "tb/wrappers/interface/interface.do"
