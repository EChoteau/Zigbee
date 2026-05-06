// ============================================================================
// Module      : msk_wrapper
// Description : Wrapper for MSK top module with unified bus architecture
// ============================================================================
module msk_wrapper #(
    parameter int SAMPLES_PER_HALF_SINE = 10,
    parameter int MSK_RES               = 6,
    parameter int CFG_WIDTH             = 3,
    parameter int BUS_IN_WIDTH          = 22,
    parameter int BUS_OUT_WIDTH         = 14
)(
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_out_en,       // Output enable (1=drive bus, 0=tri-state)
    input  logic [CFG_WIDTH-1:0] i_cfg,

    input  logic [BUS_IN_WIDTH-1:0]  i_bus_in,
    output logic [BUS_OUT_WIDTH-1:0] o_bus_out
);

    // ==========================================================================
    // Configuration modes
    // ==========================================================================
    localparam logic [2:0] CFG_NORMAL              = 3'b000;  // Normal operation (default)
    localparam logic [2:0] CFG_DEBUG_ENC           = 3'b001;  // Debug encodeur override
    localparam logic [2:0] CFG_DEBUG_DEMUX         = 3'b010;  // Debug demux override
    localparam logic [2:0] CFG_DEBUG_SHAPING       = 3'b011;  // Debug shaping override
    localparam logic [2:0] CFG_DEBUG_ALL           = 3'b100;  // Debug all overrides

    // ==========================================================================
    // Input bus decoding (7 bits)
    // ==========================================================================
    // IN[0]:   s_flag_enable     (all modes)
    // IN[1]:   s_enable_ech      (all modes)
    // IN[2]:   s_b_in            (all modes)
    // IN[3]:   s_dbg_enc_b_in    (modes 1, 4)
    // IN[4]:   s_dbg_demux_b_enc (modes 2, 4)
    // IN[5]:   s_dbg_shaping_a_I (modes 3, 4)
    // IN[6]:   s_dbg_shaping_a_Q (modes 3, 4)

    logic s_flag_enable;
    logic s_enable_ech;
    logic s_b_in;
    logic s_dbg_enc_b_in;
    logic s_dbg_demux_b_enc;
    logic s_dbg_shaping_a_I;
    logic s_dbg_shaping_a_Q;

    assign s_flag_enable        = i_bus_in[0];
    assign s_enable_ech         = i_bus_in[1];
    assign s_b_in               = i_bus_in[2];
    assign s_dbg_enc_b_in       = i_bus_in[3];
    assign s_dbg_demux_b_enc    = i_bus_in[4];
    assign s_dbg_shaping_a_I    = i_bus_in[5];
    assign s_dbg_shaping_a_Q    = i_bus_in[6];

    // ==========================================================================
    // Override enable signals (generated per mode)
    // ==========================================================================
    logic s_dbg_enc_override_en;
    logic s_dbg_demux_override_en;
    logic s_dbg_shaping_override_en;

    always_comb begin
        s_dbg_enc_override_en     = 1'b0;
        s_dbg_demux_override_en   = 1'b0;
        s_dbg_shaping_override_en = 1'b0;

        case (i_cfg)
            CFG_DEBUG_ENC: begin
                s_dbg_enc_override_en = 1'b1;
            end
            CFG_DEBUG_DEMUX: begin
                s_dbg_demux_override_en = 1'b1;
            end
            CFG_DEBUG_SHAPING: begin
                s_dbg_shaping_override_en = 1'b1;
            end
            CFG_DEBUG_ALL: begin
                s_dbg_enc_override_en     = 1'b1;
                s_dbg_demux_override_en   = 1'b1;
                s_dbg_shaping_override_en = 1'b1;
            end
            default: begin
                s_dbg_enc_override_en     = 1'b0;
                s_dbg_demux_override_en   = 1'b0;
                s_dbg_shaping_override_en = 1'b0;
            end
        endcase
    end

    // ==========================================================================
    // Signals from top_msk
    // ==========================================================================
    logic signed [MSK_RES-1:0] s_I_BB;
    logic signed [MSK_RES-1:0] s_Q_BB;
    logic s_dbg_b_enc;
    logic s_dbg_a_I;
    logic s_dbg_a_Q;
    logic signed [MSK_RES-1:0] s_dbg_I_BB;
    logic signed [MSK_RES-1:0] s_dbg_Q_BB;

    // ==========================================================================
    // TOP_MSK INSTANTIATION
    // ==========================================================================
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

    // ==========================================================================
    // OUTPUT BUS MAPPING (14 bits) according to user's table
    // ==========================================================================
    // OUT[13]:     1'b0 (constant, all modes)
    // OUT[12]:     s_enable_ech (feedback, all modes)
    // OUT[11:6]:   s_I_BB[5:0] (modes 0, 3)
    // OUT[5:0]:    s_Q_BB[5:0] (modes 0, 3)
    // OUT[2:0]:    debug outputs (modes 1, 2, 4 - multiplexed)

    always_comb begin
        // Default: tie all outputs to 0
        o_bus_out = '0;

        // Only drive outputs if enabled
        if (i_out_en) begin
            // Always output enable_ech feedback and constant 0
            o_bus_out[13] = 1'b0;
            o_bus_out[12] = s_enable_ech;

            unique case (i_cfg)
                // ====================================================================
                // CFG_NORMAL (0x0): Normal operation (default)
                // Output: I_BB[5:0], Q_BB[5:0]
                // ====================================================================
                CFG_NORMAL: begin
                    o_bus_out[11:6]  = s_I_BB[5:0];
                    o_bus_out[5:0]   = s_Q_BB[5:0];
                end

                // ====================================================================
                // CFG_DEBUG_ENC (0x1): Debug encodeur
                // Output: s_dbg_b_enc at OUT[0]
                // ====================================================================
                CFG_DEBUG_ENC: begin
                    o_bus_out[0] = s_dbg_b_enc;
                end

                // ====================================================================
                // CFG_DEBUG_DEMUX (0x2): Debug demux
                // Output: s_dbg_a_I at OUT[1], s_dbg_a_Q at OUT[0]
                // ====================================================================
                CFG_DEBUG_DEMUX: begin
                    o_bus_out[1] = s_dbg_a_I;
                    o_bus_out[0] = s_dbg_a_Q;
                end

                // ====================================================================
                // CFG_DEBUG_SHAPING (0x3): Debug shaping
                // Output: I_BB[5:0], Q_BB[5:0] (same as normal)
                // ====================================================================
                CFG_DEBUG_SHAPING: begin
                    o_bus_out[11:6]  = s_I_BB[5:0];
                    o_bus_out[5:0]   = s_Q_BB[5:0];
                end

                // ====================================================================
                // CFG_DEBUG_ALL (0x4): Debug all blocks
                // Output: s_dbg_b_enc at OUT[2], s_dbg_a_I at OUT[1], s_dbg_a_Q at OUT[0]
                // ====================================================================
                CFG_DEBUG_ALL: begin
                    o_bus_out[2] = s_dbg_b_enc;
                    o_bus_out[1] = s_dbg_a_I;
                    o_bus_out[0] = s_dbg_a_Q;
                end

                default: begin
                    o_bus_out = '0;
                end
            endcase
        end
        // When i_out_en = 0, o_bus_out stays 0 (tri-state)
    end

endmodule
