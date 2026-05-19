#!/bin/bash
# =====================================================
# Testbench: MSK Wrapper
# Run from project root: ./tb/msk/run_simu_rtl_wrapper.sh
# =====================================================

source config/config_RTL

vdel -all -lib lib_rtl
vlib lib_rtl
vmap lib_rtl lib_rtl

vlog -sv rtl/msk/*.sv rtl/top/wrappers/msk_wrapper.sv -work lib_rtl
vlog -sv tb/msk/wrapper_msk_tb.sv -work lib_rtl

vsim -c -voptargs=+acc lib_rtl.wrapper_msk_tb -do "run; quit -f"
