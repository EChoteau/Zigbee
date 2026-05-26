task automatic run_msk_wrapper_test_plan();
begin
    test_msk_wrapper_debug_shaping();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_msk_wrapper_debug_enc();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_msk_wrapper_debug_all();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_msk_wrapper_debug_demux();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    test_msk_wrapper_normal();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

    $display("\n========== ALL INTERFACE WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask