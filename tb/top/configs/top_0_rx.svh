task automatic test_0_rx();
    begin
        $display("[%0t] test_0_rx", $time);
        i_top_cfg = 3'd0; // Default RX
        i_wrapper_cfg = 3'b000;
        i_rst_n = 0;
        repeat (2) @(posedge i_clk);
        i_rst_n = 1;
        repeat (20) @(posedge i_clk);
    end
endtask
