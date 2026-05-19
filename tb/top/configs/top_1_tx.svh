task automatic test_1_tx();
    begin
        $display("[%0t] test_1_tx - Setting TX configuration", $time);
        // Apply reset with safe negedge timing
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 2);
        
        // Set top configuration to TX mode (3'd1)
        tb_pkg::set_config_top(i_clk, i_top_cfg, 3'd1);
        repeat (20) @(posedge i_clk);
        
        // TODO: Test wrapper config setup from top level
        $display("[%0t] test_1_tx - TX configuration complete", $time);
    end
endtask
