#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Running interface TB..."
source ./interface/run_interface_tb.sh

echo "Running demod TB..."
source ./demod/run_demod_tb.sh

echo "All done."
