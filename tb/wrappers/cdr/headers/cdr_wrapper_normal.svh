task automatic test_cdr_wrapper_normal();
    logic [21:0] bus_val;
    int timeout;
    begin
        $display("\n========== TEST: CFG0 (CDR NORMAL MODE) ==========");
        tb_pkg::set_config(i_clk, i_cfg_local, 3'b000);
        repeat(2) @(posedge i_clk);

        $display("  [NORMAL] Injection d'un flux DPHI stable (+8)...");
        bus_val = '0;
        bus_val[7:0] = 8'sd8; 
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        
        // Attente d'une impulsion sample_enable et validation de la donnee sur plusieurs cycles
        // o_bus_out[0] = s_sample_enable, o_bus_out[1] = s_data
        timeout = 0;
        bit data_ok = 1'b0;
        while (timeout < 50 && data_ok == 1'b0) begin
            @(posedge i_clk);
            if (o_bus_out[0] == 1'b1) begin
                if (o_bus_out[1] == 1'b1) begin
                    data_ok = 1'b1;
                end
            end
            timeout++;
        end

        assert (data_ok == 1'b1)
            $display("  [NORMAL] PASS: Donnee '1' recuperee avec succes !");
        else
            $error("  [NORMAL] FAIL: Erreur de donnee.");

        $display("========== CFG0 COMPLETE ==========\n");
    end
endtask