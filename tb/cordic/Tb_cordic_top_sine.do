# =====================================================
# TB Cordic Top Sine 
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_RTL] {
    vlib lib_RTL
    vmap lib_RTL lib_RTL
}

vlog -incr -sv -work lib_RTL +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc tb/cordic/*.sv

vsim -voptargs=+acc lib_RTL.tb_cordic_top_sine -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/tb_cordic_top_sine/clk \
sim:/tb_cordic_top_sine/I_in_reg \
sim:/tb_cordic_top_sine/Q_in_reg \
sim:/tb_cordic_top_sine/Phase_out_reg \
sim:/tb_cordic_top_sine/Phase_out_raw \
sim:/tb_cordic_top_sine/angle \
sim:/tb_cordic_top_sine/i_val \
sim:/tb_cordic_top_sine/q_val

run -all

wave zoom full

#quit -f
