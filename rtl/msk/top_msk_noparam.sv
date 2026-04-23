// ==============================================================================
// Module      : top_msk
// Description : Top-level du modulateur MSK (Baseband)
//               Relie l'encodeur différentiel, le démultiplexeur et le shaping
// ==============================================================================

module top_msk (
    input  logic              i_clk,         // Horloge système rapide (ex: 50 MHz)
    input  logic              i_rst_n,       // Reset asynchrone ACTIF BAS
    input  logic              i_flag_enable, // Tick au rythme des bits entrants (Tb)
    input  logic              i_enable_ech,  // Tick d'échantillonnage pour dessiner la courbe
    input  logic              i_b_in,        // Bit brut entrant (bk)
    output logic signed [5:0] o_I_BB,        // Onde I finale (sur 6 bits signés vers DAC)
    output logic signed [5:0] o_Q_BB         // Onde Q finale (sur 6 bits signés vers DAC)
);

    // --------------------------------------------------------------------------
    // 1. DÉCLARATION DES FILS INTERNES (Préfixe w_ pour "wire")
    // --------------------------------------------------------------------------
    // Ces fils relient les boîtes entre elles
    logic w_b_enc;  // Sortie de l'encodeur -> Entrée du demux
    logic w_a_I;    // Sortie Voie I du demux -> Entrée I du shaping
    logic w_a_Q;    // Sortie Voie Q du demux -> Entrée Q du shaping


    // --------------------------------------------------------------------------
    // 2. INSTANCIATION DES BLOCS (Câblage)
    // --------------------------------------------------------------------------

    // --- Bloc 1 : L'Encodeur Différentiel ---
    encodeur_diff inst_encodeur (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_flag_enable (i_flag_enable),
        .i_b_in        (i_b_in),
        .o_b_out       (w_b_enc)         // On connecte la sortie au fil interne
    );

    // --- Bloc 2 : Le Démultiplexeur (Aiguilleur) ---
    demux_msk inst_demux (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_flag_enable (i_flag_enable),
        .i_b_enc       (w_b_enc),        // On récupère le fil venant de l'encodeur
        .o_a_I         (w_a_I),          // On sort sur le fil I
        .o_a_Q         (w_a_Q)           // On sort sur le fil Q
    );

    // --- Bloc 3 : La Mise en Forme (Shaping avec la ROM) ---
    shaping_msk inst_shaping (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_enable_ech  (i_enable_ech),
        .i_a_I         (w_a_I),          // On récupère le fil I venant du demux
        .i_a_Q         (w_a_Q),          // On récupère le fil Q venant du demux
        .o_I_BB        (o_I_BB),         // Sortie finale vers l'extérieur
        .o_Q_BB        (o_Q_BB)          // Sortie finale vers l'extérieur
    );

endmodule