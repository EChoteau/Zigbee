task automatic test_demod_wrapper_debug_demod_i();
begin
    $display("\n========== DEMOD WRAPPER TEST: DEBUG_DEMOD_I ==========");
    set_demod_config(CFG_DEBUG_DEMOD_I);

    drive_debug_iq_sample(4'hA, 4'h5);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_DEMOD_I");

    drive_debug_iq_sample(4'h0, 4'hF);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_DEMOD_I");

    $display("========== DEMOD WRAPPER TEST DEBUG_DEMOD_I PASS ==========");
end
endtask
