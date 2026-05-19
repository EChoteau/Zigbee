# =====================================================
# TB Cordic Complete - POST-SYNTHESIS
# =====================================================

if ![file isdirectory lib_route] {
    vlib lib_route
    vmap lib_route lib_route
}

vlog -incr -sv -work lib_route +acc asic/pnr/output_data/cordic_system/cordic_system_postroute.v
vlog -incr -sv -work lib_route +acc tb/cordic/complete_tb.sv

vsim -voptargs=+acc lib_route.complete_tb \
     -sdfmax /complete_tb/dut=asic/pnr/output_data/cordic_system/cordic_system_postroute.sdf \
     -sdfnoerror -sdfnowarn \
     -L c35_CORELIB

add wave -position insertpoint  \
sim:/complete_tb/i_clk \
sim:/complete_tb/i_rst_n \
sim:/complete_tb/i_i \
sim:/complete_tb/i_q \
sim:/complete_tb/o_phase \

run -all
wave zoom full
