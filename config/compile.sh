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
    echo " vsim work.wave_generator_tb"
    echo "----------------------------------------------------"
else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo " Erreur lors de la compilation. Vérifiez le log."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
