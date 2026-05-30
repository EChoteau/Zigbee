# ==============================================================================
# PLACEMENT DES CELLULES STANDARD
# AMS C35B4C3 - Innovus
# ==============================================================================


# Noeud technologique (>= 130nm → 250 pour C35)
setDesignMode -process 250

# End caps aux bords des rows
setEndCapMode -prefix ENDCAP -leftEdge ENDCAPL -rightEdge ENDCAPR
addEndCap -prefix ENDCAP

# Optimisation des vias pendant le placement
setViaGenMode -optimize_cross_via true -optimize_via_on_routing_track true

# Layers de routing autorisés pour le global routing early
setRouteMode -earlyGlobalMinRouteLayer 1
setRouteMode -earlyGlobalMaxRouteLayer 4

# Évite les DRC de spacing aux bords du floorplan
setPlaceMode -padForPinNearBorder true

# Useful skew activé pour la flexibilité timing
setOptMode -usefulSkew true


# ------------------------------------------------------------------------------
# GROUPES DE CHEMINS TIMING
# ------------------------------------------------------------------------------
set_interactive_constraint_modes [all_constraint_modes -active]
reset_path_group   -all
reset_path_exception

set input_ports  [all_inputs  -no_clocks]
set output_ports [all_outputs]
set regs         [all_registers]
set gated_cells  [filter_collection $regs "is_integrated_clock_gating_cell == true"]
set regs         [remove_from_collection $regs $gated_cells]

group_path -name reg2reg  -from $regs        -to $regs
group_path -name in2reg   -from $input_ports -to $regs
group_path -name reg2out  -from $regs        -to $output_ports
group_path -name in2out   -from $input_ports -to $output_ports
group_path -name reg2gate -from $regs        -to $gated_cells
group_path -name in2gate  -from $input_ports -to $gated_cells

set_interactive_constraint_modes {}

setPathGroupOptions reg2reg  -effortLevel high
setPathGroupOptions in2reg   -effortLevel high
setPathGroupOptions reg2out  -effortLevel high
setPathGroupOptions in2out   -effortLevel high
setPathGroupOptions reg2gate -effortLevel high
setPathGroupOptions in2gate  -effortLevel high


# ------------------------------------------------------------------------------
# PLACEMENT ET OPTIMISATION PRE-CTS
# ------------------------------------------------------------------------------
place_opt_design

setOptMode -fixDRC true -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS