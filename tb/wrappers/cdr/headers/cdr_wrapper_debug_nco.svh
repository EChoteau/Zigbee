task automatic test_cdr_wrapper_debug_nco();
    logic [21:0] bus_val;
    int timeout;
    begin
        $display("\n========== TEST: CFG4 (NCO) ==========");
        tb_pkg::set_config(i_clk, i_cfg_local, 3'b100);
        repeat(2) @(posedge i_clk);

        $display("  [NCO] Attente du signal d'horloge avec CTRL=0...");
        bus_val = '0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        
        timeout = 0;
        // o_bus_out[0] = s_ack
        while (o_bus_out[0] == 1'b0 && timeout < 20) begin
            @(posedge i_clk);
            timeout++;
        end
        
        if (timeout >= 20) $error("  [NCO] FAIL: L'oscillateur est bloque !");
        else $display("  [NCO] PASS: Tick d'horloge genere avec succes.");

        $display("========== CFG4 COMPLETE ==========\n");
    end
endtask