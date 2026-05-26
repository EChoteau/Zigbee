task automatic test_interface_wrapper_fifo_rx();
    logic [21:0] bus_val;
    logic [7:0] expected_data;
    logic [7:0] read_data;

    begin
        $display("\n========== START TEST: CFG_FIFO_RX (0x5) ==========");
        
        tb_pkg::set_config(i_clk, i_cfg_local, CFG_FIFO_RX);
        repeat(2) @(posedge i_clk);

        assert (i_cfg_local == CFG_FIFO_RX)
            $display("  [FIFO_RX] Config ok");
        else
            $error("  [FIFO_RX] Config error");

        // --- 1. VERIFICATION FIFO VIDE AU DEMARRAGE ---
        assert (o_bus_out[9] == 1'b1)
            $display("  [FIFO_RX] PASS : FIFO is initially empty");
        else
            $error("  [FIFO_RX] FAIL : FIFO should be empty at startup");

        // --- 2. REMPLISSAGE COMPLET DE LA FIFO (8 bytes) ---
        $display("  [FIFO_RX] Filling FIFO with 8 bytes...");
        for (int i = 0; i < 8; i++) begin
            bus_val = '0;
            bus_val[0] = 1'b1; // fifo_rx_wr_en
            bus_val[17:10] = 8'hC0 + i; // data_in (C0, C1, C2...)
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            
            // On rabaisse le write enable
            tb_pkg::set_bus(i_clk, i_bus_in, '0);
        end

        // --- 3. VERIFICATION DRAPEAUX FULL ET EMPTY ---
        assert (o_bus_out[8] == 1'b1)
            $display("  [FIFO_RX] PASS : FIFO FULL flag is set after 8 writes");
        else
            $error("  [FIFO_RX] FAIL : FIFO FULL flag is NOT set!");

        assert (o_bus_out[9] == 1'b0)
            $display("  [FIFO_RX] PASS : FIFO EMPTY flag is cleared");
        else
            $error("  [FIFO_RX] FAIL : FIFO EMPTY flag is still set!");

        // --- 4. LECTURE ET VERIFICATION DES DONNEES ---
        $display("  [FIFO_RX] Reading back 8 bytes...");
        for (int i = 0; i < 8; i++) begin
            expected_data = 8'hC0 + i;
            
            // Impulsion de lecture (rd_en = 1)
            bus_val = '0;
            bus_val[1] = 1'b1; // fifo_rx_rd_en
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            
            // On desactive la lecture.
            // L'appel a set_bus passe 1 cycle d'horloge. 
            // La memoire synchrone de la FIFO a donc sorti la donnee sur o_bus_out[7:0].
            tb_pkg::set_bus(i_clk, i_bus_in, '0);
            
            read_data = o_bus_out[7:0];
            
            assert (read_data === expected_data)
                $display("  [FIFO_RX] PASS : Read 0x%0h (Expected 0x%0h)", read_data, expected_data);
            else
                $error("  [FIFO_RX] FAIL : Read 0x%0h, Expected 0x%0h", read_data, expected_data);
        end

        // --- 5. VERIFICATION FIFO VIDE A LA FIN ---
        assert (o_bus_out[9] == 1'b1)
            $display("  [FIFO_RX] PASS : FIFO is empty again after 8 reads");
        else
            $error("  [FIFO_RX] FAIL : FIFO should be empty!");

        $display("========== CFG_FIFO_RX TEST COMPLETE ==========\n");
    end
endtask