module fir_top (
    input  wire                    i_clk,
    input  wire                    i_rst_n,
    input  wire                    i_sample_en,
    input  wire signed [7:0]       i_x_in,      // Entrée 8 bits du démodulateur
    output wire signed [7:0]       o_y_out      // Sortie finale 8 bits
);

    // =========================
    // Paramètres internes
    // =========================
    localparam N          = 9;
    localparam IN_W       = 8;
    localparam COEF_W     = 8;
    localparam CORE_OUT_W = IN_W + COEF_W + 2;

    // =========================
    // Signaux internes
    // =========================
    wire signed [N*IN_W-1:0]       w_x_delay_flat;
    wire signed [N*COEF_W-1:0]     w_h_flat;
    wire signed [CORE_OUT_W-1:0]   w_y_full;

    // =========================
    // Delay line
    // =========================
    delay_line #(
        .N(N),
        .IN_WIDTH(IN_W)
    ) u_delay (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_sample_en(i_sample_en),
        .i_x_in     (i_x_in),
        .o_x_out_flat(w_x_delay_flat)
    );

    // =========================
    // ROM des coefficients
    // =========================
    coeff_rom #(
        .N(N),
        .COEF_WIDTH(COEF_W)
    ) u_coeff (
        .o_h_flat(w_h_flat)
    );

    // =========================
    // Coeur du calcul FIR
    // =========================
    fir_core #(
        .N(N),
        .IN_WIDTH(IN_W),
        .COEF_WIDTH(COEF_W)
    ) u_core (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_x_flat(w_x_delay_flat),
        .i_h_flat(w_h_flat),
        .o_y_out (w_y_full)
    );

    // =========================
    // Réduction de précision
    // =========================
    // On garde les bits [17:10] pour obtenir une sortie 8 bits
    assign o_y_out = w_y_full[17:10];

endmodule
