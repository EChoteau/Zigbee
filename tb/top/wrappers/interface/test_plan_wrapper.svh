////////////////////////////////////////////////////////////////////////////////
// test_plan_wrapper.svh
// ============================================================================
// Wrapper test plan - smoke/basic tests for interface_wrapper config 000
////////////////////////////////////////////////////////////////////////////////

task automatic run_test_plan_wrapper;
begin
    $display("[PLAN] Start wrapper config 000 test plan");

    // Test 1: Reset behavior
    apply_reset(5);
    run_tc_wrapper_reset();

    // Test 2: TX path nominal operation
    apply_reset(5);
    run_tc_wrapper_tx_path();

    // Test 3: Config 000 verification
    apply_reset(5);
    run_tc_wrapper_config_000();

    $display("[PLAN] Wrapper config 000 test plan PASS");
end
endtask
