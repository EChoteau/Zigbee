source config/config_ASIC

cd asic/synth/interface

dc_shell -f synth.tcl | tee log_synthese.log
#design_vision