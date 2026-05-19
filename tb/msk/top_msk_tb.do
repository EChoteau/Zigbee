# =====================================================
# TB MSK Top
# =====================================================

vdel -all -lib lib_rtl
vlib lib_rtl
vmap lib_rtl lib_rtl

vlog -sv rtl/msk/*.sv -work lib_rtl
vlog -sv tb/msk/top_msk_tb.sv -work lib_rtl

vsim -voptargs=+acc lib_rtl.top_msk

run
quit -f
