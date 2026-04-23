vlib work 

vmap work work 

vlog ./../rtl/msk/encodeur_diff.sv ./../rtl/msk/demux_msk.sv ./../rtl/msk/shaping_msk_cfg.sv ./../rtl/msk/top_msk_cfg.sv ./../tb/msk/top_msk_cfg.sv 

vsim -voptargs="+acc" work.top_msk_tb
