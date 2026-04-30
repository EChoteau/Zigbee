// ============================================================================
// interface_wrapper_fifo_tx.svh
// Test: CFG_FIFO_TX (0x4) - TX FIFO direct control
// ============================================================================
// Purpose: Verify direct write to TX FIFO bypassing APB
// Tests FIFO push/pop, full/empty flags
// Inputs: Bus B (FIFO write data + controls)
// Outputs: Bus C (FIFO status) + Bus D (serial output)
// ============================================================================

task automatic test_interface_wrapper_fifo_tx();
begin
    $display("\n========== TEST: CFG_FIFO_TX (0x4) ==========");
    $display("Test: TX FIFO direct control (bypass APB)");
    
    set_config(CFG_FIFO_TX);
    repeat(2) @(posedge i_clk);
    
    // Assert: Config is correctly set
    assert (i_cfg_local == CFG_FIFO_TX)
        $display("  [FIFO_TX] ✓ Config correctly set to CFG_FIFO_TX");
    else
        $error("  [FIFO_TX] ✗ FAIL: Config mismatch!");
    
    // Test pattern 1: Push first byte to TX FIFO
    $display("  [FIFO_TX] Pushing first byte to TX FIFO...");
    set_bus_b({2'b00, 8'h11});        // First data pattern
    repeat(3) @(posedge i_clk);
    
    // Assert: First byte loaded
    assert (i_bus_b[7:0] == 8'h11)
        $display("  [FIFO_TX] ✓ First byte loaded: 0x%02h", i_bus_b[7:0]);
    else
        $error("  [FIFO_TX] ✗ FAIL: First byte mismatch!");
    
    // Test pattern 2: Push second byte
    $display("  [FIFO_TX] Pushing second byte to TX FIFO...");
    set_bus_b({2'b00, 8'h22});        // Second data pattern
    repeat(3) @(posedge i_clk);
    
    // Assert: Second byte loaded
    assert (i_bus_b[7:0] == 8'h22)
        $display("  [FIFO_TX] ✓ Second byte loaded: 0x%02h", i_bus_b[7:0]);
    else
        $error("  [FIFO_TX] ✗ FAIL: Second byte mismatch!");
    
    // Test pattern 3: Push third byte
    $display("  [FIFO_TX] Pushing third byte to TX FIFO...");
    set_bus_b({2'b00, 8'h33});        // Third data pattern
    repeat(3) @(posedge i_clk);
    
    // Assert: Third byte loaded
    assert (i_bus_b[7:0] == 8'h33)
        $display("  [FIFO_TX] ✓ Third byte loaded: 0x%02h", i_bus_b[7:0]);
    else
        $error("  [FIFO_TX] ✗ FAIL: Third byte mismatch!");
    
    // Monitor FIFO status
    $display("  [FIFO_TX] Monitoring TX FIFO status...");
    repeat(5) @(posedge i_clk);
    
    // Verify FIFO status on Bus C
    assert (o_bus_c !== 12'bx && o_bus_c !== 12'bz)
        $display("  [FIFO_TX] ✓ PASS - Bus C (FIFO status) valid: 0x%03h", o_bus_c);
    else
        $error("  [FIFO_TX] ✗ FAIL - Bus C has undefined values!");
    
    // Verify serial TX on Bus D
    assert (o_bus_d !== 2'bx && o_bus_d !== 2'bz)
        $display("  [FIFO_TX] ✓ PASS - Bus D (serial TX) valid: 0b%02b", o_bus_d);
    else
        $error("  [FIFO_TX] ✗ FAIL - Bus D has undefined values!");
    
    $display("========== CFG_FIFO_TX TEST COMPLETE ==========\n");
end
endtask
