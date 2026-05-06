module demod_wrapper #(
    parameter int CFG_WIDTH      = 3,
    parameter int BUS_IN_WIDTH   = 18,
    parameter int BUS_OUT_WIDTH  = 14
)(
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_out_en,    // Output enable (1=drive bus, 0=tri-state)
    input  logic [CFG_WIDTH-1:0] i_cfg,

    // ADC inputs for normal mode testing
    input  logic [3:0]       i_i,
    input  logic [3:0]       i_q,

    input  logic [BUS_IN_WIDTH-1:0]  i_bus_in,
    output logic [BUS_OUT_WIDTH-1:0] o_bus_out
);

    localparam logic [2:0] CFG_NORMAL         = 3'b000;  // Normal operation: I+Q demod → FIR (default)
    localparam logic [2:0] CFG_DEBUG_DEMOD_I  = 3'b001;  // Debug: I demod debug only + cos_test
    localparam logic [2:0] CFG_DEBUG_DEMOD_Q  = 3'b010;  // Debug: Q demod debug only + sin_test
    localparam logic [2:0] CFG_RESERVED       = 3'b011;  // Reserved
    localparam logic [2:0] CFG_DEBUG_FIR_I    = 3'b100;  // Debug: FIR I path direct injection
    localparam logic [2:0] CFG_DEBUG_FIR_Q    = 3'b101;  // Debug: FIR Q path direct injection
    localparam logic [2:0] CFG_DEBUG_FIRC_I   = 3'b110;  // Debug: FIR I chain (debug I, zero Q)
    localparam logic [2:0] CFG_DEBUG_FIRC_Q   = 3'b111;  // Debug: FIR Q chain (zero I, debug Q)

    // Input bus decoding (18 bits)
    // IN[17:14] : s_test_i[3:0]
    // IN[13:10] : s_test_q[3:0]
    // IN[17:10] : s_test_fir_in[7:0] (overlaps with test_i/q but used in FIR modes)
    logic [3:0]        s_test_i;
    logic [3:0]        s_test_q;
    logic signed [7:0] s_test_fir_in;

    assign s_test_i      = i_bus_in[17:14];
    assign s_test_q      = i_bus_in[13:10];
    assign s_test_fir_in = i_bus_in[17:10];

    // Mux for demod inputs based on configuration
    logic [3:0] s_demod_i_in;
    logic [3:0] s_demod_q_in;

    always_comb begin
        // Default (NORMAL mode): use real ADC inputs
        s_demod_i_in = i_i;
        s_demod_q_in = i_q;

        case (i_cfg)
            CFG_DEBUG_DEMOD_I: begin
                s_demod_i_in = s_test_i;
                s_demod_q_in = s_test_q;
            end

            CFG_DEBUG_DEMOD_Q: begin
                s_demod_i_in = s_test_i;
                s_demod_q_in = s_test_q;
            end

            default: begin
                s_demod_i_in = i_i;
                s_demod_q_in = i_q;
            end
        endcase
    end

    // Demod outputs
    logic signed [5:0] s_i_bb;
    logic signed [5:0] s_q_bb;
    logic signed [3:0] s_cos_test;
    logic signed [3:0] s_sin_test;
    logic signed [7:0] s_demod_out_i;
    logic signed [7:0] s_demod_out_q;

    demod_top u_demod_top (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_cfg         (i_cfg),

        // Normal inputs (routed from i_i and i_q or constants)
        .i_i           (s_demod_i_in),
        .i_q           (s_demod_q_in),

        // Debug/test inputs from input bus
        .i_dbg_i       (s_test_i),
        .i_dbg_q       (s_test_q),
        .i_dbg_fir_in  (s_test_fir_in),

        .o_i_bb        (s_i_bb),
        .o_q_bb        (s_q_bb),

        .o_cos_test    (s_cos_test),
        .o_sin_test    (s_sin_test),

        .o_demod_out_i (s_demod_out_i),
        .o_demod_out_q (s_demod_out_q)
    );

    // ==========================================================================
    // OUTPUT BUS MAPPING (14 bits)
    // ==========================================================================
    // OUT[13]:     s_i_bb[5] (all modes)
    // OUT[12]:     s_q_bb[5] (all modes)
    // OUT[11:8]:   s_cos_test[3:0] (CFG: 0,2) | s_sin_test[3:0] (CFG: 1,3) | s_i_bb[5:2] (CFG: 4,5,6,7)
    // OUT[7:0]:    s_demod_out_i[7:0] (CFG: 0,2) | s_demod_out_q[7:0] (CFG: 1,3) | s_q_bb[5:0] (CFG: 4,5,6,7)

    always_comb begin
        // Default: tie all outputs to 0
        o_bus_out = '0;

        // Only drive outputs if enabled
        if (i_out_en) begin
            unique case (i_cfg)
                // ====================================================================
                // CFG_NORMAL (0x0): Normal operation (default config)
                // Input: i_i, i_q (real ADC inputs)
                // Output: Complete demod+FIR chain (s_i_bb, s_q_bb)
                // ====================================================================
                CFG_NORMAL: begin
                    o_bus_out[5:0]   = s_q_bb[5:0];
                    o_bus_out[11:6]  = s_i_bb[5:0];
                    o_bus_out[12]    = s_q_bb[5];
                    o_bus_out[13]    = s_i_bb[5];
                end

                // ====================================================================
                // CFG_DEBUG_DEMOD_I (0x1): I channel demodulation (debug)
                // Test: cos_test output + I demod output with debug inputs
                // ====================================================================
                CFG_DEBUG_DEMOD_I: begin
                    o_bus_out[7:0]   = s_demod_out_i[7:0];
                    o_bus_out[11:8]  = s_cos_test[3:0];
                    o_bus_out[12]    = s_q_bb[5];
                    o_bus_out[13]    = s_i_bb[5];
                end

                // ====================================================================
                // CFG_DEBUG_DEMOD_Q (0x2): Q channel demodulation (debug)
                // Test: sin_test output + Q demod output with debug inputs
                // ====================================================================
                CFG_DEBUG_DEMOD_Q: begin
                    o_bus_out[7:0]   = s_demod_out_q[7:0];
                    o_bus_out[11:8]  = s_sin_test[3:0];
                    o_bus_out[12]    = s_q_bb[5];
                    o_bus_out[13]    = s_i_bb[5];
                end

                // ====================================================================
                // CFG_RESERVED (0x3): Reserved for future use
                // ====================================================================
                CFG_RESERVED: begin
                    o_bus_out = '0;
                end

                // ====================================================================
                // CFG_DEBUG_FIR_I (0x4): FIR I path with direct injection
                // Test: FIR I output with direct s_test_fir_in injection
                // ====================================================================
                CFG_DEBUG_FIR_I: begin
                    o_bus_out[5:0]   = s_q_bb[5:0];
                    o_bus_out[11:6]  = s_i_bb[5:0];
                    o_bus_out[12]    = s_q_bb[5];
                    o_bus_out[13]    = s_i_bb[5];
                end

                // ====================================================================
                // CFG_DEBUG_FIR_Q (0x5): FIR Q path with direct injection
                // Test: FIR Q output with direct s_test_fir_in injection
                // ====================================================================
                CFG_DEBUG_FIR_Q: begin
                    o_bus_out[5:0]   = s_q_bb[5:0];
                    o_bus_out[11:6]  = s_i_bb[5:0];
                    o_bus_out[12]    = s_q_bb[5];
                    o_bus_out[13]    = s_i_bb[5];
                end

                // ====================================================================
                // CFG_DEBUG_FIRC_I (0x6): FIR I chain (debug I, zero Q)
                // Test: Full path I → Demod → FIR (Q frozen to 0, debug I injection)
                // ====================================================================
                CFG_DEBUG_FIRC_I: begin
                    o_bus_out[5:0]   = s_q_bb[5:0];
                    o_bus_out[11:6]  = s_i_bb[5:0];
                    o_bus_out[12]    = s_q_bb[5];
                    o_bus_out[13]    = s_i_bb[5];
                end

                // ====================================================================
                // CFG_DEBUG_FIRC_Q (0x7): FIR Q chain (zero I, debug Q)
                // Test: Full path Q → Demod → FIR (I frozen to 0, debug Q injection)
                // ====================================================================
                CFG_DEBUG_FIRC_Q: begin
                    o_bus_out[5:0]   = s_q_bb[5:0];
                    o_bus_out[11:6]  = s_i_bb[5:0];
                    o_bus_out[12]    = s_q_bb[5];
                    o_bus_out[13]    = s_i_bb[5];
                end

                default: begin
                    o_bus_out = '0;
                end
            endcase
        end
        // When i_out_en = 0, o_bus_out stays 0 (tri-state)
    end

endmodule
