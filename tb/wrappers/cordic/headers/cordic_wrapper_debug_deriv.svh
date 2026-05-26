task automatic test_cordic_wrapper_debug_deriv();
    logic [21:0] bus_val;
    logic signed [7:0] deriv_out;
    begin
        $display("\n========== TEST: CFG2 (DERIVATEUR COMPACT) ==========");
        tb_pkg::set_config(i_clk, i_cfg_local, 3'b010); // MODE_2
        repeat(2) @(posedge i_clk);

        $display("  [DERIV] Initialisation du derivateur a 0...");
        bus_val = '0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        // On attend 2 cycles pour s'assurer que s_phase_reg et o_phase_deriv sont bien a 0
        repeat(2) @(posedge i_clk); 

        $display("  [DERIV] Injection d'une rampe de phase (+10 par cycle)...");
        // On commence la boucle à 1 pour envoyer 10, 20, 30...
        for (int i = 1; i <= 5; i++) begin
            bus_val[7:0] = i * 10; 
            
            // La tache set_bus ecrit la valeur ET attend le prochain front montant.
            // Au front montant, le RTL fait : o_phase_deriv <= i_phase - s_phase_reg
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val); 
            
            // Des la sortie de set_bus, le resultat du cycle est disponible !
            deriv_out = o_bus_out[7:0]; 
            
            // ASSERTION A L'INTERIEUR DE LA BOUCLE : On check chaque pas !
            assert (deriv_out == 8'sd10) 
                $display("  [DERIV] PASS: Etape %0d, Derivee exacte de +10 calculee !", i);
            else $error("  [DERIV] FAIL: Etape %0d, Derivee attendue = 10. Lue = %d", i, deriv_out);
        end

        $display("========== CFG2 COMPLETE ==========\n");
    end
endtask