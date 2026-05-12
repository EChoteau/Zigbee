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

source config/config_ASIC

cd asic/pnr/work_virtuoso

innovus -batch -execute "set module_name $MODULE" -files ../scripts/flow.tcl
