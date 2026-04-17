#////////////////////////////////////////////////////
# DEROULEMENT DU FLOW DE CONCEPTION
#////////////////////////////////////////////////////

setMultiCpuUsage -localCpu 16

# Init le design (netlist, lef, alims, etc..)
source ../scripts/init.tcl
init_design

# Placement des pads + creation de la grille + connexion des pads d'alimentation a la grille
source ../scripts/design_config.tcl
setAnalysisMode -analysisType onChipVariation

saveDesign dbs/floorplan_enc

# Placement des standard cells
source ../scripts/placement.tcl

saveDesign dbs/prects_enc

# Création du clock_tree
source ../scripts/clock_tree_synthesis.tcl
saveDesign dbs/postcts_enc

# Ajout des fillers in core and pads
source ../scripts/add_fillers.tcl
saveDesign dbs/addFiller_enc

routeDesign

# Vérifications physiques finales après routage
verifyGeometry
verifyConnectivity

# Vérification DRC finale après routage
verify_drc

# Exports post-route pour simulation back-annotée
file mkdir ../output_data
saveNetlist ../output_data/${init_top_cell}_postroute.v
write_sdf ../output_data/${init_top_cell}_postroute.sdf

# Open GUI for inspection
win
suspend
