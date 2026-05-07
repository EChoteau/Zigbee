task automatic test_demod_wrapper_debug_firc_q();
begin
    $display("\n========== DEMOD WRAPPER TEST: DEBUG_FIRC_Q ==========");
    set_demod_config(CFG_DEBUG_FIRC_Q);

    drive_debug_iq_sample(4'h6, 4'h9);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_FIRC_Q");

    drive_debug_iq_sample(4'hB, 4'h4);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_FIRC_Q");

    $display("========== DEMOD WRAPPER TEST DEBUG_FIRC_Q PASS ==========");
end
endtask
