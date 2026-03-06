module coeff_rom #(
    parameter N = 32,
    parameter COEF_WIDTH = 12
)(
    output wire signed [N*COEF_WIDTH-1:0] h_flat
);

    // Coefficients FIR - Fc = 1 MHz, Fstop = 2.5 MHz
    wire signed [COEF_WIDTH-1:0] i_h_int [0:N-1];

    assign i_h_int[0]  =  12'sd3;
    assign i_h_int[1]  =  12'sd7;
    assign i_h_int[2]  =  12'sd11;
    assign i_h_int[3]  =  12'sd11;
    assign i_h_int[4]  =  12'sd6;
    assign i_h_int[5]  = -12'sd7;
    assign i_h_int[6]  = -12'sd24;
    assign i_h_int[7]  = -12'sd42;
    assign i_h_int[8]  = -12'sd51;
    assign i_h_int[9]  = -12'sd44;
    assign i_h_int[10] = -12'sd13;
    assign i_h_int[11] =  12'sd43;
    assign i_h_int[12] =  12'sd120;
    assign i_h_int[13] =  12'sd205;
    assign i_h_int[14] =  12'sd283;
    assign i_h_int[15] =  12'sd338;

    // Symétrie
    assign i_h_int[16] = i_h_int[15];
    assign i_h_int[17] = i_h_int[14];
    assign i_h_int[18] = i_h_int[13];
    assign i_h_int[19] = i_h_int[12];
    assign i_h_int[20] = i_h_int[11];
    assign i_h_int[21] = i_h_int[10];
    assign i_h_int[22] = i_h_int[9];
    assign i_h_int[23] = i_h_int[8];
    assign i_h_int[24] = i_h_int[7];
    assign i_h_int[25] = i_h_int[6];
    assign i_h_int[26] = i_h_int[5];
    assign i_h_int[27] = i_h_int[4];
    assign i_h_int[28] = i_h_int[3];
    assign i_h_int[29] = i_h_int[2];
    assign i_h_int[30] = i_h_int[1];
    assign i_h_int[31] = i_h_int[0];

    // Conversion vers vecteur plat
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : pack
            assign h_flat[(i+1)*COEF_WIDTH-1 -: COEF_WIDTH] = i_h_int[i];
        end
    endgenerate

endmodule
