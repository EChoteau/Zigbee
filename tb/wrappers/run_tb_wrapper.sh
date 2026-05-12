#!/bin/bash
source config/config_RTL

set -euo pipefail

echo "Running interface TB..."
./tb/wrappers/interface/run_interface_tb.sh

echo "Running demod TB..."
./tb/wrappers/demod/run_demod_tb.sh

echo "Running CDR TB..."
./tb/wrappers/cdr/run_cdr_tb.sh

echo "Running MSK TB..."
./tb/wrappers/msk/run_msk_tb.sh

echo "All done."
