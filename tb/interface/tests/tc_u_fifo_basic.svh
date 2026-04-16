task automatic run_tc_u_fifo_basic;
    logic [7:0] expected;
    int i;
begin
    $display("[U_FIFO] Basic FIFO test start");

    u_fifo_wr_en = 1'b0;
    u_fifo_rd_en = 1'b0;
    u_fifo_din   = '0;
    @(posedge i_clk); #1;

    assert (u_fifo_empty == 1'b1)
        else $fatal(1, "[U_FIFO] FIFO should be empty after reset");

    for (i = 0; i < 3; i++) begin
        u_fifo_din   = 8'h10 + i;
        u_fifo_wr_en = 1'b1;
        @(posedge i_clk); #1;
        u_fifo_wr_en = 1'b0;
    end

    assert (u_fifo_empty == 1'b0)
        else $fatal(1, "[U_FIFO] FIFO should not be empty after writes");

    for (i = 0; i < 3; i++) begin
        expected = 8'h10 + i;
        u_fifo_rd_en = 1'b1;
        @(posedge i_clk); #1;
        assert (u_fifo_rd_valid == 1'b1)
            else $fatal(1, "[U_FIFO] rd_valid should pulse on read %0d", i);
        assert (u_fifo_dout == expected)
            else $fatal(1, "[U_FIFO] Data mismatch on read %0d. got=%0h expected=%0h", i, u_fifo_dout, expected);
        u_fifo_rd_en = 1'b0;
        @(posedge i_clk); #1;
    end

    assert (u_fifo_empty == 1'b1)
        else $fatal(1, "[U_FIFO] FIFO should be empty after all reads");

    $display("[U_FIFO] Basic FIFO test PASS");
end
endtask
