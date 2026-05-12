task automatic test_3_interface();
    begin
        // INTERFACE Wrapper tests
        `include "tb/wrappers/interface/headers/interface_wrapper_baud.svh"
        `include "tb/wrappers/interface/headers/interface_wrapper_fifo_rx.svh"
        `include "tb/wrappers/interface/headers/interface_wrapper_fifo_tx.svh"
        `include "tb/wrappers/interface/headers/interface_wrapper_loopback.svh"
        `include "tb/wrappers/interface/headers/interface_wrapper_rx_only.svh"
        `include "tb/wrappers/interface/headers/interface_wrapper_serdes.svh"
        `include "tb/wrappers/interface/headers/interface_wrapper_tx_only.svh"
        `include "tb/wrappers/interface/headers/interface_wrapper_test_plan.svh"

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
