# =====================================================
# TB Top - Coverage (console only)
# =====================================================

set cov_ucdb "coverage/raw/top/top.ucdb"

# Create a dedicated coverage library
if ![file isdirectory lib_RTL_cov] {
    vlib lib_RTL_cov
    vmap lib_RTL_cov lib_RTL_cov
}

# Compile RTL with coverage
vlog -incr -sv -cover bcesft -work lib_RTL_cov +acc rtl/top/zigbee_top.sv
vlog -incr -sv -cover bcesft -work lib_RTL_cov +acc rtl/top/wrappers/*.sv
vlog -incr -sv -cover bcesft -work lib_RTL_cov +acc rtl/interface/*.sv
vlog -incr -sv -cover bcesft -work lib_RTL_cov +acc rtl/cdr/*.sv
vlog -incr -sv -cover bcesft -work lib_RTL_cov +acc rtl/cordic/*.sv
vlog -incr -sv -cover bcesft -work lib_RTL_cov +acc rtl/demod/*.sv
vlog -incr -sv -cover bcesft -work lib_RTL_cov +acc rtl/demod/FIR/*.v
vlog -incr -sv -cover bcesft -work lib_RTL_cov +acc rtl/demod/WAVE/*.sv
vlog -incr -sv -cover bcesft -work lib_RTL_cov +acc rtl/msk/*.sv

# Compile TB without coverage to keep reports RTL-only
vlog -incr -sv -work lib_RTL_cov +acc tb/top/include/*.sv
vlog -incr -sv -work lib_RTL_cov +acc tb/top/interface/*.sv
vlog -incr -sv -work lib_RTL_cov +acc tb/top/demod/*.sv
vlog -incr -sv -work lib_RTL_cov +acc tb/wrappers/interface/*.sv
vlog -incr -sv -work lib_RTL_cov +acc tb/wrappers/demod/*.sv
vlog -incr -sv -work lib_RTL_cov +acc tb/top/*.sv

# Run in console with coverage enabled
vsim -coverage -voptargs=+acc lib_RTL_cov.top_tb -sdfnoerror -sdfnowarn -L c35_CORELIB
run -all

# Save coverage and exit
coverage save -code bcesft -cvg $cov_ucdb
quit -f
