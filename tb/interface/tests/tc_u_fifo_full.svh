task automatic run_tc_u_fifo_full;
    logic [7:0] expected;
    int i;
begin
    $display("[U_FIFO] Full FIFO test start");

    // Initialization
    u_fifo_wr_en = 1'b0;
    u_fifo_rd_en = 1'b0;
    u_fifo_din   = '0;
    @(posedge i_clk); #1;

    assert (u_fifo_empty == 1'b1)
        else $fatal(1, "[U_FIFO] FIFO should be empty initially");
    assert (u_fifo_full == 1'b0)
        else $fatal(1, "[U_FIFO] FIFO should not be full initially");

    // Write until FIFO is full
    for (i = 0; i < FIFO_DEPTH; i++) begin
        u_fifo_din   = 8'h20 + i;
        u_fifo_wr_en = 1'b1;
        @(posedge i_clk); #1;
        u_fifo_wr_en = 1'b0;
        
        if (i < FIFO_DEPTH - 1) begin
            assert (u_fifo_full == 1'b0)
                else $fatal(1, "[U_FIFO] FIFO should not be full yet (write %0d)", i);
        end else begin
            assert (u_fifo_full == 1'b1)
                else $fatal(1, "[U_FIFO] FIFO should be full after %0d writes", FIFO_DEPTH);
        end
    end

    assert (u_fifo_empty == 1'b0)
        else $fatal(1, "[U_FIFO] FIFO should not be empty after writes");

    // Attempt to write when full (overflow condition)
    u_fifo_din   = 8'hFF;
    u_fifo_wr_en = 1'b1;
    @(posedge i_clk); #1;
    u_fifo_wr_en = 1'b0;
    
    assert (u_fifo_full == 1'b1)
        else $fatal(1, "[U_FIFO] FIFO should still be full after overflow write");

    // Read back and verify the first FIFO_DEPTH elements match
    for (i = 0; i < FIFO_DEPTH; i++) begin
        expected = 8'h20 + i;
        u_fifo_rd_en = 1'b1;
        @(posedge i_clk); #1;
        
        assert (u_fifo_rd_valid == 1'b1)
            else $fatal(1, "[U_FIFO] rd_valid should pulse on read %0d", i);
        assert (u_fifo_dout == expected)
            else $fatal(1, "[U_FIFO] Data mismatch on read %0d. got=%0h expected=%0h", i, u_fifo_dout, expected);
        
        u_fifo_rd_en = 1'b0;
        @(posedge i_clk); #1;
        
        // After reading at least 1 element, FIFO should no longer be full
        assert (u_fifo_full == 1'b0)
            else $fatal(1, "[U_FIFO] FIFO should not be full after read %0d", i);
    end

    // Verify empty state
    assert (u_fifo_empty == 1'b1)
        else $fatal(1, "[U_FIFO] FIFO should be empty after all reads");
    assert (u_fifo_full == 1'b0)
        else $fatal(1, "[U_FIFO] FIFO should not be full");

    $display("[U_FIFO] Full FIFO test PASS");
end
endtask
