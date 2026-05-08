task automatic test_interface_wrapper_fifo_tx();
    logic [21:0] bus_val;
    logic [7:0] expected_data;
    logic [7:0] read_data;

    begin
        $display("\n========== START TEST: CFG_FIFO_TX (0x4) ==========");
        
        set_config(CFG_FIFO_TX);
        repeat(2) @(posedge i_clk);

        assert (i_cfg_local == CFG_FIFO_TX)
            $display("  [FIFO_TX] Config ok");
        else
            $error("  [FIFO_TX] Config error");

        // --- 1. VERIFICATION FIFO VIDE AU DEMARRAGE ---
        assert (o_bus_out[9] == 1'b1)
            $display("  [FIFO_TX] PASS : FIFO is initially empty");
        else
            $error("  [FIFO_TX] FAIL : FIFO should be empty at startup");

        // --- 2. REMPLISSAGE COMPLET DE LA FIFO (8 bytes) ---
        $display("  [FIFO_TX] Filling TX FIFO with 8 bytes...");
        for (int i = 0; i < 8; i++) begin
            bus_val = '0;
            bus_val[0] = 1'b1; // fifo_tx_wr_en
            bus_val[17:10] = 8'hD0 + i; // data_in (D0, D1, D2...)
            set_bus(bus_val);
            
            // Rabaisser wr_en
            set_bus('0);
        end

        // --- 3. VERIFICATION DRAPEAUX FULL ET EMPTY ---
        assert (o_bus_out[8] == 1'b1)
            $display("  [FIFO_TX] PASS : FIFO FULL flag is set after 8 writes");
        else
            $error("  [FIFO_TX] FAIL : FIFO FULL flag is NOT set!");

        assert (o_bus_out[9] == 1'b0)
            $display("  [FIFO_TX] PASS : FIFO EMPTY flag is cleared");
        else
            $error("  [FIFO_TX] FAIL : FIFO EMPTY flag is still set!");

        // --- 4. LECTURE ET VERIFICATION DES DONNEES ---
        $display("  [FIFO_TX] Reading back 8 bytes...");
        for (int i = 0; i < 8; i++) begin
            expected_data = 8'hD0 + i;
            
            // Impulsion de lecture (rd_en = 1)
            bus_val = '0;
            bus_val[1] = 1'b1; // fifo_tx_rd_en
            set_bus(bus_val);
            
            // Desactiver la lecture (passe 1 cycle, donc la donnee sort sur la memoire synchrone)
            set_bus('0);
            
            read_data = o_bus_out[7:0];
            
            assert (read_data === expected_data)
                $display("  [FIFO_TX] PASS : Read 0x%0h (Expected 0x%0h)", read_data, expected_data);
            else
                $error("  [FIFO_TX] FAIL : Read 0x%0h, Expected 0x%0h", read_data, expected_data);
        end

        // --- 5. VERIFICATION FIFO VIDE A LA FIN ---
        assert (o_bus_out[9] == 1'b1)
            $display("  [FIFO_TX] PASS : FIFO is empty again after 8 reads");
        else
            $error("  [FIFO_TX] FAIL : FIFO should be empty!");

        $display("========== CFG_FIFO_TX TEST COMPLETE ==========\n");
    end
endtask