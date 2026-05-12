// CDR Wrapper tests - include task definitions at module level
`include "tb/wrappers/cdr/headers/cdr_wrapper_normal.svh"
`include "tb/wrappers/cdr/headers/cdr_wrapper_debug_decision.svh"
`include "tb/wrappers/cdr/headers/cdr_wrapper_debug_pd.svh"
`include "tb/wrappers/cdr/headers/cdr_wrapper_debug_lf.svh"
`include "tb/wrappers/cdr/headers/cdr_wrapper_debug_nco.svh"
`include "tb/wrappers/cdr/headers/cdr_wrapper_test_plan.svh"

task automatic test_7_cdr();
    begin
        $display("[%0t] test_7_cdr", $time);
        i_top_cfg = 3'd7;
        i_wrapper_cfg = 3'b000;
        i_rst_n = 0;
        repeat (2) @(posedge i_clk);
        i_rst_n = 1;
        repeat (2) @(posedge i_clk);

        // Run CDR wrapper test plan
        run_cdr_wrapper_test_plan();
    end
endtask
