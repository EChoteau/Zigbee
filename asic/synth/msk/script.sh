source config/config_ASIC

cd asic/synth/msk

dc_shell -f msk_system_complete.tcl | tee log_synthese.log
#design_vision