task automatic test_6_cordic();
    begin
        $display("[%0t] test_6_cordic - Setting CORDIC configuration", $time);
        // Apply reset with safe negedge timing
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 2);
        
        // Set top configuration to CORDIC mode (3'd6)
        tb_pkg::set_config_top(i_clk, i_top_cfg, 3'd6);
        repeat (20) @(posedge i_clk);
        
        // Run CORDIC wrapper test plan
        run_cordic_wrapper_test_plan(i_clk, i_rst_n, i_wrapper_cfg, i_bus_in, o_bus_out);

        $display("[%0t] test_6_cordic - CORDIC configuration complete", $time);
    end
endtask
