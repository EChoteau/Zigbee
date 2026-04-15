# =====================================================
# TB Cordic Complete - POST-SYNTHESIS
# =====================================================

if ![file isdirectory lib_SYNTH] {
    vlib lib_SYNTH
    vmap lib_SYNTH lib_SYNTH
}

vlog -incr -sv -work lib_SYNTH +acc asic/synth/netlist/cordic_system_complete.v
vlog -incr -sv -work lib_SYNTH +acc tb/cordic/complete_tb.sv

vsim -voptargs=+acc lib_SYNTH.complete_tb \
     -sdfmax /complete_tb/dut=asic/synth/netlist/cordic_system_complete.sdf \
     -sdfnoerror -sdfnowarn \
     -L c35_CORELIB

add wave -position insertpoint  \
sim:/complete_tb/i_clk \
sim:/complete_tb/i_rst_n \
sim:/complete_tb/i_i_in \
sim:/complete_tb/i_q_in \
sim:/complete_tb/o_phase_out \

run -all
wave zoom full
