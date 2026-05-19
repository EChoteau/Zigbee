task automatic test_0_rx();
    begin
        $display("[%0t] test_0_rx - Setting RX configuration", $time);
        // Apply reset with safe negedge timing
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 2);
        
        // Set top configuration to RX mode (3'd0)
        tb_pkg::set_config_top(i_clk, i_top_cfg, 3'd0);
        repeat (20) @(posedge i_clk);
        
        // TODO: Test wrapper config setup from top level
        $display("[%0t] test_0_rx - RX configuration complete", $time);
    end
endtask
