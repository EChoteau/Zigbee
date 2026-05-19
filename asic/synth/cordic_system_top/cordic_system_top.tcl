# --- 1. Setup ---
#set_app_var target_library "work.db"
#set_app_var link_library "* $target_library"

remove_design -all
#sh rm -rf WORK

# --- 2. Lecture ---
analyze -library WORK -format sverilog { \
    ../../../rtl/cordic/boxcar_filter.sv \
    ../../../rtl/cordic/cordic_init.sv \
    ../../../rtl/cordic/cordic_step.sv \
    ../../../rtl/cordic/cordic_system_top.sv \
    ../../../rtl/cordic/cordic_comb.sv \
    ../../../rtl/cordic/cordic_pipeline.sv \
    ../../../rtl/cordic/cordic_hybride.sv \
    ../../../rtl/cordic/derivate.sv \
}

elaborate cordic_system_top -library WORK
current_design cordic_system_top
link

# --- 3. Contraintes ---
create_clock -name i_clk -period 100 {i_clk}
set_clock_uncertainty 5 i_clk
set_max_area 0

# --- 4. Synthèse ---
current_design cordic_system_top
ungroup -all -flatten
compile_ultra -gate_clock
# (Optionnel)
# compile_ultra -incremental


# --- 5. Rapports ---
# On crée un dossier 'reports' pour ne pas polluer l'espace de travail
file mkdir reports
report_timing > reports/timing.rpt
report_area   > reports/area.rpt
report_power  > reports/power.rpt
report_constraint -all_violators > reports/violations.rpt


# --- 6. Export Files for Simulation ---
# Write the Gate-Level Netlist
write -format verilog -hierarchy -output netlist/cordic_system_top_synth.v

# Write the SDF timing file
write_sdf netlist/cordic_system_top_synth.sdf

exit