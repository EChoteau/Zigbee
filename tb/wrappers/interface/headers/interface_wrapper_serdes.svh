task automatic test_interface_wrapper_serdes();
    logic [21:0] bus_val;
    logic [7:0] tx_test_data = 8'hCA;
    logic [7:0] rx_test_data = 8'h53;
    logic [7:0] captured_tx;

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
        
        bus_val = '0;
        bus_val[7:0] = tx_test_data; 
        bus_val[8] = 1'b1;           
        bus_val[9] = 1'b0;           
        set_bus(bus_val);
        repeat(2) @(posedge i_clk);
        
        bus_val[8] = 1'b0;           
        bus_val[9] = 1'b1;           
        set_bus(bus_val);
        repeat(2) @(posedge i_clk);

        $display("  [SERDES] Generation de 8 baud ticks et capture...");
        for (int i = 0; i < 8; i++) begin
            bus_val[21] = 1'b1;
            set_bus(bus_val);
            
            bus_val[21] = 1'b0;
            set_bus(bus_val);
            
            captured_tx[i] = o_bus_out[10];
        end

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
            bus_val[19] = rx_test_data[i]; 
            bus_val[20] = 1'b1;            
            set_bus(bus_val);
            
            // Au 8eme bit (i==7), le RTL a leve le flag push (o_bus_out[8])
            // exactement a ce moment precis, on l'attrape au vol !
            if (i == 7) begin
                assert (o_bus_out[8] == 1'b1)
                    $display("  [SERDES] PASS : Signal push detecte au 8eme bit !");
                else
                    $error("  [SERDES] FAIL : Signal push manquant !");
            end

            bus_val[20] = 1'b0;            
            set_bus(bus_val);
        end

        // La boucle est finie, la donnee parallele reconstruite nous attend sagement
        assert (o_bus_out[7:0] === rx_test_data)
            $display("  [SERDES] PASS : Deserializer a recu = 0x%0h", o_bus_out[7:0]);
        else
            $error("  [SERDES] FAIL : Recu 0x%0h, attendu 0x%0h", o_bus_out[7:0], rx_test_data);

        $display("\n========== CFG_SERDES TEST COMPLETE ==========\n");
    end
endtask