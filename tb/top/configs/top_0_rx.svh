task automatic test_0_rx();
    begin
        $display("[%0t] test_0_rx", $time);
        i_top_cfg = 3'd0; // Default RX
        i_wrapper_cfg = 3'b000;
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        repeat (20) @(posedge clk);
    end
endtask
