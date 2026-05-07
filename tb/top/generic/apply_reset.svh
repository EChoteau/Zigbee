// Helper task: apply_reset
task automatic apply_reset(int cycles);
begin
    i_rst_n = 1'b0;
    repeat (cycles) @(posedge i_clk);
    i_rst_n = 1'b1;
    @(posedge i_clk);
end
endtask
