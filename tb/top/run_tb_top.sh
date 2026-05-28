source config/config_RTL

vdel -all -lib lib_RTL 2>/dev/null || true
vlib lib_RTL
vmap lib_RTL lib_RTL

vlog -incr -sv -work lib_RTL +acc rtl/top/zigbee_top.sv
vlog -incr -sv -work lib_RTL +acc rtl/top/wrappers/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/interface/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/cdr/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/demod/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/demod/FIR/*.v
vlog -incr -sv -work lib_RTL +acc rtl/demod/WAVE/*.sv
vlog -incr -sv -work lib_RTL +acc rtl/msk/*.sv

vlog -incr -sv -work lib_RTL +acc tb/top/include/tb_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/top/interface/*.sv
vlog -incr -sv -work lib_RTL +acc tb/top/demod/*.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/interface/interface_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/msk/msk_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/demod/demod_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/cordic/cordic_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/cdr/cdr_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/top/top_tb.sv

n=lib_RTL.top_tb
vsim -c ${n} -do "tb/top/top_tb.do"