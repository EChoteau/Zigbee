# --- 1. Setup ---
remove_design -all

# --- 2. Lecture ---
analyze -library WORK -format sverilog { \
	../../../rtl/interface/serializer.sv \
	../../../rtl/interface/interface_top.sv \
	../../../rtl/interface/fifo.sv \
	../../../rtl/interface/deserializer.sv \
	../../../rtl/interface/baud_rate_gen.sv \
	../../../rtl/interface/apb_slave_regs.sv \
}

elaborate interface_top -library WORK -parameters "FIFO_DEPTH=8"
current_design interface_top_FIFO_DEPTH8
link

# --- 3. Contraintes ---
set_operating_conditions -library c35_CORELIB_TYP TYPICAL
create_clock -name i_clk -period 100 {i_clk}
# set_clock_uncertainty 5 i_clk
# set_max_area 0

# --- 4. Synthese ---
current_design interface_top_FIFO_DEPTH8
set_ungroup interface_top_FIFO_DEPTH8
set_boundary_optimization interface_top_FIFO_DEPTH8
set_scan_configuration -style none
set_flatten true -design interface_top_FIFO_DEPTH8 -effort high -minimize multiple_output -phase true
set_structure true -design interface_top_FIFO_DEPTH8 -boolean true -timing false

# set_max_fanout 3 interface_top_FIFO_DEPTH8
# set_max_transition 1.5 interface_top_FIFO_DEPTH8
set_dynamic_optimization true
set_leakage_optimization true
# set_max_dynamic_power 0
# set_max_leakage_power 0
compile_ultra -gate_clock

# --- 5. Rapports ---
file mkdir reports
report_timing > reports/timing.rpt
report_area > reports/area.rpt
report_power > reports/power.rpt
report_constraint -all_violators > reports/violations.rpt
report_clock_gating > reports/report_cg_summaryfifo8.txt

# --- 6. Export Files for Simulation ---
file mkdir netlist
write -format verilog -hierarchy -output netlist/interface_synth.v
write_sdf netlist/interface_synth.sdf

exit
