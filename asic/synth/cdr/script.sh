source config/config_ASIC

cd asic/synth/CDR

dc_shell -f dc_script.tcl | tee log_synthese.log
#design_vision