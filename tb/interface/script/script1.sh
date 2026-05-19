#!/bin/sh
set -e

vdel -all -lib lib_rtl
vlib lib_rtl
vmap lib_rtl lib_rtl

vlog -sv rtl/interface/*.sv -work lib_rtl
vlog -sv tb/interface/common/*.sv -work lib_rtl
vlog -sv tb/interface/*.sv -work lib_rtl

vsim -voptargs=+acc lib_rtl.interface_top_tb
