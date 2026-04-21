task automatic run_tc_u_fifo_edges;
    logic [7:0] before_data;
begin
    $display("[U_FIFO_EDGE] FIFO edge test start");

    u_fifo_wr_en = 1'b0;
    u_fifo_rd_en = 1'b0;
    u_fifo_din   = '0;
    @(posedge i_clk); #1;

    // Underflow read: no rd_valid pulse
    before_data = u_fifo_dout;
    u_fifo_rd_en = 1'b1;
    @(posedge i_clk); #1;
    assert (u_fifo_rd_valid == 1'b0)
        else $fatal(1, "[U_FIFO_EDGE] rd_valid must stay 0 on empty read");
    assert (u_fifo_dout == before_data)
        else $fatal(1, "[U_FIFO_EDGE] o_data changed on empty read");
    u_fifo_rd_en = 1'b0;

    // Simultaneous read+write when non-empty should keep occupancy stable
    u_fifo_din   = 8'h55;
    u_fifo_wr_en = 1'b1;
    @(posedge i_clk); #1;
    u_fifo_wr_en = 1'b0;

    assert (u_fifo_empty == 1'b0)
        else $fatal(1, "[U_FIFO_EDGE] FIFO should contain one element");

    u_fifo_din   = 8'hAA;
    u_fifo_wr_en = 1'b1;
    u_fifo_rd_en = 1'b1;
    @(posedge i_clk); #1;
    assert (u_fifo_rd_valid == 1'b1)
        else $fatal(1, "[U_FIFO_EDGE] rd_valid expected on simultaneous rd/wr");
    assert (u_fifo_dout == 8'h55)
        else $fatal(1, "[U_FIFO_EDGE] Read should return oldest data (55)");
    u_fifo_wr_en = 1'b0;
    u_fifo_rd_en = 1'b0;

    // Remaining element should now be 0xAA
    u_fifo_rd_en = 1'b1;
    @(posedge i_clk); #1;
    assert (u_fifo_rd_valid == 1'b1)
        else $fatal(1, "[U_FIFO_EDGE] Missing rd_valid for remaining element");
    assert (u_fifo_dout == 8'hAA)
        else $fatal(1, "[U_FIFO_EDGE] Remaining data mismatch. got=%0h expected=AA", u_fifo_dout);
    u_fifo_rd_en = 1'b0;

    @(posedge i_clk); #1;
    assert (u_fifo_empty == 1'b1)
        else $fatal(1, "[U_FIFO_EDGE] FIFO should be empty at end");

    $display("[U_FIFO_EDGE] FIFO edge test PASS");
end
endtask
