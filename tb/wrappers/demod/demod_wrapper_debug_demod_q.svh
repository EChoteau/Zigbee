task automatic test_demod_wrapper_debug_demod_q();
begin
    $display("\n========== DEMOD WRAPPER TEST: DEBUG_DEMOD_Q ==========");
    set_demod_config(CFG_DEBUG_DEMOD_Q);

    drive_debug_iq_sample(4'h3, 4'hC);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_DEMOD_Q");

    drive_debug_iq_sample(4'hF, 4'h0);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_DEMOD_Q");

    $display("========== DEMOD WRAPPER TEST DEBUG_DEMOD_Q PASS ==========");
end
endtask
