#!/bin/bash

# 1. Création de la librairie de travail (lib_rtl)
# On supprime l'ancienne si elle existe pour repartir de zéro
if [ -d "lib_rtl" ]; then
    rm -rf lib_rtl
fi

vlib lib_rtl
vmap lib_rtl lib_rtl

# 2. Compilation des fichiers
# -sv indique que nous utilisons le SystemVerilog
echo "Compiling design..."
vlog -sv wave_generator.sv
vlog -sv demod.sv

echo "Compiling testbench..."
vlog -sv wave_generator_tb.sv
vlog -sv demod_tb.sv

# 3. Vérification du succès
if [ $? -eq 0 ]; then
    echo "----------------------------------------------------"
    echo " Compilation réussie !"
    echo " Pour lancer la simulation, tapez :"
    echo " vsim lib_rtl.wave_generator_tb"
    echo "----------------------------------------------------"
else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo " Erreur lors de la compilation. Vérifiez le log."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
