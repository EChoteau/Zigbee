// Helper task: apply_reset
task automatic apply_reset(int cycles);
begin
    rst_n = 1'b0;
    repeat (cycles) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
end
endtask
