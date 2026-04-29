////////////////////////////////////////////////////////////////////////////////
// tc_wrapper_reset.svh
// ============================================================================
// Test Case: Verify wrapper reset behavior in config 000
////////////////////////////////////////////////////////////////////////////////

task automatic run_tc_wrapper_reset;
begin
    $display("[WRAPPER_TC0] Reset test start");

    // After reset, check all signals are in safe state
    assert (o_pready === 1'b1)
        else $fatal(1, "[WRAPPER_TC0] o_pready should be 1 after reset");

    assert (o_pslverr === 1'b0)
        else $fatal(1, "[WRAPPER_TC0] o_pslverr should be 0 after reset");

    assert (o_tx_valid === 1'b0)
        else $fatal(1, "[WRAPPER_TC0] o_tx_valid should be 0 after reset");

    assert (o_dbg_tx_fifo_empty === 1'b1)
        else $fatal(1, "[WRAPPER_TC0] TX FIFO should be empty after reset");

    assert (o_dbg_rx_fifo_empty === 1'b1)
        else $fatal(1, "[WRAPPER_TC0] RX FIFO should be empty after reset");

    $display("[WRAPPER_TC0] Reset test PASS");
end
endtask
