task automatic test_4_msk();
    begin
        $display("[%0t] test_4_msk - Setting MSK configuration", $time);
        // Apply reset with safe negedge timing
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 2);
        
        // Set top configuration to MSK mode (3'd4)
        tb_pkg::set_config_top(i_clk, i_top_cfg, 3'd4);
        repeat (2) @(posedge i_clk);

        $display("[%0t] test_4_msk - MSK configuration complete", $time);

        // Run MSK wrapper test plan
        run_msk_wrapper_test_plan(i_clk, i_rst_n, i_wrapper_cfg, i_bus_in, o_bus_out);

        // Run MSK top-level test plan
        run_msk_test_plan_full(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        $display("[%0t] test_4_msk - MSK tests complete", $time);
    end
endtask
