source $vars(data_dir)/constraints_variables.sdc

#create_clock -name clk  -period $clk_period(clk) -waveform "0 [expr $clk_period(clk)/2]" [get_ports "clk"]
set clk_pin_obj [get_pins -quiet "io_$clk_root(clk)/Y"]
if {[sizeof_collection $clk_pin_obj] > 0} {
	create_clock -name $clk_root(clk) -period $clk_period(clk) -waveform "0 [expr $clk_period(clk)/2]" $clk_pin_obj
} else {
	create_clock -name $clk_root(clk) -period $clk_period(clk) -waveform "0 [expr $clk_period(clk)/2]" [get_ports "$clk_root(clk)"]
}
#set_clock_transition 200ps -max [get_clocks "clk"]
#set_clock_latency "$clk_period(clk)ns" -max [get_clocks "clk"]
#set_clock_latency 0ns -min [get_clocks "clk"]

