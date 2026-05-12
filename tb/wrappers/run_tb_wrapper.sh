#!/bin/bash
source config/config_RTL

set -euo pipefail

cd "$(dirname "$0")"

echo "Running interface TB..."
cd interface/
./run_interface_tb.sh
cd ..

echo "Running demod TB..."
cd demod/
./run_demod_tb.sh
cd ..

echo "Running CDR TB..."
cd cdr/
./run_cdr_tb.sh
cd ..

echo "All done."
