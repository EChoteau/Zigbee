source config/config_ASIC

cd asic/synth/demod_system

dc_shell -f demod_system.tcl | tee log_synthese.log
#design_vision