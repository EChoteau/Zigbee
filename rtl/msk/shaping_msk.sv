// ==============================================================================
// Module      : shaping_msk
// Description : Mise en forme Half-Sine (Modulation MSK) avec ROM optimisée
// Norme       : Projet ZigBee (SystemVerilog, Reset actif bas, Préfixes stricts)
// ==============================================================================

module shaping_msk (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_enable_ech,
    input  logic              i_a_I,
    input  logic              i_a_Q,
    output logic signed [5:0] o_I_BB,
    output logic signed [5:0] o_Q_BB
);

    // --------------------------------------------------------------------------
    // 1. DÉCLARATION DES SIGNAUX INTERNES
    // --------------------------------------------------------------------------
    logic [5:0] s_phase;         // 0 à 49

    logic [5:0] w_phase_I;       // phase décalée de 25 points
    logic [5:0] w_mirror_I;
    logic [5:0] w_mirror_Q;

    logic [4:0] w_ad_rom_I;      // 0 à 24
    logic [4:0] w_ad_rom_Q;      // 0 à 24

    logic signed [5:0] w_val_I;
    logic signed [5:0] w_val_Q;

    // Optionnel mais recommandé pour éviter les sauts
    logic s_bit_I;
    logic s_bit_Q;

    // --------------------------------------------------------------------------
    // 2. LE COMPTEUR PRINCIPAL
    // --------------------------------------------------------------------------
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (i_rst_n == 1'b0) begin
            s_phase <= 6'd0;
        end else if (i_enable_ech == 1'b1) begin
            if (s_phase == 6'd49) begin
                s_phase <= 6'd0;
            end else begin
                s_phase <= s_phase + 6'd1;
            end
        end
    end

    // --------------------------------------------------------------------------
    // 3. CAPTURE DES BITS AUX FRONTIÈRES DE SYMBOLE
    // --------------------------------------------------------------------------
    // Q commence à phase 0, I est décalé de 25 points
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (i_rst_n == 1'b0) begin
            s_bit_I <= 1'b0;
            s_bit_Q <= 1'b0;
        end else if (i_enable_ech == 1'b1) begin
            if (s_phase == 6'd0) begin
                s_bit_Q <= i_a_Q;
            end
            if (s_phase == 6'd25) begin
                s_bit_I <= i_a_I;
            end
        end
    end

    // --------------------------------------------------------------------------
    // 4. LOGIQUE COMBINATOIRE : DÉPHASAGE ET SYMÉTRIE
    // --------------------------------------------------------------------------
    // Décalage circulaire de 25 points pour la voie I
    assign w_phase_I  = (s_phase < 6'd25) ? (s_phase + 6'd25) : (s_phase - 6'd25);

    assign w_mirror_I = 6'd49 - w_phase_I;
    assign w_mirror_Q = 6'd49 - s_phase;

    // Lecture directe de 0 à 24 puis lecture miroir de 24 à 0
    assign w_ad_rom_I = (w_phase_I < 6'd25) ? w_phase_I[4:0] : w_mirror_I[4:0];
    assign w_ad_rom_Q = (s_phase   < 6'd25) ? s_phase[4:0]   : w_mirror_Q[4:0];

    // --------------------------------------------------------------------------
    // 5. ROM 25 POINTS
    // --------------------------------------------------------------------------
    const logic signed [5:0] ROM_HALF_SINUS [0:24] = '{
        6'd0,  6'd2,  6'd4,  6'd6,  6'd8,
        6'd10, 6'd12, 6'd14, 6'd16, 6'd17,
        6'd19, 6'd20, 6'd22, 6'd23, 6'd25,
        6'd26, 6'd27, 6'd28, 6'd29, 6'd29,
        6'd30, 6'd30, 6'd31, 6'd31, 6'd31
    };

    assign w_val_I = ROM_HALF_SINUS[w_ad_rom_I];
    assign w_val_Q = ROM_HALF_SINUS[w_ad_rom_Q];

    // --------------------------------------------------------------------------
    // 6. APPLICATION DU SIGNE
    // --------------------------------------------------------------------------
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (i_rst_n == 1'b0) begin
            o_I_BB <= 6'sd0;
            o_Q_BB <= 6'sd0;
        end else if (i_enable_ech == 1'b1) begin
            o_I_BB <= (s_bit_I == 1'b1) ? w_val_I : -w_val_I;
            o_Q_BB <= (s_bit_Q == 1'b1) ? w_val_Q : -w_val_Q;
        end
    end

endmodule
