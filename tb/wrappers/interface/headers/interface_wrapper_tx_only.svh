task automatic test_interface_wrapper_tx_only();
    logic [7:0] test_data = 8'hA5; 
    logic [7:0] captured_data;
    int timeout;

    begin
        $display("\n========== START TEST: CFG_TX_ONLY (0x1) ==========");
        
        // set config
        set_config(CFG_TX_ONLY);
        repeat(2) @(posedge i_clk);

        assert (i_cfg_local == CFG_TX_ONLY)
            $display("  [TX_ONLY] Config ok");
        else
            $error("  [TX_ONLY] Config error");

        // --- 1. CONFIGURATION DU BAUD RATE ---
        $display("  [TX_ONLY] Configuration APB: Diviseur Baud Rate = 0x02...");
        // ADDR_DIVIDER = 0x0C, valeur = 0x02
        // SETUP: psel=1, penable=0, pwrite=1
        set_bus({1'b0, 1'b0, 1'b0, 8'h02, 8'h0C, 1'b1, 1'b0, 1'b1});
        // ACCESS: psel=1, penable=1, pwrite=1
        set_bus({1'b0, 1'b0, 1'b0, 8'h02, 8'h0C, 1'b1, 1'b1, 1'b1});
        set_bus('0);
        repeat(2) @(posedge i_clk);

        // --- 2. ACTIVATION DU TX ---
        $display("  [TX_ONLY] Configuration APB: Activation TX_START et GLOBAL_EN...");
        // ADDR_CONTROL = 0x08, valeur = 0x09 (bit 3: tx_start, bit 0: global_en)
        // SETUP
        set_bus({1'b0, 1'b0, 1'b0, 8'h09, 8'h08, 1'b1, 1'b0, 1'b1});
        // ACCESS
        set_bus({1'b0, 1'b0, 1'b0, 8'h09, 8'h08, 1'b1, 1'b1, 1'b1});
        set_bus('0);
        repeat(2) @(posedge i_clk);

        // --- 3. ECRITURE DANS LA FIFO TX ---
        $display("  [TX_ONLY] Ecriture APB: Envoi de la donnee 0x%0h dans la FIFO TX...", test_data);
        // ADDR_DATA = 0x00, valeur = test_data
        // SETUP
        set_bus({1'b0, 1'b0, 1'b0, test_data, 8'h00, 1'b1, 1'b0, 1'b1});
        // ACCESS
        set_bus({1'b0, 1'b0, 1'b0, test_data, 8'h00, 1'b1, 1'b1, 1'b1});
        set_bus('0);

        // --- 4. OBSERVATION DE LA SORTIE SERIE ---
        $display("  [TX_ONLY] Attente de l'emission serie...");
        
        // Attente que tx_valid (o_bus_out[13]) passe a 1 (indique que le TX a demarre)
        timeout = 0;
        while (o_bus_out[13] == 1'b0 && timeout < 50) begin
            @(posedge i_clk);
            timeout++;
        end

        if (timeout >= 50) begin
            $error("  [TX_ONLY] Timeout: TX n'a jamais demarre !");
        end else begin
            // Le TX a demarre. On attend l'arrivee du 1er bit.
            // Avec un diviseur de 0x02, la periode est de 3 cycles. 
            // En RTL, la premiere mise a jour de o_serial_data a lieu 4 cycles apres le passage de tx_busy a 1.
            repeat(4) @(posedge i_clk);
            
            for (int i = 0; i < 8; i++) begin
                // Lire la sortie serie sur o_bus_out[12]
                captured_data[i] = o_bus_out[12];
                
                // Attendre la periode d'un bit (3 cycles) avant d'echantillonner le bit suivant
                if (i < 7) repeat(3) @(posedge i_clk);
            end

            // Verification de la donnee reconstruite
            assert (captured_data === test_data)
                $display("  [TX_ONLY] PASS : Serie capturee = 0x%0h", captured_data);
            else
                $error("  [TX_ONLY] FAIL : Capture 0x%0h, attendu 0x%0h", captured_data, test_data);
        end

        // --- 5. FIN DU TEST ---
        // On attend que tx_busy redescende a 0 pour confirmer la fin de trame
        while (o_bus_out[13] == 1'b1) @(posedge i_clk);
        $display("  [TX_ONLY] Transmission terminee (tx_busy = 0)");

        $display("========== CFG_TX_ONLY TEST COMPLETE ==========\n");
    end
endtask