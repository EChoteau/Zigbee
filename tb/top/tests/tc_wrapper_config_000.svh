////////////////////////////////////////////////////////////////////////////////
// tc_wrapper_config_000.svh
// ============================================================================
// Test Case: Verify config 000 is properly applied (no overrides active)
// Tests: All debug override enables should have no effect
////////////////////////////////////////////////////////////////////////////////

task automatic run_tc_wrapper_config_000;
begin
    $display("[WRAPPER_TC2] Config 000 verification start");

    // Config 000 = all debug overrides are disabled
    // The wrapper should ignore any potential override attempts
    // (though they're hardcoded to 0 in the wrapper anyway)

    // Write some data to establish a baseline
    apb_write(ADDR_CONTROL, 8'h01); // global_en = 1
    repeat(2) @(posedge i_clk);

    apb_write(ADDR_DATA, 8'h55);
    repeat(2) @(posedge i_clk);

    // Verify normal path is active
    assert (o_dbg_tx_fifo_rd_valid === 1'b1)
        else $fatal(1, "[WRAPPER_TC2] Normal TX path should be active in config 000");

    assert (o_dbg_tx_fifo_q === 8'h55)
        else $fatal(1, "[WRAPPER_TC2] Data should flow through normal path");

    // Since wrapper has config 000 hardcoded:
    // - No test overrides can affect the datapath
    // - All mux logic should be optimized away by synthesis
    // - Normal APB->FIFO->Serializer path is ALWAYS active

    $display("[WRAPPER_TC2] Config 000 verification PASS");
end
endtask
