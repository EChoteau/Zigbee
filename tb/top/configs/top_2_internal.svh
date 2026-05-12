task automatic test_2_internal();
    // task-local declarations must appear before statements
    integer i;
    begin
        $display("[%0t] test_2_internal", $time);        
        i_top_cfg = 3'd2;
        // Use wrapper config 1 for MSK: injection into encoder (see msk_test_wrapper)
        i_wrapper_cfg = 3'b000;
        i_rst_n = 0;
        repeat (2) @(posedge i_clk);
        i_rst_n = 1;
        repeat (20) @(posedge i_clk);

        // Generate a simple bitstream into the MSK wrapper via i_bus_in[0]
        $display("[TEST2] Sending bitstream to MSK wrapper...");
        // Send a 16-bit pattern LSB first
        for (i = 0; i < 16; i = i + 1) begin
            i_bus_in = 22'b0;
            i_bus_in[0] = (i % 2); // alternate 1/0 pattern
            repeat (4) @(posedge i_clk);
        end

        // Let MSK produce its output and let CDR capture it
        repeat (40) @(posedge i_clk);

        // Sample the recovered stream from top outputs (CDR wrapper outputs)
        $display("[TEST2] Observed CDR outputs: o_bus_out=0x%03h", o_bus_out);

        $display("[TEST2] test_2_internal complete");
    end
endtask
