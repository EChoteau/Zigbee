task automatic test_interface_wrapper_serdes();
    logic [21:0] bus_val;
    logic [7:0] tx_test_data = 8'hCA; // 11001010
    logic [7:0] rx_test_data = 8'h53; // 01010011
    logic [7:0] captured_tx;
    int timeout;

    begin
        $display("\n========== START TEST: CFG_SERDES (0x6) ==========");
        
        set_config(CFG_SERDES);
        repeat(2) @(posedge i_clk);

        assert (i_cfg_local == CFG_SERDES)
            $display("  [SERDES] Config ok");
        else
            $error("  [SERDES] Config error");

        // ==========================================================
        // 1. TEST DU SERIALIZER (TX)
        // ==========================================================
        $display("\n  [SERDES] --- Test du Serializer ---");
        $display("  [SERDES] Presentation de la donnee 0x%0h...", tx_test_data);
        
        // On simule une FIFO contenant une donnee valide
        bus_val = '0;
        bus_val[7:0] = tx_test_data; // ser_tx_data
        bus_val[8] = 1'b1;           // ser_tx_data_valid = true
        bus_val[9] = 1'b0;           // ser_tx_fifo_empty = false
        set_bus(bus_val);
        repeat(2) @(posedge i_clk);
        
        // Le serializer est sense avoir charge la donnee (tx_busy passe a 1)
        // On simule la FIFO qui se vide
        bus_val[8] = 1'b0;           // valid = 0
        bus_val[9] = 1'b1;           // empty = 1
        set_bus(bus_val);
        repeat(2) @(posedge i_clk);

        $display("  [SERDES] Generation de 8 baud ticks et capture...");
        for (int i = 0; i < 8; i++) begin
            // Envoyer un tick manuel (bit 21)
            bus_val[21] = 1'b1;
            set_bus(bus_val);
            
            // Attendre la reaction du RTL (mise a jour de serial_tx)
            repeat(2) @(posedge i_clk);
            
            // Capturer la sortie serie sur o_bus_out[10]
            captured_tx[i] = o_bus_out[10];
            
            // Rabaisser le tick
            bus_val[21] = 1'b0;
            set_bus(bus_val);
            repeat(1) @(posedge i_clk);
        end

        // Verification du mot serialise
        assert (captured_tx === tx_test_data)
            $display("  [SERDES] PASS : Serializer a emis = 0x%0h", captured_tx);
        else
            $error("  [SERDES] FAIL : Capture 0x%0h, attendu 0x%0h", captured_tx, tx_test_data);


        // ==========================================================
        // 2. TEST DU DESERIALIZER (RX)
        // ==========================================================
        $display("\n  [SERDES] --- Test du Deserializer ---");
        $display("  [SERDES] Injection bit par bit de 0x%0h...", rx_test_data);
        
        bus_val = '0;
        for (int i = 0; i < 8; i++) begin
            // Placer le bit de donnee et lever le valid (sample_valid = bit 20)
            bus_val[19] = rx_test_data[i]; 
            bus_val[20] = 1'b1;            
            set_bus(bus_val);
            
            // Rabaisser le valid (pour simuler une impulsion de 1 cycle)
            bus_val[20] = 1'b0;            
            set_bus(bus_val);
        end

        $display("  [SERDES] Attente du signal push (fin de deserialisation)...");
        
        // o_bus_out[8] = s_dbg_des_o_push
        timeout = 0;
        while (o_bus_out[8] == 1'b0 && timeout < 20) begin 
            @(posedge i_clk);
            timeout++;
        end

        if (timeout >= 20) begin
            $error("  [SERDES] Timeout: Deserializer n'a jamais envoye push !");
        end else begin
            // La donnee parallele reconstruite est dispo sur o_bus_out[7:0]
            assert (o_bus_out[7:0] === rx_test_data)
                $display("  [SERDES] PASS : Deserializer a recu = 0x%0h", o_bus_out[7:0]);
            else
                $error("  [SERDES] FAIL : Recu 0x%0h, attendu 0x%0h", o_bus_out[7:0], rx_test_data);
        end

        $display("\n========== CFG_SERDES TEST COMPLETE ==========\n");
    end
endtask