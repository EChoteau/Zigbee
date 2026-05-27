// ============================================================================
// PACKAGE: cordic_wrapper_tasks_pkg
// ============================================================================
// Wrapper test tasks for CORDIC wrapper, callable from top_tb.
// ============================================================================

package cordic_wrapper_tasks_pkg;

    import tb_pkg::*;

    task automatic test_cordic_wrapper_debug_cordic(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic signed [7:0] phase_out;
        begin
            $display("\n========== TEST: CFG1 (CORDIC ISOLE) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b001); // MODE_1
            repeat(2) @(posedge i_clk);

            $display("  [CORDIC] Injection I=31, Q=31 (+45 degres)...");
            bus_val = '0;
            bus_val[5:0]  = 6'd31;
            bus_val[11:6] = 6'd31;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            // Latence du pipeline
            repeat(15) @(posedge i_clk);
            phase_out = o_bus_out[7:0];

            // ASSERTION : 45 degres correspond a 8'sh20 (32) dans ta table.
            // On verifie que c'est strictement positif et > 20 pour eponger les arrondis fixes.
            assert (phase_out > 8'sd20)
                $display("  [CORDIC] PASS: Phase positive calculee correctement : %d", phase_out);
            else $error("  [CORDIC] FAIL: Phase attendue > 20 pour le quadrant 1. Lue = %d", phase_out);

            $display("  [CORDIC] Injection I=31, Q=-31 (-45 degres)...");
            bus_val[11:6] = -6'sd31; // Q negatif
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            repeat(15) @(posedge i_clk);
            phase_out = o_bus_out[7:0];

            // ASSERTION : Phase doit etre strictement negative
            assert (phase_out < -8'sd20)
                $display("  [CORDIC] PASS: Phase negative calculee correctement : %d", phase_out);
            else $error("  [CORDIC] FAIL: Phase attendue < -20 pour le quadrant 4. Lue = %d", phase_out);

            $display("========== CFG1 COMPLETE ==========\n");
        end
    endtask

    task automatic test_cordic_wrapper_debug_deriv(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic signed [7:0] deriv_out;
        begin
            $display("\n========== TEST: CFG2 (DERIVATEUR COMPACT) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b010); // MODE_2
            repeat(2) @(posedge i_clk);

            $display("  [DERIV] Initialisation du derivateur a 0...");
            bus_val = '0;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            // On attend 2 cycles pour s'assurer que s_phase_reg et o_phase_deriv sont bien a 0
            repeat(2) @(posedge i_clk);

            $display("  [DERIV] Injection d'une rampe de phase (+10 par cycle)...");
            // On commence la boucle a 1 pour envoyer 10, 20, 30...
            for (int i = 1; i <= 5; i++) begin
                bus_val[7:0] = i * 10;

                // La tache set_bus ecrit la valeur ET attend le prochain front montant.
                // Au front montant, le RTL fait : o_phase_deriv <= i_phase - s_phase_reg
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

                // Lecture apres mise a jour du registre de derivee.
                @(posedge i_clk);
                deriv_out = o_bus_out[7:0];

                // ASSERTION A L'INTERIEUR DE LA BOUCLE : On check chaque pas !
                assert (deriv_out == 8'sd10)
                    $display("  [DERIV] PASS: Etape %0d, Derivee exacte de +10 calculee !", i);
                else $error("  [DERIV] FAIL: Etape %0d, Derivee attendue = 10. Lue = %d", i, deriv_out);
            end

            $display("========== CFG2 COMPLETE ==========\n");
        end
    endtask

    task automatic test_cordic_wrapper_debug_filter(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic signed [7:0] filter_out;
        begin
            $display("\n========== TEST: CFG3 (FILTRE COMPACT) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b011); // MODE_3
            repeat(2) @(posedge i_clk);

            $display("  [FILTER] Injection d'une constante de 20...");
            bus_val = '0;
            bus_val[7:0] = 8'sd20; // Constante a 20
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            // On attend que les N=5 etages de la ligne a retard se remplissent completement
            repeat(10) @(posedge i_clk);
            filter_out = o_bus_out[7:0];

            // ASSERTION : Puisque le Boxcar_filter fait la SOMME de N=5 echantillons,
            // la sortie doit etre EXACTEMENT 5 * 20 = 100.
            assert (filter_out == 8'sd100)
                $display("  [FILTER] PASS: Somme glissante N=5 correcte (5 * 20 = 100) !");
            else $error("  [FILTER] FAIL: Sortie attendue = 100. Lue = %d", filter_out);

            $display("========== CFG3 COMPLETE ==========\n");
        end
    endtask

    task automatic test_cordic_wrapper_normal(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic signed [7:0] final_out;
        begin
            $display("\n========== TEST: CFG0 (CORDIC NORMAL CHAIN) ==========");
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, 3'b000); // MODE_0
            repeat(2) @(posedge i_clk);

            // ---------------------------------------------------------
            // ETAPE 1 : Vecteur statique -> Frequence nulle
            // ---------------------------------------------------------
            $display("  [NORMAL] Etape 1: Vecteur constant I=31, Q=31 (Phase = 45 deg)...");
            bus_val = '0;
            bus_val[5:0]  = 6'd31;
            bus_val[11:6] = 6'd31;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

            // On attend que le pipeline se remplisse (CORDIC + DERIV + FILTRE)
            repeat(25) @(posedge i_clk);

            final_out = o_bus_out[7:0];
            $display("  [NORMAL] Sortie finale Filtre : %d", final_out);

            // ASSERTION 1 : La derivee d'une phase constante doit etre 0
            assert (final_out == 8'sd0)
                $display("  [NORMAL] PASS 1: Frequence nulle confirmee pour un vecteur statique.");
            else
                $error("  [NORMAL] FAIL 1: La sortie doit etre 0 pour un vecteur fixe. Lu = %d", final_out);

            // ---------------------------------------------------------
            // ETAPE 2 : Vecteur en rotation -> Frequence positive
            // ---------------------------------------------------------
            $display("  [NORMAL] Etape 2: Rotation +90 deg/cycle (I, Q)...");
            // On fait tourner le vecteur : Q1 -> Q2 -> Q3 -> Q4 pour simuler une frequence
            for (int i = 0; i < 20; i++) begin
                bus_val = '0;
                case (i % 4)
                    0: begin bus_val[5:0] =  6'sd31; bus_val[11:6] =  6'sd31; end // Quadrant 1 (+45 deg)
                    1: begin bus_val[5:0] = -6'sd31; bus_val[11:6] =  6'sd31; end // Quadrant 2 (+135 deg)
                    2: begin bus_val[5:0] = -6'sd31; bus_val[11:6] = -6'sd31; end // Quadrant 3 (-135 deg)
                    3: begin bus_val[5:0] =  6'sd31; bus_val[11:6] = -6'sd31; end // Quadrant 4 (-45 deg)
                endcase
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            end

            final_out = o_bus_out[7:0];
            $display("  [NORMAL] Sortie finale Filtre en rotation : %d", final_out);

            // ASSERTION 2 : La derivee d'une phase croissante doit etre positive
            assert (final_out > 8'sd0)
                $display("  [NORMAL] PASS 2: Frequence positive detectee avec succes en dynamique !");
            else
                $error("  [NORMAL] FAIL 2: La frequence doit etre > 0 en rotation. Lu = %d", final_out);

            $display("========== CFG0 COMPLETE ==========\n");
        end
    endtask

    task automatic run_cordic_wrapper_test_plan(
        ref logic i_clk,
        ref logic i_rst_n,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
    begin
        test_cordic_wrapper_debug_cordic(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_cordic_wrapper_debug_deriv(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_cordic_wrapper_debug_filter(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        test_cordic_wrapper_normal(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);

        $display("\n========== ALL CORDIC WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
    end
    endtask

endpackage : cordic_wrapper_tasks_pkg
