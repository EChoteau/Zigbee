# --- 1. Setup ---
#set_app_var target_library "work.db"
#set_app_var link_library "* $target_library"

remove_design -all
#sh rm -rf WORK

# --- 2. Lecture ---
analyze -library WORK -format sverilog { \
    ../../rtl/cordic/Boxcar_filter.sv \
    ../../rtl/cordic/Cordic_init.sv \
    ../../rtl/cordic/Cordic_step.sv \
    ../../rtl/cordic/Cordic_system_complete.sv \
    ../../rtl/cordic/Cordic_top.sv \
    ../../rtl/cordic/Cordic_top_pipeline.sv \
    ../../rtl/cordic/Derivate.sv \
}

elaborate cordic_system_complete -library WORK
current_design cordic_system_complete
link

# --- 3. Contraintes ---
create_clock -name clk -period 20 clk
set_clock_uncertainty 5 clk
set_max_area 0

# --- 4. Synthèse ---
current_design cordic_system_complete
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
write -format verilog -hierarchy -output netlist/cordic_system_complete.v

# Write the SDF timing file
write_sdf netlist/cordic_system_complete.sdf