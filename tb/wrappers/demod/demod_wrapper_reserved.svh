task automatic test_demod_wrapper_reserved();
begin
    $display("\n========== DEMOD WRAPPER TEST: RESERVED ==========");
    set_demod_config(CFG_RESERVED);

    drive_normal_sample(4'hF, 4'h0);
    wait_demod_cycles(2);
    expect_demod_bus_zero("RESERVED");

    drive_debug_iq_sample(4'hA, 4'h5);
    wait_demod_cycles(2);
    expect_demod_bus_zero("RESERVED");

    $display("========== DEMOD WRAPPER TEST RESERVED PASS ==========");
end
endtask
