task automatic test_2_internal();
    begin
        $display("[%0t] test_2_internal - Setting INTERNAL configuration", $time);        
        // Apply reset with safe negedge timing
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 2);
        
        // Set top configuration to INTERNAL mode (3'd2)
        tb_pkg::set_config_top(i_clk, i_top_cfg, 3'd2);
        repeat (20) @(posedge i_clk);
        
        // TODO: Test wrapper config setup from top level
        $display("[%0t] test_2_internal - INTERNAL configuration complete", $time);
    end
endtask
