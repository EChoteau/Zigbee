# ==============================================================================
# FLOORPLAN ET GRILLE D'ALIMENTATION
# AMS C35B4C3 - Innovus
#
# Layers C35B4 : MET1(H) MET2(V) MET3(H) MET4(V)
# Routing standard : MET1-MET3, MET4 réservé power
# ==============================================================================


# ------------------------------------------------------------------------------
# 1. FLOORPLAN
# ------------------------------------------------------------------------------
if {$module_name eq "zigbee_top"} {
    # Placement des pads IO depuis le fichier .io
    loadIoFile "../input_data/${sdc_dir}/${module_name}_pads.io"
    floorPlan -site standard -d {2000 2000 80 80 80 80} -noSnapToGrid -coreMarginsBy io
} else {
    floorPlan -site standard -r 1 0.7 80 80 80 80
}


# ------------------------------------------------------------------------------
# 2. GRILLE D'ALIMENTATION
# ------------------------------------------------------------------------------

# Power ring autour du core, entre les IO et le core
# MET3 (horizontal) top/bottom, MET4 (vertical) left/right
setAddRingMode \
    -stacked_via_top_layer    MET4 \
    -stacked_via_bottom_layer MET1 \
    -via_using_exact_crossover_size 1 \
    -orthogonal_only true

addRing \
    -nets  {vdd! gnd!} \
    -type  core_rings \
    -follow io \
    -layer {top MET3 bottom MET3 left MET4 right MET4} \
    -width   {top 20  bottom 20  left 20  right 20} \
    -spacing {top 5   bottom 5   left 5   right 5} \
    -offset  {top 5   bottom 5   left 5   right 5}

# Stripes verticales MET2 traversant le core
# Nombre de sets calculé dynamiquement selon la largeur du core
set box_core [get_db current_design .core_bbox]
set core_x1  [lindex $box_core 0 0]
set core_x2  [lindex $box_core 0 2]
set nb_of_sets [expr {int(($core_x2 - $core_x1) / 125) - 1}]

setAddStripeMode \
    -stacked_via_top_layer    MET4 \
    -stacked_via_bottom_layer MET1 \
    -via_using_exact_crossover_size true \
    -orthogonal_only true

addStripe \
    -nets           {gnd! vdd!} \
    -layer          MET2 \
    -direction      vertical \
    -width          5 \
    -spacing        0.5 \
    -number_of_sets $nb_of_sets \
    -start_from     left \
    -start_offset   80 \
    -stop_offset    100


# ------------------------------------------------------------------------------
# 3. CONNEXION DES NETS GLOBAUX
# ------------------------------------------------------------------------------
clearGlobalNets

# Core standard cells
globalNetConnect vdd!    -type pgpin -pin vdd!    -inst * -module {}
globalNetConnect gnd!    -type pgpin -pin gnd!    -inst * -module {}

# IO cells (nets 3.3V séparés)
globalNetConnect vdd3r1! -type pgpin -pin vdd3r1! -inst * -module {}
globalNetConnect vdd3r2! -type pgpin -pin vdd3r2! -inst * -module {}
globalNetConnect vdd3o!  -type pgpin -pin vdd3o!  -inst * -module {}
globalNetConnect gnd3r!  -type pgpin -pin gnd3r!  -inst * -module {}
globalNetConnect gnd3o!  -type pgpin -pin gnd3o!  -inst * -module {}

# Cellules PWR/GND avec pin nommée "A"
globalNetConnect vdd! -type pgpin -pin A -inst PWR* -module {}
globalNetConnect gnd! -type pgpin -pin A -inst GND* -module {}

applyGlobalNets


# ------------------------------------------------------------------------------
# 4. ROUTAGE SPECIAL (POWER)
# ------------------------------------------------------------------------------
sroute \
    -connect          {padPin padRing corePin floatingStripe} \
    -nets             {vdd! gnd!} \
    -layerChangeRange {MET1 MET4} \
    -allowJogging     1 \
    -allowLayerChange 1

editPowerVia -add_vias 1