module derivative #(
    parameter WIDTH = 8
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic signed [WIDTH-1:0] i_phase,
    output logic signed [WIDTH-1:0] o_phase_deriv
);

    logic signed [WIDTH-1:0] s_phase_reg;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            s_phase_reg   <= '0;
            o_phase_deriv <= '0;
        end else begin
            // 1. Store previous phase
            s_phase_reg <= i_phase;

            // 2. Calculate Difference %180
            o_phase_deriv <= i_phase - s_phase_reg;

        end
    end

endmodule

