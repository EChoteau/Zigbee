#!/usr/bin/env bash

set -e

if [ "$#" -gt 1 ]; then
	echo "Usage: $0 <module>"
	echo "Example: $0 top"
	exit 1
fi

MODULE="${1:-top}"

source config/config_ASIC

cd asic/pnr/work

innovus -batch -execute "set module_name $MODULE" -files ../scripts/flow.tcl
