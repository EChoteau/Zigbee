task automatic run_tc_u_serializer_basic;
    logic [7:0] payload;
    logic [7:0] captured;
    int bit_idx;
    int timeout;
begin
    $display("[U_SER] Basic serializer test start");

    payload = 8'hA6;
    captured = '0;

    u_ser_baud_tick     = 1'b0;
    u_ser_tx_data       = '0;
    u_ser_tx_data_valid = 1'b0;
    u_ser_tx_fifo_empty = 1'b1;

    @(posedge i_clk); #1;

    u_ser_tx_fifo_empty = 1'b0;
    timeout = 0;
    while ((u_ser_tx_fifo_pop !== 1'b1) && (timeout < 50)) begin
        @(posedge i_clk); #1;
        timeout++;
    end
    assert (u_ser_tx_fifo_pop == 1'b1)
        else $fatal(1, "[U_SER] Timeout waiting o_tx_fifo_pop");

    u_ser_tx_fifo_empty = 1'b1;
    u_ser_tx_data       = payload;
    u_ser_tx_data_valid = 1'b1;
    @(posedge i_clk); #1;
    u_ser_tx_data_valid = 1'b0;

    bit_idx = 0;
    timeout = 0;
    while (bit_idx < 8) begin
        @(posedge i_clk);
        u_ser_baud_tick = ~u_ser_baud_tick;
        #1;

        if (u_ser_tx_sample_tick) begin
            captured[bit_idx] = u_ser_serial_data;
            bit_idx++;
        end

        timeout++;
        assert (timeout < 300)
            else $fatal(1, "[U_SER] Timeout waiting serialized bits");
    end

    u_ser_baud_tick = 1'b0;

    assert (captured == payload)
        else $fatal(1, "[U_SER] Serialized data mismatch. got=%0h expected=%0h", captured, payload);

    timeout = 0;
    while ((u_ser_tx_busy !== 1'b0) && (timeout < 30)) begin
        @(posedge i_clk); #1;
        timeout++;
    end
    assert (u_ser_tx_busy == 1'b0)
        else $fatal(1, "[U_SER] Busy should return low at end of frame");

    $display("[U_SER] Basic serializer test PASS");
end
endtask
