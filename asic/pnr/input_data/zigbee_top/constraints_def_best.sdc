source $vars(data_dir)/constraints_variables.sdc

set_interactive_constraint_modes [all_constraint_modes -active]

set_input_transition $input_transition_min_best -min [get_ports "i_rst_n"]
set_input_transition $input_transition_min_best -min [get_ports {i_cfg_top[*]}]
set_input_transition $input_transition_min_best -min [get_ports {i_cfg[*]}]
set_input_transition $input_transition_min_best -min [get_ports {i_bus_in[*]}]

set_input_transition $input_transition_max_best -max [get_ports "i_rst_n"]
set_input_transition $input_transition_max_best -max [get_ports {i_cfg_top[*]}]
set_input_transition $input_transition_max_best -max [get_ports {i_cfg[*]}]
set_input_transition $input_transition_max_best -max [get_ports {i_bus_in[*]}]

set_load -pin_load $std_load_best [get_ports {o_bus_out[*]}]
set_max_capacitance $max_cap_best [get_ports {o_bus_out[*]}]

set_input_delay  -max [expr $clk_period(clk) * 0.4] \
    -clock $clk_root(clk) [get_ports {i_cfg_top[*]}]
set_input_delay  -max [expr $clk_period(clk) * 0.4] \
    -clock $clk_root(clk) [get_ports {i_cfg[*]}]
set_input_delay  -max [expr $clk_period(clk) * 0.4] \
    -clock $clk_root(clk) [get_ports {i_bus_in[*]}]
set_input_delay  -max [expr $clk_period(clk) * 0.4] \
    -clock $clk_root(clk) [get_ports i_rst_n]

set_output_delay -max [expr $clk_period(clk) * 0.4] \
    -clock $clk_root(clk) [get_ports {o_bus_out[*]}]

set_input_delay  -min 0.0 -clock $clk_root(clk) [get_ports {i_cfg_top[*]}]
set_input_delay  -min 0.0 -clock $clk_root(clk) [get_ports {i_cfg[*]}]
set_input_delay  -min 0.0 -clock $clk_root(clk) [get_ports {i_bus_in[*]}]
set_input_delay  -min 0.0 -clock $clk_root(clk) [get_ports i_rst_n]
set_output_delay -min 0.0 -clock $clk_root(clk) [get_ports {o_bus_out[*]}]

set_false_path -from [get_ports i_rst_n]