task automatic test_demod_wrapper_debug_fir_q();
begin
    $display("\n========== DEMOD WRAPPER TEST: DEBUG_FIR_Q ==========");
    set_demod_config(CFG_DEBUG_FIR_Q);

    drive_fir_sample(8'sd12);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_FIR_Q");

    drive_fir_sample(-8'sd12);
    wait_demod_cycles(3);
    expect_demod_bus_valid("DEBUG_FIR_Q");

    $display("========== DEMOD WRAPPER TEST DEBUG_FIR_Q PASS ==========");
end
endtask
