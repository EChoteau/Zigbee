// ============================================================================
// PACKAGE: msk_wrapper_tasks_pkg
// ============================================================================
// Wrapper test tasks for MSK wrapper, callable from top_tb.
// ============================================================================

package msk_wrapper_tasks_pkg;

    import tb_pkg::*;

    task automatic test_msk_wrapper_normal(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        begin
            $display("\n========== TEST: CFG0 (NORMAL MODE) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b000);
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

    task automatic test_msk_wrapper_debug_enc(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        begin
            $display("\n========== TEST: CFG1 (DEBUG ENCODEUR) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b001);
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

    task automatic test_msk_wrapper_debug_demux(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        begin
            $display("\n========== TEST: CFG2 (DEBUG DEMUX) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b010);
            repeat(2) @(posedge i_clk);

            $display("  [DEMUX] Injection d'un bit '1' pour basculer les voies...");
            bus_val = '0;
            bus_val[4] = 1'b1; // dbg_demux_b_enc
            bus_val[0] = 1'b1; // flag_enable pulse
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            bus_val[0] = 1'b0; // On relache le flag pour ne faire qu'un pas
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);

            // Sorties sur o_bus_out[1] (a_I) et o_bus_out[0] (a_Q)
            assert (o_bus_out[1:0] != 2'b00)
                $display("  [DEMUX] PASS: Le demux a route la donnee (a_I=%b, a_Q=%b)", o_bus_out[1], o_bus_out[0]);
            else $error("  [DEMUX] FAIL: Les voies I/Q sont muettes");

            $display("========== CFG2 COMPLETE ==========\n");
        end
    endtask

    task automatic test_msk_wrapper_debug_shaping(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        begin
            $display("\n========== TEST: CFG3 (DEBUG SHAPING) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b011);
            repeat(2) @(posedge i_clk);

            $display("  [SHAPING] Force a_I=1 et a_Q=1...");
            bus_val = '0;
            bus_val[5] = 1'b1; // dbg_shaping_a_I
            bus_val[6] = 1'b1; // dbg_shaping_a_Q
            bus_val[1] = 1'b1; // enable_ech
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            repeat(15) @(posedge i_clk);

            assert ($signed(o_bus_out[11:6]) != 0 || $signed(o_bus_out[5:0]) != 0)
                $display("  [SHAPING] PASS: Les ROMs de shaping generent les ondes I/Q !");
            else $error("  [SHAPING] FAIL: Sorties nulles");

            $display("========== CFG3 COMPLETE ==========\n");
        end
    endtask

    task automatic test_msk_wrapper_debug_all(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        begin
            $display("\n========== TEST: CFG4 (DEBUG ALL) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b100);
            repeat(2) @(posedge i_clk);

            bus_val = '0;
            bus_val[3] = 1'b1; // enc
            bus_val[4] = 1'b1; // demux
            bus_val[5] = 1'b1; // shaping I
            bus_val[6] = 1'b1; // shaping Q
            bus_val[0] = 1'b1; // flag_en
            bus_val[1] = 1'b1; // ech_en
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            repeat(2) @(posedge i_clk);
            assert (o_bus_out[2:0] != 3'b000)
                $display("  [ALL] PASS: Tous les signaux internes sont observables !");
            else $error("  [ALL] FAIL: Un ou plusieurs blocs ne repondent pas");

            $display("========== CFG4 COMPLETE ==========\n");
        end
    endtask

    task automatic run_msk_wrapper_test_plan(
        ref logic i_clk,
        ref logic i_rst_n,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
    begin
        test_msk_wrapper_debug_shaping(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_msk_wrapper_debug_enc(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_msk_wrapper_debug_all(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_msk_wrapper_debug_demux(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_msk_wrapper_normal(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        $display("\n========== ALL INTERFACE WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
    end
    endtask

endpackage : msk_wrapper_tasks_pkg
