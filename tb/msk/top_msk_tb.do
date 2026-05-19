# =====================================================
# TB MSK Top
# =====================================================

vdel -all -lib work
vlib work
vmap work work

vlog -sv rtl/msk/*.sv -work work
vlog -sv tb/msk/top_msk_tb.sv -work work

vsim -voptargs=+acc work.top_msk

run
quit -f
