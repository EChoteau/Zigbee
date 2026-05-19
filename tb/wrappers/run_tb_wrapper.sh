#!/bin/bash
# =====================================================
# Master Testbench: All Wrappers
# Run from project root: ./tb/wrappers/run_tb_wrapper.sh
# =====================================================

source config/config_RTL

set -u

echo "Running interface TB..."
./tb/wrappers/interface/run_interface_tb.sh

echo "Running demod TB..."
./tb/wrappers/demod/run_demod_tb.sh

echo "Running CDR TB..."
./tb/wrappers/cdr/run_cdr_tb.sh

echo "Running MSK TB..."
./tb/wrappers/msk/run_msk_tb.sh

echo "All done."
