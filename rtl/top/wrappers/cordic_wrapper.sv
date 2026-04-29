// ============================================================================
// Module      : cordic_wrapper
// Description : Test wrapper for the Cordic -> Derivative -> Filter chain.
//               Provides injection via `i_bus_a` and observation buses.
//               Supports 8 configs (C0,C1,C2) selecting which block
//               receives injection and which block is observed.
// ============================================================================

module cordic_wrapper #(
    parameter int WIDTH_IN   = 6,
    parameter int FILTER_N   = 5,
    parameter int WIDTH_PHASE= WIDTH_IN + 2,
    parameter int CFG_WIDTH  = 3,
    parameter int BUS_A_WIDTH = 12,
    parameter int BUS_B_WIDTH = 10,
    parameter int BUS_C_WIDTH = 12,
    parameter int BUS_D_WIDTH = 2
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg,

    // All inputs come from `i_bus_a` LSBs and all observed outputs
    // are driven on `o_bus_c` LSBs.

    input  logic [BUS_A_WIDTH-1:0] i_bus_a, // LSB used
    input  logic [BUS_B_WIDTH-1:0] i_bus_b, // unused
    output logic [BUS_C_WIDTH-1:0] o_bus_c,  // LSB used
    output logic [BUS_D_WIDTH-1:0] o_bus_d   // unused
);

    // ------------------------------------------------------------------
    // Internal wires
    // ------------------------------------------------------------------
    logic signed [WIDTH_PHASE-1:0] w_phase_cordic;
    logic signed [WIDTH_PHASE-1:0] w_phase_deriv;
    logic signed [WIDTH_PHASE-1:0] w_phase_filter_in;
    logic signed [WIDTH_PHASE-1:0]   w_phase_filter_out;
    logic signed [WIDTH_IN-1:0]    w_cordic_i, w_cordic_q;

    // Muxed sources
    logic signed [WIDTH_PHASE-1:0] mux_deriv_in;
    logic signed [WIDTH_PHASE-1:0] mux_filter_in;

    // ------------------------------------------------------------------
    // Configuration modes
    // ------------------------------------------------------------------
    localparam logic [2:0] MODE_0 = 3'b000;
    localparam logic [2:0] MODE_1 = 3'b001;
    localparam logic [2:0] MODE_2 = 3'b010;
    localparam logic [2:0] MODE_3 = 3'b011;
    localparam logic [2:0] MODE_4 = 3'b100;
    localparam logic [2:0] MODE_5 = 3'b101;
    localparam logic [2:0] MODE_6 = 3'b110;
    localparam logic [2:0] MODE_7 = 3'b111;

    // Default assignments
    always_comb begin
        // Use LSBs of bus A for all inputs by default
        w_cordic_i   = i_bus_a[WIDTH_IN-1:0];
        w_cordic_q   = i_bus_a[2*WIDTH_IN-1:WIDTH_IN];
        mux_deriv_in   = w_phase_cordic; // default to cordic output
        mux_filter_in  = w_phase_deriv;  // default to derivative output

        o_bus_c = w_phase_filter_out[BUS_C_WIDTH-1:0]; // default output
        o_bus_d = '0; // unused

        unique case (i_cfg)
            // Conf 0: 000 -> Input=Cordic, Output=Filter
            MODE_0: begin
                // Already set by default, no overrides needed
            end

            // MODE_1: 001 -> Input=Cordic, Output=Cordic
            MODE_1: begin
                o_bus_c = w_phase_cordic[BUS_C_WIDTH-1:0];
            end

            // MODE_2: 010 -> Input=Derivate, Output=Derivate
            MODE_2: begin
                mux_deriv_in   = i_bus_a[WIDTH_PHASE-1:0];
                o_bus_c = w_phase_deriv[BUS_C_WIDTH-1:0];
            end

            // MODE_3: 011 -> Input=Filter, Output=Filter
            MODE_3: begin
                mux_filter_in  = i_bus_a[WIDTH_PHASE-1:0];
                o_bus_c = w_phase_filter_out[BUS_C_WIDTH-1:0];
            end

            // MODE_4: 100 -> Input=Cordic, Output=Derivate
            MODE_4: begin
                o_bus_c = w_phase_deriv[BUS_C_WIDTH-1:0];
            end

            // MODE_5: 101 -> Input=Cordic, Output=Filter
            MODE_5: begin
                // Already set by default, no overrides needed
            end

            // MODE_6: 110 -> Input=Derivate, Output=Filter
            MODE_6: begin
                mux_deriv_in   = i_bus_a[WIDTH_PHASE-1:0];
                o_bus_c = w_phase_filter_out[BUS_C_WIDTH-1:0];
            end

            // MODE_7: 111 -> Input=Filter, Output=Filter
            MODE_7: begin
                mux_filter_in  = i_bus_a[WIDTH_PHASE-1:0];
                o_bus_c = w_phase_filter_out[BUS_C_WIDTH-1:0];
            end

            default: ;
        endcase
    end

    // ------------------------------------------------------------------
    // Instantiate blocks (cordic_top, derivative, boxcar_filter)
    // ------------------------------------------------------------------
    cordic_top #(
        .WIDTH_IN(WIDTH_IN),
        .WIDTH_PHASE(WIDTH_PHASE)
    ) cordic_top_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_i(w_cordic_i),
        .i_q(w_cordic_q),
        .o_phase(w_phase_cordic)
    );

    derivative #(
        .WIDTH(WIDTH_PHASE)
    ) derivative_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_phase(mux_deriv_in),
        .o_phase_deriv(w_phase_deriv)
    );

    boxcar_filter #(
        .WIDTH(WIDTH_PHASE), .N(FILTER_N)
    ) boxcar_filter_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_data(mux_filter_in),
        .o_data(w_phase_filter_out)
    );


endmodule
