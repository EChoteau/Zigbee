// ============================================================================
// Module      : msk_test_wrapper
// Description : Version alignée sur le template CORDIC (Bus A en Input).
// ============================================================================

module msk_test_wrapper #(
    parameter int SAMPLES_PER_HALF_SINE = 10,
    parameter int MSK_RES               = 6,
    parameter int CFG_WIDTH             = 3,
    parameter int BUS_A_WIDTH           = 12, 
    parameter int BUS_B_WIDTH           = 10, 
    parameter int BUS_C_WIDTH           = 12, 
    parameter int BUS_D_WIDTH           = 2   
)(
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg,
    // --- INTERFACE DE TEST (Identique au CORDIC) ---
    input  logic [BUS_A_WIDTH-1:0] i_bus_a, // INPUT pure (Injection)
    input  logic [BUS_B_WIDTH-1:0] i_bus_b, // Unused
    output logic [BUS_C_WIDTH-1:0] o_bus_c, // Observation Data
    output logic [BUS_D_WIDTH-1:0] o_bus_d  // Observation Sync
);

    // --------------------------------------------------------------------------
    // 1. FILS INTERNES (including pad-like signals)
    // --------------------------------------------------------------------------
    // Signals that were previously in the port list for pad I/Os — keep them
    // internal since `top` does not provide explicit pad connections.
    logic        i_flag_enable;
    logic        i_enable_ech;
    logic        i_b_in;
    logic signed [MSK_RES-1:0] o_I_BB;
    logic signed [MSK_RES-1:0] o_Q_BB;

    logic w_b_enc;               // Fil interne : Encodeur -> Demux
    logic w_a_I, w_a_Q;          // Fil interne : Demux -> Shaping
    
    // --------------------------------------------------------------------------
    // 2. MUX (Aiguillage)
    // --------------------------------------------------------------------------
    logic mux_to_enc;
    logic mux_to_dmx;
    logic mux_to_shp_I, mux_to_shp_Q;

    // --------------------------------------------------------------------------
    // 3. LOGIQUE DE CONFIGURATION
    // --------------------------------------------------------------------------
    always_comb begin
        // --- Sources par défaut (Mode Normal : les blocs sont chaînés) ---
        mux_to_enc   = i_b_in;       
        mux_to_dmx   = w_b_enc;      
        mux_to_shp_I = w_a_I;        
        mux_to_shp_Q = w_a_Q;

        // --- Observation par défaut (On regarde la sortie finale) ---
        o_bus_c = {o_I_BB, o_Q_BB}; 
        o_bus_d = {1'b0, i_enable_ech};

        unique case (i_cfg)
            // CONFIG 1 : Injection dans l'Encodeur
            3'b001: begin
                mux_to_enc = i_bus_a[0]; // On force l'entrée de l'encodeur
                o_bus_c    = {11'b0, w_b_enc}; // On observe sa sortie
            end

            // CONFIG 2 : Injection dans le Demux (On saute l'encodeur)
            3'b010: begin
                mux_to_dmx = i_bus_a[0]; // On force l'entrée du Demux
                o_bus_c    = {10'b0, w_a_I, w_a_Q}; // On observe I et Q (1-bit chacun)
            end

            // CONFIG 3 : Injection dans le Shaping (On saute tout l'amont)
            3'b011: begin
                mux_to_shp_I = i_bus_a[0]; // Force Bit I
                mux_to_shp_Q = i_bus_a[1]; // Force Bit Q
                // o_bus_c affiche déjà o_I_BB et o_Q_BB par défaut
            end

            // CONFIG 4 : Observation des signaux de contrôle internes
            3'b100: begin
                o_bus_c = {9'b0, w_b_enc, w_a_I, w_a_Q}; // Monitor bit par bit
                
            end

            default: ; 
        endcase
    end

    // --------------------------------------------------------------------------
    // 4. INSTANCIATIONS
    // --------------------------------------------------------------------------
    encodeur_diff inst_encodeur (
        .i_clk(i_clk), 
        .i_rst_n(i_rst_n), 
        .i_flag_enable(i_flag_enable),
        .i_b_in(mux_to_enc), 
        .o_b_out(w_b_enc)
    );

    demux_msk inst_demux (
        .i_clk(i_clk), 
        .i_rst_n(i_rst_n), 
        .i_flag_enable(i_flag_enable),
        .i_b_enc(mux_to_dmx), 
        .o_a_I(w_a_I), 
        .o_a_Q(w_a_Q)
    );

    shaping_msk #(.SAMPLES_PER_HALF_SINE(SAMPLES_PER_HALF_SINE), .MSK_RES(MSK_RES)) 
    inst_shaping (
        .i_clk(i_clk), 
        .i_rst_n(i_rst_n), 
        .i_enable_ech(i_enable_ech),
        .i_a_I(mux_to_shp_I), 
        .i_a_Q(mux_to_shp_Q),
        .o_I_BB(o_I_BB), 
        .o_Q_BB(o_Q_BB)
    );

endmodule
