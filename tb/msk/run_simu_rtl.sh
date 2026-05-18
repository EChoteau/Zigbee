vdel -all -lib work
vlib work
vmap work work

vlog -sv ../../rtl/msk/*.sv -work work
vlog -sv tb_shaping_msk_bus.sv -work work

vsim -voptargs=+acc work.tb_shaping_msk_bus
