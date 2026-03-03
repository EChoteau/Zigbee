task automatic run_tc_t0_reset_smoke;
    logic [APB_DATA_WIDTH-1:0] rd;
begin
    $display("[T0] Reset/Smoke test start");

    assert (o_pready === 1'b1)
        else $fatal(1, "[T0] o_pready should be 1 after reset");

    assert (o_pslverr === 1'b0)
        else $fatal(1, "[T0] o_pslverr should be 0 after reset");

    assert (o_tx_valid === 1'b0)
        else $fatal(1, "[T0] o_tx_valid should be 0 after reset");

    apb_read(ADDR_CONTROL, rd);
    assert (rd[4:0] == 5'b0)
        else $fatal(1, "[T0] CONTROL reset mismatch. got=%0h", rd[4:0]);

    apb_read(ADDR_DIVIDER, rd);
    assert (rd[7:0] == 8'h00)
        else $fatal(1, "[T0] DIVIDER reset mismatch. got=%0h", rd[7:0]);

    apb_read(ADDR_STATUS, rd);
    assert (rd[4:0] == 5'b00001)
        else $fatal(1, "[T0] STATUS reset mismatch. got=%0b expected=00001", rd[4:0]);

    apb_read(ADDR_DATA, rd);
    assert (rd[7:0] == 8'h00)
        else $fatal(1, "[T0] DATA reset value mismatch. got=%0h", rd[7:0]);

    $display("[T0] Reset/Smoke test PASS");
end
endtask
