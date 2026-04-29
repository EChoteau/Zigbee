
// ==============================================================================
// Module      : top_msk
// Description : Top-level du modulateur MSK (Baseband) - Version Configurable
// ==============================================================================

module top_msk #(
    parameter int SAMPLES_PER_HALF_SINE = 10, // Transmis au shaping
    parameter int MSK_RES               = 6   // Transmis au shaping
)(
    input  logic                 i_clk,         // Horloge 10 MHz
    input  logic                 i_rst_n,       // Reset asynchrone actif bas
    input  logic                 i_flag_enable, // Tick tous les Tb (500ns)
    input  logic                 i_enable_ech,  // Tick échantillonnage (100ns)
    input  logic                 i_b_in,        // Bit brut bk
    output logic signed [MSK_RES-1:0] o_I_BB,   // Onde I finale
    output logic signed [MSK_RES-1:0] o_Q_BB    // Onde Q finale
);

    // --------------------------------------------------------------------------
    // 1. DÉCLARATION DES FILS INTERNES
    // --------------------------------------------------------------------------
    logic w_b_enc;  // Sortie encodeur -> Entrée demux
    logic w_a_I;    // Sortie Voie I demux -> Entrée I shaping
    logic w_a_Q;    // Sortie Voie Q demux -> Entrée Q shaping

    // --------------------------------------------------------------------------
    // 2. INSTANCIATION DES BLOCS
    // --------------------------------------------------------------------------

    // --- Bloc 1 : L'Encodeur Différentiel ---
    // (L'encodeur ne dépend pas du nombre de points, pas de paramètres ici)
    encodeur_diff inst_encodeur (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_flag_enable (i_flag_enable),
        .i_b_in        (i_b_in),
        .o_b_out       (w_b_enc)
    );

    // --- Bloc 2 : Le Démultiplexeur ---
    // (Le demux ne fait qu'aiguiller les bits, pas de paramètres ici)
    demux_msk inst_demux (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_flag_enable (i_flag_enable),
        .i_b_enc       (w_b_enc),
        .o_a_I         (w_a_I),
        .o_a_Q         (w_a_Q)
    );

    // --- Bloc 3 : La Mise en Forme (Shaping) ---
    // ICI ON TRANSMET LES PARAMÈTRES
    shaping_msk #(
        .SAMPLES_PER_HALF_SINE (SAMPLES_PER_HALF_SINE),
        .MSK_RES               (MSK_RES)
    ) inst_shaping (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_enable_ech  (i_enable_ech),
        .i_a_I         (w_a_I),
        .i_a_Q         (w_a_Q),
        .o_I_BB        (o_I_BB),
        .o_Q_BB        (o_Q_BB)
    );

endmodule
