task automatic test_demod_wrapper_debug_fir_i();
begin
    $display("\n========== DEMOD WRAPPER TEST: DEBUG_FIR_I ==========");
    set_demod_config(CFG_DEBUG_FIR_I);

    drive_fir_sample(8'sd20);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_FIR_I");

    drive_fir_sample(-8'sd20);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_FIR_I");

    $display("========== DEMOD WRAPPER TEST DEBUG_FIR_I PASS ==========");
end
endtask
