task automatic test_interface_wrapper_baud();
    int cycle_count;
    int expected_cycles;

    begin
        $display("\n========== START TEST: CFG_BAUD (0x7) ==========");
        
        // set config
        set_config(CFG_BAUD);
        repeat(2) @(posedge i_clk);

        assert (i_cfg_local == CFG_BAUD)
            $display("  [BAUD] Config ok");
        else
            $error("  [BAUD] Config error");

        // --- Test 1: Diviseur tres rapide (0x02) pour simu courte ---
        $display("  [BAUD] Setting fast divisor to 0x02...");
        set_bus({13'h00, 8'h02, 1'b1}); 
        
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