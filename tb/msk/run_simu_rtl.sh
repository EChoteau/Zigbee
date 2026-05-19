#!/bin/bash
# =====================================================
# Testbench: MSK RTL
# Run from project root: ./tb/msk/run_simu_rtl.sh
# =====================================================

source config/config_RTL

vdel -all -lib work
vlib work
vmap work work

vlog -sv rtl/msk/*.sv -work work
vlog -sv tb/msk/top_msk_tb.sv -work work

vsim -c -voptargs=+acc work.top_msk_tb
