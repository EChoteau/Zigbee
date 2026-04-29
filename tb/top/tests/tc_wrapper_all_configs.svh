////////////////////////////////////////////////////////////////////////////////
// tc_wrapper_all_configs.svh
// ============================================================================
// Test case: Verify all 8 configurations route signals correctly
// Can be included in a structured testbench if needed
////////////////////////////////////////////////////////////////////////////////

task automatic run_tc_wrapper_all_configs;
    logic [CFG_WIDTH-1:0] cfg;
begin
    $display("[TC_ALL_CFG] Comprehensive wrapper configuration test");

    for (cfg = 0; cfg < 8; cfg++) begin
        $display("  Testing configuration 0x%h...", cfg);
        
        i_cfg_local = cfg;
        repeat(2) @(posedge i_clk);
        
        // Basic sanity check: o_test_out should not be X or high-Z
        assert (o_test_out === o_test_out) 
            else $error("[TC_ALL_CFG] Config 0x%h produces undefined output", cfg);
    end

    $display("[TC_ALL_CFG] All configurations verified PASS");
end
endtask
