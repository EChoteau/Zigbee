# =====================================================
# TB Demod Complete - POST-SYNTHESIS
# =====================================================

if ![file isdirectory lib_synth] {
    vlib lib_synth
    vmap lib_synth lib_synth
}

vlog -incr -sv -work lib_synth +acc ../../asic/synth/demod_system/netlist/demod_system_synth.v
vlog -incr -sv -work lib_synth +acc tb_all.sv

vsim -voptargs=+acc lib_synth.tb_demod_system \
     -sdfmax /tb_demod_system/dut=../../asic/synth/demod_system/netlist/demod_system_synth.sdf \
     -sdfnoerror -sdfnowarn \
     -L c35_CORELIB

#add wave -position insertpoint  \
#sim:/complete_tb/i_clk \
#sim:/complete_tb/i_rst_n \
#sim:/complete_tb/i_i \
#sim:/complete_tb/i_q \
# sim:/complete_tb/o_phase \

run -all
wave zoom full
