analyze -format sverilog {/tp/xph2app/xph2app112/Zigbee/Zigbee/rtl/interface/serializer.sv /tp/xph2app/xph2app112/Zigbee/Zigbee/rtl/interface/interface_top.sv /tp/xph2app/xph2app112/Zigbee/Zigbee/rtl/interface/fifo.sv /tp/xph2app/xph2app112/Zigbee/Zigbee/rtl/interface/deserializer.sv /tp/xph2app/xph2app112/Zigbee/Zigbee/rtl/interface/baud_rate_gen.sv /tp/xph2app/xph2app112/Zigbee/Zigbee/rtl/interface/apb_slave_regs.sv}
elaborate interface_top -parameters "FIFO_DEPTH=8"
set_operating_conditions -library c35_CORELIB_TYP TYPICAL
create_clock -name i_clk -period 20 i_clk
#ungroup -all -flatten
set_max_area 0

set_ungroup interface_top_FIFO_DEPTH8
set_boundary_optimization interface_top_FIFO_DEPTH8
set_scan_configuration -style none
set_flatten true -design interface_top_FIFO_DEPTH8 -effort high -minimize multiple_output -phase true
set_structure true -design interface_top_FIFO_DEPTH8 -boolean true -timing false


#set_max_fanout 3 interface_top
#set_max_transition 1.5 interface_top
set_dynamic_optimization true
set_leakage_optimization true
#set_max_dynamic_power 0
#set_max_leakage_power 0
compile_ultra -gate_clock
write -hierarchy -format verilog -output /tp/xph2app/xph2app112/Zigbee/Zigbee/tb/interface/synth/interfacefifo4.v
write_sdf interfacefifo4
report_clock_gating > report_cg_summaryfifo8.txt
