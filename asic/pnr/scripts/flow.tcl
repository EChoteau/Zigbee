# ==============================================================================
#                   PHYSICAL DESIGN FLOW EXECUTION (INNOVUS)
# ==============================================================================

setMultiCpuUsage -localCpu 8
source ../scripts/vars.tcl

# ------------------------------------------------------------------------------
# 1. INITIALIZATION
# ------------------------------------------------------------------------------
puts "\n======================================================\n--- 1. INITIALIZATION ---\n======================================================\n"
# Loading the netlist, libraries (LEF) and power definitions
source ../scripts/init.tcl
init_design
# set init_ignore_pgpin_polarity_check "gnd!"
read_power_intent -1801 ../scripts/zigbee_top_io.upf
commit_power_intent

# ------------------------------------------------------------------------------
# 2. FLOORPLAN & POWER GRID
# ------------------------------------------------------------------------------
puts "\n======================================================\n--- 2. FLOORPLAN & POWER GRID ---\n======================================================\n"
# Pads placement, power grid creation and power pad connections
source ../scripts/design_config.tcl
setAnalysisMode -analysisType onChipVariation
saveDesign dbs/floorplan_enc

# ------------------------------------------------------------------------------
# 3. PLACEMENT
# ------------------------------------------------------------------------------
puts "\n======================================================\n--- 3. PLACEMENT ---\n======================================================\n"
# Standard cells placement
source ../scripts/placement.tcl
saveDesign dbs/prects_enc

# ------------------------------------------------------------------------------
# 4. CLOCK TREE SYNTHESIS (CTS)
puts "\n======================================================\n--- 4. CLOCK TREE SYNTHESIS (CTS) ---\n======================================================\n"
# ------------------------------------------------------------------------------
# Clock tree creation and balancing
source ../scripts/clock_tree_synthesis.tcl
saveDesign dbs/postcts_enc

# ------------------------------------------------------------------------------
# 5. ROUTING AND OPTIMIZATION
# ------------------------------------------------------------------------------
puts "\n======================================================\n--- 5. ROUTING AND OPTIMIZATION ---\n======================================================\n"
# Prerequisites validation (complete power grid, no congestion)
verifyConnectivity -type special

# Main routing
routeDesign

# Extraction RC
setExtractRCMode -engine postRoute
extractRC

# Post-Route Optimizations (Hold, Setup, DRC)
optDesign -postRoute
optDesign -postRoute -hold

saveDesign dbs/postroute_enc

# ------------------------------------------------------------------------------
# 6. INTERNAL SIGNOFF AND VERIFICATIONS
# ------------------------------------------------------------------------------
puts "\n======================================================\n--- 6. INTERNAL SIGNOFF AND VERIFICATIONS ---\n======================================================\n"
# Unconnected pins check
verifyConnectivity -type all

# Geometric Design Rule Checking (DRC)
verifyGeometry

# ------------------------------------------------------------------------------
# 7. FILLER INSERTION
# ------------------------------------------------------------------------------
puts "\n======================================================\n--- 7. FILLER INSERTION ---\n======================================================\n"
# Filling empty spaces in core and pads
source ../scripts/add_fillers.tcl
saveDesign dbs/addFiller_enc

# ------------------------------------------------------------------------------
# 8. FINAL STEPS
puts "\n======================================================\n--- 8. FINAL STEPS ---\n======================================================\n"
# ------------------------------------------------------------------------------
# Final checks, report generation and fabrication files output
source ../scripts/final_steps.tcl

# Open graphical interface for visual inspection
win
suspend
