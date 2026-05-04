// Wrapper test case: tx path
task automatic run_tc_wrapper_tx_path();
begin
    $display("[WRAPPER_TC] run_tc_wrapper_tx_path invoked");
    // minimal exercise of TX path: ensure wrapper config and pulse bus
    i_wrapper_cfg = 3'b001;
    i_bus_a = 12'b0;
    i_bus_b = 10'b0;
    repeat (5) @(posedge clk);
end
endtask
