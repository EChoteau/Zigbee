task automatic run_cdr_wrapper_test_plan();
begin

    test_cdr_wrapper_debug_decision();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_cdr_wrapper_debug_lf();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_cdr_wrapper_debug_nco();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_cdr_wrapper_debug_pd();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_cdr_wrapper_normal();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    $display("\n========== ALL CDR WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask