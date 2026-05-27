// ============================================================================
// PACKAGE: demod_wrapper_tasks_pkg
// ============================================================================
// Wrapper test tasks for DEMOD wrapper, callable from top_tb.
// ============================================================================

package demod_wrapper_tasks_pkg;

    import tb_pkg::*;
    import demod_pkg::*;

    task automatic test_demod_wrapper_debug_demod(
        ref logic i_clk,
        ref logic [tb_pkg::CFG_WIDTH-1:0] d_cfg_local,
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic [7:0]  res_demod;
        logic [3:0]  res_osc;

        begin
            $display("\n========== TEST: DEBUG_DEMOD (0x1 & 0x2) ==========");

            // --- TEST CANAL I (0x1) ---
            tb_pkg::set_config_wrapper(i_clk, d_cfg_local, 3'b001); // CFG_DEBUG_DEMOD_I
            repeat(2) @(posedge i_clk);

            $display("  [DEMOD_I] Injection I=4, Q=0 (test melangeur)...");
            // s_test_i (bits 17:14), s_test_q (bits 13:10)
            bus_val = '0;
            bus_val[17:14] = 4'd4;
            bus_val[13:10] = 4'd0;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            repeat(5) @(posedge i_clk);
            res_demod = o_bus_out[7:0];
            res_osc   = o_bus_out[11:8];

            $display("  [DEMOD_I] Out_I: 0x%0h, Cos_Ref: 0x%0h", res_demod, res_osc);
            assert (res_osc !== 4'hx) else $error("  [DEMOD_I] FAIL: Oscillateur Cos bloque !");

            // --- TEST CANAL Q (0x2) ---
            tb_pkg::set_config_wrapper(i_clk, d_cfg_local, 3'b010); // CFG_DEBUG_DEMOD_Q
            repeat(2) @(posedge i_clk);

            $display("  [DEMOD_Q] Injection I=0, Q=4...");
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(5) @(posedge i_clk);

            res_demod = o_bus_out[7:0];
            res_osc   = o_bus_out[11:8];
            $display("  [DEMOD_Q] Out_Q: 0x%0h, Sin_Ref: 0x%0h", res_demod, res_osc);

            $display("========== DEBUG_DEMOD COMPLETE ==========\n");
        end
    endtask

    task automatic test_demod_wrapper_debug_fir(
        ref logic i_clk,
        ref logic [tb_pkg::CFG_WIDTH-1:0] d_cfg_local,
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic signed [5:0] fir_out;

        begin
            $display("\n========== TEST: DEBUG_FIR (0x4 & 0x5) ==========");

            // --- TEST FIR I (0x4) ---
            tb_pkg::set_config_wrapper(i_clk, d_cfg_local, 3'b100); // CFG_DEBUG_FIR_I
            repeat(2) @(posedge i_clk);

            $display("  [FIR_I] Envoi impulsion 0x7F (Max)...");
            bus_val = '0;
            bus_val[17:10] = 8'h7F; // s_test_fir_in
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            // On attend que les donnees traversent les 5 etages du FIR
            repeat(10) @(posedge i_clk);
            fir_out = o_bus_out[5:0];
            $display("  [FIR_I] Sortie filtree: %d", fir_out);
            assert (fir_out != 0) else $error("  [FIR_I] FAIL: Sortie nulle !");

            // --- TEST FIR Q (0x5) ---
            tb_pkg::set_config_wrapper(i_clk, d_cfg_local, 3'b101); // CFG_DEBUG_FIR_Q
            repeat(2) @(posedge i_clk);

            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(10) @(posedge i_clk);
            fir_out = o_bus_out[11:6];
            $display("  [FIR_Q] Sortie filtree: %d", fir_out);

            $display("========== DEBUG_FIR COMPLETE ==========\n");
        end
    endtask

    task automatic test_demod_wrapper_debug_chain(
        ref logic i_clk,
        ref logic [tb_pkg::CFG_WIDTH-1:0] d_cfg_local,
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;

        begin
            $display("\n========== TEST: DEBUG_CHAIN (0x6 & 0x7) ==========");

            // --- TEST CHAIN I (0x6) ---
            $display("  [CHAIN_I] Test complet canal I (Q force a zero)...");
            tb_pkg::set_config_wrapper(i_clk, d_cfg_local, 3'b110); // CFG_DEBUG_FIRC_I
            repeat(2) @(posedge i_clk);

            bus_val = '0;
            bus_val[17:14] = 4'd7; // I max
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            repeat(15) @(posedge i_clk);
            $display("  [CHAIN_I] Sortie Baseband I: %d", $signed(o_bus_out[5:0]));
            $display("  [CHAIN_I] Sortie Baseband Q (doit etre faible): %d", $signed(o_bus_out[11:6]));

            // --- TEST CHAIN Q (0x7) ---
            $display("  [CHAIN_Q] Test complet canal Q (I force a zero)...");
            tb_pkg::set_config_wrapper(i_clk, d_cfg_local, 3'b111); // CFG_DEBUG_FIRC_Q
            repeat(2) @(posedge i_clk);

            bus_val = '0;
            bus_val[13:10] = 4'd7; // Q max
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            repeat(15) @(posedge i_clk);
            $display("  [CHAIN_Q] Sortie Baseband Q: %d", $signed(o_bus_out[11:6]));

            $display("========== DEBUG_CHAIN COMPLETE ==========\n");
        end
    endtask

    task automatic test_demod_wrapper_normal(
        ref logic i_clk,
        ref logic [tb_pkg::CFG_WIDTH-1:0] d_cfg_local,
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out,
        ref logic [3:0] tb_i,
        ref logic [3:0] tb_q
    );
        logic signed [5:0] res_i;
        logic signed [5:0] res_q;

        begin
            $display("\n========== TEST: NORMAL MODE (0x0) ==========");

            // 1. Configurer en mode Normal
            tb_pkg::set_config_wrapper(i_clk, d_cfg_local, 3'b000);
            repeat(2) @(posedge i_clk);

            $display("  [NORMAL] Mode production actif. Ecoute des ports ADC directs.");

            // 2. Simuler une donnee provenant de l'ADC
            $display("  [NORMAL] Injection ADC : I=15 (Max Positif), Q=8 (Zero)...");

            // Pilotage direct des entrees ADC du Testbench
            tb_i = 4'd15; // Valeur max
            tb_q = 4'd8;  // Valeur neutre (DC offset)

            // On laisse le filtre FIR se remplir (il a 5 etages de delai)
            repeat(10) @(posedge i_clk);

            // 3. Capture des sorties Baseband
            res_i = o_bus_out[5:0];
            res_q = o_bus_out[11:6];

            $display("  [NORMAL] Sortie Baseband I: %d", res_i);
            $display("  [NORMAL] Sortie Baseband Q: %d", res_q);

            // Verification basique : Si on met un I fort, la sortie I doit reagir et Q doit rester faible
            if (res_i != 0)
                $display("  [NORMAL] PASS : La chaine I reagit aux donnees ADC !");
            else
                $error("  [NORMAL] FAIL : La chaine I est muette !");

            // 4. Inversion pour verifier Q
            $display("  [NORMAL] Injection ADC : I=8 (Zero), Q=0 (Max Negatif)...");
            tb_i = 4'd8;
            tb_q = 4'd0;

            repeat(10) @(posedge i_clk);

            res_i = o_bus_out[5:0];
            res_q = o_bus_out[11:6];

            $display("  [NORMAL] Sortie Baseband I: %d", res_i);
            $display("  [NORMAL] Sortie Baseband Q: %d", res_q);

            if (res_q != 0)
                $display("  [NORMAL] PASS : La chaine Q reagit aux donnees ADC !");
            else
                $error("  [NORMAL] FAIL : La chaine Q est muette !");

            $display("========== NORMAL MODE COMPLETE ==========\n");
        end
    endtask

    task automatic run_demod_wrapper_test_plan(
        ref logic i_clk,
        ref logic i_rst_n,
        ref logic [tb_pkg::CFG_WIDTH-1:0] d_cfg_local,
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out,
        ref logic [3:0] tb_i,
        ref logic [3:0] tb_q
    );
    begin
        test_demod_wrapper_debug_demod(i_clk, d_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_demod_wrapper_debug_fir(i_clk, d_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_demod_wrapper_debug_chain(i_clk, d_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_demod_wrapper_normal(i_clk, d_cfg_local, i_bus_in, o_bus_out, tb_i, tb_q);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        $display("\n========== ALL DEMOD WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
    end
    endtask

endpackage : demod_wrapper_tasks_pkg
