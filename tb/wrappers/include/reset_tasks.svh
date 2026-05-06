////////////////////////////////////////////////////////////////////////////////
// reset_tasks.svh
// ============================================================================
// Reset management tasks
////////////////////////////////////////////////////////////////////////////////

// Apply reset for N cycles
task automatic apply_reset(int cycles);
begin
    i_rst_n = 1'b0;
    repeat(cycles) @(posedge i_clk);
    i_rst_n = 1'b1;
    repeat(2) @(posedge i_clk);
end
endtask
