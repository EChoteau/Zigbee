// ============================================================================
// PACKAGE: cdr_wrapper_tasks_pkg
// ============================================================================
// Wrapper test tasks for CDR wrapper, callable from top_tb.
// ============================================================================

package cdr_wrapper_tasks_pkg;

    import tb_pkg::*;

    task automatic test_cdr_wrapper_debug_decision(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        begin
            $display("\n========== TEST: CFG1 (DECISION BLOCK) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b001);
            repeat(2) @(posedge i_clk);

            $display("  [DECISION] Test de l'avance de phase (dphi = +8)...");
            bus_val = '0;
            bus_val[7:0] = 8'sd8; // w_dphi = +8
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);
            // o_bus_out[0] = s_decision_sig
            assert (o_bus_out[0] == 1'b1)
                $display("  [DECISION] PASS: decision = 1");
            else $error("  [DECISION] FAIL: dphi=+8 doit donner decision=1");

            $display("  [DECISION] Test du retard de phase (dphi = -8)...");
            bus_val[7:0] = -8'sd8; // w_dphi = -8
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);
            assert (o_bus_out[0] == 1'b0)
                $display("  [DECISION] PASS: decision = 0");
            else $error("  [DECISION] FAIL: dphi=-8 doit donner decision=0");

            $display("========== CFG1 COMPLETE ==========\n");
        end
    endtask

    task automatic test_cdr_wrapper_debug_lf(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic signed [3:0] ctrl;
        begin
            $display("\n========== TEST: CFG3 (LOOP FILTER) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b011);
            repeat(2) @(posedge i_clk);

            $display("  [LF] Injection d'une impulsion UP...");
            bus_val = '0;
            bus_val[12] = 1'b1; // w_lf_up = 1
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            bus_val[12] = 1'b0;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val); // Rabaisser le signal
            repeat(2) @(posedge i_clk);

            ctrl = o_bus_out[3:0]; // o_bus_out contient s_control
            assert (ctrl == 4'sd1)
                $display("  [LF] PASS: Commande de controle = +1");
            else $error("  [LF] FAIL: ctrl devrait etre +1 apres un UP. Lu = %d", ctrl);

            $display("  [LF] Envoi de l'acquittement (ACK)...");
            bus_val = '0;
            bus_val[10] = 1'b1; // w_lf_ctrl_ack = 1
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            bus_val[10] = 1'b0;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);

            ctrl = o_bus_out[3:0];
            assert (ctrl == 4'sd0)
                $display("  [LF] PASS: Commande remise a zero");
            else $error("  [LF] FAIL: ctrl devrait etre 0 apres un ACK. Lu = %d", ctrl);

            $display("========== CFG3 COMPLETE ==========\n");
        end
    endtask

    task automatic test_cdr_wrapper_debug_nco(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        int timeout;
        begin
            $display("\n========== TEST: CFG4 (NCO) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b100);
            repeat(2) @(posedge i_clk);

            $display("  [NCO] Attente du signal d'horloge avec CTRL=0...");
            bus_val = '0;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            timeout = 0;
            // o_bus_out[0] = s_ack
            while (o_bus_out[0] == 1'b0 && timeout < 20) begin
                @(posedge i_clk);
                timeout++;
            end

            if (timeout >= 20) $error("  [NCO] FAIL: L'oscillateur est bloque !");
            else $display("  [NCO] PASS: Tick d'horloge genere avec succes.");

            $display("========== CFG4 COMPLETE ==========\n");
        end
    endtask

    task automatic test_cdr_wrapper_debug_pd(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        begin
            $display("\n========== TEST: CFG2 (PHASE DETECTOR) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b010);
            repeat(2) @(posedge i_clk);

            // Simulation d'une transition asynchrone
            $display("  [PD] Generation d'une transition asynchrone...");
            bus_val = '0;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);

            bus_val[11] = 1'b1; // decision_in = 1
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(1) @(posedge i_clk);

            bus_val[10] = 1'b1; // sample_clk = 1
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);

            // On verifie que le detecteur reagit (up ou down ne sont pas nuls)
            // o_bus_out[1:0] = {s_up, s_down}
            assert (o_bus_out[1:0] != 2'b00)
                $display("  [PD] PASS: Le detecteur a reagi (UP=%b, DOWN=%b)", o_bus_out[1], o_bus_out[0]);
            else $error("  [PD] FAIL: Le detecteur de phase est muet !");

            $display("========== CFG2 COMPLETE ==========\n");
        end
    endtask

    task automatic test_cdr_wrapper_normal(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        int timeout;
        bit data_ok;
        begin
            $display("\n========== TEST: CFG0 (CDR NORMAL MODE) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b000);
            repeat(2) @(posedge i_clk);

            $display("  [NORMAL] Injection d'un flux DPHI stable (+8)...");
            bus_val = '0;
            bus_val[7:0] = 8'sd8;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            // Attente d'une impulsion sample_enable et validation de la donnee sur plusieurs cycles
            // o_bus_out[0] = s_sample_enable, o_bus_out[1] = s_data
            timeout = 0;
            data_ok = 1'b0;
            while (timeout < 50 && data_ok == 1'b0) begin
                @(posedge i_clk);
                if (o_bus_out[0] == 1'b1) begin
                    if (o_bus_out[1] == 1'b1) begin
                        data_ok = 1'b1;
                    end
                end
                timeout++;
            end

            assert (data_ok == 1'b1)
                $display("  [NORMAL] PASS: Donnee '1' recuperee avec succes !");
            else
                $error("  [NORMAL] FAIL: Erreur de donnee.");

            $display("========== CFG0 COMPLETE ==========\n");
        end
    endtask

    task automatic run_cdr_wrapper_test_plan(
        ref logic i_clk,
        ref logic i_rst_n,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
    begin
        test_cdr_wrapper_debug_decision(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_cdr_wrapper_debug_lf(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_cdr_wrapper_debug_nco(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_cdr_wrapper_debug_pd(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_cdr_wrapper_normal(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        $display("\n========== ALL CDR WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
    end
    endtask

endpackage : cdr_wrapper_tasks_pkg
