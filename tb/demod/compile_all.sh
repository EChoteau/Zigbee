#!/bin/bash

# 1. Création de la librairie de travail (work)
if [ -d "work" ]; then
    rm -rf work
fi

vlib work
vmap work work

# 2. Compilation du Design (RTL)
echo "Compiling design (WAVE, DEMOD, FIR)..."

# Bloc WAVE (Générateur + Démodulateur)
vlog -sv +acc rtl/demod/WAVE/wave_generator.sv
# Attention : Assure-toi que ton fichier s'appelle IQ_DEMOD.sv ou demod.sv
vlog -sv +acc rtl/demod/WAVE/demod.sv 

# Bloc FIR
vlog -sv +acc rtl/demod/FIR/delay_line.v
vlog -sv +acc rtl/demod/FIR/coeff_rom.v
vlog -sv +acc rtl/demod/FIR/fir_core.v
vlog -sv +acc rtl/demod/FIR/fir_top.v

# Bloc TOP (Le module qui relie tout)
vlog -sv +acc rtl/demod/top_level_all.sv

# 3. Compilation du Testbench Global
echo "Compiling global testbench..."
vlog -sv +acc tb/demod/tb_all.sv
vlog -sv +acc tb/demod/tb_fir.v

# 4. Vérification du succès
if [ $? -eq 0 ]; then
    echo "----------------------------------------------------"
    echo " Compilation réussie !"
    echo " Pour lancer la simulation du système complet, tapez :"
    echo " vsim -voptargs=\"+acc\" work.system_tb"
    echo "----------------------------------------------------"
else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo " Erreur lors de la compilation. Vérifiez le log."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
