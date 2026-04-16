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

# Open GUI for inspection
win

# Création du clock_tree
source ../scripts/clock_tree_synthesis.tcl
saveDesign dbs/postcts_enc

# Ajout des fillers in core and pads
source ../scripts/add_fillers.tcl
saveDesign dbs/addFiller_enc

routeDesign


# Useful skew
#setOptMode -usefulSkewPostRoute true




#setEdit -layer_horizontal {MET1}
#setEdit -layer_horizontal {MET3}
#setEdit -layer_vertical  {MET2} 
#setEdit -layer_vertical  {MET4}

#setEdit -spacing 0.45 -layer MET1
#setEdit -spacing 0.5 -layer MET2
#setEdit -spacing 0.6 -layer MET3
#setEdit -spacing 0.6 -layer MET4


#setMetalFill -gapSpacing 0.45 	-layer MET1
#setMetalFill -gapSpacing 0.5 	-layer MET2
#setMetalFill -gapSpacing 0.6	-layer MET3
#setMetalFill -gapSpacing 0.6	-layer MET4

#routeDesign -globalDetail -viaOpt -wireOpt

#optDesign -postRoute

#routeDesign

#route_opt_design

#saveDesign dbs/routeBeforePinAnalysis_enc

#pinAnalysis
#pinAlignment
#fixVia -short

#saveDesign dbs/route_enc

