#!/bin/bash
# =====================================================
# Testbench: MSK RTL
# Run from project root: ./tb/msk/run_simu_rtl.sh
# =====================================================

source config/config_RTL

vdel -all -lib lib_rtl
vlib lib_rtl
vmap lib_rtl lib_rtl

vlog -sv rtl/msk/*.sv -work lib_rtl
vlog -sv tb/msk/top_msk_tb.sv -work lib_rtl

vsim -c -voptargs=+acc lib_rtl.top_msk_tb -do "run; quit -f"
