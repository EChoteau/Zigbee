current_design interface_top
ungroup -all -flatten
set_operating_conditions -library c35_CORELIB_TYP TYPICAL
set_max_area 0
compile -exact_map -area_effort low -power_effort high -gate_clock

