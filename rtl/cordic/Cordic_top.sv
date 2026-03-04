module cordic_top #(
    parameter int WIDTH_IN = 8,
    parameter int WIDTH_PHASE = WIDTH_IN + 2,
    parameter int WIDTH_INTERNAL = WIDTH_IN + 4,
    parameter int NUM_STEPS = WIDTH_IN
)(
    input  logic signed [WIDTH_IN-1:0] I_in,
    input  logic signed [WIDTH_IN-1:0] Q_in,
    output logic signed [WIDTH_PHASE-1:0] Phase_out
);

    // --- 1. Angle Table Generation from python cordic-table.py ---
    // CORDIC Atan Table for WIDTH_PHASE=10, NUM_STEPS=10
    localparam logic signed [10-1:0] ATAN_TABLE [0:9] = '{
        10'sh80, // step 0: 45.0000 deg
        10'sh4c, // step 1: 26.5651 deg
        10'sh28, // step 2: 14.0362 deg
        10'sh14, // step 3: 7.1250 deg
        10'sh0a, // step 4: 3.5763 deg
        10'sh05, // step 5: 1.7899 deg
        10'sh03, // step 6: 0.8952 deg
        10'sh01, // step 7: 0.4476 deg
        10'sh01, // step 8: 0.2238 deg
        10'sh00 // step 9: 0.1119 deg
    };

    // --- 2. Internal Interconnects ---
    // Arrays to hold the signals between each step
    wire signed [WIDTH_INTERNAL-1:0] i_wire [0:NUM_STEPS];
    wire signed [WIDTH_INTERNAL-1:0] q_wire [0:NUM_STEPS];
    wire signed [WIDTH_PHASE-1:0] p_wire [0:NUM_STEPS];

    // --- 3. Pre-Processing ---
    // Mandatory to move the vector to the Right Half Plane (I > 0)
    cordic_init #(
        .WIDTH_IN(WIDTH_IN),
        .WIDTH_PHASE(WIDTH_PHASE),
        .WIDTH_INTERNAL(WIDTH_INTERNAL)
    ) init_inst (
        .I_in(I_in),
        .Q_in(Q_in),
        .I_init(i_wire[0]),
        .Q_init(q_wire[0]),
        .PHASE_init(p_wire[0])
    );

    // --- 4. Iterative Chain ---
    genvar i;
    generate
        for (i = 0; i < NUM_STEPS; i = i + 1) begin : cordic_steps
            cordic_step #(
                .WIDTH(WIDTH_INTERNAL),
                .WIDTH_PHASE(WIDTH_PHASE),
                .ITER(i),
                .ANGLE_VAL(ATAN_TABLE[i])
            ) step_inst (
                .I_in(i_wire[i]),
                .Q_in(q_wire[i]),
                .PHASE_in(p_wire[i]),
                .I_next(i_wire[i+1]),
                .Q_next(q_wire[i+1]),
                .PHASE_next(p_wire[i+1])
            );
        end
    endgenerate

    // --- 5. Final Output ---
    assign Phase_out = p_wire[NUM_STEPS];

endmodule

