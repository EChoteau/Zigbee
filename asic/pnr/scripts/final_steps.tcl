set output_root "../output_data/${module_name}"
set reports_dir "$output_root/reports"
set fab_dir "$output_root/fab"
set gds_map_file "../input_data/gds2.map"

file mkdir $output_root
file mkdir $reports_dir
file mkdir $fab_dir

# Final physical checks
verifyGeometry
verifyConnectivity
verify_drc

# Reports
report_timing > "$reports_dir/timing.rpt"
report_area > "$reports_dir/area.rpt"
report_power > "$reports_dir/power.rpt"
report_constraint -all_violators > "$reports_dir/violations.rpt"
report_qor -file "$reports_dir/qor.rpt"

# Fabrication handoff files
streamOut "$fab_dir/${module_name}.gds" -mapFile $gds_map_file
saveNetlist "$output_root/${module_name}_postroute.v"
write_sdf "$output_root/${module_name}_postroute.sdf"