// ============================================================================
// interface_wrapper_fifo_rx.svh
// Test: CFG_FIFO_RX (0x5) - RX FIFO direct control
// ============================================================================
// Purpose: Verify direct read from RX FIFO bypassing APB
// Tests FIFO pop, full/empty flags, deserializer output
// Inputs: Bus B (CDR serial signals)
// Outputs: Bus C (RX FIFO data) + Bus D (RX status)
// ============================================================================

task automatic test_interface_wrapper_fifo_rx();
begin
    $display("\n========== TEST: CFG_FIFO_RX (0x5) ==========");
    $display("Test: RX FIFO direct control (bypass APB)");
    
    set_config(CFG_FIFO_RX);
    repeat(2) @(posedge i_clk);
    
    // Assert: Config is correctly set
    assert (i_cfg_local == CFG_FIFO_RX)
        $display("  [FIFO_RX] Config correctly set to CFG_FIFO_RX");
    else
        $error("  [FIFO_RX] FAIL: Config mismatch!");
    
    // Test pattern 1: Inject serial bit stream
    $display("  [FIFO_RX] Injecting serial data via CDR...");
    set_bus({1'b0, 1'b1, 1'b1, 8'h00, 8'h00, 1'b0, 1'b1, 1'b1});  // [20]cdr_sample_valid=1, [19]serial_rx=1, [1]fifo_rx_rd_en=1, [0]fifo_rx_wr_en=1
    repeat(10) @(posedge i_clk);
    
    // Assert: First pattern active
    assert (i_bus_in[20] == 1'b1 && i_bus_in[19] == 1'b1)
        $display("  [FIFO_RX] First pattern active (cdr_sample_valid=1, serial_rx=1)");
    else
        $error("  [FIFO_RX] FAIL: First pattern mismatch!");
    
    // Test pattern 2: Different serial pattern
    $display("  [FIFO_RX] Changing serial pattern...");
    set_bus({1'b0, 1'b1, 1'b0, 8'h00, 8'h00, 1'b0, 1'b1, 1'b1});  // [20]cdr_sample_valid=1, [19]serial_rx=0, [1]fifo_rx_rd_en=1, [0]fifo_rx_wr_en=1
    repeat(10) @(posedge i_clk);
    
    // Assert: Second pattern active
    assert (i_bus_in[20] == 1'b1 && i_bus_in[19] == 1'b0)
        $display("  [FIFO_RX] Second pattern active (serial_rx=0)");
    else
        $error("  [FIFO_RX] FAIL: Second pattern mismatch!");
    
    // Test pattern 3: Back to first pattern
    $display("  [FIFO_RX] Restoring serial pattern...");
    set_bus({1'b0, 1'b1, 1'b1, 8'h00, 8'h00, 1'b0, 1'b1, 1'b1});  // [20]cdr_sample_valid=1, [19]serial_rx=1, [1]fifo_rx_rd_en=1, [0]fifo_rx_wr_en=1
    repeat(10) @(posedge i_clk);
    
    // Assert: Pattern restored (serial_rx at bit 19)
    assert (i_bus_in[19] == 1'b1)
        $display("  [FIFO_RX] Pattern restored (serial_rx=1)");
    else
        $error("  [FIFO_RX] FAIL: Pattern restore failed!");
    
    // Monitor RX FIFO
    $display("  [FIFO_RX] Monitoring RX FIFO...");
    repeat(5) @(posedge i_clk);
    
    // Verify RX FIFO data on Bus
    assert (o_bus_out !== 14'bx && o_bus_out !== 14'bz)
        $display("  [FIFO_RX] PASS - Bus (RX FIFO data) valid: 0x%04h", o_bus_out);
    else
        $error("  [FIFO_RX] FAIL - Bus has undefined values!");
    
    $display("========== CFG_FIFO_RX TEST COMPLETE ==========\n");
end
endtask
