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


SOURCE_FILE="asic/synth/zigbee_top/netlist/zigbee_top_synth.v"
TARGET_FILE="asic/pnr/input_data/zigbee_top/zigbee_top_synth.v"

if [ ! -f "$SOURCE_FILE" ]; then
	echo "Error: Source file '$SOURCE_FILE' not found."
	exit 1
fi

cp "$SOURCE_FILE" "$TARGET_FILE.tmp"
tr -d '\r' < "$TARGET_FILE.tmp" | awk 'found || /^[[:space:]]*module[[:space:]]/ { found=1; print }' > "$TARGET_FILE"
rm -f "$TARGET_FILE.tmp"

if [ -f "$TARGET_FILE" ]; then
	echo "Successfully copied and processed '$SOURCE_FILE' to '$TARGET_FILE'."
else
	echo "Error: Failed to copy and process '$SOURCE_FILE'."
	exit 1
fi

cd asic/pnr/work_virtuoso

source ../../../config/bashrc_cdsic617_ams_410_isr15

#echo "exactProcessOption C35B4C3" > .amsenv
#
## DRC runset for Calibre
#echo "*DRC Rules File creation"
#cat << 'EOF' > .calibreDrcRunset
#*drcRulesFile: $AMS_DIR/calibre/c35b4/c35b4c3.rules
#*drcIncludeSVRFCmds: 1
#*drcSVRFCmds: {#DEFINE NO_METRES}
#*cmnVConnectNamesState: ALL
#*cmnVConnectReport: 1
#EOF
#
##LVS runset for Calibre
#echo "*LVS Rules File creation"
#cat << 'EOF' > .calibreLvsRunset
#*lvsRulesFile: $AMS_DIR/calibre/c35b4/c35b4c3.rules
#*pexRulesFile: $AMS_DIR/calibre/c35b4/c35b4c3.rules
#*cmnPreTrigger: $AMS_DIR/programs/bin/rewrite_cal_netlist %s
#EOF
#
##PERC runset for Calibre
#echo "*PERC Rules File creation"
#cat << 'EOF' > .calibrePercRunset
#*percRulesFile: 
#*percSourceGetFromViewer: 1
#*percPercInput: SOURCENETLIST
#*percReportMaximumAll: 1
#*percReportOptions: NO_NET_TYPE
#*percEnvVars: {KV 2 Runset}
#*cmnTemplate_RN: CALIBRE/%l/PERC/SCHEMA
#*cmnPreTrigger: $AMS_DIR/programs/bin/rewrite_cal_netlist -perc %s
#*cmnShowOptions: 1
#*cmnRunHier: 0
#EOF

echo "Run Calibre for DRC and LVS"

ams_cds -tech c35b4 -mode fb -nologo
#ams_cds -tech c35b4 -mode fb -execute "source ../scripts/pnr_verification.il" &

cd ../../../