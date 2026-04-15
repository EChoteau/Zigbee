module cordic_top #(
    parameter int WIDTH_IN = 8,
    parameter int WIDTH_PHASE = WIDTH_IN + 2,
    parameter int WIDTH_INTERNAL = WIDTH_IN + 4,
    parameter int NUM_STEPS = 10 //WIDTH_IN
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic signed [WIDTH_IN-1:0] i_i_in,
    input  logic signed [WIDTH_IN-1:0] i_q_in,
    output logic signed [WIDTH_PHASE-1:0] o_phase_out
);

    // --- 1. Angle Table Generation from python cordic-table.py ---
    // CORDIC Atan Table originally generated for WIDTH_PHASE=10, NUM_STEPS=10
    // Stored with element width tied to WIDTH_PHASE to avoid truncation/extension.
    localparam logic signed [WIDTH_PHASE-1:0] ATAN_TABLE [0:9] = '{
        10'sh80, // step 0: 45.0000 deg
        10'sh4c, // step 1: 26.5651 deg
        10'sh28, // step 2: 14.0362 degs
        10'sh14, // step 3: 7.1250 deg
        10'sh0a, // step 4: 3.5763 deg
        10'sh05, // step 5: 1.7899 deg
        10'sh03, // step 6: 0.8952 deg
        10'sh01, // step 7: 0.4476 deg
        10'sh01, // step 8: 0.2238 deg
        10'sh00  // step 9: 0.1119 deg
    };

    // Elaboration-time parameter checks to ensure safe use of ATAN_TABLE
    initial begin
        if (NUM_STEPS > 10) begin
            $error("cordic_top: NUM_STEPS (%0d) exceeds size of ATAN_TABLE (10 entries).", NUM_STEPS);
        end
        if (WIDTH_PHASE < 10) begin
            $error("cordic_top: WIDTH_PHASE (%0d) is less than 10; ATAN_TABLE constants are 10-bit values.", WIDTH_PHASE);
        end
    end

    // --- 2. Internal Interconnects ---
    // Arrays to hold the signals between each step
    wire signed [WIDTH_INTERNAL-1:0] w_i_chain [0:NUM_STEPS];
    wire signed [WIDTH_INTERNAL-1:0] w_q_chain [0:NUM_STEPS];
    wire signed [WIDTH_PHASE-1:0] w_phase_chain [0:NUM_STEPS];

    // --- 3. Pre-Processing ---
    // Mandatory to move the vector to the Right Half Plane (I > 0)
    cordic_init #(
        .WIDTH_IN(WIDTH_IN),
        .WIDTH_PHASE(WIDTH_PHASE),
        .WIDTH_INTERNAL(WIDTH_INTERNAL)
    ) init_inst (
        .i_i_in(i_i_in),
        .i_q_in(i_q_in),
        .o_i_init(w_i_chain[0]),
        .o_q_init(w_q_chain[0]),
        .o_phase_init(w_phase_chain[0])
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
                .i_i_in(w_i_chain[i]),
                .i_q_in(w_q_chain[i]),
                .i_phase_in(w_phase_chain[i]),
                .o_i_next(w_i_chain[i+1]),
                .o_q_next(w_q_chain[i+1]),
                .o_phase_next(w_phase_chain[i+1])
            );
        end
    endgenerate

    // --- 5. Final Output ---
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_phase_out <= '0;
        end else begin
            o_phase_out <= w_phase_chain[NUM_STEPS];
        end
    end

endmodule

