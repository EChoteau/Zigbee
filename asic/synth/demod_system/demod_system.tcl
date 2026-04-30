# --- 1. Setup ---
#set_app_var target_library "work.db"
#set_app_var link_library "* $target_library"

remove_design -all
#sh rm -rf WORK

# --- 2. Lecture ---
analyze -library WORK -format sverilog { \
    ../../../rtl/demod/FIR/fir_core.v \
    ../../../rtl/demod/FIR/fir_top.v \
    ../../../rtl/demod/WAVE/demod.sv \
    ../../../rtl/demod/WAVE/wave_generator.sv \
    ../../../rtl/top/wrappers/demod_wrapper.sv \
    ../../../rtl/demod/top_level_all.sv \

}

elaborate demod_system -library WORK
current_design demod_system
link

# --- 3. Contraintes ---
create_clock -name "i_clk" -period 100 i_clk
set_clock_uncertainty 5 i_clk
set_max_area 0

# --- 4. Synthèse ---
current_design demod_system
ungroup -all -flatten
compile_ultra -gate_clock
#compile_ultra -gate_clock
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
write -format verilog -hierarchy -output netlist/demod_system_synth.v

# Write the SDF timing file
write_sdf netlist/demod_system_synth.sdf

exit
