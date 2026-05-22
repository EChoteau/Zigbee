module cordic_wrapper #(
    parameter int WIDTH_IN    = 6,
    parameter int FILTER_N    = 5,
    parameter int WIDTH_PHASE = 8,
    parameter int CFG_WIDTH   = 3,
    parameter int BUS_IN_WIDTH  = 22,
    parameter int BUS_OUT_WIDTH = 14
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg,
    input  logic i_out_en,
    
    input  logic [BUS_IN_WIDTH-1:0]  i_bus_in,
    output logic [BUS_OUT_WIDTH-1:0] o_bus_out
);

    // Modes originaux
    localparam logic [2:0] MODE_0 = 3'b000; // Normal: I/Q -> Phase -> Deriv -> Filter
    localparam logic [2:0] MODE_1 = 3'b001; // CORDIC seul
    localparam logic [2:0] MODE_2 = 3'b010; // DERIV seul (Debug Phase Input)
    localparam logic [2:0] MODE_3 = 3'b011; // FILTER seul (Debug Phase Input)
    localparam logic [2:0] MODE_4 = 3'b100; // CORDIC + DERIV
    localparam logic [2:0] MODE_5 = 3'b101; // Chaîne complète (idem MODE_0)

    // Signaux internes
    logic signed [WIDTH_IN-1:0]    w_i_in;
    logic signed [WIDTH_IN-1:0]    w_q_in;
    logic signed [WIDTH_PHASE-1:0] w_phase_debug_in;

    // --- MAPPING COMPACT ---
    // En mode Normal/CORDIC, on lit I/Q sur [11:0]
    assign w_i_in = i_bus_in[5:0];
    assign w_q_in = i_bus_in[11:6];
    
    // En mode Debug (2 & 3), on réutilise les bits [7:0] pour la phase
    assign w_phase_debug_in = i_bus_in[7:0];

    // Signaux de routage pour cordic_top
    logic signed [WIDTH_PHASE-1:0] w_phase_cordic;
    logic signed [WIDTH_PHASE-1:0] w_phase_deriv;
    logic signed [WIDTH_PHASE-1:0] w_phase_filter_out;
    
    logic signed [WIDTH_PHASE-1:0] i_phase_to_derivative;
    logic signed [WIDTH_PHASE-1:0] i_phase_to_boxcar;

    always_comb begin
        // Routage entrée Dérivateur
        if (i_cfg == MODE_2)
            i_phase_to_derivative = w_phase_debug_in;
        else
            i_phase_to_derivative = w_phase_cordic;

        // Routage entrée Filtre
        if (i_cfg == MODE_3)
            i_phase_to_boxcar = w_phase_debug_in;
        else
            i_phase_to_boxcar = w_phase_deriv;
    end

    cordic_top #(
        .WIDTH_IN(WIDTH_IN),
        .FILTER_N(FILTER_N),
        .WIDTH_PHASE(WIDTH_PHASE),
        .INSIDE_WRAPPER(1)
    ) cordic_top_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_i(w_i_in),
        .i_q(w_q_in),
        .o_phase(w_phase_filter_out),
        .o_phase_cordic(w_phase_cordic),
        .i_phase_to_derivative(i_phase_to_derivative),
        .o_phase_derivative(w_phase_deriv),
        .i_phase_to_boxcar(i_phase_to_boxcar)
    );

    // Mux de sortie unifié
    always_comb begin
        o_bus_out = '0;
        if (i_out_en) begin
            unique case (i_cfg)
                MODE_1:         o_bus_out[7:0] = w_phase_cordic;
                MODE_2, MODE_4: o_bus_out[7:0] = w_phase_deriv;
                default:        o_bus_out[7:0] = w_phase_filter_out;
            endcase
        end
    end

endmodule