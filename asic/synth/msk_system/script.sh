source config/config_ASIC

cd asic/synth/msk_system

dc_shell -f msk_system.tcl | tee log_synthese.log
#design_vision