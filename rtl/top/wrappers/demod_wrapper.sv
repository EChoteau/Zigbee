module demod_wrapper #(
    parameter int CFG_WIDTH      = 3,
    parameter int BUS_IN_WIDTH   = 22,
    parameter int BUS_OUT_WIDTH  = 14
)(
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_out_en,    
    input  logic [CFG_WIDTH-1:0] i_cfg,

    // ADC inputs are taken from the bus (i_bus_in) for wrapper mode
    input  logic [BUS_IN_WIDTH-1:0]  i_bus_in,
    output logic [BUS_OUT_WIDTH-1:0] o_bus_out
);

    localparam logic [2:0] CFG_NORMAL         = 3'b000;
    localparam logic [2:0] CFG_DEBUG_DEMOD_I  = 3'b001;
    localparam logic [2:0] CFG_DEBUG_DEMOD_Q  = 3'b010;
    localparam logic [2:0] CFG_RESERVED       = 3'b011;
    localparam logic [2:0] CFG_DEBUG_FIR_I    = 3'b100;
    localparam logic [2:0] CFG_DEBUG_FIR_Q    = 3'b101;
    localparam logic [2:0] CFG_DEBUG_FIRC_I   = 3'b110;
    localparam logic [2:0] CFG_DEBUG_FIRC_Q   = 3'b111;

    // Decode inputs from bus
    logic [3:0]        s_test_i;
    logic [3:0]        s_test_q;
    logic signed [7:0] s_test_fir_in;

    assign s_test_i      = i_bus_in[17:14];
    assign s_test_q      = i_bus_in[13:10];
    assign s_test_fir_in = i_bus_in[17:10];

    // ==========================================================================
    // OVERRIDE CONTROL SIGNALS
    // ==========================================================================
    logic              s_if_demod_override_en;
    logic [3:0]        s_if_demod_i;
    logic [3:0]        s_if_demod_q;
    logic              s_if_fir_override_en;
    logic signed [7:0] s_if_fir_i_in;
    logic signed [7:0] s_if_fir_q_in;

    always_comb begin
        // Default safe states (Normal operation)
        s_if_demod_override_en = 1'b0;
        s_if_demod_i           = '0;
        s_if_demod_q           = '0;
        s_if_fir_override_en   = 1'b0;
        s_if_fir_i_in          = '0;
        s_if_fir_q_in          = '0;

        unique case (i_cfg)
            CFG_DEBUG_DEMOD_I, CFG_DEBUG_DEMOD_Q: begin
                s_if_demod_override_en = 1'b1;
                s_if_demod_i = s_test_i;
                s_if_demod_q = s_test_q;
            end
            CFG_DEBUG_FIR_I: begin
                s_if_fir_override_en = 1'b1;
                s_if_fir_i_in = s_test_fir_in;
                s_if_fir_q_in = 8'sd0;
            end
            CFG_DEBUG_FIR_Q: begin
                s_if_fir_override_en = 1'b1;
                s_if_fir_i_in = 8'sd0;
                s_if_fir_q_in = s_test_fir_in;
            end
            CFG_DEBUG_FIRC_I: begin
                s_if_demod_override_en = 1'b1;
                s_if_demod_i = s_test_i;
                s_if_demod_q = 4'b1000; // zero ADC offset
            end
            CFG_DEBUG_FIRC_Q: begin
                s_if_demod_override_en = 1'b1;
                s_if_demod_i = 4'b1000; // zero ADC offset
                s_if_demod_q = s_test_q;
            end
            default: ; // CFG_NORMAL: Keep overrides at 0
        endcase
    end

    // Outputs from Top
    logic signed [5:0] s_i_bb;
    logic signed [5:0] s_q_bb;
    logic signed [3:0] s_cos_test;
    logic signed [3:0] s_sin_test;
    logic signed [7:0] s_demod_out_i;
    logic signed [7:0] s_demod_out_q;

    // ==========================================================================
    // OUTPUT BUS MAPPING
    // ==========================================================================
    always_comb begin
        o_bus_out = '0;
        if (i_out_en) begin
            unique case (i_cfg)
                CFG_NORMAL: begin
                    o_bus_out[5:0]   = s_i_bb[5:0];
                    o_bus_out[11:6]  = s_q_bb[5:0];
                end
                CFG_DEBUG_DEMOD_I: begin
                    o_bus_out[7:0]   = s_demod_out_i[7:0];
                    o_bus_out[11:8]  = s_cos_test[3:0];
                    o_bus_out[12]    = s_i_bb[5];
                    o_bus_out[13]    = s_q_bb[5];
                end
                CFG_DEBUG_DEMOD_Q: begin
                    o_bus_out[7:0]   = s_demod_out_q[7:0];
                    o_bus_out[11:8]  = s_sin_test[3:0];
                    o_bus_out[12]    = s_i_bb[5];
                    o_bus_out[13]    = s_q_bb[5];
                end
                CFG_DEBUG_FIR_I, CFG_DEBUG_FIR_Q, CFG_DEBUG_FIRC_I, CFG_DEBUG_FIRC_Q: begin
                    o_bus_out[5:0]   = s_i_bb[5:0];
                    o_bus_out[11:6]  = s_q_bb[5:0];
                end
                default: o_bus_out = '0;
            endcase
        end
    end

    // Connect demod_top inputs to bus-decoded signals inside the wrapper.
    // For normal operation these are the ADC samples decoded from i_bus_in;
    // when debug override is active the demod_top will use the debug inputs.
    demod_top u_demod_top (
        .i_clk                   (i_clk),
        .i_rst_n                 (i_rst_n),
        .i_i                     (s_test_i),
        .i_q                     (s_test_q),
        .i_dbg_demod_override_en (s_if_demod_override_en),
        .i_dbg_demod_i           (s_if_demod_i),
        .i_dbg_demod_q           (s_if_demod_q),
        .i_dbg_fir_override_en   (s_if_fir_override_en),
        .i_dbg_fir_i_in          (s_if_fir_i_in),
        .i_dbg_fir_q_in          (s_if_fir_q_in),
        .o_i_bb                  (s_i_bb),
        .o_q_bb                  (s_q_bb),
        .o_cos_test              (s_cos_test),
        .o_sin_test              (s_sin_test),
        .o_demod_out_i           (s_demod_out_i),
        .o_demod_out_q           (s_demod_out_q)
    );

endmodule