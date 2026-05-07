task automatic test_7_cdr();
    begin
        $display("[%0t] test_7_cdr", $time);
        i_top_cfg = 3'd7;
        i_wrapper_cfg = 3'b000;
        i_rst_n = 0;
        repeat (2) @(posedge i_clk);
        i_rst_n = 1;
        repeat (20) @(posedge i_clk);
    end
endtask
