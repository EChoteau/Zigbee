// Wrapper test case: reset
task automatic run_tc_wrapper_reset();
begin
    $display("[WRAPPER_TC] run_tc_wrapper_reset invoked");
    apply_reset(5);
    @(posedge clk);
end
endtask
