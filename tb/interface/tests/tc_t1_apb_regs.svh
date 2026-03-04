task automatic run_tc_t1_apb_regs;
    logic [APB_DATA_WIDTH-1:0] rd;
begin
    $display("[T1] APB registers test start");

    apb_write(ADDR_DIVIDER, 8'h31);
    apb_read(ADDR_DIVIDER, rd);
    assert (rd[7:0] == 8'h31)
        else $fatal(1, "[T1] DIVIDER write/read mismatch. got=%0h expected=31", rd[7:0]);

    apb_write(ADDR_CONTROL, 8'h1F);
    repeat (2) @(posedge i_clk);
    apb_read(ADDR_CONTROL, rd);
    assert (rd[4:0] == 5'b11001)
        else $fatal(1, "[T1] CONTROL autoclear mismatch. got=%0b expected=11001", rd[4:0]);

    apb_read(ADDR_STATUS, rd);
    assert (rd[0] == 1'b1)
        else $fatal(1, "[T1] STATUS.rx_empty should be 1 after reset/config");
    assert (rd[1] == 1'b0)
        else $fatal(1, "[T1] STATUS.tx_full should be 0");
    assert (rd[2] == 1'b0)
        else $fatal(1, "[T1] STATUS.tx_busy should be 0");
    assert (rd[3] == 1'b0)
        else $fatal(1, "[T1] STATUS.rx_ovf_err should be 0");
    assert (rd[4] == 1'b0)
        else $fatal(1, "[T1] STATUS.tx_und_err should be 0");

    $display("[T1] APB registers test PASS");
end
endtask
