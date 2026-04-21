#!/usr/bin/env bash

set -e

if [ "$#" -gt 1 ]; then
	echo "Usage: $0 <module>"
	echo "Example: $0 top"
	exit 1
fi

MODULE="${1:-top}"

# Run the selected synthesis script
./asic/synth/"$MODULE"/script.sh

# Copy the generated netlist and SDF to the corresponding PNR input directory
cp asic/synth/"$MODULE"/netlist/"${MODULE}"_synth.v asic/pnr/input_data/"${MODULE}"_synth.v
#cp asic/synth/"$MODULE"/netlist/"${MODULE}"_synth.sdf asic/pnr/input_data/"${MODULE}"_synth.sdf

# Run the PNR script
./asic/pnr/run_pnr.sh "$MODULE"