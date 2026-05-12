task automatic test_cordic_wrapper_debug_filter();
    logic [21:0] bus_val;
    logic signed [7:0] filter_out;
    begin
        $display("\n========== TEST: CFG3 (FILTRE ISOLÉ) ==========");
        set_config(3'b011); // MODE_3 
        repeat(2) @(posedge i_clk);

        $display("  [FILTER] Injection d'un echelon constant a 20...");
        bus_val = '0;
        bus_val[7:0] = 8'd20; // Adapte les bits d'entree si besoin
        set_bus(bus_val);
        
        // Le filtre a une fenetre N=5, il faut attendre qu'il se remplisse
        repeat(10) @(posedge i_clk);
        
        filter_out = o_bus_out[7:0]; // w_phase_filter_out 
        $display("  [FILTER] Sortie Filtree : %d", filter_out);
        
        // La moyenne d'une constante de 20 est 20 (aux arrondis pres)
        assert (filter_out != 0) else $error("  [FILTER] FAIL: Le filtre est muet.");

        $display("========== CFG3 COMPLETE ==========\n");
    end
endtask