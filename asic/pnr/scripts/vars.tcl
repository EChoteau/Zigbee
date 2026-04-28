# Essential variables for PnR flow
# All unused variables from the original codegen template have been removed

if {![info exists vars]} {
   global vars
}
global env

set name_netlist ${module_name}_synth.v

set env(VPATH) make
