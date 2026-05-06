# --- 1. Setup Environment ---
#Setup
source ../.synopsys_dc.setup

#Stop on fail
set sh_continue_on_error false

#Clean previous design
remove_design -all

# --- 2. Read ---
analyze -library WORK -format sverilog { \
	../../../../rtl/top/zigbee_top.sv \

	../../../../rtl/top/wrappers/msk_wrapper.sv \
	../../../../rtl/top/wrappers/demod_wrapper.sv \
	../../../../rtl/top/wrappers/cdr_wrapper.sv \
	../../../../rtl/top/wrappers/cordic_wrapper.sv \
	../../../../rtl/top/wrappers/interface_wrapper.sv \

	../../../../rtl/msk/demux_msk.sv \
	../../../../rtl/msk/encodeur_diff.sv \
	../../../../rtl/msk/shaping_msk.sv \
	../../../../rtl/msk/top_msk.sv \

	../../../../rtl/demod/FIR/fir_core.vs \
	../../../../rtl/demod/FIR/fir_top.vs \
	../../../../rtl/demod/WAVE/demod.sv \
	../../../../rtl/demod/WAVE/wave_generator.sv \
	../../../../rtl/demod/demod_system_top.sv \

	../../../../rtl/CDR/cdr.sv \
	../../../../rtl/CDR/hogge_phase_detector.sv \
	../../../../rtl/CDR/loop_filter.sv \
	../../../../rtl/CDR/nco.sv \
	../../../../rtl/CDR/decision.sv \
	../../../../rtl/CDR/bascule.sv \

	../../../../rtl/cordic/cordic_system.sv \
	../../../../rtl/cordic/cordic_top.sv \
	../../../../rtl/cordic/cordic_init.sv \
	../../../../rtl/cordic/cordic_step.sv \
	../../../../rtl/cordic/boxcar_filter.sv \
	../../../../rtl/cordic/cordic_top_pipeline.sv \
	../../../../rtl/cordic/cordic_top_hybride.sv \
	../../../../rtl/cordic/derivate.sv \

	../../../../rtl/interface/interface_top.sv \
	../../../../rtl/interface/serializer.sv \
	../../../../rtl/interface/fifo.sv \
	../../../../rtl/interface/deserializer.sv \
	../../../../rtl/interface/baud_rate_gen.sv \
	../../../../rtl/interface/apb_slave_regs.sv \
	
}

current_design top
elaborate top -library WORK
link

# --- 3. Constrains ---
set_operating_conditions -library c35_CORELIB_TYP TYPICAL
create_clock -name i_clk -period 100 {i_clk}
#set_clock_uncertainty 15 i_clk
set_max_area 0

# --- 4. Synthesis ---
current_design top
set_ungroup top
set_boundary_optimization top
set_scan_configuration -style none
set_flatten true -design top -effort high -minimize multiple_output -phase true
set_structure true -design top -boolean true -timing false

# set_max_fanout 3 top
# set_max_transition 1.5 top
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
write -format verilog -hierarchy -output ../netlist/top_synth.v
write_sdf ../netlist/top_synth.sdf

exit
