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

# Serial interface input (from CDR)
set_input_transition $input_transition_min_best -min [get_ports "i_serial_rx"]
set_input_transition $input_transition_min_best -min [get_ports "i_cdr_sample_valid"]

set_input_transition $input_transition_max_best -max [get_ports "i_serial_rx"]
set_input_transition $input_transition_max_best -max [get_ports "i_cdr_sample_valid"]

set_load -pin_load $std_load_best -min [get_ports "i_serial_rx"]
set_load -pin_load $std_load_best -min [get_ports "i_cdr_sample_valid"]

##---------------------------------------------------------
## Output
##---------------------------------------------------------

# APB output signals
set_max_capacitance $max_cap_best [get_ports "o_pready"]
set_max_capacitance $max_cap_best [get_ports "o_pslverr"]
set_max_capacitance $max_cap_best [get_ports "o_tx_valid"]
set_max_capacitance $max_cap_best [get_ports {o_prdata[*]}]

# Serial interface output (to MODULATION)
set_max_capacitance $max_cap_best [get_ports "o_serial_tx"]
set_max_capacitance $max_cap_best [get_ports "o_tx_sample_tick"]
