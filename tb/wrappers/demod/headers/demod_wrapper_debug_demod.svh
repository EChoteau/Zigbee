task automatic test_demod_wrapper_debug_demod();
    logic [21:0] bus_val;
    logic [7:0]  res_demod;
    logic [3:0]  res_osc;

    begin
        $display("\n========== TEST: DEBUG_DEMOD (0x1 & 0x2) ==========");
        
        // --- TEST CANAL I (0x1) ---
        tb_pkg::set_config(i_clk, d_cfg_local, 3'b001); // CFG_DEBUG_DEMOD_I [cite: 539]
        repeat(2) @(posedge i_clk);

        $display("  [DEMOD_I] Injection I=4, Q=0 (test melangeur)...");
        // s_test_i (bits 17:14), s_test_q (bits 13:10) [cite: 546-548]
        bus_val = '0;
        bus_val[17:14] = 4'd4; 
        bus_val[13:10] = 4'd0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        
        repeat(5) @(posedge i_clk);
        res_demod = o_bus_out[7:0];  // s_demod_out_i [cite: 565]
        res_osc   = o_bus_out[11:8]; // s_cos_test [cite: 566]
        
        $display("  [DEMOD_I] Out_I: 0x%0h, Cos_Ref: 0x%0h", res_demod, res_osc);
        assert (res_osc !== 4'hx) else $error("  [DEMOD_I] FAIL: Oscillateur Cos bloque !");

        // --- TEST CANAL Q (0x2) ---
        tb_pkg::set_config(i_clk, d_cfg_local, 3'b010); // CFG_DEBUG_DEMOD_Q [cite: 540]
        repeat(2) @(posedge i_clk);

        $display("  [DEMOD_Q] Injection I=0, Q=4...");
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat(5) @(posedge i_clk);
        
        res_demod = o_bus_out[7:0];  // s_demod_out_q [cite: 568]
        res_osc   = o_bus_out[11:8]; // s_sin_test [cite: 569]
        $display("  [DEMOD_Q] Out_Q: 0x%0h, Sin_Ref: 0x%0h", res_demod, res_osc);
        
        $display("========== DEBUG_DEMOD COMPLETE ==========\n");
    end
endtask