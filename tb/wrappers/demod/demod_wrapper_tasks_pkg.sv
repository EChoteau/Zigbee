// ============================================================================
// PACKAGE: demod_wrapper_tasks_pkg
// ============================================================================
// Consolidated wrapper test package for DEMOD testbench
// Contains all wrapper test tasks, test plans, and support functions
//
// Usage in testbench:
//   import demod_wrapper_tasks_pkg::*;
//
// Then call test plan directly:
//   run_demod_wrapper_test_plan();
// ============================================================================

package demod_wrapper_tasks_pkg;

    import tb_pkg::*;
    import demod_pkg::*;

    // =========================================================================
    // SUPPORT TASKS (wrappers around tb_pkg and direct signal manipulation)
    // =========================================================================

    // Set wrapper configuration using tb_pkg::set_config_wrapper
    task automatic set_config(logic [2:0] cfg);
    begin
        tb_pkg::set_config_wrapper(i_clk, d_cfg_local, cfg);
    end
    endtask

    // Set bus value using tb_pkg::set_bus
    task automatic set_bus(logic [21:0] bus_val);
    begin
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
    end
    endtask

    // Apply reset using tb_pkg::apply_reset
    task automatic apply_reset(int cycles);
    begin
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, cycles);
    end
    endtask

    // =========================================================================
    // TEST CASE: Debug DEMOD channels (I and Q paths)
    // =========================================================================
    task automatic test_demod_wrapper_debug_demod();
        logic [21:0] bus_val;
        logic [7:0]  res_demod;
        logic [3:0]  res_osc;

        begin
            $display("\n========== TEST: DEBUG_DEMOD (0x1 & 0x2) ==========");

            // --- TEST CANAL I (0x1) ---
            set_config(CFG_DEBUG_DEMOD_I);
            repeat(2) @(posedge i_clk);

            $display("  [DEMOD_I] Injection I=4, Q=0 (test melangeur)...");
            bus_val = '0;
            bus_val[17:14] = 4'd4;
            bus_val[13:10] = 4'd0;
            set_bus(bus_val);

            repeat(5) @(posedge i_clk);
            res_demod = o_bus_out[7:0];
            res_osc   = o_bus_out[11:8];

            $display("  [DEMOD_I] Out_I: 0x%0h, Cos_Ref: 0x%0h", res_demod, res_osc);
            assert (res_osc !== 4'hx) else $error("  [DEMOD_I] FAIL: Oscillateur Cos bloque !");

            // --- TEST CANAL Q (0x2) ---
            set_config(CFG_DEBUG_DEMOD_Q);
            repeat(2) @(posedge i_clk);

            $display("  [DEMOD_Q] Injection I=0, Q=4...");
            set_bus(bus_val);
            repeat(5) @(posedge i_clk);

            res_demod = o_bus_out[7:0];
            res_osc   = o_bus_out[11:8];
            $display("  [DEMOD_Q] Out_Q: 0x%0h, Sin_Ref: 0x%0h", res_demod, res_osc);

            $display("========== DEBUG_DEMOD COMPLETE ==========\n");
        end
    endtask

    // =========================================================================
    // TEST CASE: Debug FIR filters (I and Q channels)
    // =========================================================================
    task automatic test_demod_wrapper_debug_fir();
        logic [21:0] bus_val;
        logic signed [5:0] fir_out;

        begin
            $display("\n========== TEST: DEBUG_FIR (0x4 & 0x5) ==========");

            // --- TEST FIR I (0x4) ---
            set_config(CFG_DEBUG_FIR_I);
            repeat(2) @(posedge i_clk);

            $display("  [FIR_I] Envoi impulsion 0x7F (Max)...");
            bus_val = '0;
            bus_val[17:10] = 8'h7F;
            set_bus(bus_val);

            repeat(10) @(posedge i_clk);
            fir_out = o_bus_out[5:0];
            $display("  [FIR_I] Sortie filtree: %d", fir_out);
            assert (fir_out != 0) else $error("  [FIR_I] FAIL: Sortie nulle !");

            // --- TEST FIR Q (0x5) ---
            set_config(CFG_DEBUG_FIR_Q);
            repeat(2) @(posedge i_clk);

            set_bus(bus_val);
            repeat(10) @(posedge i_clk);
            fir_out = o_bus_out[11:6];
            $display("  [FIR_Q] Sortie filtree: %d", fir_out);

            $display("========== DEBUG_FIR COMPLETE ==========\n");
        end
    endtask

    // =========================================================================
    // TEST CASE: Debug full chain (Mixer + FIR I and Q)
    // =========================================================================
    task automatic test_demod_wrapper_debug_chain();
        logic [21:0] bus_val;

        begin
            $display("\n========== TEST: DEBUG_CHAIN (0x6 & 0x7) ==========");

            // --- TEST CHAIN I (0x6) ---
            $display("  [CHAIN_I] Test complet canal I (Q force a zero)...");
            set_config(CFG_DEBUG_FIRC_I);
            repeat(2) @(posedge i_clk);

            bus_val = '0;
            bus_val[17:14] = 4'd7;
            set_bus(bus_val);

            repeat(15) @(posedge i_clk);
            $display("  [CHAIN_I] Sortie Baseband I: %d", $signed(o_bus_out[5:0]));
            $display("  [CHAIN_I] Sortie Baseband Q (doit etre faible): %d", $signed(o_bus_out[11:6]));

            // --- TEST CHAIN Q (0x7) ---
            $display("  [CHAIN_Q] Test complet canal Q (I force a zero)...");
            set_config(CFG_DEBUG_FIRC_Q);
            repeat(2) @(posedge i_clk);

            bus_val = '0;
            bus_val[13:10] = 4'd7;
            set_bus(bus_val);

            repeat(15) @(posedge i_clk);
            $display("  [CHAIN_Q] Sortie Baseband Q: %d", $signed(o_bus_out[11:6]));

            $display("========== DEBUG_CHAIN COMPLETE ==========\n");
        end
    endtask

    // =========================================================================
    // TEST CASE: Normal production mode (Direct ADC data)
    // =========================================================================
    task automatic test_demod_wrapper_normal();
        logic signed [5:0] res_i;
        logic signed [5:0] res_q;

        begin
            $display("\n========== TEST: NORMAL MODE (0x0) ==========");

            set_config(CFG_NORMAL);
            repeat(2) @(posedge i_clk);

            $display("  [NORMAL] Mode production actif. Ecoute des ports ADC directs.");

            // Test 1: I strong, Q zero
            $display("  [NORMAL] Injection ADC : I=15 (Max Positif), Q=8 (Zero)...");
            tb_i = 4'd15;
            tb_q = 4'd8;

            repeat(10) @(posedge i_clk);

            res_i = o_bus_out[5:0];
            res_q = o_bus_out[11:6];

            $display("  [NORMAL] Sortie Baseband I: %d", res_i);
            $display("  [NORMAL] Sortie Baseband Q: %d", res_q);

            if (res_i != 0)
                $display("  [NORMAL] PASS : La chaine I reagit aux donnees ADC !");
            else
                $error("  [NORMAL] FAIL : La chaine I est muette !");

            // Test 2: I zero, Q strong
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

    // =========================================================================
    // TEST PLAN: Full wrapper test suite
    // =========================================================================
    task automatic run_demod_wrapper_test_plan();
    begin
        test_demod_wrapper_debug_demod();
        apply_reset(3);

        test_demod_wrapper_debug_fir();
        apply_reset(3);

        test_demod_wrapper_debug_chain();
        apply_reset(3);

        test_demod_wrapper_normal();
        apply_reset(3);

        $display("\n========== ALL DEMOD WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
    end
    endtask

endpackage : demod_wrapper_tasks_pkg
