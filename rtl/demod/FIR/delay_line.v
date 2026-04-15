module delay_line #(
    parameter N = 9,
    parameter IN_WIDTH = 8
)(
    input  wire                          i_clk,
    input  wire                          i_rst_n,
    input  wire                          i_sample_en,
    input  wire signed [IN_WIDTH-1:0]    i_x_in,
    output reg  signed [N*IN_WIDTH-1:0]  o_x_out_flat
);

    // =========================
    // Registres internes
    // =========================
    reg signed [IN_WIDTH-1:0] s_x_out [0:N-1];
    integer i;

    // =========================
    // Shift register
    // =========================
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (i = 0; i < N; i = i + 1)
                s_x_out[i] <= '0;
        end
        else if (i_sample_en) begin
            s_x_out[0] <= i_x_in;
            for (i = 1; i < N; i = i + 1)
                s_x_out[i] <= s_x_out[i-1];
        end
    end

    // =========================
    // Flatten
    // =========================
    always @(*) begin
        for (i = 0; i < N; i = i + 1)
            o_x_out_flat[(i+1)*IN_WIDTH-1 -: IN_WIDTH] = s_x_out[i];
    end

endmodule
