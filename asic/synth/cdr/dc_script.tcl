remove_design -all
set rtl_dir ..
analyze -format sverilog -define {hogge_pd} {../../../rtl/CDR//cdr.sv ../../../rtl/CDR//hogge_phase_detector.sv ../../../rtl/CDR//loop_filter.sv ../../../rtl/CDR//nco.sv ../../../rtl/CDR/decision.sv ../../../rtl/CDR/bascule.sv}



elaborate CDR -library WORK
current_design CDR
link 
create_clock -name "CLK" -period 100 -waveform {0 10} {i_clk}
set_clock_uncertainty 5 i_clk
set_max_area 0
ungroup -all -flatten
check_design
compile_ultra -gate_clock


file mkdir reports
report_timing > reports/timing.rpt
report_area   > reports/area.rpt
report_power  > reports/power.rpt
report_constraint -all_violators > reports/violations.rpt
file mkdir netlist
write -format verilog -hierarchy -output netlist/CDR_synth.v

write_sdf netlist/CDR_synth.sdf
exit
