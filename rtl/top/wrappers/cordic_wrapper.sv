// ============================================================================
// Module      : cordic_wrapper
// Description : Test wrapper for the Cordic -> Derivative -> Filter chain.
//               Unified bus interface (22-bit IN, 14-bit OUT).
//               Supports 8 configurations for block-by-block testing.
//               ORIGINAL LOGIC PRESERVED - Only bus mapping changed
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
    logic signed [WIDTH_PHASE-1:0] w_phase_filter_out;
    logic signed [WIDTH_IN-1:0]    w_cordic_i, w_cordic_q;

    // Muxed sources from modules
    logic signed [WIDTH_PHASE-1:0] mux_deriv_in;
    logic signed [WIDTH_PHASE-1:0] mux_filter_in;

    // ====================================================================
    // Input bus decoding (22 bits)
    // IN[5:0]   = cordic_i[5:0]
    // IN[11:6]  = cordic_q[5:0]
    // IN[19:12] = mux_deriv_in[7:0] or mux_filter_in[7:0]
    // ====================================================================
    assign w_cordic_i = i_bus_in[WIDTH_IN-1:0];
    assign w_cordic_q = i_bus_in[2*WIDTH_IN-1:WIDTH_IN];

    // ====================================================================
    // Configuration-based muxing (ORIGINAL LOGIC)
    // ====================================================================
    always_comb begin
        // Use LSBs of bus A for all inputs by default
        w_cordic_i   = i_bus_a[WIDTH_IN-1:0];
        w_cordic_q   = i_bus_a[2*WIDTH_IN-1:WIDTH_IN];
        mux_deriv_in   = w_phase_cordic; // default to cordic output
        mux_filter_in  = w_phase_deriv;  // default to derivative output

        o_bus_c = {{(BUS_C_WIDTH-WIDTH_PHASE){1'b0}}, w_phase_filter_out};
        o_bus_d = '0; // unused

        unique case (i_cfg)
            // MODE_0: 000 -> Input=Cordic, Output=Filter
            MODE_0: begin
                // Already set by default, no overrides needed
            end

            // MODE_1: 001 -> Input=Cordic, Output=Cordic
            MODE_1: begin
                o_bus_c = {{(BUS_C_WIDTH-WIDTH_PHASE){1'b0}}, w_phase_cordic};

            end

            // MODE_2: 010 -> Input=Derivate, Output=Derivate
            MODE_2: begin
                mux_deriv_in = i_bus_in[19:12];  // Override deriv input from bus
            end

            // MODE_3: 011 -> Input=Filter, Output=Filter
            MODE_3: begin
                mux_filter_in = i_bus_in[19:12];  // Override filter input from bus
            end

            // MODE_4: 100 -> Input=Cordic, Output=Derivate
            MODE_4: begin
                // Already set by default, no overrides needed
            end

            // MODE_5: 101 -> Input=Cordic, Output=Filter
            MODE_5: begin
                // Already set by default, no overrides needed
            end

            // MODE_6: 110 -> Input=Derivate, Output=Filter
            MODE_6: begin
                mux_deriv_in = i_bus_in[19:12];  // Override deriv input from bus
            end

            // MODE_7: 111 -> Input=Filter, Output=Filter
            MODE_7: begin
                mux_filter_in = i_bus_in[19:12];  // Override filter input from bus
            end

            default: begin
                mux_deriv_in  = w_phase_cordic;
                mux_filter_in = w_phase_deriv;
            end
        endcase
    end

    // ====================================================================
    // Output bus mapping (14 bits)
    // OUT[11:0] = phase_filter/cordic/deriv based on mode
    // OUT[13:12] = unused
    // ====================================================================
    always_comb begin
        o_bus_out = '0;  // Default: all zeros

        if (i_out_en) begin
            unique case (i_cfg)
                // Output = Filter (modes 0, 3, 5, 6, 7)
                MODE_0, MODE_3, MODE_5, MODE_6, MODE_7: begin
                    o_bus_out[7:0] = w_phase_filter_out[7:0];
                end

                // Output = Cordic (mode 1)
                MODE_1: begin
                    o_bus_out[7:0] = w_phase_cordic[7:0];
                end

                // Output = Derivative (modes 2, 4)
                MODE_2, MODE_4: begin
                    o_bus_out[7:0] = w_phase_deriv[7:0];
                end

                default: begin
                    o_bus_out = '0;
                end
            endcase
        end
        // When i_out_en = 0, o_bus_out stays 0 (tri-state)
    end

    // ====================================================================
    // Instantiate cordic_system (ORIGINAL INSTANTIATION)
    // ====================================================================
    cordic_system #(
        .WIDTH_IN(WIDTH_IN),
        .FILTER_N(FILTER_N),
        .WIDTH_PHASE(WIDTH_PHASE),
        .INSIDE_WRAPPER(1) // Set inside wrapper flag to 1 to enable internal muxing
    ) cordic_system_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_i(w_cordic_i),
        .i_q(w_cordic_q),
        .o_phase_cordic(w_phase_cordic),
        .i_phase_to_derivative(mux_deriv_in),
        .o_phase_derivative(w_phase_deriv),
        .i_phase_to_boxcar(mux_filter_in)
    );

endmodule
