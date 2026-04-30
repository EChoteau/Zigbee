vdel -all -lib work
vlib work
vmap work work

vlog -sv ../../rtl/msk/*.sv -work work
vlog -sv msk_system_tb.sv -work work

vsim -voptargs=+acc work.msk_system_tb
