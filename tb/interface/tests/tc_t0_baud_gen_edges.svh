task automatic run_tc_t0_baud_gen_edges;
    int timeout;
    int gap;
begin
    $display("[T0_BAUD_EDGE] Baud generator edge test start");

    // div=0 is clamped to 1 => tick every 2 cycles
    tb_baud_div    = 8'h00;
    tb_baud_enable = 1'b1;
    gap = 0;
    timeout = 0;
    while (timeout < 20) begin
        @(posedge i_clk); #1;
        if (tb_baud_tick) begin
            assert (gap == 1)
                else $fatal(1, "[T0_BAUD_EDGE] div=0 clamp mismatch. gap=%0d expected=1", gap);
            break;
        end
        gap++;
        timeout++;
    end
    assert (timeout < 20)
        else $fatal(1, "[T0_BAUD_EDGE] Timeout waiting first tick (div=0 clamp)");

    // disable resets counter immediately in this RTL
    tb_baud_enable = 1'b1;
    tb_baud_div    = 8'd5;
    repeat (3) @(posedge i_clk);
    tb_baud_enable = 1'b0;
    repeat (3) @(posedge i_clk); #1;
    assert (tb_baud_tick == 1'b0)
        else $fatal(1, "[T0_BAUD_EDGE] Tick should stay low while disabled");

    // re-enable starts fresh count (first tick after 6 cycles for div=5)
    tb_baud_enable = 1'b1;
    gap = 0;
    timeout = 0;
    while (timeout < 20) begin
        @(posedge i_clk); #1;
        if (tb_baud_tick) begin
            assert (gap == 5)
                else $fatal(1, "[T0_BAUD_EDGE] Re-enable count mismatch. gap=%0d expected=5", gap);
            break;
        end
        gap++;
        timeout++;
    end
    assert (timeout < 20)
        else $fatal(1, "[T0_BAUD_EDGE] Timeout waiting tick after re-enable");

    tb_baud_enable = 1'b0;
    $display("[T0_BAUD_EDGE] Baud generator edge test PASS");
end
endtask
