module fir_core #(
    parameter N = 9,
    parameter IN_WIDTH = 8,
    parameter COEF_WIDTH = 8,
    parameter PROD_WIDTH = IN_WIDTH + COEF_WIDTH,
    parameter OUT_WIDTH = PROD_WIDTH + 2
)(
    input  wire                              i_clk,
    input  wire                              i_rst_n,
    input  wire signed [N*IN_WIDTH-1:0]      i_x_flat,
    input  wire signed [N*COEF_WIDTH-1:0]    i_h_flat,
    output reg  signed [OUT_WIDTH-1:0]       o_y_out
);

    // =========================
    // Tableaux internes
    // =========================
    wire signed [IN_WIDTH-1:0]   w_x_int [0:N-1];
    wire signed [COEF_WIDTH-1:0] w_h_int [0:N-1];
    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin : gen_get_inputs
            assign w_x_int[i] = i_x_flat[(i+1)*IN_WIDTH-1 -: IN_WIDTH];
            assign w_h_int[i] = i_h_flat[(i+1)*COEF_WIDTH-1 -: COEF_WIDTH];
        end
    endgenerate

    // =========================
    // Somme des entrées symétriques
    // N=9 : paires (0,8), (1,7), (2,6), (3,5)
    // =========================
    wire signed [IN_WIDTH:0] w_x_sum [0:3];

    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_sym_sum
            assign w_x_sum[i] = w_x_int[i] + w_x_int[N-1-i];
        end
    endgenerate

    // =========================
    // Multiplications
    // =========================
    wire signed [PROD_WIDTH-1:0] w_p [0:3];

    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_multiplication
            assign w_p[i] = w_x_sum[i] * w_h_int[i];
        end
    endgenerate

    // Tap central
    wire signed [PROD_WIDTH-1:0] w_p_center;
    assign w_p_center = w_x_int[4] * w_h_int[4];

    // =========================
    // Arbre de somme
    // =========================
    wire signed [OUT_WIDTH-1:0] w_s1_0;
    wire signed [OUT_WIDTH-1:0] w_s1_1;
    wire signed [OUT_WIDTH-1:0] w_sum_final;

    assign w_s1_0     = w_p[0] + w_p[1];
    assign w_s1_1     = w_p[2] + w_p[3];
    assign w_sum_final = w_s1_0 + w_s1_1 + w_p_center;

    // =========================
    // Sortie avec reset asynchrone
    // =========================
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_y_out <= '0;
        else
            o_y_out <= w_sum_final;
    end

endmodule
