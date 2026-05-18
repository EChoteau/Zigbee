#!/bin/bash

# ==============================================================
# compile_all.sh — Compilation avec package demod_tasks_pkg
# ==============================================================

set -e   # Arrêt immédiat en cas d'erreur

RTL_DIR=../../rtl
TB_DIR=.

# ==============================================================
# 1. LIBRAIRIE
# ==============================================================
echo "--- Nettoyage ---"
[ -d work ] && rm -rf work
vlib work
vmap work work

# ==============================================================
# 2. PACKAGE (EN PREMIER — les TB en dépendent)
# ==============================================================
echo "--- Compilation Package ---"
vlog -sv $TB_DIR/demod_tasks_pkg.sv

# ==============================================================
# 3. RTL
# ==============================================================
echo "--- Compilation RTL ---"
vlog -sv +acc $RTL_DIR/demod/WAVE/wave_generator.sv
vlog -sv +acc $RTL_DIR/demod/WAVE/demod.sv
vlog -sv +acc $RTL_DIR/demod/FIR/fir_core.sv
vlog -sv +acc $RTL_DIR/demod/FIR/fir_top.sv
vlog -sv +acc $RTL_DIR/top/wrappers/demod_wrapper.sv
vlog -sv +acc $RTL_DIR/demod/demod_top.sv

# ==============================================================
# 4. TESTBENCHES (EN DERNIER — après package et RTL)
# ==============================================================
echo "--- Compilation Testbenches ---"
vlog -sv +acc $TB_DIR/tb_all.sv
vlog -sv +acc $TB_DIR/tb_fir.sv

# ==============================================================
# 5. RÉSUMÉ
# ==============================================================
echo "----------------------------------------------------"
echo " Compilation réussie !"
echo " Lancer la simulation :"
echo "   vsim -voptargs=\"+acc\" work.tb_demod_system"
echo "   vsim -voptargs=\"+acc\" work.tb_fir"
echo "----------------------------------------------------"
