task automatic test_msk_wrapper_debug_demux();
    logic [21:0] bus_val;
    begin
        $display("\n========== TEST: CFG2 (DEBUG DEMUX) ==========");
        set_config(3'b010);
        repeat(2) @(posedge i_clk);

        $display("  [DEMUX] Injection d'un bit '1' pour basculer les voies...");
        bus_val = '0;
        bus_val[4] = 1'b1; // dbg_demux_b_enc
        bus_val[0] = 1'b1; // flag_enable pulse
        set_bus(bus_val);
        bus_val[0] = 1'b0; // On relache le flag pour ne faire qu'un pas
        set_bus(bus_val);
        repeat(2) @(posedge i_clk);

        // Sorties sur o_bus_out[1] (a_I) et o_bus_out[0] (a_Q)
        assert (o_bus_out[1:0] != 2'b00) 
            $display("  [DEMUX] PASS: Le demux a route la donnee (a_I=%b, a_Q=%b)", o_bus_out[1], o_bus_out[0]);
        else $error("  [DEMUX] FAIL: Les voies I/Q sont muettes");

        $display("========== CFG2 COMPLETE ==========\n");
    end
endtask