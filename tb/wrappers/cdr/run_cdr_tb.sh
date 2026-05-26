#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

vdel -all -lib lib_rtl_cdr 2>/dev/null || true
vlib lib_rtl_cdr
vmap lib_rtl lib_rtl_cdr

# compile necessary RTL
vlog -sv ../include/tb_pkg.sv -work lib_rtl_cdr
vlog -sv ../../../rtl/cdr/*.sv -work lib_rtl_cdr
vlog -sv ../../../rtl/top/wrappers/cdr_wrapper.sv -work lib_rtl_cdr
vlog -sv tb_cdr_wrapper.sv -work lib_rtl_cdr

# run
n=lib_rtl_cdr.tb_cdr_wrapper
vsim -c ${n} -do "cdr.do"
