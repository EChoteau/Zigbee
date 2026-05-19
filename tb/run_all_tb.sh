#!/bin/bash
# =====================================================
# Master Testbench Script - Run All Testbenches
# Run from project root: ./tb/run_all_tb.sh
# =====================================================

source config/config_RTL

set -u  # Exit on undefined variables, but allow commands to fail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
passed=0
failed=0
failed_tests=""

echo "======================================================"
echo "Running All Testbenches"
echo "======================================================"
echo ""

# Function to run a testbench
run_test() {
    local name=$1
    local script=$2
    
    echo -e "${YELLOW}[TEST] $name${NC}"
    # Run script and capture exit code without exiting on failure
    if $script 2>&1; then
        echo -e "${GREEN}✓ PASSED: $name${NC}"
        ((passed++)) || true
    else
        local exit_code=$?
        echo -e "${RED}✗ FAILED: $name (exit code: $exit_code)${NC}"
        ((failed++)) || true
        failed_tests="$failed_tests\n  - $name (exit code: $exit_code)"
    fi
    echo ""
}

# Run all testbenches
run_test "CORDIC" "./tb/cordic/script"
run_test "MSK RTL" "./tb/msk/run_simu_rtl.sh"
run_test "DEMOD Compile" "./tb/demod/compile.sh"
run_test "DEMOD Compile All" "./tb/demod/compile_all.sh"
#run_test "CDR" "./tb/cdr/sim_script.sh"
run_test "INTERFACE" "./tb/interface/script/script1.sh"
run_test "Wrapper INTERFACE" "./tb/wrappers/interface/run_interface_tb.sh"
run_test "Wrapper CDR" "./tb/wrappers/cdr/run_cdr_tb.sh"
run_test "Wrapper MSK" "./tb/wrappers/msk/run_msk_tb.sh"
run_test "Wrapper DEMOD" "./tb/wrappers/demod/run_demod_tb.sh"
#run_test "Wrapper CORDIC" "./tb/wrappers/cordic/run_cordic_tb.sh"
run_test "Wrappers All" "./tb/wrappers/run_tb_wrapper.sh"
run_test "TOP" "./tb/top/run_tb_top.sh"

# Summary
echo "======================================================"
echo "Test Summary"
echo "======================================================"
echo -e "Total Passed: ${GREEN}$passed${NC}"
echo -e "Total Failed: ${RED}$failed${NC}"

if [ $failed -gt 0 ]; then
    echo -e "\n${RED}Failed Tests:${NC}$failed_tests"
    exit 1
else
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
fi
