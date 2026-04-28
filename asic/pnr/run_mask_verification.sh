#!/usr/bin/env bash

set -e

if [ "$#" -gt 1 ]; then
	echo "Usage: $0 <module>"
	echo "Example: $0 top"
	exit 1
fi

MODULE="${1:-top}"

cd asic/pnr/work_virtuoso

source ../../../config/bashrc_cdsic617_ams_410_isr15

# Launch Virtuoso with mask verification script
export MODULE_NAME=$MODULE
#ams_cds -tech c35b4 -mode fb &
ams_cds -tech c35b4 -mode fb -execute "source ../scripts/mask_verification.il" &
#virtuoso -batch -nowin -execute "source ../scripts/mask_verification.il" &