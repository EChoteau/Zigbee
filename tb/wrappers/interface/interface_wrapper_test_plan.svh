task automatic run_interface_wrapper_test_plan();
begin
    test_interface_wrapper_classic();
    apply_reset(5);

    test_interface_wrapper_tx_only();
    apply_reset(5);

    test_interface_wrapper_rx_only();
    apply_reset(5);

    test_interface_wrapper_loopback();
    apply_reset(5);

    test_interface_wrapper_fifo_tx();
    apply_reset(5);

    test_interface_wrapper_fifo_rx();
    apply_reset(5);

    test_interface_wrapper_serdes();
    apply_reset(5);

    test_interface_wrapper_baud();

    $display("\n========== ALL INTERFACE WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask