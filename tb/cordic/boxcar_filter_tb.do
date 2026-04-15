# =====================================================
# Boxcar Filter Waves
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_RTL] {
    vlib lib_RTL
    vmap lib_RTL lib_RTL
}

vlog -incr -sv -work lib_RTL +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc tb/cordic/*.sv

vsim -voptargs=+acc lib_RTL.boxcar_filter_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/boxcar_filter_tb/i_clk \
sim:/boxcar_filter_tb/i_rst_n \
sim:/boxcar_filter_tb/i_data_in \
sim:/boxcar_filter_tb/o_data_out

run -all

wave zoom full

#quit -f
