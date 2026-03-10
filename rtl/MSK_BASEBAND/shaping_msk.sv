// ==============================================================================
// Module      : shaping_msk
// Description : Mise en forme Half-Sine (Modulation MSK) avec ROM optimisée
// Norme       : Projet ZigBee (SystemVerilog, Reset actif bas, Préfixes stricts)
// ==============================================================================

module shaping_msk (
    input  logic              i_clk,        //  ( 50 MHz)
    input  logic              i_rst_n,      // Reset asynchrone ACTIF BAS
    input  logic              i_enable_ech, // Tick d'échantillonnage (vitesse de la courbe)
    input  logic              i_a_I,        // Bit de la voie I (provenant du demux)
    input  logic              i_a_Q,        // Bit de la voie Q (provenant du demux)
    output logic signed [5:0] o_I_BB,       // Onde I finale (sur 6 bits signés vers DAC)
    output logic signed [5:0] o_Q_BB        // Onde Q finale (sur 6 bits signés vers DAC)
);

    // --------------------------------------------------------------------------
    // 1. DÉCLARATION DES SIGNAUX INTERNES
    // --------------------------------------------------------------------------
    // Préfixe s_ pour les registres (séquentiel)
    logic [5:0] s_phase;         // Compteur de temps principal (0 à 63 pour une arche entière)
    
    // Préfixe w_ pour les fils (combinatoire)
    logic [5:0] w_phase_I;       // Phase décalée pour la voie I
    logic [4:0] w_ad_rom_I;      // Adresse de lecture ROM pour I (0 à 31)
    logic [4:0] w_ad_rom_Q;      // Adresse de lecture ROM pour Q (0 à 31)
    
    logic signed [5:0] w_val_I;  // Amplitude lue dans la ROM pour I
    logic signed [5:0] w_val_Q;  // Amplitude lue dans la ROM pour Q


    // --------------------------------------------------------------------------
    // 2. LE COMPTEUR PRINCIPAL (Axe X : La base de temps)
    // --------------------------------------------------------------------------
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (i_rst_n == 1'b0) begin
            s_phase <= 6'd0;
        end else begin
            if (i_enable_ech == 1'b1) begin
                s_phase <= s_phase + 6'd1;
            end
        end
    end


    // --------------------------------------------------------------------------
    // 3. LOGIQUE COMBINATOIRE : DÉPHASAGE ET SYMÉTRIE
    // --------------------------------------------------------------------------
    // -> Le retard de Tb pour la voie Q (Déphasage de Pi/2)
    assign w_phase_I = s_phase + 6'd32;

    // -> Astuce du quart d'onde : Lecture Endroit/Envers
    // Si la phase < 32 (Montée) : on lit normalement de 0 à 31
    // Si la phase >= 32 (Descente) : le ~ inverse les bits 
    
    assign w_ad_rom_I = (w_phase_I < 6'd32) ? w_phase_I[4:0] : ~w_phase_I[4:0];
    
    assign w_ad_rom_Q = (s_phase < 6'd32)   ? s_phase[4:0]   : ~s_phase[4:0];

    // --------------------------------------------------------------------------
    // 4. LA ROM (Le tableau constant SystemVerilog) :
    // --------------------------------------------------------------------------
    // Déclaration du tableau de 32 valeurs (Amplitude max 31 sur 6 bits signés)
    const logic signed [5:0] ROM_QUART_SINUS [0:31] = '{
        6'd0,  6'd2,  6'd3,  6'd5,  6'd6,  6'd8,  6'd9,  6'd11,
        6'd12, 6'd14, 6'd15, 6'd17, 6'd18, 6'd19, 6'd20, 6'd21,
        6'd22, 6'd23, 6'd24, 6'd25, 6'd26, 6'd27, 6'd28, 6'd28,
        6'd29, 6'd30, 6'd30, 6'd31, 6'd31, 6'd31, 6'd31, 6'd31
    };

    // Lecture simultanée dans la ROM pour les deux voies
    assign w_val_I = ROM_QUART_SINUS[w_ad_rom_I];
    assign w_val_Q = ROM_QUART_SINUS[w_ad_rom_Q];


    // --------------------------------------------------------------------------
    // 5. LE MULTIPLICATEUR (Complément à 2)
    // --------------------------------------------------------------------------
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (i_rst_n == 1'b0) begin
            o_I_BB <= 6'd0;
            o_Q_BB <= 6'd0;
        end else if (i_enable_ech == 1'b1) begin
            
            // Voie I : Inversion de l'onde si i_a_I vaut 0 (signe négatif)
            if (i_a_I == 1'b1) begin
                o_I_BB <= w_val_I;
            end else begin
                o_I_BB <= ~w_val_I + 6'd1; 
            end

            // Voie Q : Inversion de l'onde si i_a_Q vaut 0 (signe négatif)
            if (i_a_Q == 1'b1) begin
                o_Q_BB <= w_val_Q;
            end else begin
                o_Q_BB <= ~w_val_Q + 6'd1;
            end
            
        end
    end

endmodule
