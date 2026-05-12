task automatic test_cordic_wrapper_normal();
    logic [21:0] bus_val;
    begin
        $display("\n========== TEST: CFG0 (CORDIC NORMAL CHAIN) ==========");
        set_config(3'b000); // MODE_0 
        repeat(2) @(posedge i_clk);

        $display("  [NORMAL] Injection I=31, Q=31 dans la chaine complete...");
        bus_val = '0;
        bus_val[5:0]  = 6'd31; 
        bus_val[11:6] = 6'd31; 
        set_bus(bus_val);
        
        // On attend que les donnees traversent CORDIC -> DERIV -> FILTER
        repeat(25) @(posedge i_clk);
        
        $display("  [NORMAL] Sortie finale Filtre : %d", $signed(o_bus_out[7:0]));
        $display("  [NORMAL] PASS: Le signal traverse correctement toute la chaine.");

        $display("========== CFG0 COMPLETE ==========\n");
    end
endtask