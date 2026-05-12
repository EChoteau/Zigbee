task automatic run_msk_wrapper_test_plan();
begin
    test_msk_wrapper_debug_shaping();
    apply_reset(5);

    test_msk_wrapper_debug_enc();
    apply_reset(5);

    test_msk_wrapper_debug_all();
    apply_reset(5);

    test_msk_wrapper_debug_demux();
    apply_reset(5);

    test_msk_wrapper_normal();
    apply_reset(5);

    $display("\n========== ALL INTERFACE WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask