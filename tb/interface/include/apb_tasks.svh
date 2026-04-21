task automatic apb_write(
    input logic [APB_ADDR_WIDTH-1:0] addr,
    input logic [APB_DATA_WIDTH-1:0] data
);
begin
    @(posedge i_clk);
    i_psel    <= 1'b1;
    i_penable <= 1'b0;
    i_pwrite  <= 1'b1;
    i_paddr   <= addr;
    i_pwdata  <= data;

    @(posedge i_clk);
    i_penable <= 1'b1;

    @(posedge i_clk);
    i_psel    <= 1'b0;
    i_penable <= 1'b0;
    i_pwrite  <= 1'b0;
    i_paddr   <= '0;
    i_pwdata  <= '0;
end
endtask


task automatic apb_read(
    input  logic [APB_ADDR_WIDTH-1:0] addr,
    output logic [APB_DATA_WIDTH-1:0] data
);
begin
    @(posedge i_clk);
    i_psel    <= 1'b1;
    i_penable <= 1'b0;
    i_pwrite  <= 1'b0;
    i_paddr   <= addr;

    @(posedge i_clk);
    i_penable <= 1'b1;

    @(posedge i_clk);
    data      = o_prdata;
    i_psel    <= 1'b0;
    i_penable <= 1'b0;
    i_paddr   <= '0;
end
endtask
