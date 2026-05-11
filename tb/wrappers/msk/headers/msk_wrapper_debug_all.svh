task automatic test_msk_wrapper_debug_all();
    logic [21:0] bus_val;
    begin
        $display("\n========== TEST: CFG4 (DEBUG ALL) ==========");
        set_config(3'b100);
        repeat(2) @(posedge i_clk);

        bus_val = '0;
        bus_val[3] = 1'b1; // enc
        bus_val[4] = 1'b1; // demux
        bus_val[5] = 1'b1; // shaping I
        bus_val[6] = 1'b1; // shaping Q
        bus_val[0] = 1'b1; // flag_en
        bus_val[1] = 1'b1; // ech_en
        set_bus(bus_val);
        
        repeat(2) @(posedge i_clk);
        assert (o_bus_out[2:0] != 3'b000)
            $display("  [ALL] PASS: Tous les signaux internes sont observables !");
        else $error("  [ALL] FAIL: Un ou plusieurs blocs ne repondent pas");

        $display("========== CFG4 COMPLETE ==========\n");
    end
endtask