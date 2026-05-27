task automatic test_3_interface();
    begin
        $display("[%0t] test_3_interface - Setting INTERFACE configuration", $time);
        // Apply reset with safe negedge timing
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 2);
        
        // Set top configuration to INTERFACE mode (3'd3)
        tb_pkg::set_config_top(i_clk, i_top_cfg, 3'd3);
        repeat (20) @(posedge i_clk);
        
        $display("[%0t] test_3_interface - INTERFACE configuration complete", $time);
        
        // Run interface wrapper test plan first
        run_interface_wrapper_test_plan(i_clk, i_rst_n, i_wrapper_cfg, i_bus_in, o_bus_out);
        
        // Then run interface block tests
        run_interface_test_plan_full(i_clk, i_rst_n, i_wrapper_cfg, i_bus_in, o_bus_out);
    end
endtask

