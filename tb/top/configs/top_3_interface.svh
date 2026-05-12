// INTERFACE Wrapper tests - include task definitions at module level
`include "tb/wrappers/interface/headers/interface_wrapper_test_plan.svh"

task automatic test_3_interface();
    begin
        $display("[%0t] test_3_interface", $time);
        i_top_cfg = 3'd3;
        i_wrapper_cfg = 3'b000;
        i_rst_n = 0;
        repeat (2) @(posedge i_clk);
        i_rst_n = 1;
        repeat (2) @(posedge i_clk);

        // Run interface wrapper test plan
        run_interface_wrapper_test_plan();
    end
endtask
