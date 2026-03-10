module fir_core #(
    parameter N = 32,
    parameter IN_WIDTH = 6,
    parameter COEF_WIDTH = 12,
    parameter PROD_WIDTH = IN_WIDTH + COEF_WIDTH,
    parameter OUT_WIDTH = PROD_WIDTH + 5
)(
    input  wire clk,
    input  wire rst,
    input  wire signed [N*IN_WIDTH-1:0]   x_flat,
    input  wire signed [N*COEF_WIDTH-1:0] h_flat,
    output reg  signed [OUT_WIDTH-1:0]    y_out
);

    // =========================
    // Tableaux internes
    // =========================
    wire signed [IN_WIDTH-1:0]   i_x_int [0:N-1];
    wire signed [COEF_WIDTH-1:0] i_h_int [0:N-1];
    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin : get_inputs
            assign i_x_int[i] = x_flat[(i+1)*IN_WIDTH-1 -: IN_WIDTH];
            assign i_h_int[i] = h_flat[(i+1)*COEF_WIDTH-1 -: COEF_WIDTH];
        end
    endgenerate


    // =========================
    // Somme des entrees symetriques
    // =========================
    wire signed [IN_WIDTH:0] x_sum [0:15];

    generate
        for (i = 0; i < 16; i = i + 1) begin : sym_sum
            assign x_sum[i] = i_x_int[i] + i_x_int[N-1-i];
        end
    endgenerate


    // =========================
    // 16 Multiplications
    // =========================
    wire signed [PROD_WIDTH-1:0] p [0:15];

    generate
        for (i = 0; i < 16; i = i + 1) begin : multiplication
            assign p[i] = x_sum[i] * i_h_int[i];
        end
    endgenerate


    // =========================
    // Niveau 1 -> 8 sommes
    // =========================
    wire signed [OUT_WIDTH-1:0] s1 [0:7];

    generate
        for (i = 0; i < 8; i = i + 1) begin : SommeN1
            assign s1[i] = p[2*i] + p[2*i+1];
        end
    endgenerate


    // =========================
    // Niveau 2 -> 4
    // =========================
    wire signed [OUT_WIDTH-1:0] s2 [0:3];

    generate
        for (i = 0; i < 4; i = i + 1) begin : SommeN2
            assign s2[i] = s1[2*i] + s1[2*i+1];
        end
    endgenerate


    // =========================
    // Niveau 3 -> 2
    // =========================
    wire signed [OUT_WIDTH-1:0] s3 [0:1];

    generate
        for (i = 0; i < 2; i = i + 1) begin : SommeN3
            assign s3[i] = s2[2*i] + s2[2*i+1];
        end
    endgenerate


    // =========================
    // Niveau 4 -> 1
    // =========================
    wire signed [OUT_WIDTH-1:0] sum_final;
    assign sum_final = s3[0] + s3[1];


    // =========================
    // Sortie avec reset
    // =========================
    always @(posedge clk) begin
        if (!rst)
            y_out <= 0;
        else
            y_out <= sum_final;
    end

endmodule
