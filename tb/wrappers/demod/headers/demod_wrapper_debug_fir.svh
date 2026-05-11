task automatic test_demod_wrapper_debug_fir();
    logic [21:0] bus_val;
    logic signed [5:0] fir_out;

    begin
        $display("\n========== TEST: DEBUG_FIR (0x4 & 0x5) ==========");

        // --- TEST FIR I (0x4) ---
        set_config(3'b100); // CFG_DEBUG_FIR_I [cite: 542]
        repeat(2) @(posedge i_clk);

        $display("  [FIR_I] Envoi impulsion 0x7F (Max)...");
        bus_val = '0;
        bus_val[17:10] = 8'h7F; // s_test_fir_in [cite: 549]
        set_bus(bus_val);
        
        // On attend que les donnees traversent les 5 etages du FIR [cite: 478]
        repeat(10) @(posedge i_clk);
        fir_out = o_bus_out[5:0]; // s_i_bb [cite: 572]
        $display("  [FIR_I] Sortie filtree: %d", fir_out);
        assert (fir_out != 0) else $error("  [FIR_I] FAIL: Sortie nulle !");

        // --- TEST FIR Q (0x5) ---
        set_config(3'b101); // CFG_DEBUG_FIR_Q [cite: 543]
        repeat(2) @(posedge i_clk);
        
        set_bus(bus_val);
        repeat(10) @(posedge i_clk);
        fir_out = o_bus_out[11:6]; // s_q_bb [cite: 575]
        $display("  [FIR_Q] Sortie filtree: %d", fir_out);

        $display("========== DEBUG_FIR COMPLETE ==========\n");
    end
endtask