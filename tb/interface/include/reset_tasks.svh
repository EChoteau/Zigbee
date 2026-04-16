task automatic apply_reset(
    input int unsigned reset_cycles = 5
);
begin
    i_rst_n <= 1'b0;
    repeat (reset_cycles) @(posedge i_clk);
    i_rst_n <= 1'b1;
    @(posedge i_clk);
end
endtask
