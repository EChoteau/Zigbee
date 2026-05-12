task automatic test_cordic_wrapper_debug_deriv();
    logic [21:0] bus_val;
    logic signed [7:0] deriv_out;
    begin
        $display("\n========== TEST: CFG2 (DERIVATEUR ISOLÉ) ==========");
        set_config(3'b010); // MODE_2 
        repeat(2) @(posedge i_clk);

        $display("  [DERIV] Simulation d'une rampe de phase (rotation constante)...");
        
        // On envoie une phase qui augmente de +10 a chaque cycle
        for (int i = 0; i < 5; i++) begin
            bus_val = '0;
            // *NOTE: Adapte les bits `bus_val[x:y]` selon comment tu as mappé 
            // i_phase_to_derivative dans ton cordic_wrapper.sv
            bus_val[7:0] = i * 10; 
            set_bus(bus_val);
        end
        
        repeat(2) @(posedge i_clk); // Latence du derivateur [cite: 13]
        deriv_out = o_bus_out[7:0]; // o_bus_out[7:0] = w_phase_deriv 
        
        $display("  [DERIV] Derivee calculee : %d", deriv_out);
        assert (deriv_out == 8'sd10) else $error("  [DERIV] FAIL: La derivee devrait etre de +10. Lu = %d", deriv_out);

        $display("========== CFG2 COMPLETE ==========\n");
    end
endtask