# =====================================================
# TB Derive 
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_RTL] {
    vlib lib_RTL
    vmap lib_RTL lib_RTL
}

vlog -incr -sv -work lib_RTL +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc tb/cordic/*.sv

vsim -voptargs=+acc lib_RTL.tb_derive -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/tb_derive/clk \
sim:/tb_derive/rst_n \
sim:/tb_derive/phase_in \
sim:/tb_derive/phase_deriv

run -all

wave zoom full

#quit -f
