module cordic_hybride #(
    parameter int WIDTH_IN = 6,
    parameter int WIDTH_PHASE = WIDTH_IN + 2,
    parameter int WIDTH_INTERNAL = WIDTH_IN + 4,
    parameter int NUM_STEPS = WIDTH_IN + 2,
    parameter int N_COMB_STEPS = 4,
    parameter int M_PIPE_STAGES = NUM_STEPS / N_COMB_STEPS
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic signed [WIDTH_IN-1:0] i_i,
    input  logic signed [WIDTH_IN-1:0] i_q,
    output logic signed [WIDTH_PHASE-1:0] o_phase
);

    localparam int TABLE_STEPS = 8;
    localparam int TOTAL_HYBRID_STEPS = N_COMB_STEPS * M_PIPE_STAGES;

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
        if (WIDTH_PHASE != 8) begin
            $error("WIDTH_PHASE (%0d) must be 8 to match ATAN_TABLE width (8)", WIDTH_PHASE);
        end
    end

    // --- 2. Pipeline Registers ---
    // Registers store only the boundaries between combinational groups.
    logic signed [WIDTH_INTERNAL-1:0] s_i_reg [0:M_PIPE_STAGES];
    logic signed [WIDTH_INTERNAL-1:0] s_q_reg [0:M_PIPE_STAGES];
    logic signed [WIDTH_PHASE-1:0]    s_phase_reg [0:M_PIPE_STAGES];

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

    // --- 4. Hybrid Chain ---
    // M pipeline groups, each containing N purely combinational CORDIC steps.
    genvar m;
    genvar n;
    generate
        for (m = 0; m < M_PIPE_STAGES; m = m + 1) begin : pipe_groups
            logic signed [WIDTH_INTERNAL-1:0] w_i_comb [0:N_COMB_STEPS];
            logic signed [WIDTH_INTERNAL-1:0] w_q_comb [0:N_COMB_STEPS];
            logic signed [WIDTH_PHASE-1:0]    w_phase_comb [0:N_COMB_STEPS];

            assign w_i_comb[0] = s_i_reg[m];
            assign w_q_comb[0] = s_q_reg[m];
            assign w_phase_comb[0] = s_phase_reg[m];

            for (n = 0; n < N_COMB_STEPS; n = n + 1) begin : comb_steps
                localparam int STEP_IDX = (m * N_COMB_STEPS) + n;

                cordic_step #(
                    .WIDTH(WIDTH_INTERNAL),
                    .WIDTH_PHASE(WIDTH_PHASE),
                    .ITER(STEP_IDX),
                    .ANGLE_VAL(ATAN_TABLE[STEP_IDX])
                ) step_inst (
                    .i_i(w_i_comb[n]),
                    .i_q(w_q_comb[n]),
                    .i_phase(w_phase_comb[n]),
                    .o_i_next(w_i_comb[n+1]),
                    .o_q_next(w_q_comb[n+1]),
                    .o_phase_next(w_phase_comb[n+1])
                );
            end

            // Pipeline register between two combinational groups.
            always_ff @(posedge i_clk or negedge i_rst_n) begin
                if (!i_rst_n) begin
                    s_i_reg[m+1] <= '0;
                    s_q_reg[m+1] <= '0;
                    s_phase_reg[m+1] <= '0;
                end else begin
                    s_i_reg[m+1] <= w_i_comb[N_COMB_STEPS];
                    s_q_reg[m+1] <= w_q_comb[N_COMB_STEPS];
                    s_phase_reg[m+1] <= w_phase_comb[N_COMB_STEPS];
                end
            end
        end
    endgenerate

    // --- 5. Final Output ---
    assign o_phase = s_phase_reg[M_PIPE_STAGES];

endmodule
