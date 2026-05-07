task automatic test_1_tx();
    begin
        $display("[%0t] test_1_tx", $time);
        i_top_cfg = 3'd1; // Default TX
        i_wrapper_cfg = 3'b001;
        i_rst_n = 0;
        repeat (2) @(posedge i_clk);
        i_rst_n = 1;
        repeat (20) @(posedge i_clk);
    end
endtask
