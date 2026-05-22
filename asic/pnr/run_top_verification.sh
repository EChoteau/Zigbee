#!/usr/bin/env bash

set -e

if [ "$#" -ne 0 ]; then
    echo "Only for top module verification. No argument needed."
	echo "Not developed for other modules due to time constraints."
	echo "Usage: $0"
	exit 1
fi


echo "========================================"
echo "      RUNNING VERIFICATION FLOW         "
echo "========================================"
echo ""
echo "      FOR TOP LEVEL : zigbee_top     "
echo ""
echo "----------------------------------------"


echo "Clean previous results"
rm -rf asic/pnr/work_virtuoso
echo "Creating new work directory"
mkdir -p asic/pnr/work_virtuoso

SOURCE_FILE="asic/synth/top/netlist/zigbee_top_synth.v"
TARGET_FILE="asic/pnr/input_data/top/zigbee_top_synth.v"

if [ ! -f "$SOURCE_FILE" ]; then
	echo "Error: Source file '$SOURCE_FILE' not found."
	exit 1
fi

cp "$SOURCE_FILE" "$TARGET_FILE.tmp"
tr -d '\r' < "$TARGET_FILE.tmp" | sed -n '/module/,$p' > "$TARGET_FILE"
tr -d '\r' < "$TARGET_FILE.tmp" | awk 'found || /^[[:space:]]*module[[:space:]]/ { found=1; print }' > "$TARGET_FILE"
rm -f "$TARGET_FILE.tmp"

if [ -f "$TARGET_FILE" ]; then
	echo "Successfully copied and processed '$SOURCE_FILE' to '$TARGET_FILE'."
else
	echo "Error: Failed to copy and process '$SOURCE_FILE'."
	exit 1
fi

source ../../../config/bashrc_cdsic617_ams_410_isr15

#ams_cds -tech c35b4 -mode fb &
ams_cds -tech c35b4 -mode fb -execute "source ../scripts/pnr_verification.il" &