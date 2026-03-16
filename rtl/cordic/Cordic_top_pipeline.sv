module cordic_top_pipeline #(
    parameter int WIDTH_IN = 8,
    parameter int WIDTH_PHASE = WIDTH_IN + 2,
    parameter int WIDTH_INTERNAL = WIDTH_IN + 4,
    parameter int NUM_STEPS = 10 
)(
    input  logic clk,
    input  logic rst_n,
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

    // Elaboration-time guard: prevent out-of-bounds access to ATAN_TABLE
    if (NUM_STEPS > 10) begin : gen_num_steps_check
        initial $error("cordic_top_pipeline: NUM_STEPS (%0d) exceeds ATAN_TABLE size (10).", NUM_STEPS);
    end

    // --- 2. Pipeline Registers ---
    // We use logic instead of wire to create the buffers between stages
    logic signed [WIDTH_INTERNAL-1:0] i_reg [0:NUM_STEPS];
    logic signed [WIDTH_INTERNAL-1:0] q_reg [0:NUM_STEPS];
    logic signed [WIDTH_PHASE-1:0]    p_reg [0:NUM_STEPS];

    // --- 3. Pre-Processing (Stage 0) ---
    // Combinatorial signals for the output of the init block
    logic signed [WIDTH_INTERNAL-1:0] i_init_comb;
    logic signed [WIDTH_INTERNAL-1:0] q_init_comb;
    logic signed [WIDTH_PHASE-1:0]    p_init_comb;

    cordic_init #(
        .WIDTH_IN(WIDTH_IN),
        .WIDTH_PHASE(WIDTH_PHASE),
        .WIDTH_INTERNAL(WIDTH_INTERNAL)
    ) init_inst (
        .I_in(I_in),
        .Q_in(Q_in),
        .I_init(i_init_comb),
        .Q_init(q_init_comb),
        .PHASE_init(p_init_comb)
    );

    // Buffer the initial stage
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i_reg[0] <= '0;
            q_reg[0] <= '0;
            p_reg[0] <= '0;
        end else begin
            i_reg[0] <= i_init_comb;
            q_reg[0] <= q_init_comb;
            p_reg[0] <= p_init_comb;
        end
    end

    // --- 4. Iterative Pipelined Chain ---
    genvar i;
    generate
        for (i = 0; i < NUM_STEPS; i = i + 1) begin : cordic_steps
            // Internal combinatorial wires for the step logic
            logic signed [WIDTH_INTERNAL-1:0] i_next_comb;
            logic signed [WIDTH_INTERNAL-1:0] q_next_comb;
            logic signed [WIDTH_PHASE-1:0]    p_next_comb;

            cordic_step #(
                .WIDTH(WIDTH_INTERNAL),
                .WIDTH_PHASE(WIDTH_PHASE),
                .ITER(i),
                .ANGLE_VAL(ATAN_TABLE[i])
            ) step_inst (
                .I_in(i_reg[i]),
                .Q_in(q_reg[i]),
                .PHASE_in(p_reg[i]),
                .I_next(i_next_comb),
                .Q_next(q_next_comb),
                .PHASE_next(p_next_comb)
            );

            // The Pipeline "Buffer"
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    i_reg[i+1] <= '0;
                    q_reg[i+1] <= '0;
                    p_reg[i+1] <= '0;
                end else begin
                    i_reg[i+1] <= i_next_comb;
                    q_reg[i+1] <= q_next_comb;
                    p_reg[i+1] <= p_next_comb;
                end
            end
        end
    endgenerate

    // --- 5. Final Output ---
    // The last stage of the pipeline is already buffered in i_reg[NUM_STEPS]
    assign Phase_out = p_reg[NUM_STEPS];

endmodule
