task automatic run_tc_t4_interface_errors;
    logic [7:0] rd;
    int i;
begin
    $display("[T4_ERRORS] Interface Error Flags (Overflow/Underrun) test start");

    // Clear everything
    apb_write(ADDR_CONTROL, 8'h06); // clear_err=1, sw_reset=1
    @(posedge i_clk); #1;
    apb_write(ADDR_CONTROL, 8'h00);

    // ------------------------------------------------------------------------
    // Test 1: TX Underrun (trying to transmit with empty FIFO)
    // ------------------------------------------------------------------------
    // Enable global=1, tx_start=1 with an empty TX FIFO
    apb_write(ADDR_CONTROL, 8'h09); // global_en=1, tx_start=1 (bit 3)
    
    // Wait a bit to ensure the edge is detected
    repeat(5) @(posedge i_clk);
    
    apb_read(ADDR_STATUS, rd);
    assert (rd[4] == 1'b1)
        else $fatal(1, "[T4_ERRORS] TX Underrun error should be set when starting TX with empty FIFO");

    // Clear error
    apb_write(ADDR_CONTROL, 8'h0F); // clear_err=1 (bit 2)
    @(posedge i_clk); #1;
    apb_write(ADDR_CONTROL, 8'h01); // keep global_en=1, no tx_start retrigger
    
    apb_read(ADDR_STATUS, rd);
    assert (rd[4] == 1'b0)
        else $fatal(1, "[T4_ERRORS] TX Underrun error should be cleared");

    // ------------------------------------------------------------------------
    // Test 2: RX Overflow (receiving into a full FIFO)
    // ------------------------------------------------------------------------
    // Setup and enable global=1, rx_enable=1
    apb_write(ADDR_CONTROL, 8'h11); // global_en=1, rx_enable=1 (bit 4)
    apb_write(ADDR_DIVIDER, 8'h01);

    // Send FIFO_DEPTH + 1 bytes to force an overflow
    for (i = 0; i < FIFO_DEPTH + 1; i++) begin
        cdr_push_rx_byte(8'hA0 + i);
    end

    // Wait for deserializer to try and push the overflowing byte
    repeat(10) @(posedge i_clk);

    apb_read(ADDR_STATUS, rd);
    assert (rd[3] == 1'b1)
        else $fatal(1, "[T4_ERRORS] RX Overflow error should be set after pushing %0d bytes", FIFO_DEPTH + 1);

    assert (rd[0] == 1'b0)
        else $fatal(1, "[T4_ERRORS] RX FIFO should not be empty");

    // Clear error
    apb_write(ADDR_CONTROL, 8'h15); // clear_err=1 (bit 2)
    @(posedge i_clk); #1;
    apb_write(ADDR_CONTROL, 8'h11);
    
    apb_read(ADDR_STATUS, rd);
    assert (rd[3] == 1'b0)
        else $fatal(1, "[T4_ERRORS] RX Overflow error should be cleared");

    // Read out the FIFO elements to clean up
    for (i = 0; i < FIFO_DEPTH; i++) begin
        apb_read(ADDR_DATA, rd);
    end

    // Clean up
    apb_write(ADDR_CONTROL, 8'h02); // SW reset
    @(posedge i_clk); #1;
    apb_write(ADDR_CONTROL, 8'h00);

    $display("[T4_ERRORS] Interface Error Flags (Overflow/Underrun) test PASS");
end
endtask
