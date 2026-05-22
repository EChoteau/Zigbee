task automatic test_cordic_wrapper_normal();
    logic [21:0] bus_val;
    logic signed [7:0] final_out;
    begin
        $display("\n========== TEST: CFG0 (CORDIC NORMAL CHAIN) ==========");
        set_config(3'b000); // MODE_0
        repeat(2) @(posedge i_clk);

        // ---------------------------------------------------------
        // ETAPE 1 : Vecteur statique -> Fréquence nulle
        // ---------------------------------------------------------
        $display("  [NORMAL] Etape 1: Vecteur constant I=31, Q=31 (Phase = 45 deg)...");
        bus_val = '0;
        bus_val[5:0]  = 6'd31; 
        bus_val[11:6] = 6'd31; 
        set_bus(bus_val);
        
        // On attend que le pipeline se remplisse (CORDIC + DERIV + FILTRE)
        repeat(25) @(posedge i_clk);
        
        final_out = o_bus_out[7:0];
        $display("  [NORMAL] Sortie finale Filtre : %d", final_out);
        
        // ASSERTION 1 : La dérivée d'une phase constante doit être 0
        assert (final_out == 8'sd0) 
            $display("  [NORMAL] PASS 1: Frequence nulle confirmee pour un vecteur statique.");
        else 
            $error("  [NORMAL] FAIL 1: La sortie doit etre 0 pour un vecteur fixe. Lu = %d", final_out);

        // ---------------------------------------------------------
        // ETAPE 2 : Vecteur en rotation -> Fréquence positive
        // ---------------------------------------------------------
        $display("  [NORMAL] Etape 2: Rotation +90 deg/cycle (I, Q)...");
        // On fait tourner le vecteur : Q1 -> Q2 -> Q3 -> Q4 pour simuler une fréquence
        for (int i=0; i<20; i++) begin
            bus_val = '0;
            case (i % 4)
                0: begin bus_val[5:0] =  6'sd31; bus_val[11:6] =  6'sd31; end // Quadrant 1 (+45°)
                1: begin bus_val[5:0] = -6'sd31; bus_val[11:6] =  6'sd31; end // Quadrant 2 (+135°)
                2: begin bus_val[5:0] = -6'sd31; bus_val[11:6] = -6'sd31; end // Quadrant 3 (-135°)
                3: begin bus_val[5:0] =  6'sd31; bus_val[11:6] = -6'sd31; end // Quadrant 4 (-45°)
            endcase
            set_bus(bus_val);
        end
        
        final_out = o_bus_out[7:0];
        $display("  [NORMAL] Sortie finale Filtre en rotation : %d", final_out);
        
        // ASSERTION 2 : La dérivée d'une phase croissante doit être positive
        assert (final_out > 8'sd0) 
            $display("  [NORMAL] PASS 2: Frequence positive detectee avec succes en dynamique !");
        else 
            $error("  [NORMAL] FAIL 2: La frequence doit etre > 0 en rotation. Lu = %d", final_out);

        $display("========== CFG0 COMPLETE ==========\n");
    end
endtask