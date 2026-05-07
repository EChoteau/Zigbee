source config/config_ASIC

cd asic/synth/cordic_system_top

dc_shell -f cordic_system_top.tcl | tee log_synthese.log
#design_vision