#!/bin/bash
set -euo pipefail

# work library
vdel -all -lib lib_rtl_interface 2>/dev/null || true
vlib lib_rtl_interface
vmap lib_rtl lib_rtl_interface

# compile RTL and TB (root-relative paths)
vlog -sv rtl/interface/*.sv -work lib_rtl_interface
vlog -sv rtl/top/wrappers/interface_wrapper.sv -work lib_rtl_interface
vlog -sv tb/wrappers/interface/tb_interface_wrapper.sv -work lib_rtl_interface

# run
n=lib_rtl_interface.tb_interface_wrapper
vsim -c ${n} -do "tb/wrappers/interface/interface.do"
