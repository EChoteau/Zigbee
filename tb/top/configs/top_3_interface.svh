`include "tb/wrappers/interface/test_plan_wrapper.svh"

task automatic test_3_interface();
    begin
        $display("[%0t] test_3_interface", $time);
        i_top_cfg = 3'd3;
        i_wrapper_cfg = 3'b000;
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        repeat (20) @(posedge clk);

        // Invoke the interface wrapper test plan for wrapper config 000
        run_test_plan_wrapper();
    end
endtask
