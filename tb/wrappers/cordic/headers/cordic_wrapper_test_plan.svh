task automatic run_cordic_wrapper_test_plan();
begin
    test_cordic_wrapper_debug_cordic();
    apply_reset(3);

    test_cordic_wrapper_debug_deriv();
    apply_reset(3);

    test_cordic_wrapper_debug_filter();
    apply_reset(3);

    test_cordic_wrapper_normal();
    apply_reset(3);

    $display("\n========== ALL CORDIC WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask