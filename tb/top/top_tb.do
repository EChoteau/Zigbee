# =====================================================
# TB Top
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_RTL] {
    vlib lib_RTL
    vmap lib_RTL lib_RTL
}

vlog -incr -sv -work lib_RTL +acc rtl/top/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/top/wrappers/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/interface/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/CDR/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/demod/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/msk/*.sv

vlog -incr -sv -work lib_RTL +acc tb/top/*.sv
vlog -incr -sv -work lib_RTL +acc tb/top/configs/*.sv

vsim -voptargs=+acc lib_RTL.top_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/top_tb/clk \
sim:/top_tb/rst_n \
sim:/top_tb/i_top_cfg \
sim:/top_tb/i_wrapper_cfg \
sim:/top_tb/o_bus_c \
sim:/top_tb/o_bus_d \
sim:/top_tb/i_bus_a \
sim:/top_tb/i_bus_b

run -all

wave zoom full

quit -f
