task automatic run_interface_wrapper_test_plan();
begin
    test_interface_wrapper_tx_only();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_interface_wrapper_rx_only();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_interface_wrapper_loopback();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_interface_wrapper_fifo_tx();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_interface_wrapper_fifo_rx();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_interface_wrapper_serdes();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_interface_wrapper_baud();

    $display("\n========== ALL INTERFACE WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask