
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
vlog -sv demux_msk_tb.sv            -work work
vlog -sv encodeur_tb.sv             -work work
vlog -sv shaping_msk_tb.sv          -work work
vlog -sv top_msk_tb.sv           -work work
vlog -sv tb_demux_msk_bus.sv        -work work
vlog -sv tb_encodeur_msk_bus.sv     -work work
vlog -sv tb_shaping_msk_bus.sv      -work work
vlog -sv tb_top_msk_bus.sv          -work work

# ============================================================================
# PARTIE 1 : SIMULATION DES TESTBENCHES COMPLETS (APPROCHE BUS)
# ============================================================================

echo ""
echo "========================================================"
echo " RUNNING PART 1: BUS-BASED TESTBENCHES"
echo "========================================================"

# --- TEST 1 : ENCODEUR BUS ---
echo "-> Running: tb_encodeur_msk_bus"
vsim -voptargs=+acc work.tb_encodeur_msk_bus
run -all
quit -sim

# --- TEST 2 : DEMUX BUS ---
echo "-> Running: tb_demux_msk_bus"
vsim -voptargs=+acc work.tb_demux_msk_bus
run -all
quit -sim

# --- TEST 3 : SHAPING BUS ---
echo "-> Running: tb_shaping_msk_bus"
vsim -voptargs=+acc work.tb_shaping_msk_bus
run -all
quit -sim

# --- TEST 4 : TOP BUS ---
echo "-> Running: tb_top_msk_bus"
vsim -voptargs=+acc work.tb_top_msk_bus
run -all
quit -sim

# ============================================================================
# PARTIE 2 : SIMULATION DES TESTBENCHES CLASSIQUES / ANCIENS
# ============================================================================

echo ""
echo "========================================================"
echo " RUNNING PART 2: CLASSIC / GL TESTBENCHES"
echo "========================================================"

# --- TEST 5 : ENCODEUR CLASSIC ---
echo "-> Running: encodeur_tb"
vsim -voptargs=+acc work.tb_encodeur_diff
run -all
quit -sim

# --- TEST 6 : DEMUX CLASSIC ---
echo "-> Running: demux_msk_tb"
vsim -voptargs=+acc work.demux_msk_tb
run -all
quit -sim

# --- TEST 7 : SHAPING CLASSIC ---
echo "-> Running: shaping_msk_tb"
vsim -voptargs=+acc work.shaping_msk_tb
run -all
quit -sim

# --- TEST 8 : TOP GATE LEVEL CLASSIC ---
echo "-> Running: top_msk_gl_tb"
vsim -voptargs=+acc work.top_msk_tb
run -all
quit -sim

echo ""
echo "========================================================"
echo "     TOUTES LES 8 SIMULATIONS ONT ETE EXECUTEES"
echo "========================================================"
