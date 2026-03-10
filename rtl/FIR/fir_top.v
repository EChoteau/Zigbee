module fir_top (
    input  wire clk,
    input  wire rstn,
    input  wire sample_en,
    input  wire signed [12:0] x_in,  // Entrée 13-bits du démodulateur
    output wire signed [7:0]  y_out  // Sortie finale 8-bits
);

    // Paramètres internes
    localparam N = 32;
    localparam IN_W = 13;
    localparam COEF_W = 12;
    // Calcul de la largeur interne (13+12 + log2(32)) = 30 bits
    localparam CORE_OUT_W = IN_W + COEF_W + 5; 

    wire signed [N*IN_W-1:0] x_delay_flat;
    wire signed [N*COEF_W-1:0] h_flat;
    wire signed [CORE_OUT_W-1:0] y_full;

    // delay line
    delay_line #(.N(N), .IN_WIDTH(IN_W)) u_delay (
        .clk(clk), .rstn(rstn), .sample_en(sample_en),
        .x_in(x_in), .x_out_flat(x_delay_flat)
    );

    // ROM des coefficients
    coeff_rom #(.N(N), .COEF_WIDTH(COEF_W)) u_coeff (
        .h_flat(h_flat)
    );

    // Coeur du calcul (Full precision)
    fir_core #(.N(N), .IN_WIDTH(IN_W), .COEF_WIDTH(COEF_W)) u_core (
        .clk(clk), .rstn(rstn),
        .x_flat(x_delay_flat), .h_flat(h_flat),
        .y_out(y_full)
    );

    // On garde les 8 bits de poids forts
    // On ignore les bits de débordement inutiles et les bits de bruit en bas
    //assign y_out = y_full[CORE_OUT_W-1 : CORE_OUT_W-8]; 
    assign y_out = y_full[18:11];

endmodule
