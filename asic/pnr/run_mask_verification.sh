#!/usr/bin/env bash

set -e

if [ "$#" -gt 1 ]; then
	echo "Usage: $0 <module>"
	echo "Example: $0 top"
	exit 1
fi

MODULE="${1:-top}"

source config/bashrc_cdsic617_ams_410_isr15

cd asic/pnr/work_virtuoso

# Launch Virtuoso with mask verification script
export MODULE_NAME=$MODULE
amsc35b4
#virtuoso -batch -nowin -execute "source ../scripts/mask_verification.il" &