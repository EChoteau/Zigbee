task automatic test_7_cdr();
    begin
        $display("[%0t] test_7_cdr - Setting CDR configuration", $time);
        // Apply reset with safe negedge timing
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 2);
        
        // Set top configuration to CDR mode (3'd7)
        tb_pkg::set_config_top(i_clk, i_top_cfg, 3'd7);
        repeat (2) @(posedge i_clk);

        // Run CDR wrapper test plan
        run_cdr_wrapper_test_plan(i_clk, i_rst_n, i_wrapper_cfg, i_bus_in, o_bus_out);
    end
endtask
