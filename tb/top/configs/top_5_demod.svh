task automatic test_5_demod();
    begin
        // DEMOD Wrapper tests
        `include "tb/wrappers/demod/headers/demod_wrapper_normal.svh"
        `include "tb/wrappers/demod/headers/demod_wrapper_debug_demod.svh"
        `include "tb/wrappers/demod/headers/demod_wrapper_debug_fir.svh"
        `include "tb/wrappers/demod/headers/demod_wrapper_debug_chain.svh"
        `include "tb/wrappers/demod/headers/demod_wrapper_test_plan.svh"

        $display("[%0t] test_5_demod", $time);
        i_top_cfg = 3'd5;
        i_wrapper_cfg = 3'b000;
        i_rst_n = 0;
        repeat (2) @(posedge i_clk);
        i_rst_n = 1;
        repeat (2) @(posedge i_clk);

        // Run demod wrapper test plan
        run_demod_wrapper_test_plan();
    end
endtask
