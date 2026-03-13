module cordic_top_hybride #(
    parameter int WIDTH_IN = 8,
    parameter int WIDTH_PHASE = WIDTH_IN + 2,
    parameter int WIDTH_INTERNAL = WIDTH_IN + 4,
    parameter int NUM_STEPS = 10,
    parameter int N_COMB_STEPS = 2,
    parameter int M_PIPE_STAGES = NUM_STEPS / N_COMB_STEPS
)(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [WIDTH_IN-1:0] I_in,
    input  logic signed [WIDTH_IN-1:0] Q_in,
    output logic signed [WIDTH_PHASE-1:0] Phase_out
);

    localparam int TABLE_STEPS = 10;
    localparam int TOTAL_HYBRID_STEPS = N_COMB_STEPS * M_PIPE_STAGES;

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

    // Elaboration checks for hybrid partitioning and table coverage.
    initial begin
        if (N_COMB_STEPS <= 0) begin
            $error("N_COMB_STEPS must be > 0");
        end
        if ((NUM_STEPS % N_COMB_STEPS) != 0) begin
            $error("NUM_STEPS (%0d) must be a multiple of N_COMB_STEPS (%0d)", NUM_STEPS, N_COMB_STEPS);
        end
        if (TOTAL_HYBRID_STEPS != NUM_STEPS) begin
            $error("TOTAL_HYBRID_STEPS (%0d) must match NUM_STEPS (%0d)", TOTAL_HYBRID_STEPS, NUM_STEPS);
        end
        if (NUM_STEPS > TABLE_STEPS) begin
            $error("NUM_STEPS (%0d) exceeds ATAN_TABLE size (%0d)", NUM_STEPS, TABLE_STEPS);
        end
    end

    // --- 2. Pipeline Registers ---
    // Registers store only the boundaries between combinational groups.
    logic signed [WIDTH_INTERNAL-1:0] i_reg [0:M_PIPE_STAGES];
    logic signed [WIDTH_INTERNAL-1:0] q_reg [0:M_PIPE_STAGES];
    logic signed [WIDTH_PHASE-1:0]    p_reg [0:M_PIPE_STAGES];

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

    // --- 4. Hybrid Chain ---
    // M pipeline groups, each containing N purely combinational CORDIC steps.
    genvar m;
    genvar n;
    generate
        for (m = 0; m < M_PIPE_STAGES; m = m + 1) begin : pipe_groups
            logic signed [WIDTH_INTERNAL-1:0] i_comb [0:N_COMB_STEPS];
            logic signed [WIDTH_INTERNAL-1:0] q_comb [0:N_COMB_STEPS];
            logic signed [WIDTH_PHASE-1:0]    p_comb [0:N_COMB_STEPS];

            assign i_comb[0] = i_reg[m];
            assign q_comb[0] = q_reg[m];
            assign p_comb[0] = p_reg[m];

            for (n = 0; n < N_COMB_STEPS; n = n + 1) begin : comb_steps
                localparam int STEP_IDX = (m * N_COMB_STEPS) + n;

                cordic_step #(
                    .WIDTH(WIDTH_INTERNAL),
                    .WIDTH_PHASE(WIDTH_PHASE),
                    .ITER(STEP_IDX),
                    .ANGLE_VAL(ATAN_TABLE[STEP_IDX])
                ) step_inst (
                    .I_in(i_comb[n]),
                    .Q_in(q_comb[n]),
                    .PHASE_in(p_comb[n]),
                    .I_next(i_comb[n+1]),
                    .Q_next(q_comb[n+1]),
                    .PHASE_next(p_comb[n+1])
                );
            end

            // Pipeline register between two combinational groups.
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    i_reg[m+1] <= '0;
                    q_reg[m+1] <= '0;
                    p_reg[m+1] <= '0;
                end else begin
                    i_reg[m+1] <= i_comb[N_COMB_STEPS];
                    q_reg[m+1] <= q_comb[N_COMB_STEPS];
                    p_reg[m+1] <= p_comb[N_COMB_STEPS];
                end
            end
        end
    endgenerate

    // --- 5. Final Output ---
    assign Phase_out = p_reg[M_PIPE_STAGES];

endmodule
