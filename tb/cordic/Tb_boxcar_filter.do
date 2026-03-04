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

vsim -voptargs=+acc lib_RTL.tb_boxcar_filter -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/tb_boxcar_filter/clk \
sim:/tb_boxcar_filter/rst_n \
sim:/tb_boxcar_filter/d_in \
sim:/tb_boxcar_filter/d_out

run -all

wave zoom full

#quit -f
