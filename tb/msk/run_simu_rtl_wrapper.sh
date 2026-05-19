#!/bin/bash
# =====================================================
# Testbench: MSK Wrapper
# Run from project root: ./tb/msk/run_simu_rtl_wrapper.sh
# =====================================================

source config/config_RTL

vdel -all -lib work
vlib work
vmap work work

vlog -sv rtl/msk/*.sv rtl/top/wrappers/msk_wrapper.sv -work work
vlog -sv tb/msk/wrapper_msk_tb.sv -work work

vsim -c -voptargs=+acc work.wrapper_msk_tb -do "run; quit -f"
