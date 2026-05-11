# 1. Nettoyage et création de la bibliothèque
vdel -all -lib work
vlib work
vmap work work

# 2. Compilation de TOUS les fichiers RTL (incluant le wrapper)
# Assure-toi que msk_test_wrapper.sv est bien dans ce dossier
vlog -sv ../../rtl/msk/*.sv ../../rtl/top/wrappers/msk_wrapper.sv -work work

# 3. Compilation du Testbench DU WRAPPER
# Si tu as créé un nouveau TB pour le wrapper, change le nom ici
vlog -sv wrapper_msk_tb.sv -work work

# 4. Lancement de la simulation
# On cible maintenant le testbench du wrapper
vsim -voptargs=+acc work.wrapper_msk_tb
