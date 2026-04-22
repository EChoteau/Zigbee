source config/config_ASIC

cd asic/synth/demod

dc_shell -f demod_dc_shell_script.tcl | tee log_synthese.log
#design_vision