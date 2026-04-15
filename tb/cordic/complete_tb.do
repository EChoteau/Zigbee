# =====================================================
# TB Cordic Top
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_RTL] {
    vlib lib_RTL
    vmap lib_RTL lib_RTL
}

vlog -incr -sv -work lib_RTL +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc tb/cordic/*.sv

vsim -voptargs=+acc lib_RTL.complete_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/complete_tb/i_clk \
sim:/complete_tb/i_rst_n \
sim:/complete_tb/i_i \
sim:/complete_tb/i_q \
sim:/complete_tb/o_phase

run -all

wave zoom full

#quit -f
