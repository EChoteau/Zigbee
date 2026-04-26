module cordic_top_pipeline #(
    parameter int WIDTH_IN = 6,
    parameter int WIDTH_PHASE = WIDTH_IN + 2,
    parameter int WIDTH_INTERNAL = WIDTH_IN + 4,
    parameter int NUM_STEPS = WIDTH_IN + 2
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic signed [WIDTH_IN-1:0] i_i,
    input  logic signed [WIDTH_IN-1:0] i_q,
    output logic signed [WIDTH_PHASE-1:0] o_phase
);

    // --- 1. Angle Table Generation from python cordic-table.py ---
    localparam logic signed [8-1:0] ATAN_TABLE [0:7] = '{
        8'sh20, // step 0: 45.0000 deg
        8'sh13, // step 1: 26.5651 deg
        8'sh0a, // step 2: 14.0362 deg
        8'sh05, // step 3: 7.1250 deg
        8'sh03, // step 4: 3.5763 deg
        8'sh01, // step 5: 1.7899 deg
        8'sh01, // step 6: 0.8952 deg
        8'sh00 // step 7: 0.4476 deg
    };

    // Elaboration-time guard: prevent out-of-bounds access to ATAN_TABLE
    if (NUM_STEPS > 8) begin : gen_num_steps_check
        initial $error("cordic_top_pipeline: NUM_STEPS (%0d) exceeds ATAN_TABLE size (10).", NUM_STEPS);
    end

    // --- 2. Pipeline Registers ---
    // We use logic instead of wire to create the buffers between stages
    logic signed [WIDTH_INTERNAL-1:0] s_i_reg [0:NUM_STEPS];
    logic signed [WIDTH_INTERNAL-1:0] s_q_reg [0:NUM_STEPS];
    logic signed [WIDTH_PHASE-1:0]    s_phase_reg [0:NUM_STEPS];

    // --- 3. Pre-Processing (Stage 0) ---
    // Combinatorial signals for the output of the init block
    logic signed [WIDTH_INTERNAL-1:0] w_i_init_comb;
    logic signed [WIDTH_INTERNAL-1:0] w_q_init_comb;
    logic signed [WIDTH_PHASE-1:0]    w_phase_init_comb;

    cordic_init #(
        .WIDTH_IN(WIDTH_IN),
        .WIDTH_PHASE(WIDTH_PHASE),
        .WIDTH_INTERNAL(WIDTH_INTERNAL)
    ) init_inst (
        .i_i(i_i),
        .i_q(i_q),
        .o_i_init(w_i_init_comb),
        .o_q_init(w_q_init_comb),
        .o_phase_init(w_phase_init_comb)
    );

    // Buffer the initial stage
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            s_i_reg[0] <= '0;
            s_q_reg[0] <= '0;
            s_phase_reg[0] <= '0;
        end else begin
            s_i_reg[0] <= w_i_init_comb;
            s_q_reg[0] <= w_q_init_comb;
            s_phase_reg[0] <= w_phase_init_comb;
        end
    end

    // --- 4. Iterative Pipelined Chain ---
    genvar i;
    generate
        for (i = 0; i < NUM_STEPS; i = i + 1) begin : cordic_steps
            // Internal combinatorial wires for the step logic
            logic signed [WIDTH_INTERNAL-1:0] w_i_next_comb;
            logic signed [WIDTH_INTERNAL-1:0] w_q_next_comb;
            logic signed [WIDTH_PHASE-1:0]    w_phase_next_comb;

            cordic_step #(
                .WIDTH(WIDTH_INTERNAL),
                .WIDTH_PHASE(WIDTH_PHASE),
                .ITER(i),
                .ANGLE_VAL(ATAN_TABLE[i])
            ) step_inst (
                .i_i(s_i_reg[i]),
                .i_q(s_q_reg[i]),
                .i_phase(s_phase_reg[i]),
                .o_i_next(w_i_next_comb),
                .o_q_next(w_q_next_comb),
                .o_phase_next(w_phase_next_comb)
            );

            // The Pipeline "Buffer"
            always_ff @(posedge i_clk or negedge i_rst_n) begin
                if (!i_rst_n) begin
                    s_i_reg[i+1] <= '0;
                    s_q_reg[i+1] <= '0;
                    s_phase_reg[i+1] <= '0;
                end else begin
                    s_i_reg[i+1] <= w_i_next_comb;
                    s_q_reg[i+1] <= w_q_next_comb;
                    s_phase_reg[i+1] <= w_phase_next_comb;
                end
            end
        end
    endgenerate

    // --- 5. Final Output ---
    // The last stage of the pipeline is already buffered in i_reg[NUM_STEPS]
    assign o_phase = s_phase_reg[NUM_STEPS];

endmodule
