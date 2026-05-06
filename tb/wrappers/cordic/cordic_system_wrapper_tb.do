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
vlog -incr -sv -work lib_RTL +acc tb/wrappers/cordic/*.sv


vsim -voptargs=+acc lib_RTL.cordic_system_wrapper_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/cordic_system_wrapper_tb/o_phase

run -all

wave zoom full

#quit -f
