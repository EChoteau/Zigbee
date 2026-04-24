
proc amsFillperi {} {
	##-- Add Peri Filler cells
	set fillerList {100_P 50_P 20_P 10_P 5_P 2_P 1_P 01_P}
	foreach fillcell $fillerList {
		addIoFiller -cell PERI_SPACER_$fillcell -prefix pfill
	}
}

setFillerMode -core {FILLANT1 FILLANT2 FILLANT5 FILLANT10 FILLANT25} -preserveUserOrder true

addFiller -cell FILL25 FILL10 FILL5 FILL2 FILL1 -prefix FILLER -fitGap

if {[info exists module_name] && $module_name eq "top"} {
	amsFillperi
}