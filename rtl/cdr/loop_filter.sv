module loop_filter #(
    parameter int WIDTH = 8
) (
    input  logic                        i_clk,
    input  logic                        i_rst_n,
    input  logic                        i_ctrl_ack,
    input  logic                        i_up,
    input  logic                        i_down,
    output logic signed [WIDTH-1:0]     o_ctrl
);

    logic s_up_d, s_down_d;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            o_ctrl <= '0;
            s_up_d <= 1'b0;
            s_down_d <= 1'b0;
        end
        else begin
            s_up_d <= i_up;
            s_down_d <= i_down;

            if (i_up & ~s_up_d)
                o_ctrl <= $signed(4'sd1);
            else if (i_down & ~s_down_d)
                o_ctrl <= $signed(4'sd-1);
            else if (i_ctrl_ack)
                o_ctrl <= '0;  // Reset after consumption
        end
    end

endmodule
