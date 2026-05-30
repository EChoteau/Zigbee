# ==============================================================================
# INSERTION DES CELLULES DE REMPLISSAGE
# AMS C35B4C3 - Innovus
# ==============================================================================


# Fillers core (avec antennes pour les règles DRC AMS)
setFillerMode -core {FILLANT1 FILLANT2 FILLANT5 FILLANT10 FILLANT25} -preserveUserOrder true
addFiller -cell {FILL25 FILL10 FILL5 FILL2 FILL1} -prefix FILLER -fitGap

# Fillers périphérie IO (uniquement pour le top avec ring IO)
if {$module_name eq "zigbee_top"} {
    addIoFiller \
        -cell {PERI_SPACER_100_P PERI_SPACER_50_P PERI_SPACER_20_P PERI_SPACER_10_P \
               PERI_SPACER_5_P  PERI_SPACER_2_P  PERI_SPACER_1_P  PERI_SPACER_01_P} \
        -prefix pfill
}