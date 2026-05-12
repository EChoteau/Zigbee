task automatic test_cordic_wrapper_debug_filter();
    logic [21:0] bus_val;
    logic signed [7:0] filter_out;
    begin
        $display("\n========== TEST: CFG3 (FILTRE COMPACT) ==========");
        set_config(3'b011); // MODE_3
        repeat(2) @(posedge i_clk);

        $display("  [FILTER] Injection d'une constante de 20...");
        bus_val = '0;
        bus_val[7:0] = 8'sd20; // Constante a 20
        set_bus(bus_val);
        
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