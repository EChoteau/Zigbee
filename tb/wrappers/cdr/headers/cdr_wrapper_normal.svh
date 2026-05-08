task automatic test_cdr_wrapper_normal();
    logic [21:0] bus_val;
    int timeout;
    begin
        $display("\n========== TEST: CFG0 (CDR NORMAL MODE) ==========");
        set_config(3'b000);
        repeat(2) @(posedge i_clk);

        $display("  [NORMAL] Injection d'un flux DPHI stable (+8)...");
        bus_val = '0;
        bus_val[7:0] = 8'sd8; 
        set_bus(bus_val);
        
        // Attente de l'echantillonnage par le NCO interne
        // o_bus_out[0] = s_sample_enable
        timeout = 0;
        while (o_bus_out[0] == 1'b0 && timeout < 20) begin
            @(posedge i_clk);
            timeout++;
        end
        
        // Au cycle suivant, la donnee doit etre recuperee sur o_bus_out[1] (o_data)
        @(posedge i_clk);
        assert (o_bus_out[1] == 1'b1)
            $display("  [NORMAL] PASS: Donnee '1' recuperee avec succes !");
        else
            $error("  [NORMAL] FAIL: Erreur de donnee.");

        $display("========== CFG0 COMPLETE ==========\n");
    end
endtask