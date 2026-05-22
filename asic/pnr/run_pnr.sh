#!/usr/bin/env bash



set -e

if [ "$#" -gt 1 ]; then
	echo "Usage: $0 <module>"
	echo "Example: $0 top"
	exit 1
fi

ARG="${1:-zigbee_top}"

case "$ARG" in
	msk|mod|1|modulation)
		MODULE="msk"
		;;
	demod|demodulation|2)
		MODULE="demod"
		;;
	cordic|co|3)
		MODULE="cordic"
		;;
	cdr|4)
		MODULE="cdr"
		;;
	interface|inter|fifo|5)
		MODULE="interface"
		;;
	zigbee_top|top|zigbee)
		MODULE="zigbee_top"
		;;
	*)
		MODULE="$ARG"
		;;
esac

echo ""
echo "========================================"
echo "           RUNNING PNR FLOW             "
echo "========================================"
echo ""
echo "       FOR LEVEL : $MODULE              "
echo ""
echo "----------------------------------------"


echo "Clean previous results"
rm -rf asic/pnr/work_innovus
echo "Creating new work directory"
mkdir -p asic/pnr/work_innovus

cd asic/pnr/work_innovus

echo "Sourcing config"
source ../../../config/config_ASIC

echo "Running Innovus for PNR"
innovus -batch -execute "set module_name $MODULE" -files ../scripts/flow.tcl


echo ""
echo ""
echo "========================================"
echo "                PNR END                 "
echo "========================================"

cd ../../../