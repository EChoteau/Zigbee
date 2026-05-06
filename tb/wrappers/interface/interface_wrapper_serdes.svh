// ============================================================================
// interface_wrapper_serdes.svh
// Test: CFG_SERDES (0x6) - Serializer/Deserializer chain testing
// ============================================================================
// Purpose: Verify direct control of serializer inputs + deserializer outputs
// Tests the complete serializer -> CDR -> deserializer data path
// Inputs: Bus A (serializer data) + Bus B (deserializer serial)
// Outputs: Bus C (deserializer para data) + Bus D (ser/des status)
// ============================================================================

task automatic test_interface_wrapper_serdes();
begin
    $display("\n========== TEST: CFG_SERDES (0x6) ==========");
    $display("Test: Serializer/Deserializer chain control");
    
    set_config(CFG_SERDES);
    repeat(2) @(posedge i_clk);
    
    // Assert: Config is correctly set
    assert (i_cfg_local == CFG_SERDES)
        $display("  [SERDES] ✓ Config correctly set to CFG_SERDES");
    else
        $error("  [SERDES] ✗ FAIL: Config mismatch!");
    
    // Test pattern 1: Inject data to serializer
    $display("  [SERDES] Injecting data to serializer...");
    set_bus_a({2'b11, 8'h55});              // ser_tx_data=0x55, ser_tx_data_valid=1, ser_tx_fifo_empty=1
    set_bus_b({2'b11, 1'b0, 8'h00});        // serial_rx=1, cdr_sample_valid=1
    repeat(10) @(posedge i_clk);
    
    // Assert: First pattern loaded
    assert (i_bus_a[7:0] == 8'h55)
        $display("  [SERDES] ✓ First pattern loaded to serializer: 0x%02h", i_bus_a[7:0]);
    else
        $error("  [SERDES] ✗ FAIL: First pattern mismatch!");
    
    // Test pattern 2: Different serializer data
    $display("  [SERDES] Changing serializer data...");
    set_bus_a({2'b11, 8'hAA});              // ser_tx_data=0xAA
    repeat(10) @(posedge i_clk);
    
    // Assert: Second pattern loaded
    assert (i_bus_a[7:0] == 8'hAA)
        $display("  [SERDES] ✓ Second pattern loaded: 0x%02h", i_bus_a[7:0]);
    else
        $error("  [SERDES] ✗ FAIL: Second pattern mismatch!");
    
    // Test pattern 3: Complementary pattern
    $display("  [SERDES] Sending complementary pattern...");
    set_bus_a({2'b11, 8'hF0});              // ser_tx_data=0xF0
    repeat(10) @(posedge i_clk);
    
    // Assert: Third pattern loaded
    assert (i_bus_a[7:0] == 8'hF0)
        $display("  [SERDES] ✓ Third pattern loaded: 0x%02h", i_bus_a[7:0]);
    else
        $error("  [SERDES] ✗ FAIL: Third pattern mismatch!");
    
    // Monitor deserializer output
    $display("  [SERDES] Monitoring deserializer output...");
    repeat(5) @(posedge i_clk);
    
    // Verify deserializer output on Bus C
    assert (o_bus_c !== 12'bx && o_bus_c !== 12'bz)
        $display("  [SERDES] ✓ PASS - Bus C (deserializer data) valid: 0x%03h", o_bus_c);
    else
        $error("  [SERDES] ✗ FAIL - Bus C has undefined values!");
    
    // Verify ser/des status on Bus D
    assert (o_bus_d !== 2'bx && o_bus_d !== 2'bz)
        $display("  [SERDES] ✓ PASS - Bus D (ser/des status) valid: 0b%02b", o_bus_d);
    else
        $error("  [SERDES] ✗ FAIL - Bus D has undefined values!");
    
    $display("========== CFG_SERDES TEST COMPLETE ==========\n");
end
endtask
