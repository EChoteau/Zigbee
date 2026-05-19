
# ============================================================================
# SCRIPT DE SIMULATION AUTOMATIQUE INTEGRAL (TOUS LES TESTBENCHES)
# ============================================================================

# 1. Nettoyage et création de la bibliothèque de travail
if [file exists work] {
    vdel -all -lib work
}
vlib work
vmap work work

# 2. Compilation du RTL MSK
echo "=== COMPILATION DU RTL MSK ==="
vlog -sv ../../rtl/msk/*.sv -work work

# 3. Compilation de TOUS les Testbenches présents
echo "=== COMPILATION DE TOUS LES TESTBENCHES ==="

vlog -sv tb_demux_msk_bus.sv        -work work
vlog -sv tb_encodeur_msk_bus.sv     -work work
vlog -sv tb_shaping_msk_bus.sv      -work work
vlog -sv tb_top_msk_bus.sv          -work work



# --- TEST 4 : TOP BUS ---
echo "-> Running: tb_top_msk_bus"
vsim -voptargs=+acc work.tb_top_msk_bus
run -all


