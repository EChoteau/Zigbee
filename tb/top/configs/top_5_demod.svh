task automatic test_5_demod();
    begin
        $display("[%0t] test_5_demod - Setting DEMOD configuration", $time);
        // Apply reset with safe negedge timing
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 2);

        // Set top configuration to DEMOD mode (3'd5)
        tb_pkg::set_config_top(i_clk, i_top_cfg, 3'd5);
        repeat (20) @(posedge i_clk);

        $display("[%0t] test_5_demod - DEMOD configuration complete", $time);

        // Run demod wrapper test plan first
        run_demod_wrapper_test_plan(i_clk, i_rst_n, i_wrapper_cfg, i_bus_in, o_bus_out, tb_i, tb_q);

        // Then run demod block tests
        run_demod_test_plan_full(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        $display("[%0t] test_5_demod - DEMOD tests completed", $time);
    end
endtask
