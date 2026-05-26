task automatic run_demod_wrapper_test_plan();
begin

    test_demod_wrapper_debug_demod();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_demod_wrapper_debug_fir();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_demod_wrapper_debug_chain();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_demod_wrapper_normal();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    $display("\n========== ALL DEMOD WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask