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

vsim -voptargs=+acc lib_RTL.tb_complete -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/tb_complete/clk \
sim:/tb_complete/rst_n \
sim:/tb_complete/I_in \
sim:/tb_complete/Q_in \
sim:/tb_complete/phase_out

run -all

wave zoom full

#quit -f
