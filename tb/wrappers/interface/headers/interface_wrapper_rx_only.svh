task automatic test_interface_wrapper_rx_only();
    logic [7:0] test_data = 8'hA5; 
    logic [7:0] read_data;
    int timeout;

    begin
        $display("\n========== START TEST: CFG_RX_ONLY (0x2) ==========");
        
        // set config
        tb_pkg::set_config(i_clk, i_cfg_local, CFG_RX_ONLY);
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