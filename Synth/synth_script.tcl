# my synthesis script
analyze -format sverilog {../rtl/WAVE/demod.sv ../rtl/WAVE/wave_generator.sv ../rtl/FIR/coeff_rom.v ../rtl/FIR/delay_line.v ../rtl/FIR/fir_core.v ../rtl/FIR/fir_top.v ../rtl/top_level_all.sv}
elaborate receiver_system

# --- Contraintes ---
create_clock -name "CLK" -period 20 -waveform { 0 10  }  { CLK  }
set_clock_uncertainty 5 clk
set_max_area 0

# --- Synthèse ---
current_design receiver_system
ungroup -all -flatten
compile_ultra -gate_clock
# (Optionnel)
# compile_ultra -incremental


# --- Rapports ---
# On crée un dossier 'reports' pour ne pas polluer l'espace de travail
file mkdir reports
report_timing > reports/timing.rpt
report_area   > reports/area.rpt
report_power  > reports/power.rpt
report_constraint -all_violators > reports/violations.rpt


# --- 6Export Files for Simulation ---
# Write the Gate-Level Netlist
write -format verilog -hierarchy -output netlist/receiver_system.v

# Write the SDF timing file
write_sdf netlist/receiver_system.sdf


