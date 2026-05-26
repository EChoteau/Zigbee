task automatic test_cordic_wrapper_debug_cordic();
    logic [21:0] bus_val;
    logic signed [7:0] phase_out;
    begin
        $display("\n========== TEST: CFG1 (CORDIC ISOLÉ) ==========");
        tb_pkg::set_config(i_clk, i_cfg_local, 3'b001); // MODE_1
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