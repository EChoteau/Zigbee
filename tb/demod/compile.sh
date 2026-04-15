#!/bin/bash

# 1. Création de la librairie de travail (work)
# On supprime l'ancienne si elle existe pour repartir de zéro
if [ -d "work" ]; then
    rm -rf work
fi

vlib work
vmap work work

# 2. Compilation des fichiers
# -sv indique que nous utilisons le SystemVerilog
echo "Compiling design..."
vlog -sv +acc rtl/WAVE/wave_generator.sv
vlog -sv +acc demod.sv

vlog -sv +acc rtl/FIR/delay_line.v
vlog -sv +acc rtl/FIR/coeff_rom.v
vlog -sv +acc rtl/FIR/fir_core.v
vlog -sv +acc rtl/FIR/fir_top.v

echo "Compiling testbench..."
vlog -sv +acc tb/wave_generator_tb.sv
vlog -sv +acc tb/demod_tb.sv
vlog -sv +acc tb/tb_fir.v

# 3. Vérification du succès
if [ $? -eq 0 ]; then
    echo "----------------------------------------------------"
    echo " Compilation réussie !"
    echo " Pour lancer la simulation, tapez :"
    echo " vsim work.wave_generator_tb"
    echo "----------------------------------------------------"
else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo " Erreur lors de la compilation. Vérifiez le log."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
