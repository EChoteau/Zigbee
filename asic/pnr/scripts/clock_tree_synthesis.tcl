# ==============================================================================
# CLOCK TREE SYNTHESIS (CTS)
# AMS C35B4C3 - Innovus / ccopt
# ==============================================================================


# Mode ccopt avec inverseurs automatiques
setCTSMode -engine ccopt
set_ccopt_property use_inverters auto
setCCOptMode -cts_opt_type full
setOptMode -usefulSkewCCOpt standard

# Règle NDR pour les nets d'horloge : double largeur et double spacing MET1-MET4
add_ndr -name cts_ndr \
    -width_multiplier   {MET1:MET4 2} \
    -spacing_multiplier {MET1:MET4 2}

# Trunk sur MET3, leaves sur MET2
create_route_type -name trunk_route -non_default_rule cts_ndr -bottom_preferred_layer MET3
create_route_type -name leaf_route  -non_default_rule cts_ndr -bottom_preferred_layer MET2
set_ccopt_property route_type -net_type trunk trunk_route
set_ccopt_property route_type -net_type leaf  leaf_route

# Génération et chargement du spec ccopt
create_ccopt_clock_tree_spec -file ccopt.spec
source ccopt.spec

# Synthèse et optimisation concurrente CTS + timing
ccopt_design

# Optimisation post-CTS et rapports timing
optDesign -postCTS
timeDesign -postCTS
timeDesign -postCTS -hold