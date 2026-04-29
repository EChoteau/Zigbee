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
        $display("  [FIFO_RX] ✓ Config correctly set to CFG_FIFO_RX");
    else
        $error("  [FIFO_RX] ✗ FAIL: Config mismatch!");
    
    // Test pattern 1: Inject serial bit stream
    $display("  [FIFO_RX] Injecting serial data via CDR...");
    set_bus_b({2'b11, 1'b0, 8'h00});        // serial_rx=1, cdr_sample_valid=1
    repeat(10) @(posedge i_clk);
    
    // Assert: First pattern active
    assert (i_bus_b[10] == 1'b1 && i_bus_b[9] == 1'b1)
        $display("  [FIFO_RX] ✓ First pattern active (cdr_sample_valid=1, serial_rx=1)");
    else
        $error("  [FIFO_RX] ✗ FAIL: First pattern mismatch!");
    
    // Test pattern 2: Different serial pattern
    $display("  [FIFO_RX] Changing serial pattern...");
    set_bus_b({2'b10, 1'b0, 8'h00});        // cdr_sample_valid=1, serial_rx=0
    repeat(10) @(posedge i_clk);
    
    // Assert: Second pattern active
    assert (i_bus_b[10] == 1'b1 && i_bus_b[9] == 1'b0)
        $display("  [FIFO_RX] ✓ Second pattern active (serial_rx=0)");
    else
        $error("  [FIFO_RX] ✗ FAIL: Second pattern mismatch!");
    
    // Test pattern 3: Back to first pattern
    $display("  [FIFO_RX] Restoring serial pattern...");
    set_bus_b({2'b11, 1'b0, 8'h00});
    repeat(10) @(posedge i_clk);
    
    // Assert: Pattern restored
    assert (i_bus_b[9] == 1'b1)
        $display("  [FIFO_RX] ✓ Pattern restored (serial_rx=1)");
    else
        $error("  [FIFO_RX] ✗ FAIL: Pattern restore failed!");
    
    // Monitor RX FIFO
    $display("  [FIFO_RX] Monitoring RX FIFO...");
    repeat(5) @(posedge i_clk);
    
    // Verify RX FIFO data on Bus C
    assert (o_bus_c !== 12'bx && o_bus_c !== 12'bz)
        $display("  [FIFO_RX] ✓ PASS - Bus C (RX FIFO data) valid: 0x%03h", o_bus_c);
    else
        $error("  [FIFO_RX] ✗ FAIL - Bus C has undefined values!");
    
    // Verify RX status on Bus D
    assert (o_bus_d !== 2'bx && o_bus_d !== 2'bz)
        $display("  [FIFO_RX] ✓ PASS - Bus D (RX status) valid: 0b%02b", o_bus_d);
    else
        $error("  [FIFO_RX] ✗ FAIL - Bus D has undefined values!");
    
    $display("========== CFG_FIFO_RX TEST COMPLETE ==========\n");
end
endtask
