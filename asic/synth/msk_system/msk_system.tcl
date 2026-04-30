remove_design -all

# --- 2. Lecture ---
analyze -library WORK -format sverilog { \
    ../../../rtl/msk/encodeur_diff.sv \
    ../../../rtl/msk/demux_msk.sv \
    ../../../rtl/msk/shaping_msk.sv \
    ../../../rtl/msk/msk_system.sv \
}

elaborate msk_system -library WORK
current_design msk_system
link

# --- 3. Contraintes ---
create_clock -name i_clk -period 100 {i_clk}
set_clock_uncertainty 5 i_clk
set_max_area 0

# --- 4. Synthèse ---
current_design msk_system
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
write -format verilog -hierarchy -output netlist/msk_system_synth.v

# Write the SDF timing file
write_sdf netlist/msk_system_synth.sdf

exit