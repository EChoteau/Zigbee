# =====================================================
# TB Derive 
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_rtl] {
    vlib lib_rtl
    vmap lib_rtl lib_rtl
}

vlog -incr -sv -work lib_rtl +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_rtl +acc tb/cordic/*.sv

vsim -voptargs=+acc lib_rtl.derive_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/derive_tb/i_clk \
sim:/derive_tb/i_rst_n \
sim:/derive_tb/i_phase \
sim:/derive_tb/o_phase_deriv

run -all

wave zoom full

#quit -f
