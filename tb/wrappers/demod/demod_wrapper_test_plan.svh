task automatic run_demod_wrapper_test_plan();
begin
    test_demod_wrapper_normal();
    apply_demod_reset(3);

    test_demod_wrapper_debug_demod_i();
    apply_demod_reset(3);

    test_demod_wrapper_debug_demod_q();
    apply_demod_reset(3);

    test_demod_wrapper_reserved();
    apply_demod_reset(3);

    test_demod_wrapper_debug_fir_i();
    apply_demod_reset(3);

    test_demod_wrapper_debug_fir_q();
    apply_demod_reset(3);

    test_demod_wrapper_debug_firc_i();
    apply_demod_reset(3);

    test_demod_wrapper_debug_firc_q();

    $display("\n========== ALL DEMOD WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask