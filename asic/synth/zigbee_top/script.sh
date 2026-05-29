## SCRIPT SYNTHESIS
#
# To run this script
# Be in Zigbee root directory and run :
# $ source asic/synth/top/script.sh
#
# This script will run the synthesis of the top level design (zigbee_top.sv) using design_vision.

echo ""
echo "========================================"
echo "           RUNNING SYNTHESIS            "
echo "========================================"
echo ""
echo "      FOR TOP LEVEL : zigbee_top.sv     "
echo ""
echo "----------------------------------------"


source config/config_ASIC
cd asic/synth/zigbee_top

#Clean previous results
rm -rf reports
rm -rf netlist
rm -rf work
mkdir reports
mkdir netlist
mkdir work

cd work

#Run design_vision for synthesis
dc_shell -f ../synth.tcl < /dev/null | tee log_synthese.log

echo ""
echo ""
echo "========================================"
echo "            SYNTHESIS SUMMARY           "
echo "========================================"

# Count errors and warnings in the log file
NB_ERRORS=$(grep -i -c "error:" log_synthese.log)
NB_WARNINGS=$(grep -i -c "warning:" log_synthese.log)
NB_UNREFERENCES=$(grep -i -c "unresolved references" log_synthese.log)

if [ "$NB_ERRORS" -gt 0 ]; then
    # \e[41m = red background, \e[97m = white text, \e[0m = reset
    echo -e "                \e[41m\e[97m FAIL \e[0m"
    echo ""
    
    # Extract blocks from the command to the end of the log
    # Design vision is on stop on fail so the log ends shortly after the error
    BLOCK_COMPILE=$(sed -n '/compile_ultra/,$p' log_synthese.log)
    BLOCK_ANALYZE=$(sed -n '/analyze -library/,$p' log_synthese.log)
    BLOCK_ELABORATE=$(sed -n '/elaborate zigbee_top/,$p' log_synthese.log)

    # Check in reverse chronological order
    if [ -n "$BLOCK_COMPILE" ] && echo "$BLOCK_COMPILE" | grep -i -q "error:"; then
        # \e[100m = gray background, \e[97m = white text, \e[0m = reset
        echo -e "=> Error located in phase : \e[100m\e[97m compile_ultra \e[0m"
        # Display the details :
        echo "First errors (4 rows):"
        echo "$BLOCK_COMPILE" | grep -i -B 1 "error:" | head -n 4

    elif [ -n "$BLOCK_ELABORATE" ] && echo "$BLOCK_ELABORATE" | grep -i -q "error:"; then
        # \e[100m = gray background, \e[97m = white text, \e[0m = reset
        echo -e"=> Error located in phase : \e[100m\e[97m elaborate \e[0m"
        # Display the details :
        echo "First errors (4 rows):"
        echo "$BLOCK_ELABORATE" | grep -i -B 1 "error:" | head -n 4
        
    elif [ -n "$BLOCK_ANALYZE" ] && echo "$BLOCK_ANALYZE" | grep -i -q "error:"; then
        # \e[100m = gray background, \e[97m = white text, \e[0m = reset
        echo -e "=> Error located in phase : \e[100m\e[97m analyze \e[0m"
        # Display the details :
        echo "First errors (4 rows):"
        echo "$BLOCK_ANALYZE" | grep -i -B 1 "error:" | head -n 4
    else
        echo -e "=> Error phase not dynamically identified. See the complete log."
    fi
else
    
    if [ "$NB_UNREFERENCES" -gt 0 ]; then
        # \e[43m = yellow background, \e[97m = white text, \e[0m = reset
        echo -e "                \e[43m\e[97m DONE WITH UNREFERENCED \e[0m"
    else
        # \e[42m = green background, \e[97m = white text, \e[0m = reset
        echo -e "                \e[42m\e[97m DONE \e[0m"
    fi
fi

echo "----------------------------------------"
echo -e " Total Errors   : $NB_ERRORS"
echo -e " Total Warnings : $NB_WARNINGS"
echo "========================================"

cd ../../../../
