module coeff_rom #(
    parameter N = 9,
    parameter COEF_WIDTH = 8
)(
    output wire signed [N*COEF_WIDTH-1:0] o_h_flat
);

    // =========================
    // Coefficients FIR
    // =========================
    wire signed [COEF_WIDTH-1:0] w_h_int [0:N-1];

    assign w_h_int[0] = -8'sd13;
    assign w_h_int[1] = -8'sd8;
    assign w_h_int[2] =  8'sd35;
    assign w_h_int[3] =  8'sd97;
    assign w_h_int[4] =  8'sd127;  // centre

    // Symétrie
    assign w_h_int[5] = w_h_int[3];
    assign w_h_int[6] = w_h_int[2];
    assign w_h_int[7] = w_h_int[1];
    assign w_h_int[8] = w_h_int[0];

    // =========================
    // Conversion vers vecteur plat
    // =========================
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_pack
            assign o_h_flat[(i+1)*COEF_WIDTH-1 -: COEF_WIDTH] = w_h_int[i];
        end
    endgenerate

endmodule
