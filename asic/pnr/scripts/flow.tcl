# ==============================================================================
# FLOW PnR COMPLET - AMS C35B4C3
# Innovus
#
# Usage : innovus -execute flow.tcl -overwrite
# ==============================================================================

setMultiCpuUsage -localCpu 8
source ../scripts/vars.tcl


# ------------------------------------------------------------------------------
# 1. INIT
# ------------------------------------------------------------------------------
puts "\n=== 1. INITIALISATION ===\n"
source ../scripts/init.tcl
init_design


# ------------------------------------------------------------------------------
# 2. FLOORPLAN & POWER GRID
# ------------------------------------------------------------------------------
puts "\n=== 2. FLOORPLAN & POWER GRID ===\n"
source ../scripts/design_config.tcl
setAnalysisMode -analysisType onChipVariation
saveDesign dbs/floorplan_enc


# ------------------------------------------------------------------------------
# 3. PLACEMENT
# ------------------------------------------------------------------------------
puts "\n=== 3. PLACEMENT ===\n"
source ../scripts/placement.tcl
saveDesign dbs/prects_enc


# ------------------------------------------------------------------------------
# 4. CLOCK TREE SYNTHESIS
# ------------------------------------------------------------------------------
puts "\n=== 4. CTS ===\n"
source ../scripts/clock_tree_synthesis.tcl
saveDesign dbs/postcts_enc


# ------------------------------------------------------------------------------
# 5. ROUTING
# ------------------------------------------------------------------------------
puts "\n=== 5. ROUTING ===\n"
verifyConnectivity -type special
routeDesign
setExtractRCMode -engine postRoute
extractRC
optDesign -postRoute
optDesign -postRoute -hold
saveDesign dbs/postroute_enc


# ------------------------------------------------------------------------------
# 6. FILLERS
# ------------------------------------------------------------------------------
puts "\n=== 6. FILLERS ===\n"
source ../scripts/add_fillers.tcl
saveDesign dbs/filler_enc


# ------------------------------------------------------------------------------
# 7. EXPORT
# ------------------------------------------------------------------------------
puts "\n=== 7. EXPORT ===\n"
source ../scripts/final_steps.tcl


win
suspend