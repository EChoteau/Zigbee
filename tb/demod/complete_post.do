# =====================================================
# TB Demod Complete - POST-SYNTHESIS
# =====================================================

if ![file isdirectory lib_SYNTH] {
    vlib lib_SYNTH
    vmap lib_SYNTH lib_SYNTH
}

vlog -incr -sv -work lib_SYNTH +acc ../../asic/synth/demod/netlist/demod_synth.v
vlog -incr -sv -work lib_SYNTH +acc tb_all.sv

vsim -voptargs=+acc lib_SYNTH.tb_receiver_system \
     -sdfmax /tb_receiver_system/dut=../../asic/synth/demod/netlist/demod_synth.sdf \
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
