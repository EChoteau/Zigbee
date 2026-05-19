#!/bin/bash
# =====================================================
# Testbench: DEMOD - Compile All
# Run from project root: ./tb/demod/compile_all.sh
# =====================================================

source config/config_RTL

# 1. Création de la librairie de travail (lib_rtl)
if [ -d "lib_rtl" ]; then
    rm -rf lib_rtl
fi

vlib lib_rtl
vmap lib_rtl lib_rtl

# 2. Compilation du Design (RTL)
echo "Compiling design (WAVE, DEMOD, FIR)..."

# Bloc WAVE (Générateur + Démodulateur)
vlog -sv +acc rtl/demod/WAVE/wave_generator.sv
vlog -sv +acc rtl/demod/WAVE/demod.sv

# Bloc FIR
vlog -sv +acc rtl/demod/FIR/fir_core.sv
vlog -sv +acc rtl/demod/FIR/fir_top.sv

# Bloc WRAPPER (Le module qui relie tout)
vlog -sv +acc rtl/top/wrappers/demod_wrapper.sv

# Bloc TOP (Le module qui relie tout)
vlog -sv +acc rtl/demod/demod_system_top.sv

# 3. Compilation du Testbench Global
echo "Compiling global testbench..."
vlog -sv +acc tb/demod/tb_all.sv
vlog -sv +acc tb/demod/tb_fir.v
vlog -sv +acc tb/demod/tb_wrapper.sv
vlog -sv +acc tb/demod/demod_tb.sv

# 4. Vérification du succès
if [ $? -eq 0 ]; then
    echo "----------------------------------------------------"
    echo " Compilation réussie !"
    echo " Pour lancer la simulation du système complet, tapez :"
    echo " vsim -voptargs=\"+acc\" lib_rtl.system_tb"
    echo "----------------------------------------------------"
else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo " Erreur lors de la compilation. Vérifiez le log."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
