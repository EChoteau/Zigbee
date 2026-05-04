task automatic test_4_demod();
    begin
        $display("[%0t] test_4_demod", $time);
        i_top_cfg = 3'd4;
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        i_wrapper_cfg = 3'b000;
        repeat (20) @(posedge clk);
    end
endtask
