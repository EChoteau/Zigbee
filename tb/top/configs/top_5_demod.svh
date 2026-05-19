task automatic test_5_demod();
    begin
        $display("[%0t] test_5_demod - Setting DEMOD configuration", $time);
        // Apply reset with safe negedge timing
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 2);
        
        // Set top configuration to DEMOD mode (3'd5)
        tb_pkg::set_config_top(i_clk, i_top_cfg, 3'd5);
        repeat (2) @(posedge i_clk);

        // Run demod wrapper test plan
        run_demod_wrapper_test_plan();
    end
endtask
