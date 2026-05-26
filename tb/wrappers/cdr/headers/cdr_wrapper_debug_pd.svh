task automatic test_cdr_wrapper_debug_pd();
    logic [21:0] bus_val;
    begin
        $display("\n========== TEST: CFG2 (PHASE DETECTOR) ==========");
        tb_pkg::set_config(i_clk, i_cfg_local, 3'b010);
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

        // On vérifie que le détecteur réagit (up ou down ne sont pas nuls)
        // o_bus_out[1:0] = {s_up, s_down}
        assert (o_bus_out[1:0] != 2'b00) 
            $display("  [PD] PASS: Le detecteur a reagi (UP=%b, DOWN=%b)", o_bus_out[1], o_bus_out[0]);
        else $error("  [PD] FAIL: Le detecteur de phase est muet !");

        $display("========== CFG2 COMPLETE ==========\n");
    end
endtask