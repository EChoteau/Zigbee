// Validation des modes 0x6 (Chain I) et 0x7 (Chain Q)
task automatic test_demod_wrapper_debug_chain();
    logic [21:0] bus_val;

    begin
        $display("\n========== TEST: DEBUG_CHAIN (0x6 & 0x7) ==========");

        // --- TEST CHAIN I (0x6) ---
        $display("  [CHAIN_I] Test complet canal I (Q force a zero)...");
        tb_pkg::set_config(i_clk, d_cfg_local, 3'b110); // CFG_DEBUG_FIRC_I [cite: 544]
        repeat(2) @(posedge i_clk);

        bus_val = '0;
        bus_val[17:14] = 4'd7; // I max
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

        repeat(15) @(posedge i_clk);
        $display("  [CHAIN_I] Sortie Baseband I: %d", $signed(o_bus_out[5:0]));
        $display("  [CHAIN_I] Sortie Baseband Q (doit etre faible): %d", $signed(o_bus_out[11:6]));

        // --- TEST CHAIN Q (0x7) ---
        $display("  [CHAIN_Q] Test complet canal Q (I force a zero)...");
        tb_pkg::set_config(i_clk, d_cfg_local, 3'b111); // CFG_DEBUG_FIRC_Q [cite: 545]
        repeat(2) @(posedge i_clk);

        bus_val = '0;
        bus_val[13:10] = 4'd7; // Q max
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

        repeat(15) @(posedge i_clk);
        $display("  [CHAIN_Q] Sortie Baseband Q: %d", $signed(o_bus_out[11:6]));

        $display("========== DEBUG_CHAIN COMPLETE ==========\n");
    end
endtask