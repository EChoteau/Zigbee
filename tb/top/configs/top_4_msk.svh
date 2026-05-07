task automatic test_4_msk();
    begin
        $display("[%0t] test_4_msk", $time);
        i_top_cfg = 3'd4;
        i_wrapper_cfg = 3'b000;
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        // Wrapper tests goes here
        repeat (20) @(posedge clk);
    end
endtask
