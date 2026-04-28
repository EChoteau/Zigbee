#!/usr/bin/env bash

set -e

if [ "$#" -gt 1 ]; then
	echo "Usage: $0 <module>"
	echo "Example: $0 top"
	exit 1
fi

MODULE="${1:-top}"

source config/config_ASIC

cd asic/pnr/output_data/$MODULE

# Launch Virtuoso with mask verification script
export MODULE_NAME=$MODULE
virtuoso -batch -nowin -execute "source ../../../scripts/mask_verification.il" &

sleep 2
echo "Virtuoso is running mask verification for module: $MODULE"
echo "Check output_data/$MODULE/verification/ for DRC and LVS reports"
