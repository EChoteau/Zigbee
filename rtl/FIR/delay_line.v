module delay_line #(
    parameter N = 32,
    parameter IN_WIDTH = 6
)(
    input  wire clk,
    input  wire rst,
    input  wire sample_en,
    input  wire signed [IN_WIDTH-1:0] x_in,
    output reg signed [N*IN_WIDTH-1:0] x_out_flat
);

    reg signed [IN_WIDTH-1:0] i_x_out [0:N-1]; // signal interne en Verilog
    integer i;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < N; i = i + 1)
                i_x_out[i] <= 0;
        end
        else if (sample_en) begin
            i_x_out[0] <= x_in;
            for (i = 1; i < N; i = i + 1)
                i_x_out[i] <= i_x_out[i-1];
        end
    end

    // Conversion du tableau interne vers vecteur plat
    always @(*) begin
        for (i = 0; i < N; i = i + 1)
            x_out_flat[(i+1)*IN_WIDTH-1 -: IN_WIDTH] = i_x_out[i];
    end

endmodule
