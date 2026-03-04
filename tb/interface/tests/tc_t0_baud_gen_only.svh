task automatic run_tc_t0_baud_gen_only;
    int cyc_since_tick;
    int tick_count;
    int expected_gap;
begin
    $display("[T0_BAUD] Baud generator standalone test start");

    tb_baud_enable <= 1'b0;
    tb_baud_div    <= 8'd3;
    repeat (6) @(posedge i_clk);
    assert (tb_baud_tick == 1'b0)
        else $fatal(1, "[T0_BAUD] Tick should stay low when disabled");

    tb_baud_enable <= 1'b1;
    cyc_since_tick = 0;
    tick_count = 0;
    expected_gap = tb_baud_div;

    while (tick_count < 3) begin
        @(posedge i_clk);
        if (tb_baud_tick) begin
            assert (cyc_since_tick == expected_gap)
                else $fatal(1, "[T0_BAUD] Tick period mismatch. got=%0d expected=%0d", cyc_since_tick, expected_gap);
            cyc_since_tick = 0;
            tick_count++;
        end else begin
            cyc_since_tick++;
            assert (cyc_since_tick <= expected_gap)
                else $fatal(1, "[T0_BAUD] Timeout waiting for tick");
        end
    end

    tb_baud_enable <= 1'b0;
    repeat (4) @(posedge i_clk);
    assert (tb_baud_tick == 1'b0)
        else $fatal(1, "[T0_BAUD] Tick should be low after disable");

    $display("[T0_BAUD] Baud generator standalone test PASS");
end
endtask
