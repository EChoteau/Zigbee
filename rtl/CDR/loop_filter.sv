module loop_filter #(
    parameter WIDTH = 8
)(
    input  wire               i_clk,
    input  wire               i_rst_n,
    input wire                  i_ctrl_ack,
    input  wire               i_up,
    input  wire               i_down,
    output reg signed [WIDTH-1:0] o_ctrl
);

logic s_up_d, s_down_d;

always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        o_ctrl   <= (WIDTH-1)'0;
        s_up_d   <= 0;
        s_down_d <= 0;
    end
    else begin
        s_up_d   <= i_up;
        s_down_d <= i_down;

        if      (i_up   & ~s_up_d)   o_ctrl <=  1;
        else if (i_down & ~s_down_d) o_ctrl <= -1;
        else if (i_ctrl_ack)          o_ctrl <=  0;  // reset après consommation
    end
end

endmodule
