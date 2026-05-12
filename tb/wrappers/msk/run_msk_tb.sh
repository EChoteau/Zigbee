#!/bin/bash
set -euo pipefail

# work library
vdel -all -lib lib_rtl_msk 2>/dev/null || true
vlib lib_rtl_msk
vmap lib_rtl lib_rtl_msk

# compile RTL and TB (root-relative paths)
vlog -sv rtl/msk/*.sv -work lib_rtl_msk
vlog -sv rtl/top/wrappers/msk_wrapper.sv -work lib_rtl_msk
vlog -sv tb/wrappers/msk/tb_msk_wrapper.sv -work lib_rtl_msk

# run
n=lib_rtl_msk.tb_msk_wrapper
vsim -c ${n} -do "tb/wrappers/msk/msk_wrapper.do"
