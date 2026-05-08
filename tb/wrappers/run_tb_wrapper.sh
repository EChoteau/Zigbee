#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Running interface TB..."
cd interface/
source run_interface_tb.sh
cd ..

echo "Running demod TB..."
cd demod/
source run_demod_tb.sh
cd ..

echo "All done."
