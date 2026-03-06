module fir_top (
    input  wire clk,
    input  wire rst,
    input  wire sample_en,
    input  wire signed [5:0] x_in,
    output wire signed [22:0] y_out
);

    // Flat vectors
    wire signed [32*6-1:0] x_delay_flat;
    wire signed [32*12-1:0] h_flat;

    // Delay line
    delay_line u_delay (
        .clk(clk),
        .rst(rst),
        .sample_en(sample_en),
        .x_in(x_in),
        .x_out_flat(x_delay_flat)
    );

    // Coefficient ROM
    coeff_rom u_coeff (
        .h_flat(h_flat)
    );

    // FIR core
    fir_core u_core (
        .clk(clk),
        .rst(rst),
        .x_flat(x_delay_flat),
        .h_flat(h_flat),
        .y_out(y_out)
    );

endmodule
