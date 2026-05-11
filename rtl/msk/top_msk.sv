
// ==============================================================================
// Module      : top_msk
// Description : Top-level du modulateur MSK (Baseband) - Version avec Debug
// ==============================================================================

module top_msk #(
    parameter int SAMPLES_PER_HALF_SINE = 10, // shaping
    parameter int MSK_RES               = 6   // shaping
)( 
    // original inputs
    input  logic                 i_clk,         // Horloge 10 MHz
    input  logic                 i_rst_n,       // Reset asynchrone actif bas
    input  logic                 i_flag_enable, // Tick tous les Tb (500ns)
    input  logic                 i_enable_ech,  // Tick échantillonnage (100ns) comme la clk 
    input  logic                 i_b_in,        // Bit brut bk qui arrive à chaque flag_enable

    // Debug inputs - overrides
    input  logic                 i_dbg_enc_override_en,
    input  logic                 i_dbg_enc_b_in,
    input  logic                 i_dbg_demux_override_en,
    input  logic                 i_dbg_demux_b_enc,
    input  logic                 i_dbg_shaping_override_en,
    input  logic                 i_dbg_shaping_a_I,
    input  logic                 i_dbg_shaping_a_Q,

    // Original outputs
    output logic signed [MSK_RES-1:0] o_I_BB,   // Onde I finale
    output logic signed [MSK_RES-1:0] o_Q_BB,   // Onde Q finale

    // Debug outputs - observability
    output logic                 o_dbg_b_enc,
    output logic                 o_dbg_a_I,
    output logic                 o_dbg_a_Q,
    output logic signed [MSK_RES-1:0] o_dbg_I_BB,
    output logic signed [MSK_RES-1:0] o_dbg_Q_BB
);

    // --------------------------------------------------------------------------
    // 1. DÉCLARATION DES FILS INTERNES
    // --------------------------------------------------------------------------
    logic w_b_enc;  // Sortie encodeur -> Entrée demux
    logic w_a_I;    // Sortie Voie I demux -> Entrée I shaping
    logic w_a_Q;    // Sortie Voie Q demux -> Entrée Q shaping

    // --------------------------------------------------------------------------
    // 2. MUX LOGIC FOR DEBUG OVERRIDES
    // --------------------------------------------------------------------------
    logic mux_to_enc;
    logic mux_to_demux;
    logic mux_to_shaping_I, mux_to_shaping_Q;

    assign mux_to_enc = i_dbg_enc_override_en ? i_dbg_enc_b_in : i_b_in;
    assign mux_to_demux = i_dbg_demux_override_en ? i_dbg_demux_b_enc : w_b_enc;
    assign mux_to_shaping_I = i_dbg_shaping_override_en ? i_dbg_shaping_a_I : w_a_I;
    assign mux_to_shaping_Q = i_dbg_shaping_override_en ? i_dbg_shaping_a_Q : w_a_Q;

    // --------------------------------------------------------------------------
    // 3. INSTANCIATION DES BLOCS
    // --------------------------------------------------------------------------

    // --- Bloc 1 : L'Encodeur Différentiel ---
    encodeur_diff inst_encodeur (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_flag_enable (i_flag_enable),
        .i_b_in        (mux_to_enc),
        .o_b_out       (w_b_enc)
    );

    // --- Bloc 2 : Le Démultiplexeur ---
    demux_msk inst_demux (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_flag_enable (i_flag_enable),
        .i_b_enc       (mux_to_demux),
        .o_a_I         (w_a_I),
        .o_a_Q         (w_a_Q)
    );

    // --- Bloc 3 : La Mise en Forme (Shaping) ---
    shaping_msk #(
        .SAMPLES_PER_HALF_SINE (SAMPLES_PER_HALF_SINE),
        .MSK_RES               (MSK_RES)
    ) inst_shaping (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_enable_ech  (i_enable_ech),
        .i_a_I         (mux_to_shaping_I),
        .i_a_Q         (mux_to_shaping_Q),
        .o_I_BB        (o_I_BB),
        .o_Q_BB        (o_Q_BB)
    );

    // --------------------------------------------------------------------------
    // 4. DEBUG OUTPUTS
    // --------------------------------------------------------------------------
    assign o_dbg_b_enc = w_b_enc;
    assign o_dbg_a_I = w_a_I;
    assign o_dbg_a_Q = w_a_Q;
    assign o_dbg_I_BB = o_I_BB;
    assign o_dbg_Q_BB = o_Q_BB;
endmodule
