#!/usr/bin/csh

# ==============================================================
# sim_coverage.csh
# Usage: ./sim_coverage.csh <testbench>
# ==============================================================

if ($#argv < 1) then
    echo "Usage: $0 <testbench>"
    exit 1
endif

set tb      = $1
set rtl_dir = ../../rtl/cdr
set tb_dir  = ../../tb/cdr
set script_dir = `pwd`   # Répertoire courant pour trouver run_cov.do

# ==============================================================
# 1. NETTOYAGE
# ==============================================================
echo "--- Nettoyage ---"
vdel -all -lib work
vlib work
vmap work work

# ==============================================================
# 2. COMPILATION
# ==============================================================
vlog -sv $tb_dir/cdr_tasks_pkg.sv

if ($#argv >= 2) then
    vlog -sv $rtl_dir/*.sv -define $2 -define behaviour_model
else
    vlog -sv $rtl_dir/*.sv -define behaviour_model
endif

vlog -sv `ls $tb_dir/*.sv | grep -v cdr_tasks_pkg`

# ==============================================================
# 3. SIMULATION
#    -c               : mode batch (sans GUI)
#    -coverage        : active la collecte
#    +acc=npr         : garde la hiérarchie (pas de flatten)
#    -do run_cov.do   : fichier de commandes séparé
# ==============================================================
vopt +cover=bces+t work.$tb -o ${tb}_cov \
     +acc=npr -L c35_CORELIB

vsim -coverage work.${tb}_cov \
     -do $script_dir/run_cov.do

# ==============================================================
# 4. RAPPORTS
# ==============================================================
echo "--- Génération des rapports ---"
vcover report -details -code bces -file coverage_report.txt cov.ucdb
vcover report -html -htmldir html_coverage/ cov.ucdb
vcover report -totals -code bces cov.ucdb
