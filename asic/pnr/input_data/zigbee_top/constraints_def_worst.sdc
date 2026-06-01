source $vars(data_dir)/constraints_variables.sdc

set_interactive_constraint_modes [all_constraint_modes -active]

#---------------------------------------------------------
# Transitions sur les entrées (ok, on garde)
#---------------------------------------------------------
set_input_transition $input_transition_min_worst -min [get_ports "i_rst_n"]
set_input_transition $input_transition_min_worst -min [get_ports {i_cfg_top[*]}]
set_input_transition $input_transition_min_worst -min [get_ports {i_cfg[*]}]
set_input_transition $input_transition_min_worst -min [get_ports {i_bus_in[*]}]

set_input_transition $input_transition_max_worst -max [get_ports "i_rst_n"]
set_input_transition $input_transition_max_worst -max [get_ports {i_cfg_top[*]}]
set_input_transition $input_transition_max_worst -max [get_ports {i_cfg[*]}]
set_input_transition $input_transition_max_worst -max [get_ports {i_bus_in[*]}]

# Retiré set_input_transition sur i_clk — c'est l'horloge, géré par create_clock

#---------------------------------------------------------
# Charge sur les SORTIES uniquement (retiré des entrées)
#---------------------------------------------------------
set_load -pin_load $std_load_worst [get_ports {o_bus_out[*]}]
set_max_capacitance $max_cap_worst [get_ports {o_bus_out[*]}]

#---------------------------------------------------------
# Delays I/O — setup (max)
# Si tu veux set_false_path à la place, commente ce bloc
# et décommente les false_path en bas
#---------------------------------------------------------
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

# Min delay pour hold
set_input_delay  -min 0.0 -clock $clk_root(clk) [get_ports {i_cfg_top[*]}]
set_input_delay  -min 0.0 -clock $clk_root(clk) [get_ports {i_cfg[*]}]
set_input_delay  -min 0.0 -clock $clk_root(clk) [get_ports {i_bus_in[*]}]
set_input_delay  -min 0.0 -clock $clk_root(clk) [get_ports i_rst_n]
set_output_delay -min 0.0 -clock $clk_root(clk) [get_ports {o_bus_out[*]}]

#---------------------------------------------------------
# Optionnel : false path sur reset asynchrone
#---------------------------------------------------------
set_false_path -from [get_ports i_rst_n]

# Si tu veux ignorer tout le timing I/O, décommente ça
# et commente le bloc delays ci-dessus :
# set_false_path -from [all_inputs]
# set_false_path -to   [all_outputs]