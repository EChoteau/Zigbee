// Wrapper test case: config 000
task automatic run_tc_wrapper_config_000();
begin
    $display("[WRAPPER_TC] run_tc_wrapper_config_000 invoked");
    i_wrapper_cfg = 3'b000;
    repeat (3) @(posedge clk);
end
endtask
