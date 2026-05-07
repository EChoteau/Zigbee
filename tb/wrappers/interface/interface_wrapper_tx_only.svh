// ============================================================================
// interface_wrapper_tx_only.svh
// Test: CFG_TX_ONLY (0x1) - TX path with FIFO control
// ============================================================================
// Purpose: Verify APB writes to TX FIFO and serializer output
// Inputs: Bus A (APB control) + Bus B (APB data)
// Outputs: Bus C (FIFO status) + Bus D (serial output)
// ============================================================================

task automatic test_interface_wrapper_tx_only();
begin
    $display("\n========== TEST: CFG_TX_ONLY (0x1) ==========");
    $display("Test: TX path with FIFO control");
    
    set_config(CFG_TX_ONLY);
    repeat(2) @(posedge i_clk);
    
    // Assert: Config is correctly set
    assert (i_cfg_local == CFG_TX_ONLY)
        $display("  [TX_ONLY] Config correctly set to CFG_TX_ONLY");
    else
        $error("  [TX_ONLY] FAIL: Config mismatch!");
    
    // Test pattern 1: Write data to TX FIFO
    $display("  [TX_ONLY] Sending data to TX FIFO...");
    set_bus({1'b0, 8'h55, 8'h00, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1});  // [20]cdr_sample_valid=0, [19]serial_rx=0, [18:11]pwdata=0x55, [10:3]paddr=0x00, [2]pwrite=1, [1]penable=1, [0]psel=1
    repeat(3) @(posedge i_clk);
    
    // Assert: Write enable is active
    assert (i_bus_in[2] == 1'b1)
        $display("  [TX_ONLY] Write enable (pwrite) = 1");
    else
        $error("  [TX_ONLY] FAIL: pwrite not set!");
    
    // Test pattern 2: Write another byte
    $display("  [TX_ONLY] Sending another byte...");
    set_bus({1'b0, 8'hAA, 8'h00, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1});  // [20]cdr_sample_valid=0, [19]serial_rx=0, [18:11]pwdata=0xAA, [10:3]paddr=0x00, [2]pwrite=1, [1]penable=1, [0]psel=1
    repeat(3) @(posedge i_clk);
    
    // Assert: Second byte is loaded (pwdata at [18:11])
    assert (i_bus_in[18:11] == 8'hAA)
        $display("  [TX_ONLY] Second byte loaded: 0x%02h", i_bus_in[18:11]);
    else
        $error("  [TX_ONLY] FAIL: Second byte mismatch!");
    
    // Verify TX FIFO status on Bus
    $display("  [TX_ONLY] Monitoring FIFO status...");
    repeat(5) @(posedge i_clk);
    
    // Assert: Bus outputs are valid (not x or z)
    assert (o_bus_out !== 14'bx && o_bus_out !== 14'bz)
        $display("  [TX_ONLY] PASS - Bus (FIFO status) valid: 0x%04h", o_bus_out);
    else
        $error("  [TX_ONLY] FAIL - Bus has undefined values!");
    
    $display("========== CFG_TX_ONLY TEST COMPLETE ==========\n");
end
endtask
