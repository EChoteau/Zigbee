# --- 1. Setup Environment ---
#Setup
source ../.synopsys_dc.setup

#Stop on fail
set sh_script_stop_severity E
set sh_continue_on_error false

#Clean previous design
remove_design -all

# --- 2. Read ---
set source_files [glob -nocomplain \
	../../../../rtl/top/zigbee_top.sv \
	../../../../rtl/top/wrappers/*.sv \
	../../../../rtl/msk/*.sv \
	../../../../rtl/demod/*.sv \
	../../../../rtl/demod/FIR/*.sv \
	../../../../rtl/demod/WAVE/*.sv \
	../../../../rtl/CDR/*.sv \
	../../../../rtl/cordic/*.sv \
	../../../../rtl/interface/*.sv \
]

analyze -library WORK -format sverilog $source_files

current_design zigbee_top
elaborate zigbee_top -library WORK
link

# --- 3. Constrains ---
set_operating_conditions -library c35_CORELIB_TYP TYPICAL
create_clock -name i_clk -period 100 {i_clk}
#set_clock_uncertainty 15 i_clk
set_max_area 0

# --- 4. Synthesis ---
current_design zigbee_top
set_ungroup zigbee_top
set_boundary_optimization zigbee_top
set_scan_configuration -style none
set_flatten true -design zigbee_top -effort high -minimize multiple_output -phase true
set_structure true -design zigbee_top -boolean true -timing false

set_max_fanout 3 zigbee_top
set_max_fanout 3 zigbee_top
# set_max_transition 1.5 zigbee_top
set_dynamic_optimization true
set_leakage_optimization true
# set_max_dynamic_power 0
# set_max_leakage_power 0
compile_ultra -gate_clock

# --- 5. Reports ---
report_timing > ../reports/timing.rpt
report_area > ../reports/area.rpt
report_power > ../reports/power.rpt
report_constraint -all_violators > ../reports/violations.rpt
report_clock_gating > ../reports/report_cg_summary.txt

# --- 6. Export Files for Simulation ---
write -format verilog -hierarchy -output ../netlist/zigbee_top_synth.v
write_sdf ../netlist/zigbee_top_synth.sdf

exit
