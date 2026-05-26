task automatic run_cordic_wrapper_test_plan();
begin
    test_cordic_wrapper_debug_cordic();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_cordic_wrapper_debug_deriv();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_cordic_wrapper_debug_filter();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    test_cordic_wrapper_normal();
    tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

    $display("\n========== ALL CORDIC WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask