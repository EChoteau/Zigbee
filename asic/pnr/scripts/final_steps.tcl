# ==============================================================================
# VÉRIFICATIONS FINALES ET EXPORT
# AMS C35B4C3 - Innovus
# ==============================================================================

set output_root "../output_data/${sdc_dir}"
set reports_dir "$output_root/reports"
set fab_dir     "$output_root/fab"

file mkdir $output_root
file mkdir $reports_dir
file mkdir $fab_dir


# ------------------------------------------------------------------------------
# VÉRIFICATIONS INTERNES INNOVUS
# ------------------------------------------------------------------------------
verifyConnectivity -type all -noAntenna
verifyGeometry


# ------------------------------------------------------------------------------
# RAPPORTS TIMING / SURFACE / CONSO
# ------------------------------------------------------------------------------
report_timing            > "$reports_dir/timing.rpt"
report_area              > "$reports_dir/area.rpt"
report_power             > "$reports_dir/power.rpt"
report_constraint -all_violators > "$reports_dir/violations.rpt"
report_qor -file           "$reports_dir/qor.rpt"


# ------------------------------------------------------------------------------
# SAUVEGARDE
# ------------------------------------------------------------------------------
saveDesign dbs/final_enc

# Netlist post-route (simulation)
saveNetlist "$output_root/${module_name}_postroute.v"

# Netlist physique avec VDD/VSS (LVS / Virtuoso)
saveNetlist "$output_root/${module_name}_lvs.v" -phys

# SDF pour simulation temporelle
write_sdf "$output_root/${module_name}_postroute.sdf"


# ------------------------------------------------------------------------------
# EXPORT GDSII
# Notes :
#   -attachNetName 13  → écrit les labels de nets sur tous les layers
#                        (nécessaire pour que Calibre résolve VDD/VSS)
#   -attachInstanceName 13 → idem pour les instances
#   -mapFile gds2.map  → mapping layers Innovus → numéros GDS AMS C35B4
# ------------------------------------------------------------------------------
set top_cell "${module_name}"
if {$module_name eq "zigbee_top"} {
    set top_cell "${module_name}_io"
}

streamOut zigbee_top_io.gds \
    -mapFile         gds2.map \
    -libName         DesignLib \
    -structureName   $top_cell \
    -attachInstanceName 13 \
    -attachNetName      13 \
    -stripes 1 \
    -units   1000 \
    -mode    ALL


# ------------------------------------------------------------------------------
# EXPORT DEF
# ------------------------------------------------------------------------------
defOut -floorplan -netlist -routing "$fab_dir/${module_name}.def"

puts "\n=== Export terminé : $fab_dir ==="