// MSK Wrapper tests - include task definitions at module level
`include "tb/wrappers/msk/headers/msk_wrapper_test_plan.svh"

task automatic test_4_msk();
    begin
        $display("[%0t] test_4_msk", $time);
        i_top_cfg = 3'd4;
        i_wrapper_cfg = 3'b000;
        i_rst_n = 0;
        repeat (2) @(posedge i_clk);
        i_rst_n = 1;
        repeat (2) @(posedge i_clk);

        // Run MSK wrapper test plan
        run_msk_wrapper_test_plan();
    end
endtask
