# =====================================================
# TB Cordic Top - POST-SYNTHESIS
# =====================================================

if ![file isdirectory lib_SYNTH] {
    vlib lib_SYNTH
    vmap lib_SYNTH lib_SYNTH
}

vlog -incr -sv -work lib_SYNTH +acc asic/synth/netlist/cordic_system_complete.v
vlog -incr -sv -work lib_SYNTH +acc tb/cordic/Tb_complete.sv

vsim -voptargs=+acc lib_SYNTH.tb_complete \
     -sdfmax /tb_complete/DUT=asic/synth/netlist/cordic_system_complete.sdf \
     -sdfnoerror -sdfnowarn \
     -L c35_CORELIB

add wave -position insertpoint  \
sim:/tb_complete/clk \
sim:/tb_complete/rst_n \
sim:/tb_complete/I_in \
sim:/tb_complete/Q_in \
sim:/tb_complete/phase_out \

run -all
wave zoom full