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

vsim -voptargs=+acc lib_RTL.derive_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/derive_tb/i_clk \
sim:/derive_tb/i_rst_n \
sim:/derive_tb/i_phase_in \
sim:/derive_tb/o_phase_deriv

run -all

wave zoom full

#quit -f
