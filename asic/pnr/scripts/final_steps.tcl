#////////////////////////////////////////////////////
# FINAL VERIFICATION AND EXPORT (COMPLETE VERSION)
#////////////////////////////////////////////////////

set output_root "../output_data/${module_name}"
if {$module_name eq "zigbee_top"} {
    set output_root "../output_data/${sdc_dir}"
}
set reports_dir "$output_root/reports"
set fab_dir "$output_root/fab"
set gds_map_file "../input_data/gds2.map"

file mkdir $output_root
file mkdir $reports_dir
file mkdir $fab_dir

verifyConnectivity -type special -noAntenna
verifyGeometry
verify_drc

puts "=== Extract RC parasitics ==="
extractRC

puts "=== Generate Reports ==="
report_timing > "$reports_dir/timing.rpt"
report_area > "$reports_dir/area.rpt"
report_power > "$reports_dir/power.rpt"
report_constraint -all_violators > "$reports_dir/violations.rpt"
report_qor -file "$reports_dir/qor.rpt"

puts "=== Save Design Files ==="
saveDesign dbs/final_enc

# Simulation netlist (without power pins)
saveNetlist "$output_root/${module_name}_postroute.v"

# VIRTUOSO / LVS: Physical netlist with VDD/VSS connected throughout the design
puts "=== Save Physical Netlist for Virtuoso/LVS ==="
saveNetlist "$output_root/${module_name}_lvs.v" -phys

write_sdf "$output_root/${module_name}_postroute.sdf"

puts "=== Export GDSII ==="

streamOut "$fab_dir/${module_name}.gds" -mapFile "${gds_map_file}" -labelText -netlistInstancePort

puts "=== Save DEF ==="
defOut -floorplan -netlist -routing "$fab_dir/${module_name}.def"

puts "=== All verification and export steps completed ==="