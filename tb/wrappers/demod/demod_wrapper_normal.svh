task automatic test_demod_wrapper_normal();
begin
    $display("\n========== DEMOD WRAPPER TEST: NORMAL ==========");
    set_demod_config(CFG_NORMAL);

    drive_normal_sample(4'd15, 4'd8);
    wait_demod_cycles(3);
    expect_demod_bus_valid("NORMAL");

    drive_normal_sample(4'd8, 4'd15);
    wait_demod_cycles(3);
    expect_demod_bus_valid("NORMAL");

    assert (i_cfg_local == CFG_NORMAL)
        else $fatal(1, "[NORMAL] config mismatch");

    $display("========== DEMOD WRAPPER TEST NORMAL PASS ==========");
end
endtask
