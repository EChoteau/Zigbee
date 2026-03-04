task automatic cdr_push_rx_byte(
    input logic [7:0] data
);
    int i;
begin
    for (i = 0; i < 8; i++) begin
        @(posedge i_clk);
        i_serial_rx        <= data[i];
        i_cdr_sample_valid <= 1'b1;

        @(posedge i_clk);
        i_cdr_sample_valid <= 1'b0;
    end
end
endtask


task automatic run_tc_t3_rx_nominal;
    logic [APB_DATA_WIDTH-1:0] rd;
begin
    $display("[T3] RX nominal test start");

    i_serial_rx <= 1'b1;
    apb_write(ADDR_CONTROL, 8'h11); // global_en=1, rx_enable=1

    cdr_push_rx_byte(8'h3C);
    repeat (2) @(posedge i_clk);

    apb_read(ADDR_STATUS, rd);
    assert (rd[0] == 1'b0)
        else $fatal(1, "[T3] STATUS.rx_empty should be 0 after one received byte");

    apb_read(ADDR_DATA, rd);
    assert (rd[7:0] == 8'h3C)
        else $fatal(1, "[T3] RX byte mismatch. got=%0h expected=3C", rd[7:0]);

    apb_read(ADDR_STATUS, rd);
    assert (rd[0] == 1'b1)
        else $fatal(1, "[T3] STATUS.rx_empty should return to 1 after pop");

    $display("[T3] RX nominal test PASS");
end
endtask
