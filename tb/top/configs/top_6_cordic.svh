task automatic test_6_cordic();
    begin
        $display("[%0t] test_6_cordic", $time);
        i_top_cfg = 3'd6;
        i_wrapper_cfg = 3'b000;
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        repeat (20) @(posedge clk);
    end
endtask
