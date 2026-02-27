module cordic_top #(
    parameter int WIDTH = 16,
    parameter int NUM_STEPS = 16
)(
    input  logic signed [WIDTH-1:0] I_in,
    input  logic signed [WIDTH-1:0] Q_in,
    output logic signed [WIDTH-1:0] Phase_out
);

    // --- 1. Angle Table Generation from python cordic-table.py ---
    // CORDIC Atan Table for WIDTH=16, NUM_STEPS=16
    localparam logic signed [16-1:0] ATAN_TABLE [0:15] = '{
	    16'sh2000, // step 0: 45.0000 deg
	    16'sh12e4, // step 1: 26.5651 deg
	    16'sh09fb, // step 2: 14.0362 deg
	    16'sh0511, // step 3: 7.1250 deg
	    16'sh028b, // step 4: 3.5763 deg
	    16'sh0146, // step 5: 1.7899 deg
	    16'sh00a3, // step 6: 0.8952 deg
	    16'sh0051, // step 7: 0.4476 deg
	    16'sh0029, // step 8: 0.2238 deg
	    16'sh0014, // step 9: 0.1119 deg
	    16'sh000a, // step 10: 0.0560 deg
	    16'sh0005, // step 11: 0.0280 deg
	    16'sh0003, // step 12: 0.0140 deg
	    16'sh0001, // step 13: 0.0070 deg
	    16'sh0001, // step 14: 0.0035 deg
	    16'sh0000 // step 15: 0.0017 deg
    };

    // --- 2. Internal Interconnects ---
    // Arrays to hold the signals between each step
    wire signed [WIDTH-1:0] i_wire [0:NUM_STEPS];
    wire signed [WIDTH-1:0] q_wire [0:NUM_STEPS];
    wire signed [WIDTH-1:0] p_wire [0:NUM_STEPS];

    // --- 3. Pre-Processing ---
    // Mandatory to move the vector to the Right Half Plane (I > 0)
    cordic_init #(WIDTH) init_inst (
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
                .WIDTH(WIDTH),
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

