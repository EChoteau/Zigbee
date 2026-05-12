`include "tb/wrappers/interface/headers/interface_wrapper_baud.svh"
`include "tb/wrappers/interface/headers/interface_wrapper_fifo_rx.svh"
`include "tb/wrappers/interface/headers/interface_wrapper_fifo_tx.svh"
`include "tb/wrappers/interface/headers/interface_wrapper_loopback.svh"
`include "tb/wrappers/interface/headers/interface_wrapper_rx_only.svh"
`include "tb/wrappers/interface/headers/interface_wrapper_serdes.svh"
`include "tb/wrappers/interface/headers/interface_wrapper_tx_only.svh"

task automatic run_interface_wrapper_test_plan();
begin
    test_interface_wrapper_tx_only();
    apply_reset(5);

    test_interface_wrapper_rx_only();
    apply_reset(5);

    test_interface_wrapper_loopback();
    apply_reset(5);

    test_interface_wrapper_fifo_tx();
    apply_reset(5);

    test_interface_wrapper_fifo_rx();
    apply_reset(5);

    test_interface_wrapper_serdes();
    apply_reset(5);

    test_interface_wrapper_baud();

    $display("\n========== ALL INTERFACE WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
end
endtask