# =====================================================
# TB Cordic Top Sine 
# =====================================================

# Create the library only if it doesn't exist
if ![file isdirectory lib_RTL] {
    vlib lib_RTL
    vmap lib_RTL lib_RTL
}

vlog -incr -sv -work lib_RTL +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc tb/cordic/*.sv

vsim -voptargs=+acc lib_RTL.cordic_top_sine_tb -sdfnoerror -sdfnowarn -L c35_CORELIB

add wave -position insertpoint  \
sim:/cordic_top_sine_tb/i_clk \
sim:/cordic_top_sine_tb/i_i_in_reg \
sim:/cordic_top_sine_tb/i_q_in_reg \
sim:/cordic_top_sine_tb/o_phase_out_reg \
sim:/cordic_top_sine_tb/w_phase_out_raw \
sim:/cordic_top_sine_tb/s_angle \
sim:/cordic_top_sine_tb/s_i_val \
sim:/cordic_top_sine_tb/s_q_val

run -all

wave zoom full

#quit -f
