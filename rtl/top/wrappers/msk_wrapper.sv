// ============================================================================
// Module      : msk_test_wrapper
// Description : Wrapper de test multi-bus pour le modulateur MSK.
//               Permet l'isolation des blocs (Encodeur, Demux, Shaping)
//               via injection (Bus A) et observation (Buses B, C, D).
// ============================================================================

module msk_test_wrapper #(
    parameter int SAMPLES_PER_HALF_SINE = 10, // Nombre de points par bosse
    parameter int MSK_RES               = 6,  // Résolution des sorties (bits)
    parameter int CFG_WIDTH             = 3,  // Largeur du sélecteur de mode
    parameter int BUS_A_WIDTH           = 8,  // Bus d'injection (Entrée de test)
    parameter int BUS_B_WIDTH           = 8,  // Bus status (Signaux 1-bit)
    parameter int BUS_C_WIDTH           = 12, // Bus Data (Sorties I + Q combinées)
    parameter int BUS_D_WIDTH           = 1   // Bus de synchronisation
)(
    // Signaux globaux
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg, // Sélection du mode de test

    // Entrées fonctionnelles
    input  logic        i_flag_enable, // Tick bit (Tb)
    input  logic        i_enable_ech,  // Tick échantillonnage (Te)
    input  logic        i_b_in,        // Bit d'entrée brut

    // Sorties fonctionnelles (vers le reste du chip)
    output logic signed [MSK_RES-1:0] o_I_BB,
    output logic signed [MSK_RES-1:0] o_Q_BB,

    // --- INTERFACE DE TEST (4 BUS) ---
    inout  logic [BUS_A_WIDTH-1:0] io_bus_a, // Injection de signaux forcés
    output logic [BUS_B_WIDTH-1:0] o_bus_b,  // Monitoring des bits internes
    output logic [BUS_C_WIDTH-1:0] o_bus_c,  // Monitoring des ondes (I & Q)
    output logic [BUS_D_WIDTH-1:0] o_bus_d   // Signal de synchronisation Te
);

    // --------------------------------------------------------------------------
    // 1. DÉCLARATION DES FILS INTERNES (Signaux réels des blocs)
    // --------------------------------------------------------------------------
    logic w_b_enc; // Sortie de l'encodeur différentiel
    logic w_a_I;   // Sortie voie I du démultiplexeur
    logic w_a_Q;   // Sortie voie Q du démultiplexeur

    // --------------------------------------------------------------------------
    // 2. SIGNAUX D'AIGUILLAGE (MUX)
    // --------------------------------------------------------------------------
    // Ces signaux portent soit la valeur réelle, soit la valeur forcée par le testeur
    logic mux_to_dmx;
    logic mux_to_enc;
    logic mux_to_shp_I, mux_to_shp_Q;

    // --------------------------------------------------------------------------
    // 3. LOGIQUE DE CONFIGURATION ET ROUTAGE
    // --------------------------------------------------------------------------
    // Définition des constantes de mode pour la lisibilité
    localparam logic [2:0] MODE_NORMAL   = 3'b000;
    localparam logic [2:0] MODE_ENC_ONLY = 3'b001;
    localparam logic [2:0] MODE_DMX_ONLY = 3'b010;
    localparam logic [2:0] MODE_SHP_ONLY = 3'b011;
    localparam logic [2:0] MODE_FULL_OBS = 3'b100;

    always_comb begin
        // --- Configuration par défaut (Mode Normal / Pass-through) ---
        io_bus_a     = 'z;          // Haute impédance (écoute le bus)
        o_bus_b      = '0;          // Pas de monitoring
        o_bus_c      = '0;          // Pas de monitoring data
        o_bus_d      = '0;          // Pas de sync
        
        mux_to_enc   = i_b_in;
        mux_to_dmx   = w_b_enc;     // Connexion normale Enc -> Dmx
        mux_to_shp_I = w_a_I;       // Connexion normale Dmx -> Shp I
        mux_to_shp_Q = w_a_Q;       // Connexion normale Dmx -> Shp Q

        unique case (i_cfg)
            // MODE 001 : Test Encodeur (Observation sortie)
            MODE_ENC_ONLY: begin
                mux_to_enc = io_bus_a[0]; // On injecte via Bus A
                o_bus_b[0] = w_b_enc; // On vérifie le bit encodé
            end

            // MODE 010 : Test Démultiplexeur (Injection A -> Observation B)
            MODE_DMX_ONLY: begin
                mux_to_dmx = io_bus_a[0]; // On force l'entrée avec le bus A
                o_bus_b[0] = w_a_I;       // On observe la voie I
                o_bus_b[1] = w_a_Q;       // On observe la voie Q
            end

            // MODE 011 : Test Shaping/ROM (Injection A -> Observation C & D)
            MODE_SHP_ONLY: begin
                mux_to_shp_I = io_bus_a[0]; // On force le bit I
                mux_to_shp_Q = io_bus_a[1]; // On force le bit Q
                o_bus_c      = {o_I_BB, o_Q_BB}; // Observation I (6b) + Q (6b) = 12 bits
                o_bus_d      = i_enable_ech;     // Sync pour lecture échantillon
            end

            // MODE 100 : Observation totale 
            MODE_FULL_OBS: begin
                o_bus_b[0] = w_b_enc;
                o_bus_b[1] = w_a_I;
                o_bus_b[2] = w_a_Q;
                o_bus_c    = {o_I_BB, o_Q_BB}; 
                o_bus_d    = i_enable_ech;
            end

            default: ; 
        endcase
    end

    // --------------------------------------------------------------------------
    // 4. INSTANCIATION DES BLOCS (DUT)
    // --------------------------------------------------------------------------

    // --- Bloc 1 : Encodeur Différentiel ---
    encodeur_diff inst_encodeur (
        .i_b_in(mux_to_enc), // On branche le signal multiplexé
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_flag_enable (i_flag_enable),
        .o_b_out       (w_b_enc)
    );

    // --- Bloc 2 : Démultiplexeur MSK ---
    demux_msk inst_demux (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_flag_enable (i_flag_enable),
        .i_b_enc       (mux_to_dmx), // Source contrôlée par le wrapper
        .o_a_I         (w_a_I),
        .o_a_Q         (w_a_Q)
    );

    // --- Bloc 3 : Mise en forme (Shaping / ROM) ---
    shaping_msk #(
        .SAMPLES_PER_HALF_SINE (SAMPLES_PER_HALF_SINE),
        .MSK_RES               (MSK_RES)
    ) inst_shaping (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_enable_ech (i_enable_ech),
        .i_a_I        (mux_to_shp_I), // Source contrôlée par le wrapper
        .i_a_Q        (mux_to_shp_Q), // Source contrôlée par le wrapper
        .o_I_BB       (o_I_BB),
        .o_Q_BB       (o_Q_BB)
    );

endmodule
