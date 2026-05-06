// ============================================================================
// Module      : msk_wrapper
// Description : Wrapper for MSK top module 
// ============================================================================
module msk_wrapper #(
    parameter int SAMPLES_PER_HALF_SINE = 10,
    parameter int MSK_RES               = 6,
    parameter int CFG_WIDTH             = 3,
    parameter int BUS_A_WIDTH           = 12,
    parameter int BUS_B_WIDTH           = 10,
    parameter int BUS_C_WIDTH           = 12,
    parameter int BUS_D_WIDTH           = 2
)(
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg_local,
    input  logic [BUS_A_WIDTH-1:0] i_bus_a,
    input  logic [BUS_B_WIDTH-1:0] i_bus_b,
    output logic [BUS_C_WIDTH-1:0] o_bus_c,
    output logic [BUS_D_WIDTH-1:0] o_bus_d
);



    // --- INTERFACE DE TEST  ---
    input  logic [BUS_A_WIDTH-1:0] i_bus_a, // INPUT pure (Injection)
    input  logic [BUS_B_WIDTH-1:0] i_bus_b, // Unused
    output logic [BUS_C_WIDTH-1:0] o_bus_c, // Observation Data
    output logic [BUS_D_WIDTH-1:0] o_bus_d  // Observation Sync
);

    // --------------------------------------------------------------------------
    // 1. FILS INTERNES
    // --------------------------------------------------------------------------

    logic        i_flag_enable,
    logic        i_enable_ech,
    logic        i_b_in,
    logic signed [MSK_RES-1:0] o_I_BB,
    logic signed [MSK_RES-1:0] o_Q_BB,
    logic w_b_enc;               // Fil interne : Encodeur -> Demux
    logic w_a_I, w_a_Q;          // Fil interne : Demux -> Shaping
    
    // --------------------------------------------------------------------------
    // 2. MUX (Aiguillage)
    // --------------------------------------------------------------------------
    logic mux_to_enc;
    logic mux_to_dmx;
    logic mux_to_shp_I, mux_to_shp_Q;

    always_comb begin
        // Default: normal operation
        s_flag_enable = i_bus_a[0];
        s_enable_ech  = i_bus_a[1];
        s_b_in        = i_bus_a[2];
        s_dbg_enc_override_en = 1'b0;
        s_dbg_enc_b_in = 1'b0;
        s_dbg_demux_override_en = 1'b0;
        s_dbg_demux_b_enc = 1'b0;
        s_dbg_shaping_override_en = 1'b0;
        s_dbg_shaping_a_I = 1'b0;
        s_dbg_shaping_a_Q = 1'b0;

        // Default outputs
        o_bus_c = {s_I_BB, s_Q_BB};
        o_bus_d = {1'b0, s_enable_ech};

        unique case (i_cfg_local)
            // ====================================================================
            // CFG_NORMAL (0x0): Normal operation
            // Inputs: Bus A [2:0] for normal inputs
            // Outputs: Bus C (I_BB, Q_BB), Bus D (enable_ech)
            // ====================================================================
            CFG_NORMAL: begin
                // Already set in defaults
            end

            // ====================================================================
            // CFG_ENC_OVERRIDE (0x1): Override encodeur input
            // Inputs: Bus A [3] for override value
            // Outputs: Bus C (b_enc), Bus D (enable_ech)
            // ====================================================================
            CFG_ENC_OVERRIDE: begin
                s_dbg_enc_override_en = 1'b1;
                s_dbg_enc_b_in = i_bus_a[3];
                o_bus_c = {11'b0, s_dbg_b_enc};
            end

            // ====================================================================
            // CFG_DEMUX_OVERRIDE (0x2): Override demux input
            // Inputs: Bus A [4] for override value
            // Outputs: Bus C (a_I, a_Q), Bus D (enable_ech)
            // ====================================================================
            CFG_DEMUX_OVERRIDE: begin
                s_dbg_demux_override_en = 1'b1;
                s_dbg_demux_b_enc = i_bus_a[4];
                o_bus_c = {10'b0, s_dbg_a_I, s_dbg_a_Q};
            end

            // ====================================================================
            // CFG_SHAPING_OVERRIDE (0x3): Override shaping inputs
            // Inputs: Bus A [6:5] for override values
            // Outputs: Bus C (I_BB, Q_BB), Bus D (enable_ech)
            // ====================================================================
            CFG_SHAPING_OVERRIDE: begin
                s_dbg_shaping_override_en = 1'b1;
                s_dbg_shaping_a_I = i_bus_a[5];
                s_dbg_shaping_a_Q = i_bus_a[6];
                // o_bus_c already set to I_BB, Q_BB
            end

            // ====================================================================
            // CFG_OBSERVE_INTERNALS (0x4): Observe internal signals
            // Outputs: Bus C (b_enc, a_I, a_Q), Bus D (enable_ech)
            // ====================================================================
            CFG_OBSERVE_INTERNALS: begin
                o_bus_c = {9'b0, s_dbg_b_enc, s_dbg_a_I, s_dbg_a_Q};
            end

            default: begin
                // Default case
            end
        endcase
    end

    top_msk #(
        .SAMPLES_PER_HALF_SINE(SAMPLES_PER_HALF_SINE),
        .MSK_RES(MSK_RES)
    ) u_top_msk (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flag_enable(s_flag_enable),
        .i_enable_ech(s_enable_ech),
        .i_b_in(s_b_in),
        .i_dbg_enc_override_en(s_dbg_enc_override_en),
        .i_dbg_enc_b_in(s_dbg_enc_b_in),
        .i_dbg_demux_override_en(s_dbg_demux_override_en),
        .i_dbg_demux_b_enc(s_dbg_demux_b_enc),
        .i_dbg_shaping_override_en(s_dbg_shaping_override_en),
        .i_dbg_shaping_a_I(s_dbg_shaping_a_I),
        .i_dbg_shaping_a_Q(s_dbg_shaping_a_Q),
        .o_I_BB(s_I_BB),
        .o_Q_BB(s_Q_BB),
        .o_dbg_b_enc(s_dbg_b_enc),
        .o_dbg_a_I(s_dbg_a_I),
        .o_dbg_a_Q(s_dbg_a_Q),
        .o_dbg_I_BB(s_dbg_I_BB),
        .o_dbg_Q_BB(s_dbg_Q_BB)
    );

endmodule
