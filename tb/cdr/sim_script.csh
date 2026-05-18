#!/usr/bin/csh

if ($#argv < 1) then
    echo "Usage: $0 <testbench> [define]"
    exit 1
endif

set tb         = $1
set rtl_dir    = ../../rtl/cdr
set tb_dir     = ../../tb/cdr
set script_dir = `pwd`

vdel -all -lib work
vlib work
vmap work work

vlog -sv $tb_dir/cdr_tasks_pkg.sv
### specifique a la compile CDR. remplacer par votre code de compile et ajouter +cover
if ($#argv >= 2) then
    vlog -sv +cover $rtl_dir/*.sv -define $2 -define behaviour_model
else
    vlog -sv +cover $rtl_dir/*.sv -define behaviour_model
endif

vlog -sv `ls $tb_dir/*.sv | grep -v cdr_tasks_pkg`
### work.$tb specifique cdr remplacer par le votre
vsim -coverage -c \
     -voptargs="+cover=bcest +acc=npr" \
     work.$tb -L c35_CORELIB \
     -do $script_dir/run_cov.do

vcover report -code bcesft -details -file coverage_report.txt cov.ucdb
vcover report -html -code bcesft -cvg -directive -details=abcdefgst -htmldir html_coverage/ cov.ucdb
vcover report -totals -code bcesft cov.ucdb
