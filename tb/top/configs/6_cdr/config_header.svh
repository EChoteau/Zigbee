task automatic test_6_cdr();
    begin
        $display("[%0t] test_6_cdr", $time);
        i_top_cfg = 3'd6;
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        i_wrapper_cfg = 3'b000;
        repeat (20) @(posedge clk);
    end
endtask
