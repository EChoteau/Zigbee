#////////////////////////////////////////////////////
# DEROULEMENT DU FLOW DE CONCEPTION
#////////////////////////////////////////////////////

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

# Open GUI for inspection
win
suspend

# Ajout des fillers in core and pads
source ../scripts/add_fillers.tcl
saveDesign dbs/addFiller_enc

routeDesign