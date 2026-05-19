# =====================================================
# TB Cordic Complete - POST-SYNTHESIS
# =====================================================

if ![file isdirectory lib_synth] {
    vlib lib_synth
    vmap lib_synth lib_synth
}

vlog -incr -sv -work lib_synth +acc asic/pnr/output_data/cordic_system/cordic_system_postroute.v
vlog -incr -sv -work lib_synth +acc tb/cordic/complete_tb.sv

vsim -voptargs=+acc lib_synth.complete_tb \
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
