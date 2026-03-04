task automatic run_test_plan_smoke;
begin
    $display("[PLAN] Start smoke/basic plan");

    apply_reset(5);
    run_tc_t0_baud_gen_only();

    apply_reset(5);
    run_tc_t0_reset_smoke();

    apply_reset(5);
    run_tc_t1_apb_regs();

    apply_reset(5);
    run_tc_t2_tx_nominal();

    apply_reset(5);
    run_tc_t3_rx_nominal();

    $display("[PLAN] Smoke/basic plan PASS");
end
endtask
