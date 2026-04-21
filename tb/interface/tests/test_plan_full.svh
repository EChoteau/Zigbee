task automatic run_test_plan_full;
begin
    $display("[PLAN] Start full interface plan");

    apply_reset(5);
    run_tc_t0_baud_gen_only();

    apply_reset(5);
    run_tc_t0_baud_gen_edges();

    apply_reset(5);
    run_tc_u_fifo_basic();

    apply_reset(5);
    run_tc_u_fifo_full();

    apply_reset(5);
    run_tc_u_fifo_edges();

    apply_reset(5);
    run_tc_u_serializer_basic();

    apply_reset(5);
    run_tc_u_serializer_edges();

    apply_reset(5);
    run_tc_u_deserializer_basic();

    apply_reset(5);
    run_tc_u_deserializer_edges();

    apply_reset(5);
    run_tc_t0_reset_smoke();

    apply_reset(5);
    run_tc_t1_apb_regs();

    apply_reset(5);
    run_tc_t2_tx_nominal();

    apply_reset(5);
    run_tc_t3_rx_nominal();

    apply_reset(5);
    run_tc_t4_interface_errors();

    apply_reset(5);
    run_tc_stress_tx_rx_noreset();

    $display("[PLAN] Full interface plan PASS");
end
endtask
