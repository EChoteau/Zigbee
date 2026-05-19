# =====================================================
# TB Top
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_rtl] {
    vlib lib_rtl
    vmap lib_rtl lib_rtl
}

vlog -incr -sv -work lib_rtl +acc rtl/top/zigbee_top.sv
vlog -incr -sv -work lib_rtl +acc rtl/top/wrappers/*.sv
vlog -incr -sv -work lib_rtl +acc rtl/interface/*.sv
vlog -incr -sv -work lib_rtl +acc rtl/cdr/*.sv
vlog -incr -sv -work lib_rtl +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_rtl +acc rtl/demod/*.sv
vlog -incr -sv -work lib_rtl +acc rtl/demod/FIR/*.v
vlog -incr -sv -work lib_rtl +acc rtl/demod/WAVE/*.sv
vlog -incr -sv -work lib_rtl +acc rtl/msk/*.sv

vlog -incr -sv -work lib_rtl +acc tb/top/*.sv

vsim -voptargs=+acc lib_rtl.top_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/top_tb/i_clk \
sim:/top_tb/i_rst_n \
sim:/top_tb/i_top_cfg \
sim:/top_tb/i_wrapper_cfg \
sim:/top_tb/i_bus_in \
sim:/top_tb/o_bus_out

run -all

wave zoom full