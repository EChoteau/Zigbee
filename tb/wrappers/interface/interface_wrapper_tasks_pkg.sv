// ============================================================================
// PACKAGE: interface_wrapper_tasks_pkg
// ============================================================================
// Wrapper test tasks for INTERFACE wrapper, callable from top_tb.
// ============================================================================

package interface_wrapper_tasks_pkg;

    import tb_pkg::*;

    // =========================================================================
    // INTERFACE WRAPPER PARAMETERS & ADDRESSES
    // =========================================================================

    localparam int APB_ADDR_WIDTH = 8;
    localparam int APB_DATA_WIDTH = 8;
    localparam int DATA_WIDTH     = 8;
    localparam int FIFO_DEPTH     = 8;
    localparam int DIV_WIDTH      = 8;

    // APB REGISTER ADDRESSES
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DATA    = 8'h00;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_STATUS  = 8'h04;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_CONTROL = 8'h08;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DIVIDER = 8'h0C;

    // Configuration modes
    localparam logic [2:0] CFG_RX_ONLY   = 3'b000;  // APB + serial loopback
    localparam logic [2:0] CFG_TX_ONLY   = 3'b001;  // TX path with FIFO control
    localparam logic [2:0] CFG_RESERVED  = 3'b010;  // RESERVED NOT USED YET
    localparam logic [2:0] CFG_LOOPBACK  = 3'b011;  // Serializer output looped to deserializer input
    localparam logic [2:0] CFG_FIFO_TX   = 3'b100;  // Direct TX FIFO control
    localparam logic [2:0] CFG_FIFO_RX   = 3'b101;  // Direct RX FIFO control
    localparam logic [2:0] CFG_SERDES    = 3'b110;  // Serializer/deserializer chain testing
    localparam logic [2:0] CFG_BAUD      = 3'b111;  // Baud rate generator control

    task automatic test_interface_wrapper_tx_only(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [7:0] test_data = 8'hA5;
        logic [7:0] captured_data;
        int timeout;

        begin
            $display("\n========== START TEST: CFG_TX_ONLY (0x1) ==========");

            // configuration du mode
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_TX_ONLY);
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

    task automatic test_interface_wrapper_rx_only(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [7:0] test_data = 8'hA5;
        logic [7:0] read_data;
        int timeout;

        begin
            $display("\n========== START TEST: CFG_RX_ONLY (0x2) ==========");

            // set config
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_RX_ONLY);
            repeat(2) @(posedge i_clk);

            assert (i_cfg_local == CFG_RX_ONLY)
                $display("  [RX_ONLY] Config ok");
            else
                $error("  [RX_ONLY] Config error");

            $display("  [RX_ONLY] Configuration APB: Activation RX_EN et GLOBAL_EN...");
            // Adresse 0x08 (ADDR_CONTROL), Data 0x11 (bit 4: rx_enable, bit 0: global_en)
            // APB SETUP: psel=1, penable=0, pwrite=1
            tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h11, 8'h08, 1'b1, 1'b0, 1'b1});
            // APB ACCESS: psel=1, penable=1, pwrite=1
            tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h11, 8'h08, 1'b1, 1'b1, 1'b1});
            // Deselect
            tb_pkg::set_bus(i_clk, i_bus_in, '0);

            $display("  [RX_ONLY] Injecting serial data 0x%0h...", test_data);

            // simuler reception serie bit par bit
            for (int i = 0; i < 8; i++) begin
                // bit 20: cdr_sample_valid, bit 19: serial_rx
                tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b1, test_data[i], 8'h00, 8'h00, 3'b000});

                // clear valid
                tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 3'b000});
            end

            timeout = 0;
            // o_bus_out[9] = s_dbg_rx_fifo_empty (passe a 0 quand la donnee arrive)
            while (o_bus_out[9] == 1'b1 && timeout < 50) begin
                @(posedge i_clk);
                timeout++;
            end

            // verif fifo pas vide (o_bus_out[9] = rx_fifo_empty)
            assert (o_bus_out[9] == 1'b0)
                $display("  [RX_ONLY] Data in FIFO");
            else
                $error("  [RX_ONLY] FIFO empty error");

            $display("  [RX_ONLY] APB read...");
            tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 1'b0, 1'b0, 1'b1});
            // read: pwrite=0, penable=1, psel=1
            tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 1'b0, 1'b1, 1'b1});

            read_data = o_bus_out[7:0];

            // check result
            assert (read_data === test_data)
                $display("  [RX_ONLY] PASS : Read 0x%0h", read_data);
            else
                $error("  [RX_ONLY] FAIL : Read 0x%0h, expected 0x%0h", read_data, test_data);

            $display("========== CFG_RX_ONLY TEST COMPLETE ==========\n");
        end
    endtask

    task automatic test_interface_wrapper_loopback(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic [7:0] test_data = 8'hC3; // 11000011 (bon pattern pour verifier l'ordre des bits)
        logic [7:0] read_data;
        int timeout;

        begin
            $display("\n========== START TEST: CFG_LOOPBACK (0x3) ==========");

            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_LOOPBACK);
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

    task automatic test_interface_wrapper_fifo_tx(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic [7:0] expected_data;
        logic [7:0] read_data;

        begin
            $display("\n========== START TEST: CFG_FIFO_TX (0x4) ==========");

            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_FIFO_TX);
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
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

                // Rabaisser wr_en
                tb_pkg::set_bus(i_clk, i_bus_in, '0);
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
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

                // Desactiver la lecture (passe 1 cycle, donc la donnee sort sur la memoire synchrone)
                tb_pkg::set_bus(i_clk, i_bus_in, '0);

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

    task automatic test_interface_wrapper_fifo_rx(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic [7:0] expected_data;
        logic [7:0] read_data;

        begin
            $display("\n========== START TEST: CFG_FIFO_RX (0x5) ==========");

            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_FIFO_RX);
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

    task automatic test_interface_wrapper_serdes(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic [7:0] tx_test_data = 8'hCA;
        logic [7:0] rx_test_data = 8'h53;
        logic [7:0] captured_tx;

        begin
            $display("\n========== START TEST: CFG_SERDES (0x6) ==========");

            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_SERDES);
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
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);

            bus_val[8] = 1'b0;
            bus_val[9] = 1'b1;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);

            $display("  [SERDES] Generation de 8 baud ticks et capture...");
            for (int i = 0; i < 8; i++) begin
                bus_val[21] = 1'b1;
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

                bus_val[21] = 1'b0;
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

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
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

                // Au 8eme bit (i==7), le RTL a leve le flag push (o_bus_out[8])
                if (i == 7) begin
                    // On se place au milieu du cycle (front descendant)
                    // pour eviter la race condition du simulateur !
                    @(negedge i_clk);

                    assert (o_bus_out[8] == 1'b1)
                        $display("  [SERDES] PASS : Signal push detecte au 8eme bit !");
                    else
                        $error("  [SERDES] FAIL : Signal push manquant !");
                end

                bus_val[20] = 1'b0;
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            end

            // La boucle est finie, la donnee parallele reconstruite nous attend sagement
            assert (o_bus_out[7:0] === rx_test_data)
                $display("  [SERDES] PASS : Deserializer a recu = 0x%0h", o_bus_out[7:0]);
            else
                $error("  [SERDES] FAIL : Recu 0x%0h, attendu 0x%0h", o_bus_out[7:0], rx_test_data);

            $display("\n========== CFG_SERDES TEST COMPLETE ==========\n");
        end
    endtask

    task automatic test_interface_wrapper_baud(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        int cycle_count;
        int expected_cycles;

        begin
            $display("\n========== START TEST: CFG_BAUD (0x7) ==========");

            // set config
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_BAUD);
            repeat(2) @(posedge i_clk);

            assert (i_cfg_local == CFG_BAUD)
                $display("  [BAUD] Config ok");
            else
                $error("  [BAUD] Config error");

            // --- Test 1: Diviseur tres rapide (0x02) pour simu courte ---
            $display("  [BAUD] Setting fast divisor to 0x02...");
            tb_pkg::set_bus(i_clk, i_bus_in, {13'h00, 8'h02, 1'b1});

            // a ajuster si ton baud gen multiplie en interne (ex: diviseur * 16)
            expected_cycles = 3;

            // synchro sur le premier tick
            while (o_bus_out[12] == 1'b0) @(posedge i_clk);
            @(posedge i_clk); // avancer d'un cycle apres le tick

            // comptage jusqu'au prochain tick
            cycle_count = 1;
            while (o_bus_out[12] == 1'b0 && cycle_count < 100) begin
                cycle_count++;
                @(posedge i_clk);
            end

            assert (cycle_count == expected_cycles)
                $display("  [BAUD] PASS : Period is %0d cycles", cycle_count);
            else
                $error("  [BAUD] FAIL : Expected %0d cycles, got %0d", expected_cycles, cycle_count);

            // --- Test 2: Diviseur un peu plus lent (0x05) pour confirmer ---
            $display("  [BAUD] Setting divisor to 0x05...");
            tb_pkg::set_bus(i_clk, i_bus_in, {13'h00, 8'h05, 1'b1});
            expected_cycles = 6;

            while (o_bus_out[12] == 1'b0) @(posedge i_clk);
            @(posedge i_clk);

            cycle_count = 1;
            while (o_bus_out[12] == 1'b0 && cycle_count < 100) begin
                cycle_count++;
                @(posedge i_clk);
            end

            assert (cycle_count == expected_cycles)
                $display("  [BAUD] PASS : Period scales correctly to %0d cycles", cycle_count);
            else
                $error("  [BAUD] FAIL : Expected %0d cycles, got %0d", expected_cycles, cycle_count);

            // --- Test 3: Disable generator ---
            $display("  [BAUD] Disabling generator...");
            tb_pkg::set_bus(i_clk, i_bus_in, {13'h00, 8'h00, 1'b0});

            cycle_count = 0;
            repeat(20) begin
                @(posedge i_clk);
                if (o_bus_out[12] == 1'b1) cycle_count++;
            end

            assert (cycle_count == 0)
                $display("  [BAUD] PASS : Generator disabled (0 ticks)");
            else
                $error("  [BAUD] FAIL : Generator still ticking!");

            $display("========== CFG_BAUD TEST COMPLETE ==========\n");
        end
    endtask

    task automatic run_interface_wrapper_test_plan(
        ref logic i_clk,
        ref logic i_rst_n,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
    begin
        test_interface_wrapper_tx_only(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_rx_only(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_loopback(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_fifo_tx(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_fifo_rx(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_serdes(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_baud(i_clk, i_cfg_local, i_bus_in, o_bus_out);

        $display("\n========== ALL INTERFACE WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
    end
    endtask

endpackage : interface_wrapper_tasks_pkg
// ============================================================================
// PACKAGE: interface_wrapper_tasks_pkg
// ============================================================================
// Wrapper test tasks for INTERFACE wrapper, callable from top_tb.
// ============================================================================

package interface_wrapper_tasks_pkg;

    import tb_pkg::*;

    // =========================================================================
    // INTERFACE WRAPPER PARAMETERS & ADDRESSES
    // =========================================================================

    localparam int APB_ADDR_WIDTH = 8;
    localparam int APB_DATA_WIDTH = 8;
    localparam int DATA_WIDTH     = 8;
    localparam int FIFO_DEPTH     = 8;
    localparam int DIV_WIDTH      = 8;

    // APB REGISTER ADDRESSES
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DATA    = 8'h00;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_STATUS  = 8'h04;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_CONTROL = 8'h08;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DIVIDER = 8'h0C;

    // Configuration modes
    localparam logic [2:0] CFG_RX_ONLY   = 3'b000;  // APB + serial loopback
    localparam logic [2:0] CFG_TX_ONLY   = 3'b001;  // TX path with FIFO control
    localparam logic [2:0] CFG_RESERVED  = 3'b010;  // RESERVED NOT USED YET
    localparam logic [2:0] CFG_LOOPBACK  = 3'b011;  // Serializer output looped to deserializer input
    localparam logic [2:0] CFG_FIFO_TX   = 3'b100;  // Direct TX FIFO control
    localparam logic [2:0] CFG_FIFO_RX   = 3'b101;  // Direct RX FIFO control
    localparam logic [2:0] CFG_SERDES    = 3'b110;  // Serializer/deserializer chain testing
    localparam logic [2:0] CFG_BAUD      = 3'b111;  // Baud rate generator control

    task automatic test_interface_wrapper_tx_only(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [7:0] test_data = 8'hA5;
        logic [7:0] captured_data;
        int timeout;

        begin
            $display("\n========== START TEST: CFG_TX_ONLY (0x1) ==========");

            // configuration du mode
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_TX_ONLY);
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
            while (o_bus_out[13] == 1'b1) @(posedge i_clk);
            $display("  [TX_ONLY] Transmission terminee (tx_busy = 0)");

            $display("========== CFG_TX_ONLY TEST COMPLETE ==========\n");
        end
    endtask

    task automatic test_interface_wrapper_rx_only(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [7:0] test_data = 8'hA5;
        logic [7:0] read_data;
        int timeout;

        begin
            $display("\n========== START TEST: CFG_RX_ONLY (0x2) ==========");

            // set config
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_RX_ONLY);
            repeat(2) @(posedge i_clk);

            assert (i_cfg_local == CFG_RX_ONLY)
                $display("  [RX_ONLY] Config ok");
            else
                $error("  [RX_ONLY] Config error");

            $display("  [RX_ONLY] Configuration APB: Activation RX_EN et GLOBAL_EN...");
            // APB SETUP: psel=1, penable=0, pwrite=1
            tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h11, 8'h08, 1'b1, 1'b0, 1'b1});
            // APB ACCESS: psel=1, penable=1, pwrite=1
            tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h11, 8'h08, 1'b1, 1'b1, 1'b1});
            // Deselect
            tb_pkg::set_bus(i_clk, i_bus_in, '0);

            $display("  [RX_ONLY] Injecting serial data 0x%0h...", test_data);

            // simuler reception serie bit par bit
            for (int i = 0; i < 8; i++) begin
                // bit 20: cdr_sample_valid, bit 19: serial_rx
                tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b1, test_data[i], 8'h00, 8'h00, 3'b000});

                // clear valid
                tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 3'b000});
            end

            timeout = 0;
            // o_bus_out[9] = s_dbg_rx_fifo_empty (passe a 0 quand la donnee arrive)
            while (o_bus_out[9] == 1'b1 && timeout < 50) begin
                @(posedge i_clk);
                timeout++;
            end

            // verif fifo pas vide (o_bus_out[9] = rx_fifo_empty)
            assert (o_bus_out[9] == 1'b0)
                $display("  [RX_ONLY] Data in FIFO");
            else
                $error("  [RX_ONLY] FIFO empty error");

            $display("  [RX_ONLY] APB read...");
            tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 1'b0, 1'b0, 1'b1});
            // read: pwrite=0, penable=1, psel=1
            tb_pkg::set_bus(i_clk, i_bus_in, {1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 1'b0, 1'b1, 1'b1});

            read_data = o_bus_out[7:0];

            // check result
            assert (read_data === test_data)
                $display("  [RX_ONLY] PASS : Read 0x%0h", read_data);
            else
                $error("  [RX_ONLY] FAIL : Read 0x%0h, expected 0x%0h", read_data, test_data);

            $display("========== CFG_RX_ONLY TEST COMPLETE ==========\n");
        end
    endtask

    task automatic test_interface_wrapper_loopback(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic [7:0] test_data = 8'hC3; // 11000011 (bon pattern pour verifier l'ordre des bits)
        logic [7:0] read_data;
        int timeout;

        begin
            $display("\n========== START TEST: CFG_LOOPBACK (0x3) ==========");

            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_LOOPBACK);
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

    task automatic test_interface_wrapper_fifo_tx(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic [7:0] expected_data;
        logic [7:0] read_data;

        begin
            $display("\n========== START TEST: CFG_FIFO_TX (0x4) ==========");

            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_FIFO_TX);
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
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

                // Rabaisser wr_en
                tb_pkg::set_bus(i_clk, i_bus_in, '0);
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
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

                // Desactiver la lecture (passe 1 cycle, donc la donnee sort sur la memoire synchrone)
                tb_pkg::set_bus(i_clk, i_bus_in, '0);

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

    task automatic test_interface_wrapper_fifo_rx(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic [7:0] expected_data;
        logic [7:0] read_data;

        begin
            $display("\n========== START TEST: CFG_FIFO_RX (0x5) ==========");

            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_FIFO_RX);
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

    task automatic test_interface_wrapper_serdes(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        logic [21:0] bus_val;
        logic [7:0] tx_test_data = 8'hCA;
        logic [7:0] rx_test_data = 8'h53;
        logic [7:0] captured_tx;

        begin
            $display("\n========== START TEST: CFG_SERDES (0x6) ==========");

            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_SERDES);
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
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);

            bus_val[8] = 1'b0;
            bus_val[9] = 1'b1;
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            repeat(2) @(posedge i_clk);

            $display("  [SERDES] Generation de 8 baud ticks et capture...");
            for (int i = 0; i < 8; i++) begin
                bus_val[21] = 1'b1;
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

                bus_val[21] = 1'b0;
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

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
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

                // Au 8eme bit (i==7), le RTL a leve le flag push (o_bus_out[8])
                if (i == 7) begin
                    // On se place au milieu du cycle (front descendant)
                    // pour eviter la race condition du simulateur !
                    @(negedge i_clk);

                    assert (o_bus_out[8] == 1'b1)
                        $display("  [SERDES] PASS : Signal push detecte au 8eme bit !");
                    else
                        $error("  [SERDES] FAIL : Signal push manquant !");
                end

                bus_val[20] = 1'b0;
                tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
            end

            // La boucle est finie, la donnee parallele reconstruite nous attend sagement
            assert (o_bus_out[7:0] === rx_test_data)
                $display("  [SERDES] PASS : Deserializer a recu = 0x%0h", o_bus_out[7:0]);
            else
                $error("  [SERDES] FAIL : Recu 0x%0h, attendu 0x%0h", o_bus_out[7:0], rx_test_data);

            $display("\n========== CFG_SERDES TEST COMPLETE ==========\n");
        end
    endtask

    task automatic test_interface_wrapper_baud(
        ref logic i_clk,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
        int cycle_count;
        int expected_cycles;

        begin
            $display("\n========== START TEST: CFG_BAUD (0x7) ==========");

            // set config
            tb_pkg::set_config_wrapper(i_clk, i_cfg_local, CFG_BAUD);
            repeat(2) @(posedge i_clk);

            assert (i_cfg_local == CFG_BAUD)
                $display("  [BAUD] Config ok");
            else
                $error("  [BAUD] Config error");

            // --- Test 1: Diviseur tres rapide (0x02) pour simu courte ---
            $display("  [BAUD] Setting fast divisor to 0x02...");
            tb_pkg::set_bus(i_clk, i_bus_in, {13'h00, 8'h02, 1'b1});

            // a ajuster si ton baud gen multiplie en interne (ex: diviseur * 16)
            expected_cycles = 3;

            // synchro sur le premier tick
            while (o_bus_out[12] == 1'b0) @(posedge i_clk);
            @(posedge i_clk); // avancer d'un cycle apres le tick

            // comptage jusqu'au prochain tick
            cycle_count = 1;
            while (o_bus_out[12] == 1'b0 && cycle_count < 100) begin
                cycle_count++;
                @(posedge i_clk);
            end

            assert (cycle_count == expected_cycles)
                $display("  [BAUD] PASS : Period is %0d cycles", cycle_count);
            else
                $error("  [BAUD] FAIL : Expected %0d cycles, got %0d", expected_cycles, cycle_count);

            // --- Test 2: Diviseur un peu plus lent (0x05) pour confirmer ---
            $display("  [BAUD] Setting divisor to 0x05...");
            tb_pkg::set_bus(i_clk, i_bus_in, {13'h00, 8'h05, 1'b1});
            expected_cycles = 6;

            while (o_bus_out[12] == 1'b0) @(posedge i_clk);
            @(posedge i_clk);

            cycle_count = 1;
            while (o_bus_out[12] == 1'b0 && cycle_count < 100) begin
                cycle_count++;
                @(posedge i_clk);
            end

            assert (cycle_count == expected_cycles)
                $display("  [BAUD] PASS : Period scales correctly to %0d cycles", cycle_count);
            else
                $error("  [BAUD] FAIL : Expected %0d cycles, got %0d", expected_cycles, cycle_count);

            // --- Test 3: Disable generator ---
            $display("  [BAUD] Disabling generator...");
            tb_pkg::set_bus(i_clk, i_bus_in, {13'h00, 8'h00, 1'b0});

            cycle_count = 0;
            repeat(20) begin
                @(posedge i_clk);
                if (o_bus_out[12] == 1'b1) cycle_count++;
            end

            assert (cycle_count == 0)
                $display("  [BAUD] PASS : Generator disabled (0 ticks)");
            else
                $error("  [BAUD] FAIL : Generator still ticking!");

            $display("========== CFG_BAUD TEST COMPLETE ==========\n");
        end
    endtask

    task automatic run_interface_wrapper_test_plan(
        ref logic i_clk,
        ref logic i_rst_n,
        ref logic [CFG_WIDTH-1:0] i_cfg_local,
        ref logic [BUS_IN_WIDTH-1:0] i_bus_in,
        ref logic [BUS_OUT_WIDTH-1:0] o_bus_out
    );
    begin
        test_interface_wrapper_tx_only(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_rx_only(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_loopback(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_fifo_tx(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_fifo_rx(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_serdes(i_clk, i_cfg_local, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        test_interface_wrapper_baud(i_clk, i_cfg_local, i_bus_in, o_bus_out);

        $display("\n========== ALL INTERFACE WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
    end
    endtask

endpackage : interface_wrapper_tasks_pkg
