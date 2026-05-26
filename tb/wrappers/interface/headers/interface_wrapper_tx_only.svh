task automatic test_interface_wrapper_tx_only();
    logic [7:0] test_data = 8'hA5; 
    logic [7:0] captured_data;
    int timeout;

    begin
        $display("\n========== START TEST: CFG_TX_ONLY (0x1) ==========");
        
        // configuration du mode
        tb_pkg::set_config(i_clk, i_cfg_local, CFG_TX_ONLY);
        repeat(2) @(posedge i_clk);

        assert (i_cfg_local == CFG_TX_ONLY)
            $display("  [TX_ONLY] Config ok");
        else
            $error("  [TX_ONLY] Config error");

        // --- 1. CONFIGURATION DU BAUD RATE ---
        $display("  [TX_ONLY] Configuration APB: Diviseur Baud Rate = 0x02...");
        // ADDR_DIVIDER = 0x0C, valeur = 0x02 (periode = 3 cycles)
        // APB SETUP
        tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h02, 8'h0C, 1'b1, 1'b0, 1'b1});
        // APB ACCESS
        tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h02, 8'h0C, 1'b1, 1'b1, 1'b1});
        tb_pkg::set_bus(i_clk, i_bus_in, '0);
        repeat(2) @(posedge i_clk);

        // --- 2. ECRITURE DANS LA FIFO (A FAIRE EN PREMIER) ---
        // On remplit la FIFO avant de lancer le moteur pour eviter l'auto-stop
        $display("  [TX_ONLY] Ecriture APB: Envoi de la donnee 0x%0h dans la FIFO...", test_data);
        // ADDR_DATA = 0x00
        // APB SETUP
        tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, test_data, 8'h00, 1'b1, 1'b0, 1'b1});
        // APB ACCESS
        tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, test_data, 8'h00, 1'b1, 1'b1, 1'b1});
        tb_pkg::set_bus(i_clk, i_bus_in, '0);
        repeat(2) @(posedge i_clk);

        // --- 3. ACTIVATION DU TX ---
        $display("  [TX_ONLY] Configuration APB: Activation TX_START et GLOBAL_EN...");
        // ADDR_CONTROL = 0x08, valeur = 0x09 (tx_start + global_en)
        // APB SETUP
        tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h09, 8'h08, 1'b1, 1'b0, 1'b1});
        // APB ACCESS
        tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h09, 8'h08, 1'b1, 1'b1, 1'b1});
        tb_pkg::set_bus(i_clk, i_bus_in, '0);

        // --- 4. OBSERVATION DE LA SORTIE SERIE ---
        $display("  [TX_ONLY] Attente de la transmission serie (tx_valid=1)...");
        
        // Utilisation du signal o_bus_out[13] corrige (s_tx_valid)
        timeout = 0;
        while (o_bus_out[13] == 1'b0 && timeout < 50) begin
            @(posedge i_clk);
            timeout++;
        end

        if (timeout >= 50) begin
            $error("  [TX_ONLY] Timeout: TX n'a jamais demarre !");
        end else begin
            $display("  [TX_ONLY] TX actif, capture des bits...");
            // Attente du 1er bit (alignement sur le baud tick)
            repeat(4) @(posedge i_clk);
            
            for (int i = 0; i < 8; i++) begin
                // Capture sur o_bus_out[12] (s_if_serial_tx)
                captured_data[i] = o_bus_out[12];
                
                // Attente de la periode d'un bit (div_val + 1 = 3 cycles)
                if (i < 7) repeat(3) @(posedge i_clk);
            end

            // Verification
            assert (captured_data === test_data)
                $display("  [TX_ONLY] PASS : Serie capturee = 0x%0h", captured_data);
            else
                $error("  [TX_ONLY] FAIL : Capture 0x%0h, attendu 0x%0h", captured_data, test_data);
        end

        // --- 5. FIN DU TEST ---
        // Attente de la fin de transmission
        while (o_bus_out[13] == 1'b1) @(posedge i_clk);
        $display("  [TX_ONLY] Transmission terminee (tx_busy = 0)");

        $display("========== CFG_TX_ONLY TEST COMPLETE ==========\n");
    end
endtask