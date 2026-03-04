task automatic run_tc_t2_tx_nominal;
    logic [APB_DATA_WIDTH-1:0] rd;
    logic [7:0] tx_captured;
    int bit_idx;
    int timeout_cycles;
begin
    $display("[T2] TX nominal test start");

    apb_write(ADDR_DIVIDER, 8'h02);
    apb_write(ADDR_CONTROL, 8'h09); // global_en=1, tx_start=1

    apb_write(ADDR_DATA, 8'hA5);

    timeout_cycles = 0;
    while ((o_tx_valid !== 1'b1) && (timeout_cycles < 50)) begin
        @(posedge i_clk);
        timeout_cycles++;
    end
    assert (o_tx_valid === 1'b1)
        else $fatal(1, "[T2] Timeout waiting for tx_busy/o_tx_valid");

    tx_captured = 8'h00;
    bit_idx = 0;
    timeout_cycles = 0;
    while (bit_idx < 8) begin
        @(posedge i_clk);
        if (o_tx_sample_tick) begin
            tx_captured[bit_idx] = o_serial_tx;
            bit_idx++;
        end
        timeout_cycles++;
        assert (timeout_cycles < 200)
            else $fatal(1, "[T2] Timeout waiting to capture 8 TX bits");
    end

    assert (tx_captured == 8'hA5)
        else $fatal(1, "[T2] Serialized byte mismatch. got=%0h expected=A5", tx_captured);

    timeout_cycles = 0;
    while ((o_tx_valid !== 1'b0) && (timeout_cycles < 20)) begin
        @(posedge i_clk);
        timeout_cycles++;
    end
    assert (o_tx_valid === 1'b0)
        else $fatal(1, "[T2] tx_busy/o_tx_valid should return to 0 after frame");

    apb_read(ADDR_STATUS, rd);
    assert (rd[2] == 1'b0)
        else $fatal(1, "[T2] STATUS.tx_busy should be 0 after TX completion");

    $display("[T2] TX nominal test PASS");
end
endtask
