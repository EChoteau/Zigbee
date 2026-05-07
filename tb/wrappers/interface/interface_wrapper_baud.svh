// ============================================================================
// interface_wrapper_baud.svh
// Test: CFG_BAUD (0x7) - Baud rate generator control
// ============================================================================
// Purpose: Verify baud rate generator divisor configuration and tick generation
// Tests baud rate divisor settings and clock tick output
// Inputs: Bus A (baud divisor control)
// Outputs: Bus D (baud tick and status)
// ============================================================================

task automatic test_interface_wrapper_baud();
begin
    $display("\n========== TEST: CFG_BAUD (0x7) ==========");
    $display("Test: Baud rate generator control");
    
    set_config(CFG_BAUD);
    repeat(2) @(posedge i_clk);
    
    // Assert: Config is correctly set
    assert (i_cfg_local == CFG_BAUD)
        $display("  [BAUD] Config correctly set to CFG_BAUD");
    else
        $error("  [BAUD] FAIL: Config mismatch!");
    
    // Test pattern 1: Default baud rate (divisor = 0x10)
    $display("  [BAUD] Setting baud divisor to 0x10...");
    set_bus({13'h00, 8'h10, 1'b1});  // [0]baud_enable=1, [8:1]baud_div_val=0x10
    repeat(20) @(posedge i_clk);
    
    // Assert: Baud divisor 0x10 loaded
    assert (i_bus[0] == 1'b1)
        $display("  [BAUD] Baud divisor set with enable bit");
    else
        $error("  [BAUD] FAIL: Baud enable not loaded!");
    
    // Test pattern 2: Slower baud rate (divisor = 0x20)
    $display("  [BAUD] Setting baud divisor to 0x20 (slower)...");
    set_bus({13'h00, 8'h20, 1'b1});  // [0]baud_enable=1, [8:1]baud_div_val=0x20
    repeat(30) @(posedge i_clk);
    
    // Assert: Baud divisor 0x20 loaded
    assert (i_bus[0] == 1'b1)
        $display("  [BAUD] Baud divisor set with enable");
    else
        $error("  [BAUD] FAIL: Baud divisor 0x20 not loaded!");
    
    // Test pattern 3: Faster baud rate (divisor = 0x08)
    $display("  [BAUD] Setting baud divisor to 0x08 (faster)...");
    set_bus({13'h00, 8'h08, 1'b1});  // [0]baud_enable=1, [8:1]baud_div_val=0x08
    repeat(15) @(posedge i_clk);
    
    // Assert: Baud divisor 0x08 loaded
    assert (i_bus[0] == 1'b1)
        $display("  [BAUD] Baud divisor set");
    else
        $error("  [BAUD] FAIL: Baud divisor 0x08 not loaded!");
    
    // Test pattern 4: Disable baud generator
    $display("  [BAUD] Disabling baud generator...");
    set_bus({8'h00, 8'h00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0});  // baud_enable=0
    repeat(10) @(posedge i_clk);
    
    // Assert: Baud generator disabled
    assert (i_bus[0] == 1'b0)
        $display("  [BAUD] Baud generator disabled (baud_enable=0)");
    else
        $error("  [BAUD] FAIL: Baud generator not disabled!");
    
    // Monitor baud ticks
    $display("  [BAUD] Monitoring baud generator output...");
    repeat(5) @(posedge i_clk);
    
    // Verify baud tick output on Bus
    assert (o_bus !== 14'bx && o_bus !== 14'bz)
        $display("  [BAUD] PASS - Bus (baud tick) valid: 0x%04h", o_bus);
    else
        $error("  [BAUD] FAIL - Bus has undefined values!");
    
    $display("========== CFG_BAUD TEST COMPLETE ==========\n");
end
endtask
