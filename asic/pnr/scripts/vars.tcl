# Essential variables for PnR flow
# All unused variables from the original codegen template have been removed

if {![info exists vars]} {
   global vars
}
global env

set name_netlist ${module_name}_synth.v
set vars(data_dir) {../input_data}

set sdc_dir $module_name
if { $module_name == "zigbee_top" } {
   set sdc_dir "top"
}

set env(VPATH) make
