module derivative #(
    parameter WIDTH = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [WIDTH-1:0] phase_in,
    output logic signed [WIDTH-1:0] phase_deriv
);

    logic signed [WIDTH-1:0] phase_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_reg   <= '0;
            phase_deriv <= '0;
        end else begin
            // 1. Store previous phase
            phase_reg <= phase_in;

            // 2. Calculate Difference %180
            phase_deriv <= phase_in - phase_reg;

        end
    end

endmodule

