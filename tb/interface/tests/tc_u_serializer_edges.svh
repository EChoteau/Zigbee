task automatic run_tc_u_serializer_edges;
    logic [7:0] payload0;
    logic [7:0] payload1;
    logic [7:0] cap0;
    logic [7:0] cap1;
    int bit_idx;
    int timeout;
begin
    $display("[U_SER_EDGE] Serializer edge test start");

    payload0 = 8'h3C;
    payload1 = 8'hC3;
    cap0 = '0;
    cap1 = '0;

    u_ser_baud_tick      = 1'b0;
    u_ser_tx_data        = '0;
    u_ser_tx_data_valid  = 1'b0;
    u_ser_tx_fifo_empty  = 1'b1;
    @(posedge i_clk); #1;

    // Must not start without request/data
    repeat (3) @(posedge i_clk); #1;
    assert (u_ser_tx_busy == 1'b0)
        else $fatal(1, "[U_SER_EDGE] Busy should stay low without data_valid");

    // Frame 0
    u_ser_tx_fifo_empty = 1'b0;
    timeout = 0;
    while ((u_ser_tx_fifo_pop !== 1'b1) && (timeout < 40)) begin
        @(posedge i_clk); #1;
        timeout++;
    end
    assert (u_ser_tx_fifo_pop == 1'b1)
        else $fatal(1, "[U_SER_EDGE] Missing fifo_pop for frame0");

    u_ser_tx_fifo_empty = 1'b1;
    u_ser_tx_data = payload0;
    u_ser_tx_data_valid = 1'b1;
    @(posedge i_clk); #1;
    u_ser_tx_data_valid = 1'b0;

    bit_idx = 0;
    timeout = 0;
    while (bit_idx < 8) begin
        u_ser_baud_tick = 1'b1;
        @(posedge i_clk); #1;
        u_ser_baud_tick = 1'b0;
        @(posedge i_clk); #1;
        if (u_ser_tx_sample_tick) begin
            cap0[bit_idx] = u_ser_serial_data;
            bit_idx++;
        end
        timeout++;
        assert (timeout < 80)
            else $fatal(1, "[U_SER_EDGE] Timeout frame0 capture");
    end
    assert (cap0 == payload0)
        else $fatal(1, "[U_SER_EDGE] Frame0 mismatch got=%0h exp=%0h", cap0, payload0);

    // Back-to-back frame 1
    u_ser_tx_fifo_empty = 1'b0;
    timeout = 0;
    while ((u_ser_tx_fifo_pop !== 1'b1) && (timeout < 40)) begin
        @(posedge i_clk); #1;
        timeout++;
    end
    assert (u_ser_tx_fifo_pop == 1'b1)
        else $fatal(1, "[U_SER_EDGE] Missing fifo_pop for frame1");
    u_ser_tx_fifo_empty = 1'b1;
    u_ser_tx_data = payload1;
    u_ser_tx_data_valid = 1'b1;
    @(posedge i_clk); #1;
    u_ser_tx_data_valid = 1'b0;

    bit_idx = 0;
    timeout = 0;
    while (bit_idx < 8) begin
        u_ser_baud_tick = 1'b1;
        @(posedge i_clk); #1;
        u_ser_baud_tick = 1'b0;
        @(posedge i_clk); #1;
        if (u_ser_tx_sample_tick) begin
            cap1[bit_idx] = u_ser_serial_data;
            bit_idx++;
        end
        timeout++;
        assert (timeout < 80)
            else $fatal(1, "[U_SER_EDGE] Timeout frame1 capture");
    end
    assert (cap1 == payload1)
        else $fatal(1, "[U_SER_EDGE] Frame1 mismatch got=%0h exp=%0h", cap1, payload1);

    assert (u_ser_tx_busy == 1'b0)
        else $fatal(1, "[U_SER_EDGE] Busy should be low at end");

    $display("[U_SER_EDGE] Serializer edge test PASS");
end
endtask
