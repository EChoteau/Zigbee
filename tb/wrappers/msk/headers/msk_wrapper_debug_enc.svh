task automatic test_msk_wrapper_debug_enc();
    logic [21:0] bus_val;
    begin
        $display("\n========== TEST: CFG1 (DEBUG ENCODEUR) ==========");
        tb_pkg::set_config(i_clk, i_cfg_local, 3'b001);
        repeat(2) @(posedge i_clk);

        $display("  [ENC] Injection d'un '1' dans l'encodeur...");
        bus_val = '0;
        bus_val[3] = 1'b1; // dbg_enc_b_in
        bus_val[0] = 1'b1; // flag_enable
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat(2) @(posedge i_clk);

        // Verification du bit sortant sur o_bus_out[0]
        assert (o_bus_out[0] == 1'b1) 
            $display("  [ENC] PASS: L'encodeur repond (sortie = 1)");
        else $error("  [ENC] FAIL: Mauvaise sortie encodeur");

        $display("========== CFG1 COMPLETE ==========\n");
    end
endtask