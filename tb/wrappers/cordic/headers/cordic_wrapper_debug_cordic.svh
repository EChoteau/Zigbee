task automatic test_cordic_wrapper_debug_cordic();
    logic [21:0] bus_val;
    logic signed [7:0] phase_out;
    begin
        $display("\n========== TEST: CFG1 (CORDIC ISOLÉ) ==========");
        set_config(3'b001); // MODE_1 
        repeat(2) @(posedge i_clk);

        $display("  [CORDIC] Injection I=31, Q=31 (Angle attendu: ~45 degres)...");
        bus_val = '0;
        // On suppose que i_i est sur [5:0] et i_q sur [11:6] selon ton top
        bus_val[5:0]  = 6'd31; 
        bus_val[11:6] = 6'd31; 
        set_bus(bus_val);
        
        // Le CORDIC est pipeliné (NUM_STEPS cycles de latence), on attend un peu
        repeat(15) @(posedge i_clk);
        
        phase_out = o_bus_out[7:0]; // o_bus_out[7:0] = w_phase_cordic 
        $display("  [CORDIC] Phase calculee : %d", phase_out);
        assert (phase_out > 0) else $error("  [CORDIC] FAIL: La phase devrait etre positive.");

        $display("  [CORDIC] Injection I=31, Q=-31 (Angle attendu: ~-45 degres)...");
        bus_val[11:6] = -6'sd31; 
        set_bus(bus_val);
        repeat(15) @(posedge i_clk);
        
        phase_out = o_bus_out[7:0];
        $display("  [CORDIC] Phase calculee : %d", phase_out);
        assert (phase_out < 0) else $error("  [CORDIC] FAIL: La phase devrait etre negative.");

        $display("========== CFG1 COMPLETE ==========\n");
    end
endtask