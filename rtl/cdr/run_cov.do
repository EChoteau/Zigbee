# ---------------------------------------------------------------
# run_cov.do — Commandes de simulation pour QuestaSim
# Appelé par vsim via -do run_cov.do
# ---------------------------------------------------------------


# Lance la simulation jusqu'à $stop ou $finish
toggle add -full -r /*
run 20ms

# Sauvegarde le coverage
coverage save -directive -code bcesft -assert -cvg cov.ucdb
# Quitte sans confirmation
quit

