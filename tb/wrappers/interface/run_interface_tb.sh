#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# work library
vdel -all -lib lib_rtl_interface 2>/dev/null || true
vlib lib_rtl_interface
vmap lib_rtl lib_rtl_interface

# compile RTL and TB
vlog -sv ../../rtl/interface/*.sv -work lib_rtl_interface
vlog -sv ../../rtl/top/wrappers/interface_wrapper.sv -work lib_rtl_interface
vlog -sv ./tb_interface_wrapper.sv -work lib_rtl_interface

# run
n=lib_rtl_interface.tb_interface_wrapper
vsim -c ${n} -do "../interface/interface.do"
