#////////////////////////////////////////////////////
# STANDARD CELLS PLACEMENT SCRIPT
#////////////////////////////////////////////////////

# Using a technology node greater than or equal to 130 nm
setDesignMode -process 250

# Placement of decoupling capacitors between vdd! gnd! power rails
setEndCapMode -prefix ENDCAP -leftEdge ENDCAPL -rightEdge ENDCAPR
addEndCap -prefix ENDCAP
#addEndCap -preCap ENDCAPL -postCap ENDCAPR -prefix ENDCAP

setViaGenMode -optimize_cross_via true -optimize_via_on_routing_track true

################# Blockages arround stripes
# Dynamic generation of blockages from special wires (MET2 layer)
set stripe_margin 0.6 ; # Adds a physical margin
foreach net {"vdd!" "gnd!"} {
    set net_ptr [dbGet top.nets.name $net -p]
    if {$net_ptr != "0x0" && $net_ptr != ""} {
        foreach sw [dbGet $net_ptr.sWires -e] {
            # Looking specifically for vertical stripes drawn on Metal 2
            if {[dbGet $sw.shape] == "stripe" && [dbGet $sw.layer.name] == "MET4"} {
                # Get the bounding box
                set box [lindex [dbGet $sw.box] 0]
                set x1 [expr [lindex $box 0] - $stripe_margin]
                set y1 [lindex $box 1]
                set x2 [expr [lindex $box 2] + $stripe_margin]
                set y2 [lindex $box 3]
                
                # Create the expanded blockage around the current stripe position
                createPlaceBlockage -type hard -box [list $x1 $y1 $x2 $y2]
            }
        }
    }
}


# Automatic placement of standard cells
setRouteMode -earlyGlobalMaxRouteLayer 4
setRouteMode -earlyGlobalMinRouteLayer 1

# Fixes spacing errors for some cells
setPlaceMode -padForPinNearBorder true


# Setting useful skew
setOptMode -usefulSkew true


# Creation of path groups
set_interactive_constraint_modes [all_constraint_modes -active]
reset_path_group -all
reset_path_exception

set input_ports [all_inputs -no_clocks]
set output_ports [all_outputs]
set rams [get_cells -quiet -hierarchical * -filter "is_memory_cell==true"]

set gated_all [filter_collection [all_registers] "is_integrated_clock_gating_cell == true"]
set gated_rtl [get_cells -quiet -hierarchical * -filter "hierarchical_name =~ *GATED"]

set seqs [all_registers]
set tmp1 [remove_from_collection $seqs $gated_all]
set regs [remove_from_collection $tmp1 $rams]

# Registers
group_path -name reg2reg 	-from $regs 		-to $regs
group_path -name in2reg 	-from $input_ports 	-to $regs
group_path -name reg2out 	-from $regs 		-to $output_ports
group_path -name in2out 	-from $input_ports 	-to $output_ports
group_path -name reg2gated 	-from $regs 		-to $gated_all
group_path -name in2gated 	-from $input_ports 	-to $gated_all

# RAMs
# No rams in our circuit

# Options for path_groups
set_interactive_constraint_modes {}
setPathGroupOptions reg2reg 	-effortLevel high -slackAdjustment 0
setPathGroupOptions in2reg 	-effortLevel high -slackAdjustment 0
setPathGroupOptions reg2out 	-effortLevel high -slackAdjustment 0
setPathGroupOptions in2out 	-effortLevel high -slackAdjustment 0
setPathGroupOptions reg2gated 	-effortLevel high -slackAdjustment 0
setPathGroupOptions in2gated 	-effortLevel high -slackAdjustment 0

place_opt_design


setOptMode -fixDRC true
setOptMode -fixCap true -fixTran  true -fixFanoutLoad false
optDesign -preCTS

