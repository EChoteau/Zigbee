// ============================================================================
// PACKAGE: interface_wrapper_tasks_pkg
// ============================================================================
// Consolidated wrapper test package for INTERFACE testbench
// Contains all wrapper test tasks, test plans, and support functions
// 
// Usage in testbench:
//   import interface_wrapper_tasks_pkg::*;
//   
// Then call test plan directly:
//   run_interface_wrapper_test_plan();
// ============================================================================

package interface_wrapper_tasks_pkg;

    import tb_pkg::*;

    // Bound by calling TB
    logic i_clk;
    logic i_rst_n;
    logic [BUS_IN_WIDTH-1:0] i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;
    logic [CFG_WIDTH-1:0] i_cfg_local;

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

    // =========================================================================
    // SUPPORT TASKS (wrappers around tb_pkg and direct signal manipulation)
    // =========================================================================

    // Set wrapper configuration using tb_pkg::set_config_wrapper
    task automatic set_config(logic [2:0] cfg);
    begin
        tb_pkg::set_config_wrapper(i_clk, i_cfg_local, cfg);
    end
    endtask

    // Set bus value using tb_pkg::set_bus
    task automatic set_bus(logic [21:0] bus_val);
    begin
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
    end
    endtask

    // Apply reset using tb_pkg::apply_reset
    task automatic apply_reset(int cycles);
    begin
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, cycles);
    end
    endtask

    // =========================================================================
    // TEST CASE: TX_ONLY mode test
    // =========================================================================
    task automatic test_interface_wrapper_tx_only();
        logic [7:0] test_data = 8'hA5; 
        logic [7:0] captured_data;
        int timeout;

        begin
            $display("\n========== START TEST: CFG_TX_ONLY (0x1) ==========");
            
            // configuration du mode
            set_config(CFG_TX_ONLY);
            repeat(2) @(posedge i_clk);

            assert (i_cfg_local == CFG_TX_ONLY)
                $display("  [TX_ONLY] Config ok");
            else
                $error("  [TX_ONLY] Config error");

            // --- 1. CONFIGURATION DU BAUD RATE ---
            $display("  [TX_ONLY] Configuration APB: Diviseur Baud Rate = 0x02...");
            // APB SETUP
            set_bus({1'b0, 1'b0, 1'b0, 8'h02, 8'h0C, 1'b1, 1'b0, 1'b1});
            // APB ACCESS
            set_bus({1'b0, 1'b0, 1'b0, 8'h02, 8'h0C, 1'b1, 1'b1, 1'b1});
            set_bus('0);
            repeat(2) @(posedge i_clk);

            // --- 2. ECRITURE DANS LA FIFO ---
            $display("  [TX_ONLY] Ecriture APB: Envoi de la donnee 0x%0h dans la FIFO...", test_data);
            // APB SETUP
            set_bus({1'b0, 1'b0, 1'b0, test_data, 8'h00, 1'b1, 1'b0, 1'b1});
            // APB ACCESS
            set_bus({1'b0, 1'b0, 1'b0, test_data, 8'h00, 1'b1, 1'b1, 1'b1});
            set_bus('0);
            repeat(2) @(posedge i_clk);

            // --- 3. ACTIVATION DU TX ---
            $display("  [TX_ONLY] Configuration APB: Activation TX_START et GLOBAL_EN...");
            // APB SETUP
            set_bus({1'b0, 1'b0, 1'b0, 8'h09, 8'h08, 1'b1, 1'b0, 1'b1});
            // APB ACCESS
            set_bus({1'b0, 1'b0, 1'b0, 8'h09, 8'h08, 1'b1, 1'b1, 1'b1});
            set_bus('0);

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
                repeat(4) @(posedge i_clk);
                
                for (int i = 0; i < 8; i++) begin
                    captured_data[i] = o_bus_out[12];
                    if (i < 7) repeat(3) @(posedge i_clk);
                end

                assert (captured_data === test_data)
                    $display("  [TX_ONLY] PASS : Serie capturee = 0x%0h", captured_data);
                else
                    $error("  [TX_ONLY] FAIL : Capture 0x%0h, attendu 0x%0h", captured_data, test_data);
            end

            while (o_bus_out[13] == 1'b1) @(posedge i_clk);
            $display("  [TX_ONLY] Transmission terminee (tx_busy = 0)");

            $display("========== CFG_TX_ONLY TEST COMPLETE ==========\n");
        end
    endtask

    // =========================================================================
    // TEST CASE: RX_ONLY mode test
    // =========================================================================
    task automatic test_interface_wrapper_rx_only();
        logic [7:0] test_data = 8'hA5; 
        logic [7:0] read_data;
        int timeout;

        begin
            $display("\n========== START TEST: CFG_RX_ONLY (0x2) ==========");
            
            set_config(CFG_RX_ONLY);
            repeat(2) @(posedge i_clk);

            assert (i_cfg_local == CFG_RX_ONLY)
                $display("  [RX_ONLY] Config ok");
            else
                $error("  [RX_ONLY] Config error");

            $display("  [RX_ONLY] Configuration APB: Activation RX_EN et GLOBAL_EN...");
            set_bus({1'b0, 1'b0, 1'b0, 8'h11, 8'h08, 1'b1, 1'b0, 1'b1});
            set_bus({1'b0, 1'b0, 1'b0, 8'h11, 8'h08, 1'b1, 1'b1, 1'b1});
            set_bus('0);

            $display("  [RX_ONLY] Injecting serial data 0x%0h...", test_data);
            
            for (int i = 0; i < 8; i++) begin
                set_bus({1'b0, 1'b1, test_data[i], 8'h00, 8'h00, 3'b000}); 
                set_bus({1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 3'b000});
            end

            timeout = 0;
            while (o_bus_out[9] == 1'b1 && timeout < 50) begin
                @(posedge i_clk);
                timeout++;
            end

            assert (o_bus_out[9] == 1'b0)
                $display("  [RX_ONLY] Data in FIFO");
            else
                $error("  [RX_ONLY] FIFO empty error");

            $display("  [RX_ONLY] APB read...");
            set_bus({1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 1'b0, 1'b0, 1'b1});
            set_bus({1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 1'b0, 1'b1, 1'b1});
            
            read_data = o_bus_out[7:0];

            assert (read_data === test_data)
                $display("  [RX_ONLY] PASS : Read 0x%0h", read_data);
            else
                $error("  [RX_ONLY] FAIL : Read 0x%0h, Expected 0x%0h", read_data, test_data);

            $display("========== CFG_RX_ONLY TEST COMPLETE ==========\n");
        end
    endtask

    // =========================================================================
    // TEST CASE: LOOPBACK mode test
    // =========================================================================
    task automatic test_interface_wrapper_loopback();
        logic [21:0] bus_val;
        logic [7:0] test_data = 8'hC3;
        logic [7:0] read_data;
        int timeout;

        begin
            $display("\n========== START TEST: CFG_LOOPBACK (0x3) ==========");
            
            set_config(CFG_LOOPBACK);
            repeat(2) @(posedge i_clk);

            assert (i_cfg_local == CFG_LOOPBACK)
                $display("  [LOOPBACK] Config ok");
            else
                $error("  [LOOPBACK] Config error");

            // --- 1. CONFIGURATION BAUD RATE ---
            $display("  [LOOPBACK] Config Baud Rate (div=0x02)...");
            bus_val = '0;
            bus_val[0] = 1'b1;
            bus_val[2] = 1'b1;
            bus_val[10:3] = 8'h0C;
            bus_val[18:11] = 8'h02;
            set_bus(bus_val);
            bus_val[1] = 1'b1;
            set_bus(bus_val);
            set_bus('0);

            // --- 2. ACTIVATION RX ET GLOBAL ---
            $display("  [LOOPBACK] Activation RX_EN et GLOBAL_EN...");
            bus_val = '0;
            bus_val[0] = 1'b1;
            bus_val[2] = 1'b1;
            bus_val[10:3] = 8'h08;
            bus_val[18:11] = 8'h11;
            set_bus(bus_val);
            bus_val[1] = 1'b1;
            set_bus(bus_val);
            set_bus('0);
            repeat(2) @(posedge i_clk);

            // --- 3. ECRITURE TX FIFO ---
            $display("  [LOOPBACK] Ecriture donnee 0x%0h dans FIFO TX...", test_data);
            bus_val = '0;
            bus_val[0] = 1'b1;
            bus_val[2] = 1'b1;
            bus_val[10:3] = 8'h00;
            bus_val[18:11] = test_data;
            set_bus(bus_val);
            bus_val[1] = 1'b1;
            set_bus(bus_val);
            set_bus('0);
            repeat(2) @(posedge i_clk);

            // --- 4. START TX ---
            $display("  [LOOPBACK] Declenchement TX_START...");
            bus_val = '0;
            bus_val[0] = 1'b1;
            bus_val[2] = 1'b1;
            bus_val[10:3] = 8'h08;
            bus_val[18:11] = 8'h19;
            set_bus(bus_val);
            bus_val[1] = 1'b1;
            set_bus(bus_val);
            set_bus('0);

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
                    while (o_bus_out[12] == 1'b0) @(posedge i_clk); 
                    bus_val = '0;
                    bus_val[20] = 1'b1;
                    set_bus(bus_val);
                    bus_val[20] = 1'b0;
                    set_bus(bus_val);
                end
            end

            timeout = 0;
            while (o_bus_out[10] == 1'b0 && timeout < 50) begin
                @(posedge i_clk);
                timeout++;
            end

            // --- 7. LECTURE RX FIFO VIA APB ---
            $display("  [LOOPBACK] Lecture de la FIFO RX...");
            bus_val = '0;
            bus_val[0] = 1'b1;
            bus_val[2] = 1'b0;
            bus_val[10:3] = 8'h00;
            set_bus(bus_val);
            bus_val[1] = 1'b1;
            set_bus(bus_val);
            
            read_data = o_bus_out[7:0];
            set_bus('0);

            assert (read_data === test_data)
                $display("  [LOOPBACK] PASS : Boucle complete reussie ! Donnee lue = 0x%0h", read_data);
            else
                $error("  [LOOPBACK] FAIL : Donnee lue 0x%0h, attendu 0x%0h", read_data, test_data);

            $display("========== CFG_LOOPBACK TEST COMPLETE ==========\n");
        end
    endtask

    // =========================================================================
    // TEST CASE: FIFO_TX mode test
    // =========================================================================
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

            assert (o_bus_out[9] == 1'b1)
                $display("  [FIFO_TX] PASS : FIFO is initially empty");
            else
                $error("  [FIFO_TX] FAIL : FIFO should be empty at startup");

            $display("  [FIFO_TX] Filling TX FIFO with 8 bytes...");
            for (int i = 0; i < 8; i++) begin
                bus_val = '0;
                bus_val[0] = 1'b1;
                bus_val[17:10] = 8'hD0 + i;
                set_bus(bus_val);
                set_bus('0);
            end

            assert (o_bus_out[8] == 1'b1)
                $display("  [FIFO_TX] PASS : FIFO FULL flag is set after 8 writes");
            else
                $error("  [FIFO_TX] FAIL : FIFO FULL flag is NOT set!");

            assert (o_bus_out[9] == 1'b0)
                $display("  [FIFO_TX] PASS : FIFO EMPTY flag is cleared");
            else
                $error("  [FIFO_TX] FAIL : FIFO EMPTY flag is still set!");

            $display("  [FIFO_TX] Reading back 8 bytes...");
            for (int i = 0; i < 8; i++) begin
                expected_data = 8'hD0 + i;
                bus_val = '0;
                bus_val[1] = 1'b1;
                set_bus(bus_val);
                set_bus('0);
                
                read_data = o_bus_out[7:0];
                
                assert (read_data === expected_data)
                    $display("  [FIFO_TX] PASS : Read 0x%0h (Expected 0x%0h)", read_data, expected_data);
                else
                    $error("  [FIFO_TX] FAIL : Read 0x%0h, Expected 0x%0h", read_data, expected_data);
            end

            assert (o_bus_out[9] == 1'b1)
                $display("  [FIFO_TX] PASS : FIFO is empty again after 8 reads");
            else
                $error("  [FIFO_TX] FAIL : FIFO should be empty!");

            $display("========== CFG_FIFO_TX TEST COMPLETE ==========\n");
        end
    endtask

    // =========================================================================
    // TEST CASE: FIFO_RX mode test
    // =========================================================================
    task automatic test_interface_wrapper_fifo_rx();
        logic [21:0] bus_val;
        logic [7:0] expected_data;
        logic [7:0] read_data;

        begin
            $display("\n========== START TEST: CFG_FIFO_RX (0x5) ==========");
            
            set_config(CFG_FIFO_RX);
            repeat(2) @(posedge i_clk);

            assert (i_cfg_local == CFG_FIFO_RX)
                $display("  [FIFO_RX] Config ok");
            else
                $error("  [FIFO_RX] Config error");

            assert (o_bus_out[9] == 1'b1)
                $display("  [FIFO_RX] PASS : FIFO is initially empty");
            else
                $error("  [FIFO_RX] FAIL : FIFO should be empty at startup");

            $display("  [FIFO_RX] Filling FIFO with 8 bytes...");
            for (int i = 0; i < 8; i++) begin
                bus_val = '0;
                bus_val[0] = 1'b1;
                bus_val[17:10] = 8'hC0 + i;
                set_bus(bus_val);
                set_bus('0);
            end

            assert (o_bus_out[8] == 1'b1)
                $display("  [FIFO_RX] PASS : FIFO FULL flag is set after 8 writes");
            else
                $error("  [FIFO_RX] FAIL : FIFO FULL flag is NOT set!");

            assert (o_bus_out[9] == 1'b0)
                $display("  [FIFO_RX] PASS : FIFO EMPTY flag is cleared");
            else
                $error("  [FIFO_RX] FAIL : FIFO EMPTY flag is still set!");

            $display("  [FIFO_RX] Reading back 8 bytes...");
            for (int i = 0; i < 8; i++) begin
                expected_data = 8'hC0 + i;
                bus_val = '0;
                bus_val[1] = 1'b1;
                set_bus(bus_val);
                set_bus('0);
                
                read_data = o_bus_out[7:0];
                
                assert (read_data === expected_data)
                    $display("  [FIFO_RX] PASS : Read 0x%0h (Expected 0x%0h)", read_data, expected_data);
                else
                    $error("  [FIFO_RX] FAIL : Read 0x%0h, Expected 0x%0h", read_data, expected_data);
            end

            assert (o_bus_out[9] == 1'b1)
                $display("  [FIFO_RX] PASS : FIFO is empty again after 8 reads");
            else
                $error("  [FIFO_RX] FAIL : FIFO should be empty!");

            $display("========== CFG_FIFO_RX TEST COMPLETE ==========\n");
        end
    endtask

    // =========================================================================
    // TEST CASE: SERDES mode test
    // =========================================================================
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

            // --- 1. TEST DU SERIALIZER (TX) ---
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

            // --- 2. TEST DU DESERIALIZER (RX) ---
            $display("\n  [SERDES] --- Test du Deserializer ---");
            $display("  [SERDES] Injection bit par bit de 0x%0h...", rx_test_data);
            
            bus_val = '0;
            for (int i = 0; i < 8; i++) begin
                bus_val[19] = rx_test_data[i]; 
                bus_val[20] = 1'b1;            
                set_bus(bus_val);
                
                if (i == 7) begin
                    @(negedge i_clk);
                    assert (o_bus_out[8] == 1'b1)
                        $display("  [SERDES] PASS : Signal push detecte au 8eme bit !");
                    else
                        $error("  [SERDES] FAIL : Signal push manquant !");
                end

                bus_val[20] = 1'b0;            
                set_bus(bus_val);
            end

            assert (o_bus_out[7:0] === rx_test_data)
                $display("  [SERDES] PASS : Deserializer a recu = 0x%0h", o_bus_out[7:0]);
            else
                $error("  [SERDES] FAIL : Recu 0x%0h, attendu 0x%0h", o_bus_out[7:0], rx_test_data);

            $display("\n========== CFG_SERDES TEST COMPLETE ==========\n");
        end
    endtask

    // =========================================================================
    // TEST CASE: BAUD mode test
    // =========================================================================
    task automatic test_interface_wrapper_baud();
        int cycle_count;
        int expected_cycles;

        begin
            $display("\n========== START TEST: CFG_BAUD (0x7) ==========");
            
            set_config(CFG_BAUD);
            repeat(2) @(posedge i_clk);

            assert (i_cfg_local == CFG_BAUD)
                $display("  [BAUD] Config ok");
            else
                $error("  [BAUD] Config error");

            // --- Test 1: Diviseur tres rapide (0x02) ---
            $display("  [BAUD] Setting fast divisor to 0x02...");
            set_bus({13'h00, 8'h02, 1'b1}); 
            
            expected_cycles = 3; 
            
            while (o_bus_out[12] == 1'b0) @(posedge i_clk);
            @(posedge i_clk);
            
            cycle_count = 1; 
            while (o_bus_out[12] == 1'b0 && cycle_count < 100) begin
                cycle_count++;
                @(posedge i_clk);
            end

            assert (cycle_count == expected_cycles)
                $display("  [BAUD] PASS : Period is %0d cycles", cycle_count);
            else
                $error("  [BAUD] FAIL : Expected %0d cycles, got %0d", expected_cycles, cycle_count);

            // --- Test 2: Diviseur un peu plus lent (0x05) ---
            $display("  [BAUD] Setting divisor to 0x05...");
            set_bus({13'h00, 8'h05, 1'b1}); 
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
            set_bus({13'h00, 8'h00, 1'b0});
            
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

    // =========================================================================
    // TEST PLAN: Full wrapper test suite
    // =========================================================================
    task automatic run_interface_wrapper_test_plan();
    begin
        test_interface_wrapper_tx_only();
        apply_reset(5);

        test_interface_wrapper_rx_only();
        apply_reset(5);

        test_interface_wrapper_loopback();
        apply_reset(5);

        test_interface_wrapper_fifo_tx();
        apply_reset(5);

        test_interface_wrapper_fifo_rx();
        apply_reset(5);

        test_interface_wrapper_serdes();
        apply_reset(5);

        test_interface_wrapper_baud();

        $display("\n========== ALL INTERFACE WRAPPER TESTS COMPLETED SUCCESSFULLY ==========");
    end
    endtask

endpackage : interface_wrapper_tasks_pkg
