source ../scripts/vars.tcl

set init_layout_view ""
set init_abstract_name ""

set init_verilog "../input_data/${module_name}/${name_netlist}"
if {$module_name eq "zigbee_top"} {
	set init_verilog "$init_verilog ../input_data/top/${module_name}_io.v"
}

set init_mmmc_file "../scripts/view_definition.tcl"

#set init_lef_file "../scripts/c35b4_A.lef /softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/CORELIB.lef /softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/IOLIB_4M.lef"
#set init_lef_file "/softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/c35b4.lef_back /softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/CORELIB.lef /softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/IOLIB_4M.lef"
set init_lef_file "/softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/c35b4.lef /softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/CORELIB.lef"

if {$module_name eq "zigbee_top"} {
	set init_top_cell "${module_name}_io"
} else {
	set init_top_cell "${module_name}"
}

set init_gnd_net "gnd! gnd3r! gnd3o!"
set init_pwr_net "vdd! vdd3r1! vdd3r2! vdd3o!"
set cts_cell_list "CLKIN0 CLKIN1 CLKIN2 CLKIN3 CLKIN4 CLKIN6 CLKIN8 CLKIN10 CLKIN12 CLKIN15 CLKBU2 CLKBU4 CLKBU6 CLKBU8 CLKBU12 CLKBU15"


