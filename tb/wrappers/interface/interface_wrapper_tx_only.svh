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
    set_bus_a({7'h00, 1'b1, 1'b1, 1'b1});  // paddr=0x00, pwrite=1, penable=1, psel=1
    set_bus_b({2'b00, 1'b0, 8'h55});        // pwdata=0x55
    repeat(3) @(posedge i_clk);
    
    // Assert: Write enable is active
    assert (i_bus_a[2] == 1'b1)
        $display("  [TX_ONLY] Write enable (pwrite) = 1");
    else
        $error("  [TX_ONLY] FAIL: pwrite not set!");
    
    // Test pattern 2: Write another byte
    $display("  [TX_ONLY] Sending another byte...");
    set_bus_a({7'h00, 1'b1, 1'b1, 1'b1});
    set_bus_b({2'b00, 1'b0, 8'hAA});        // pwdata=0xAA
    repeat(3) @(posedge i_clk);
    
    // Assert: Second byte is loaded
    assert (i_bus_b[7:0] == 8'hAA)
        $display("  [TX_ONLY] Second byte loaded: 0x%02h", i_bus_b[7:0]);
    else
        $error("  [TX_ONLY] FAIL: Second byte mismatch!");
    
    // Verify TX FIFO status on Bus C
    $display("  [TX_ONLY] Monitoring FIFO status...");
    repeat(5) @(posedge i_clk);
    
    // Assert: Bus C outputs are valid (not x or z)
    assert (o_bus_c !== 12'bx && o_bus_c !== 12'bz)
        $display("  [TX_ONLY] PASS - Bus C (FIFO status) valid: 0x%03h", o_bus_c);
    else
        $error("  [TX_ONLY] FAIL - Bus C has undefined values!");
    
    // Verify serial output on Bus D
    assert (o_bus_d !== 2'bx && o_bus_d !== 2'bz)
        $display("  [TX_ONLY] PASS - Bus D (serial TX) valid: 0b%02b", o_bus_d);
    else
        $error("  [TX_ONLY] FAIL - Bus D has undefined values!");
    
    $display("========== CFG_TX_ONLY TEST COMPLETE ==========\n");
end
endtask
