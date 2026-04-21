source config/config_ASIC

cd asic/synth/top

dc_shell -f test_system.tcl | tee log_synthese.log
#design_vision