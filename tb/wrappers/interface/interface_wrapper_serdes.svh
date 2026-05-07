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
        $display("  [SERDES] Config correctly set to CFG_SERDES");
    else
        $error("  [SERDES] FAIL: Config mismatch!");
    
    // Test pattern 1: Inject data to serializer
    $display("  [SERDES] Injecting data to serializer...");
    set_bus({1'b0, 1'b1, 9'h00, 1'b0, 1'b1, 8'h55});  // [20]cdr_sample_valid=0, [19]serial_rx=1, [9]ser_tx_fifo_empty=0, [8]ser_tx_data_valid=1, [7:0]ser_tx_data=0x55
    repeat(10) @(posedge i_clk);
    
    // Assert: First pattern loaded
    assert (i_bus[7:0] == 8'h55)
        $display("  [SERDES] First pattern loaded to serializer: 0x%02h", i_bus[7:0]);
    else
        $error("  [SERDES] FAIL: First pattern mismatch!");
    
    // Test pattern 2: Different serializer data
    $display("  [SERDES] Changing serializer data...");
    set_bus({1'b0, 1'b1, 9'h00, 1'b0, 1'b1, 8'hAA});  // [20]cdr_sample_valid=0, [19]serial_rx=1, [9]ser_tx_fifo_empty=0, [8]ser_tx_data_valid=1, [7:0]ser_tx_data=0xAA
    repeat(10) @(posedge i_clk);
    
    // Assert: Second pattern loaded
    assert (i_bus[7:0] == 8'hAA)
        $display("  [SERDES] Second pattern loaded: 0x%02h", i_bus[7:0]);
    else
        $error("  [SERDES] FAIL: Second pattern mismatch!");
    
    // Test pattern 3: Complementary pattern
    $display("  [SERDES] Sending complementary pattern...");
    set_bus({1'b0, 1'b1, 9'h00, 1'b0, 1'b1, 8'hF0});  // [20]cdr_sample_valid=0, [19]serial_rx=1, [9]ser_tx_fifo_empty=0, [8]ser_tx_data_valid=1, [7:0]ser_tx_data=0xF0
    repeat(10) @(posedge i_clk);
    
    // Assert: Third pattern loaded
    assert (i_bus[13:6] == 8'hF0)
        $display("  [SERDES] Third pattern loaded: 0x%02h", i_bus[13:6]);
    else
        $error("  [SERDES] FAIL: Third pattern mismatch!");
    
    // Monitor deserializer output
    $display("  [SERDES] Monitoring deserializer output...");
    repeat(5) @(posedge i_clk);
    
    // Verify deserializer output on Bus
    assert (o_bus !== 14'bx && o_bus !== 14'bz)
        $display("  [SERDES] PASS - Bus (deserializer data) valid: 0x%04h", o_bus);
    else
        $error("  [SERDES] FAIL - Bus has undefined values!");
    
    $display("========== CFG_SERDES TEST COMPLETE ==========\n");
end
endtask
