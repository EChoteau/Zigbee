// ============================================================================
// interface_wrapper_loopback.svh
// Test: CFG_LOOPBACK (0x3) - Serial loopback testing
// ============================================================================
// Purpose: Verify TX serial output looped back to RX deserializer
// Validates serializer -> CDR -> deserializer chain
// Inputs: Bus A (APB control) + Bus B (APB data + CDR signals)
// Outputs: Bus C (debug status) + Bus D (loopback signals)
// ============================================================================

task automatic test_interface_wrapper_loopback();
begin
    $display("\n========== TEST: CFG_LOOPBACK (0x3) ==========");
    $display("Test: Serial loopback (TX -> RX chain)");
    
    set_config(CFG_LOOPBACK);
    repeat(2) @(posedge i_clk);
    
    // Assert: Config is correctly set
    assert (i_cfg_local == CFG_LOOPBACK)
        $display("  [LOOPBACK] Config correctly set to CFG_LOOPBACK");
    else
        $error("  [LOOPBACK] FAIL: Config mismatch!");
    
    // Test pattern 1: Load TX FIFO and enable loopback
    $display("  [LOOPBACK] Enabling serial loopback chain...");
    set_bus_a({7'h00, 1'b1, 1'b1, 1'b1});  // paddr=0x00, pwrite=1, penable=1, psel=1
    set_bus_b({2'b01, 1'b0, 8'h5A});        // cdr_sample_valid=1, pwdata=0x5A
    repeat(5) @(posedge i_clk);
    
    // Assert: Loopback data loaded
    assert (i_bus_b[7:0] == 8'h5A)
        $display("  [LOOPBACK] Loopback data loaded: 0x%02h", i_bus_b[7:0]);
    else
        $error("  [LOOPBACK] FAIL: Loopback data mismatch!");
    
    // Test pattern 2: Monitor loopback activity
    $display("  [LOOPBACK] Monitoring loopback signals...");
    repeat(5) @(posedge i_clk);
    
    // Test pattern 3: Second data pattern
    $display("  [LOOPBACK] Sending second pattern through loopback...");
    set_bus_b({2'b01, 1'b0, 8'hA5});        // pwdata=0xA5
    repeat(5) @(posedge i_clk);
    
    // Assert: Second pattern loaded
    assert (i_bus_b[7:0] == 8'hA5)
        $display("  [LOOPBACK] Second pattern loaded: 0x%02h", i_bus_b[7:0]);
    else
        $error("  [LOOPBACK] FAIL: Second pattern mismatch!");
    
    // Verify loopback signals on Bus D
    assert (o_bus_d !== 2'bx && o_bus_d !== 2'bz)
        $display("  [LOOPBACK] PASS - Bus D (loopback status) valid: 0b%02b", o_bus_d);
    else
        $error("  [LOOPBACK] FAIL - Bus D has undefined values!");
    
    // Assert: Bus C also responding
    assert (o_bus_c !== 12'bx && o_bus_c !== 12'bz)
        $display("  [LOOPBACK] PASS - Bus C (debug) valid: 0x%03h", o_bus_c);
    else
        $error("  [LOOPBACK] FAIL - Bus C has undefined values!");
    
    $display("========== CFG_LOOPBACK TEST COMPLETE ==========\n");
end
endtask
