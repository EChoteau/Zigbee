# =====================================================
# TB Cordic Step
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_rtl] {
    vlib lib_rtl
    vmap lib_rtl lib_rtl
}

vlog -incr -sv -work lib_rtl +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_rtl +acc tb/cordic/*.sv

vsim -voptargs=+acc lib_rtl.cordic_step_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

run -all

quit -f
