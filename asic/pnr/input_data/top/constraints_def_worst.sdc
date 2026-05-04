source $vars(data_dir)/constraints_variables.sdc

#---------------------------------------------------------
# Input
#---------------------------------------------------------

set_interactive_constraint_modes [all_constraint_modes -active]


set_input_transition $input_transition_min_worst -min [get_ports "i_clk"]
set_input_transition $input_transition_min_worst -min [get_ports "i_rst_n"]
set_input_transition $input_transition_min_worst -min [get_ports {i_top_cfg[*]}]
set_input_transition $input_transition_min_worst -min [get_ports {i_wrapper_cfg[*]}]
set_input_transition $input_transition_min_worst -min [get_ports {i_bus_a[*]}]
set_input_transition $input_transition_min_worst -min [get_ports {i_bus_b[*]}]


set_input_transition $input_transition_max_worst -max [get_ports "i_clk"]
set_input_transition $input_transition_max_worst -max [get_ports "i_rst_n"]
set_input_transition $input_transition_max_worst -max [get_ports {i_top_cfg[*]}]
set_input_transition $input_transition_max_worst -max [get_ports {i_wrapper_cfg[*]}]
set_input_transition $input_transition_max_worst -max [get_ports {i_bus_a[*]}]
set_input_transition $input_transition_max_worst -max [get_ports {i_bus_b[*]}]


set_load -pin_load $std_load_worst -min [get_ports "i_clk"]
set_load -pin_load $std_load_worst -min [get_ports "i_rst_n"]
set_load -pin_load $std_load_worst -min [get_ports {i_top_cfg[*]}]
set_load -pin_load $std_load_worst -min [get_ports {i_wrapper_cfg[*]}]
set_load -pin_load $std_load_worst -min [get_ports {i_bus_a[*]}]
set_load -pin_load $std_load_worst -min [get_ports {i_bus_b[*]}]



##---------------------------------------------------------
## Output
##---------------------------------------------------------
set_max_capacitance $max_cap_worst [get_ports {o_bus_c[*]}]
set_max_capacitance $max_cap_worst [get_ports {o_bus_d[*]}]