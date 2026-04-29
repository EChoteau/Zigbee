////////////////////////////////////////////////////////////////////////////////
// tc_wrapper_tx_path.svh
// ============================================================================
// Test Case: Verify TX path works correctly in config 000
// Tests: APB write -> TX FIFO -> Serializer
////////////////////////////////////////////////////////////////////////////////

task automatic run_tc_wrapper_tx_path;
    logic [APB_DATA_WIDTH-1:0] tx_data;
    logic [APB_DATA_WIDTH-1:0] rd;
begin
    $display("[WRAPPER_TC1] TX path test start");

    // Enable global control
    apb_write(ADDR_CONTROL, 8'h01); // global_en = 1
    repeat(2) @(posedge i_clk);

    // Write data to TX FIFO
    tx_data = 8'hA5;
    apb_write(ADDR_DATA, tx_data);
    repeat(2) @(posedge i_clk);

    // Verify data made it to TX FIFO
    assert (o_dbg_tx_fifo_rd_valid === 1'b1)
        else $fatal(1, "[WRAPPER_TC1] TX FIFO should have valid data");

    assert (o_dbg_tx_fifo_q === tx_data)
        else $fatal(1, "[WRAPPER_TC1] TX FIFO data mismatch: expected=%0h got=%0h",
                     tx_data, o_dbg_tx_fifo_q);

    $display("[WRAPPER_TC1] TX path test PASS");
end
endtask
