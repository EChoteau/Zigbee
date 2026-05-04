task automatic test_7_internal();
    begin
        $display("[%0t] test_7_internal", $time);        
        i_top_cfg = 3'd7;
        // Use wrapper config 1 for MSK: injection into encoder (see msk_test_wrapper)
        i_wrapper_cfg = 3'b000;
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        repeat (20) @(posedge clk);

        // Generate a simple bitstream into the MSK wrapper via i_bus_a[0]
        $display("[TEST7] Sending bitstream to MSK wrapper...");
        // Send a 16-bit pattern LSB first
        integer i;
        for (i = 0; i < 16; i = i + 1) begin
            i_bus_a = 12'b0;
            i_bus_a[0] = (i % 2); // alternate 1/0 pattern
            // pulses on bus B if needed
            i_bus_b = 10'b0;
            repeat (4) @(posedge clk);
        end

        // Let MSK produce its output and let CDR capture it
        repeat (40) @(posedge clk);

        // Sample the recovered stream from top outputs (CDR wrapper outputs)
        $display("[TEST7] Observed CDR outputs: o_bus_c=0x%03h o_bus_d=0b%02b", o_bus_c, o_bus_d);

        $display("[TEST7] test_7_internal complete");
    end
endtask
