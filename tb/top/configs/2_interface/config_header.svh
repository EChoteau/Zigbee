task automatic test_2_interface();
    begin
        $display("[%0t] test_2_interface", $time);
        i_top_cfg = 3'd2;
        i_wrapper_cfg = 3'b000;
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        repeat (20) @(posedge clk);
    end
endtask
