source $vars(data_dir)/constraints_variables.sdc

#---------------------------------------------------------
# Input
#---------------------------------------------------------
set_interactive_constraint_modes [all_constraint_modes -active]

# System signals
set_input_transition $input_transition_min_best -min [get_ports "i_clk"]
set_input_transition $input_transition_min_best -min [get_ports "i_rst_n"]

set_input_transition $input_transition_max_best -max [get_ports "i_clk"]
set_input_transition $input_transition_max_best -max [get_ports "i_rst_n"]

set_load -pin_load $std_load_best -min [get_ports "i_clk"]
set_load -pin_load $std_load_best -min [get_ports "i_rst_n"]

#APB signals
set_input_transition $input_transition_min_best -min [get_ports "i_psel"]
set_input_transition $input_transition_min_best -min [get_ports "i_penable"]
set_input_transition $input_transition_min_best -min [get_ports "i_pwrite"]
set_input_transition $input_transition_min_best -min [get_ports {i_paddr[*]}]
set_input_transition $input_transition_min_best -min [get_ports {i_pwdata[*]}]


set_input_transition $input_transition_max_best -max [get_ports "i_psel"]
set_input_transition $input_transition_max_best -max [get_ports "i_penable"]
set_input_transition $input_transition_max_best -max [get_ports "i_pwrite"]
set_input_transition $input_transition_max_best -max [get_ports {i_paddr[*]}]
set_input_transition $input_transition_max_best -max [get_ports {i_pwdata[*]}] 

set_load -pin_load $std_load_best -min [get_ports "i_psel"]
set_load -pin_load $std_load_best -min [get_ports "i_penable"]
set_load -pin_load $std_load_best -min [get_ports "i_pwrite"]
set_load -pin_load $std_load_best -min [get_ports {i_paddr[*]}]
set_load -pin_load $std_load_best -min [get_ports {i_pwdata[*]}]



##---------------------------------------------------------
## Output
##---------------------------------------------------------

## Output signals
set_max_capacitance $max_cap_best [get_ports "io_o_serial_tx"]
set_max_capacitance $max_cap_best [get_ports "io_o_tx_sample_tick"]
set_max_capacitance $max_cap_best [get_ports "io_o_pready"]
set_max_capacitance $max_cap_best [get_ports "io_o_pslverr"]
set_max_capacitance $max_cap_best [get_ports {o_phase_deriv[*]}]
