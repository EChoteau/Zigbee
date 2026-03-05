task automatic run_tc_t5_sw_reset;
    logic [7:0] rd;
begin
    $display("[T5_SW_RESET] Software Reset test start");

    // Clear all initially
    apb_write(ADDR_CONTROL, 8'h02); // sw_reset=1
    @(posedge i_clk); #1;
    apb_write(ADDR_CONTROL, 8'h00);

    // Write a byte to TX FIFO
    apb_write(ADDR_DATA, 8'h5A);
    
    // Validate it's not empty
    apb_read(ADDR_STATUS, rd);
    // Remember, wait for it... actually we don't have tx_empty in status, we have rx_empty[0] and tx_full[1].
    // Wait, let's write to RX FIFO to see if it becomes empty.
    cdr_push_rx_byte(8'hA5);
    
    apb_read(ADDR_STATUS, rd);
    assert (rd[0] == 1'b0)
        else $fatal(1, "[T5] RX FIFO should NOT be empty before reset. Status got=%0h", rd);

    // Apply sw_reset
    apb_write(ADDR_CONTROL, 8'h02); // sw_reset=1 (bit 1)
    
    // According to APB regs, sw_reset auto-clears on the next cycle inside apb_slave_regs,
    // but the write takes a cycle. Wait a couple of cycles.
    repeat(3) @(posedge i_clk);

    // Verify RX FIFO is now empty
    apb_read(ADDR_STATUS, rd);
    assert (rd[0] == 1'b1)
        else $fatal(1, "[T5] RX FIFO must be empty after sw_reset. Status got=%0h", rd);

    $display("[T5_SW_RESET] Software Reset test PASS");
end
endtask
