# ==============================================================================
# INITIALISATION DU DESIGN
# AMS C35B4C3 - Innovus
# ==============================================================================

source ../scripts/vars.tcl

# Netlist verilog post-synthèse
set init_verilog "../input_data/${sdc_dir}/${name_netlist}"
if {$module_name eq "zigbee_top"} {
    set init_verilog "../input_data/${sdc_dir}/${module_name}_io.v"
}

# Fichier MMMC (vues timing)
set init_mmmc_file "../scripts/view_definition.tcl"

# Fichiers LEF (techno + cells standard + IO pour le top)
set init_lef_file "/softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/c35b4.lef \
                   /softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/CORELIB.lef"
if {$module_name eq "zigbee_top"} {
    set init_lef_file "/softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/c35b4.lef \
                       /softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/CORELIB.lef \
                       /softslin/AMS_410_ISR15/cds/HK_C35/LEF/c35b4/IOLIB_4M.lef"
}

# Cellule top
set init_top_cell "${module_name}"
if {$module_name eq "zigbee_top"} {
    set init_top_cell "${module_name}_io"
}

# Nets d'alimentation
set init_pwr_net "vdd! vdd3r1! vdd3r2! vdd3o!"
set init_gnd_net "gnd! gnd3r! gnd3o!"

# Cellules de clock pour le CTS
set cts_cell_list "CLKIN0 CLKIN1 CLKIN2 CLKIN3 CLKIN4 CLKIN6 CLKIN8 CLKIN10 \
                   CLKIN12 CLKIN15 CLKBU2 CLKBU4 CLKBU6 CLKBU8 CLKBU12 CLKBU15"