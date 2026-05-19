# =====================================================
# Boxcar Filter Waves
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_rtl] {
    vlib lib_rtl
    vmap lib_rtl lib_rtl
}

vlog -incr -sv -work lib_rtl +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_rtl +acc tb/cordic/*.sv

vsim -voptargs=+acc lib_rtl.boxcar_filter_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/boxcar_filter_tb/i_clk \
sim:/boxcar_filter_tb/i_rst_n \
sim:/boxcar_filter_tb/i_data \
sim:/boxcar_filter_tb/o_data

run -all

wave zoom full

#quit -f
