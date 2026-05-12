task automatic test_4_msk();
    begin
        `include "tb/wrappers/msk/headers/msk_wrapper_normal.svh"
        `include "tb/wrappers/msk/headers/msk_wrapper_debug_enc.svh"
        `include "tb/wrappers/msk/headers/msk_wrapper_debug_demux.svh"
        `include "tb/wrappers/msk/headers/msk_wrapper_debug_shaping.svh"
        `include "tb/wrappers/msk/headers/msk_wrapper_debug_all.svh"
        `include "tb/wrappers/msk/headers/msk_wrapper_test_plan.svh"

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
