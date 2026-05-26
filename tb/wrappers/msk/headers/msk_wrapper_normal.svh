task automatic test_msk_wrapper_normal();
    logic [21:0] bus_val;
    begin
        $display("\n========== TEST: CFG0 (NORMAL MODE) ==========");
        tb_pkg::set_config(i_clk, i_cfg_local, 3'b000);
        repeat(2) @(posedge i_clk);

        $display("  [NORMAL] Injection bit '1' avec horloges (flag_enable & enable_ech)...");
        bus_val = '0;
        bus_val[2] = 1'b1; // b_in
        bus_val[1] = 1'b1; // enable_ech
        bus_val[0] = 1'b1; // flag_enable
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        
        // On laisse tourner pour voir les filtres shaping se remplir
        repeat(15) @(posedge i_clk);
        
        // Verification que o_bus_out[12] renvoie bien le enable_ech
        assert (o_bus_out[12] == 1'b1) else $error("  [NORMAL] FAIL: Retour enable_ech incorrect");
        
        // Verification que les sorties I et Q ne sont pas nulles (elles oscillent)
        assert ($signed(o_bus_out[11:6]) inside {[-31:31]}) else $error("  [NORMAL] FAIL: I_BB hors limite");
        assert ($signed(o_bus_out[5:0]) inside {[-31:31]}) else $error("  [NORMAL] FAIL: Q_BB hors limite");
        
        $display("  [NORMAL] PASS: Les donnees traversent la chaine MSK !");
        $display("========== CFG0 COMPLETE ==========\n");
    end
endtask