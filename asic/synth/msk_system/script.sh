source config/config_ASIC

cd asic/synth/top_msk

dc_shell -f top_msk.tcl | tee log_synthese.log
#design_vision