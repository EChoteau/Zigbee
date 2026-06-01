#////////////////////////////////////////////////////
# CREATION DE L'ARBRE D'HORLOGE
#////////////////////////////////////////////////////

# Cette commande est obsolete mais fonctionne encore sur cette version pourrie d'Innovus alors on la laisse lol ;)
# Set les modes nécessaire à la création du clock_tree


#setup_func_mode hold_func_mode
#extract_clock_generator_skew_groups true

setCTSMode -engine ccopt
set_ccopt_property use_inverters auto
setCCOptMode -cts_opt_type full
setOptMode -usefulSkewCCOpt standard

# --- 2. Clock Routing Rules (NDR) ---
# Definition de la règle : Double Width & Double Spacing pour les métaux MET1 à MET4
add_ndr -name cts_ndr -width_multiplier {MET1:MET4 2} -spacing_multiplier {MET1:MET4 2}

create_route_type -name trunk_route_type -non_default_rule cts_ndr -bottom_preferred_layer MET3
create_route_type -name leaf_route_type -non_default_rule cts_ndr -bottom_preferred_layer MET2
set_ccopt_property route_type -net_type trunk trunk_route_type
set_ccopt_property route_type -net_type leaf leaf_route_type

# --- 3. Specification and Execution ---
create_ccopt_clock_tree_spec -file ccopt.spec
source ccopt.spec

# CCOPT Concurrent Optimization (Clock Tree + Datapath Setup/Hold Optimization)
ccopt_design 

# --- 4. Post-CTS Optimization and Reports ---
# Final datapath cleanup
optDesign -postCTS

# Timing reports (Setup and Hold)
timeDesign -postCTS -hold
