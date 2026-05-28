source config/config_RTL

coverage_ucdb=tb/top/cov.ucdb

vdel -all -lib lib_RTL 2>/dev/null || true
vlib lib_RTL
vmap lib_RTL lib_RTL

vlog -incr -sv -work lib_RTL +acc +cover rtl/top/zigbee_top.sv
vlog -incr -sv -work lib_RTL +acc +cover rtl/top/wrappers/*.sv
vlog -incr -sv -work lib_RTL +acc +cover rtl/interface/*.sv
vlog -incr -sv -work lib_RTL +acc +cover rtl/cdr/*.sv
vlog -incr -sv -work lib_RTL +acc +cover rtl/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc +cover rtl/demod/*.sv
vlog -incr -sv -work lib_RTL +acc +cover rtl/demod/FIR/*.v
vlog -incr -sv -work lib_RTL +acc +cover rtl/demod/WAVE/*.sv
vlog -incr -sv -work lib_RTL +acc +cover rtl/msk/*.sv

vlog -incr -sv -work lib_RTL +acc tb/top/include/tb_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/top/interface/*.sv
vlog -incr -sv -work lib_RTL +acc tb/top/msk/*.sv
vlog -incr -sv -work lib_RTL +acc tb/top/cordic/*.sv
vlog -incr -sv -work lib_RTL +acc tb/top/cdr/*.sv
vlog -incr -sv -work lib_RTL +acc tb/top/demod/*.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/interface/interface_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/msk/msk_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/demod/demod_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/cordic/cordic_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/wrappers/cdr/cdr_wrapper_tasks_pkg.sv
vlog -incr -sv -work lib_RTL +acc tb/top/top_tb.sv

n=lib_RTL.top_tb
vsim -coverage -c ${n} -voptargs="+cover=bcest +acc=npr" -do "tb/top/top_tb.do; coverage save -code bcesft -assert -cvg $coverage_ucdb; quit -f"