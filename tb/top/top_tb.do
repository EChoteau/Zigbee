# =====================================================
# TB Top
# =====================================================

add wave -position insertpoint  \
sim:/top_tb/i_clk \
sim:/top_tb/i_rst_n \
sim:/top_tb/i_top_cfg \
sim:/top_tb/i_wrapper_cfg \
sim:/top_tb/i_bus_in \
sim:/top_tb/o_bus_out

run -all

wave zoom full