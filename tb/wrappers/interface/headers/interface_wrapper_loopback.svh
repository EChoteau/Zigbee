task automatic test_interface_wrapper_loopback();
    logic [21:0] bus_val;
    logic [7:0] test_data = 8'hC3; // 11000011 (bon pattern pour verifier l'ordre des bits)
    logic [7:0] read_data;
    int timeout;

    begin
        $display("\n========== START TEST: CFG_LOOPBACK (0x3) ==========");
        
        tb_pkg::set_config(i_clk, i_cfg_local, CFG_LOOPBACK);
        repeat(2) @(posedge i_clk);

        assert (i_cfg_local == CFG_LOOPBACK)
            $display("  [LOOPBACK] Config ok");
        else
            $error("  [LOOPBACK] Config error");

        // --- 1. CONFIGURATION BAUD RATE ---
        $display("  [LOOPBACK] Config Baud Rate (div=0x02)...");
        bus_val = '0;
        bus_val[0] = 1'b1; // psel
        bus_val[2] = 1'b1; // pwrite
        bus_val[10:3] = 8'h0C; // paddr (ADDR_DIVIDER)
        bus_val[18:11] = 8'h02; // pwdata
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val); // SETUP
        bus_val[1] = 1'b1; // penable
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val); // ACCESS
        tb_pkg::set_bus(i_clk, i_bus_in, '0);

        // --- 2. ACTIVATION RX ET GLOBAL ---
        $display("  [LOOPBACK] Activation RX_EN et GLOBAL_EN (sans tx_start)...");
        bus_val = '0;
        bus_val[0] = 1'b1;
        bus_val[2] = 1'b1;
        bus_val[10:3] = 8'h08; // paddr (ADDR_CONTROL)
        bus_val[18:11] = 8'h11; // pwdata (rx_enable=1, global_en=1) -> 00010001
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        bus_val[1] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        tb_pkg::set_bus(i_clk, i_bus_in, '0);
        repeat(2) @(posedge i_clk);

        // --- 3. ECRITURE TX FIFO ---
        $display("  [LOOPBACK] Ecriture donnee 0x%0h dans FIFO TX...", test_data);
        bus_val = '0;
        bus_val[0] = 1'b1;
        bus_val[2] = 1'b1;
        bus_val[10:3] = 8'h00; // paddr (ADDR_DATA)
        bus_val[18:11] = test_data;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        bus_val[1] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        tb_pkg::set_bus(i_clk, i_bus_in, '0);
        repeat(2) @(posedge i_clk);

        // --- 4. START TX ---
        $display("  [LOOPBACK] Declenchement TX_START...");
        bus_val = '0;
        bus_val[0] = 1'b1;
        bus_val[2] = 1'b1;
        bus_val[10:3] = 8'h08; // paddr
        bus_val[18:11] = 8'h19; // pwdata (rx_en=1, tx_start=1, global=1) -> 00011001
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        bus_val[1] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        tb_pkg::set_bus(i_clk, i_bus_in, '0);

        // --- 5. SYNCHRO ET GENERATION DU CLOCK RECOVERY ---
        $display("  [LOOPBACK] Generation du signal sample_valid pour le Deserializer...");
        
        timeout = 0;
        while (o_bus_out[13] == 1'b0 && timeout < 50) begin
            @(posedge i_clk);
            timeout++;
        end

        if (timeout >= 50) begin
            $error("  [LOOPBACK] Timeout: Le TX n'a pas demarre !");
        end else begin
            for (int i = 0; i < 8; i++) begin
                // Attendre l'impulsion du baud_rate_gen interne
                while (o_bus_out[12] == 1'b0) @(posedge i_clk); 
                
                // Le bit change juste apres le tick. 
                // On declenche notre sample_valid pour echantillonner la valeur !
                bus_val = '0;
                bus_val[20] = 1'b1; // cdr_sample_valid
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val); // Dure 1 cycle d'horloge
                
                bus_val[20] = 1'b0;
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val); // Retombe a 0
            end
        end

        // --- 6. ATTENTE DE FIN DE DESERIALISATION ---
        // Le deserializer indique qu'il a fini avec un push (o_bus_out[10])
        timeout = 0;
        while (o_bus_out[10] == 1'b0 && timeout < 50) begin
            @(posedge i_clk);
            timeout++;
        end

        // --- 7. LECTURE RX FIFO VIA APB ---
        $display("  [LOOPBACK] Lecture de la FIFO RX...");
        bus_val = '0;
        bus_val[0] = 1'b1; // psel
        bus_val[2] = 1'b0; // pwrite (LECTURE)
        bus_val[10:3] = 8'h00; // paddr
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val); // SETUP
        bus_val[1] = 1'b1; // penable
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val); // ACCESS
        
        // La donnee lue est sur o_bus_out[7:0]
        read_data = o_bus_out[7:0];
        tb_pkg::set_bus(i_clk, i_bus_in, '0);

        assert (read_data === test_data)
            $display("  [LOOPBACK] PASS : Boucle complete reussie ! Donnee lue = 0x%0h", read_data);
        else
            $error("  [LOOPBACK] FAIL : Donnee lue 0x%0h, attendu 0x%0h", read_data, test_data);

        $display("========== CFG_LOOPBACK TEST COMPLETE ==========\n");
    end
endtask