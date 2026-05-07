task automatic test_demod_wrapper_debug_firc_i();
begin
    $display("\n========== DEMOD WRAPPER TEST: DEBUG_FIRC_I ==========");
    set_demod_config(CFG_DEBUG_FIRC_I);

    drive_debug_iq_sample(4'h9, 4'h1);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_FIRC_I");

    drive_debug_iq_sample(4'h2, 4'hE);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_FIRC_I");

    $display("========== DEMOD WRAPPER TEST DEBUG_FIRC_I PASS ==========");
end
endtask
