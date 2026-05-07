task automatic test_interface_wrapper_rx_only();
    logic [7:0] test_data = 8'hA5; 
    logic [7:0] read_data;

    begin
        $display("\n========== START TEST: CFG_RX_ONLY (0x2) ==========");
        
        // set config
        set_config(CFG_RX_ONLY);
        repeat(2) @(posedge i_clk);

        assert (i_cfg_local == CFG_RX_ONLY)
            $display("  [RX_ONLY] Config ok");
        else
            $error("  [RX_ONLY] Config error");

        $display("  [RX_ONLY] Injecting serial data 0x%0h...", test_data);
        
        // simuler reception serie bit par bit
        for (int i = 0; i < 8; i++) begin
            // bit 20: cdr_sample_valid, bit 19: serial_rx
            set_bus({1'b0, 1'b1, test_data[i], 8'h00, 8'h00, 3'b000}); 
            repeat(1) @(posedge i_clk);
            
            // clear valid
            set_bus({1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 3'b000});
            repeat(2) @(posedge i_clk);
        end

        // attente traitement des donnees
        repeat(5) @(posedge i_clk);

        // verif fifo pas vide (o_bus_out[9] = rx_fifo_empty)
        assert (o_bus_out[9] == 1'b0)
            $display("  [RX_ONLY] Data in FIFO");
        else
            $error("  [RX_ONLY] FIFO empty error");

        $display("  [RX_ONLY] APB read...");
        
        // read: pwrite=0, penable=1, psel=1
        set_bus({1'b0, 1'b0, 1'b0, 8'h00, 8'h00, 1'b0, 1'b1, 1'b1});
        repeat(2) @(posedge i_clk);
        
        read_data = o_bus_out[7:0];

        // check result
        assert (read_data === test_data)
            $display("  [RX_ONLY] PASS : Read 0x%0h", read_data);
        else
            $error("  [RX_ONLY] FAIL : Read 0x%0h, expected 0x%0h", read_data, test_data);

        $display("========== CFG_RX_ONLY TEST COMPLETE ==========\n");
    end
endtask