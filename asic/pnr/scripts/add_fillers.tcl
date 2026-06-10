
proc amsFillperi {} {
	##-- Add Peri Filler cells
	set fillerList {100_P 50_P 20_P 10_P 5_P 2_P 1_P 01_P}
	set cellNames {}
	foreach size $fillerList {
		lappend cellNames "PERI_SPACER_$size"
	}
	addIoFiller -cell $cellNames -prefix pfill
}

setFillerMode -core {FILLANT1 FILLANT2 FILLANT5 FILLANT10 FILLANT25} -preserveUserOrder true

addFiller -cell FILL25 FILL10 FILL5 FILL2 FILL1 -prefix FILLER -fitGap

if {[info exists module_name] && $module_name eq "zigbee_top"} {
	amsFillperi
}

# Metal fill pour respecter les règles de densité AMS
setMetalFill -layer MET2 \
    -honorLefValue
    -windowSize 100 100 -windowStep 50 50 \
    -minWidth 0.8 -maxWidth 2 -minLength 1 -maxLength 20 \
    -activeSpacing 0.8 -gapSpacing 1
addMetalFill -layer {MET2}