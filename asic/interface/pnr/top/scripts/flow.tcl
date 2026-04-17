#////////////////////////////////////////////////////
# DEROULEMENT DU FLOW DE CONCEPTION
#////////////////////////////////////////////////////

# Design initialization (netlist, lef, alims, ...)
source ../scripts/init.tcl
init_design

# Pad creation + grid creation + power connection
source ../scripts/design_config.tcl
setAnalysisMode -analysisType onChipVariation

# Floorplan saving
saveDesign dbs/floorplan_enc

# Placement des standard cells
source ../scripts/placement.tcl

# Design saving afer placement
saveDesign dbs/prects_enc

# Clock tree synthesis
source ../scripts/clock_tree_synthesis.tcl
saveDesign dbs/postcts_enc

# Open GUI for inspection
win
suspend