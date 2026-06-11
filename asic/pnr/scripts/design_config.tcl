#////////////////////////////////////////////////////
# CONFIGURATION DU FLOORPLAN
#////////////////////////////////////////////////////

#////////////////////////////////////////////////////
# Respect des règles de DRC
#////////////////////////////////////////////////////
#set min_MET1_width 0.5
#set min_MET1_spacing 0.45
#set min_MET1_to_WIDE_MET1_spacing 0.8
#set min_MET1_enclosure 0.15
#set min_MET1_density_area 30
#set min_MET1_to_KEPOUT_or_SFCDEF 0.45


#////////////////////////////////////////////////////
# Creation et placement des PADs
#////////////////////////////////////////////////////
if {![info exists module_name] || $module_name eq ""} {
	set module_name zigbee_top
}
if {$module_name eq "zigbee_top"} {
	loadIoFile ../input_data/${sdc_dir}/${module_name}_pads.io
	floorPlan -site standard -d {1893.8 1893.8 80 80 80 80} -noSnapToGrid -coreMarginsBy io
} else {
	floorPlan -site standard -r 1 0.7 80 80 80 80
	#floorPlan -site standard -d {2000 2000 80 80 80 80} -noSnapToGrid
}


#////////////////////////////////////////////////////
# Creation de la grille d'alimentation
#////////////////////////////////////////////////////

#Set les modes de création de la grille
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer MET4 -stacked_via_bottom_layer MET1 -via_using_exact_crossover_size true -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }

#Ajoute la grille
addRing -nets {gnd! vdd!} -type core_rings -follow core -layer {top MET3 bottom MET3 left MET4 right MET4} -width {top 20 bottom 20 left 20 right 20} -spacing {top 10 bottom 10 left 10 right 10} -offset {top 0.7 bottom 0.7 left 0.7 right 0.7} -center 1 -extend_corner {} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None


#Variables pour la création des stripes
#Calculs de l'offset de grille
set box_core  [get_db current_design .core_bbox]
set x1 [lindex $box_core 0 0]
set x2 [lindex $box_core 0 2]
set size_of_partition [expr $x2 - $x1]
set x [expr $size_of_partition / 125]
set nb_of_sets [expr int($x) - 1]

#Valeurs spécifique à la techno (NE PAS CHANGER !!!)
set stripe_spacing 0.6
set stripe_width 5
set stripe_direction vertical
set stripe_layer MET4
set stripe_start_offset 80
set stripe_stop_offset 100

#Set les modes pour les stripes
setAddStripeMode -ignore_block_check true -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 5 -stripe_min_length 0 -stacked_via_top_layer MET4 -stacked_via_bottom_layer MET1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring }


addStripe -nets {gnd! vdd!} -layer $stripe_layer -direction $stripe_direction -width $stripe_width -spacing $stripe_spacing -number_of_sets $nb_of_sets -start_from left -start_offset $stripe_start_offset -stop_offset $stripe_stop_offset -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit MET4 -padcore_ring_bottom_layer_limit MET1 -block_ring_top_layer_limit MET4 -block_ring_bottom_layer_limit MET1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }


#////////////////////////////////////////////////////
# ConnectGlobalNets
#////////////////////////////////////////////////////

# globalNetConnect vdd! -type pgpin -pin vdd! -all
# globalNetConnect gnd! -type pgpin -pin gnd! -all
# globalNetConnect vdd3r1! -type pgpin -pin vdd3r1! -all
# globalNetConnect vdd3r2! -type pgpin -pin vdd3r2! -all
# globalNetConnect vdd3o! -type pgpin -pin vdd3o!  -all
# globalNetConnect gnd3r! -type pgpin -pin gnd3r!  -all
# globalNetConnect gnd3o! -type pgpin -pin gnd3o!  -all


##--- Define global Power nets - make global connections
clearGlobalNets
set globalNetsList {{vdd! vdd!} {gnd! gnd!}}
set globalNetsList [lappend globalNetsList {vdd3r1! vdd3r1!} {vdd3r2! vdd3r2!} {vdd3o! vdd3o!} {gnd3r! gnd3r!} {gnd3o! gnd3o!}]
clearGlobalNets
foreach net $globalNetsList {
    set n [lindex $net 0]
    set p [lindex $net 1]
    globalNetConnect $n -type pgpin -pin $p -inst * -module {}
    print "---# GlobalConnect all $p pins to net $n"
}

globalNetConnect vdd! -type pgpin -pin A -inst PWR*
globalNetConnect gnd! -type pgpin -pin A -inst GND*

# applyGlobalNets

add_text -layer MET4 -pt {50.0 885.0} -label vdd! -drafting true
add_text -layer MET4 -pt {890.0 1826.0} -label vdd! -drafting true
add_text -layer MET4 -pt {55.0 988.0} -label gnd! -drafting true
add_text -layer MET4 -pt {1823.0 983.0} -label gnd! -drafting true



#////////////////////////////////////////////////////
# Special_route
#////////////////////////////////////////////////////

#Pour faire les stripe d'alimentation à l'horizontal
setSrouteMode -viaConnectToShape { noshape }

sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { MET1 MET4 } -padPinPortConnect { allPort allGeom } -padPinTarget { nearestTarget } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { MET1 MET4 } -nets { gnd! vdd! } -allowLayerChange 1 -targetViaLayerRange { MET1 MET4 }

editPowerVia -add_vias 1
