vlib work 

vmap work work 

vlog ./../rtl/MSK_BASEBAND/encodeur_diff.sv ./../rtl/MSK_BASEBAND/demux_msk.sv ./../rtl/MSK_BASEBAND/shaping_msk_cfg.sv ./../rtl/MSK_BASEBAND/top_msk_cfg.sv ./../tb/MSK_BASEBAND/top_msk_cfg.sv 

vsim -voptargs="+acc" work.top_msk_tb
