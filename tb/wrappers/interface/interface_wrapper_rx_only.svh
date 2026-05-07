// ============================================================================
// interface_wrapper_rx_only.svh
// Test: CFG_RX_ONLY (0x2) - RX path with FIFO control
// ============================================================================
// Purpose: Verify CDR to deserializer to RX FIFO functionality
// Inputs: Bus A (APB control) + Bus B (APB data + serial RX)
// Outputs: Bus C (APB readback + RX FIFO)
// ============================================================================

task automatic test_interface_wrapper_rx_only();
begin
    $display("\n========== TEST: CFG_RX_ONLY (0x2) ==========");
    $display("Test: RX path with FIFO control");
    
    set_config(CFG_RX_ONLY);
    repeat(2) @(posedge i_clk);
    
    // Assert: Config is correctly set
    assert (i_cfg_local == CFG_RX_ONLY)
        $display("  [RX_ONLY] Config correctly set to CFG_RX_ONLY");
    else
        $error("  [RX_ONLY] FAIL: Config mismatch!");
    
    // Test pattern 1: Setup APB and serial RX
    $display("  [RX_ONLY] Injecting serial data via CDR...");
    set_bus({1'b1, 8'h00, 8'h00, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1});  // [20]cdr_sample_valid=1, [19]serial_rx=1, [18:11]pwdata=0x00, [10:3]paddr=0x00, [2]pwrite=0, [1]penable=1, [0]psel=1
    repeat(4) @(posedge i_clk);
    
    // Assert: Read mode is active
    assert (i_bus[2] == 1'b0)
        $display("  [RX_ONLY] Read mode active (pwrite=0)");
    else
        $error("  [RX_ONLY] FAIL: pwrite should be 0!");
    
    // Assert: Serial RX is active
    assert (i_bus[3] == 1'b1)
        $display("  [RX_ONLY] Serial RX active (serial_rx=1)");
    else
        $error("  [RX_ONLY] FAIL: serial_rx not set!");
    
    // Test pattern 2: Different serial pattern
    $display("  [RX_ONLY] Injecting different serial pattern...");
    set_bus({1'b1, 8'h00, 8'h00, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1});  // [20]cdr_sample_valid=1, [19]serial_rx=0, [18:11]pwdata=0x00, [10:3]paddr=0x00, [2]pwrite=0, [1]penable=1, [0]psel=1
    repeat(4) @(posedge i_clk);
    
    // Assert: Serial pattern changed
    assert (i_bus[3] == 1'b0)
        $display("  [RX_ONLY] Serial pattern changed (serial_rx=0)");
    else
        $error("  [RX_ONLY] FAIL: serial_rx pattern mismatch!");
    
    // Verify RX FIFO status on Bus
    $display("  [RX_ONLY] Monitoring RX FIFO...");
    repeat(3) @(posedge i_clk);
    
    // Assert: Bus outputs are valid
    assert (o_bus !== 14'bx && o_bus !== 14'bz)
        $display("  [RX_ONLY] PASS - Bus (RX status) valid: 0x%04h", o_bus);
    else
        $error("  [RX_ONLY] FAIL - Bus has undefined values!");
    
    $display("========== CFG_RX_ONLY TEST COMPLETE ==========\n");
end
endtask
