task automatic run_tc_stress_tx_rx_noreset;
    logic [7:0] rd;
    logic [7:0] tx_byte;
    logic [7:0] rx_byte;
    int i;
    int phase;
    int timeout;
begin
    $display("[STRESS] TX/RX no-reset with baud changes start");

    apb_write(ADDR_CONTROL, 8'h19); // global_en=1, tx_start=1, rx_enable=1

    for (phase = 0; phase < 3; phase++) begin
        case (phase)
            0: apb_write(ADDR_DIVIDER, 8'h00);
            1: apb_write(ADDR_DIVIDER, 8'h01);
            default: apb_write(ADDR_DIVIDER, 8'h03);
        endcase

        for (i = 0; i < 6; i++) begin
            tx_byte = 8'h40 + (phase * 8) + i;
            rx_byte = 8'hA0 + (phase * 8) + i;

            apb_write(ADDR_DATA, tx_byte);
            cdr_push_rx_byte(rx_byte);

            timeout = 0;
            while ((o_tx_valid !== 1'b0) && (timeout < 200)) begin
                @(posedge i_clk); #1;
                timeout++;
            end

            apb_read(ADDR_STATUS, rd);
            assert (rd[3] == 1'b0)
                else $fatal(1, "[STRESS] RX overflow error should stay low");
            assert (rd[4] == 1'b0)
                else $fatal(1, "[STRESS] TX underrun error should stay low");

            apb_read(ADDR_DATA, rd);
            assert (rd == rx_byte)
                else $fatal(1, "[STRESS] RX data mismatch. got=%0h expected=%0h", rd, rx_byte);
        end
    end

    $display("[STRESS] TX/RX no-reset with baud changes PASS");
end
endtask
