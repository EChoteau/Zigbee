module demod_wrapper (
    input  logic              i_clk,
    input  logic              i_rst_n,

    input  logic [3:0]        i_i,
    input  logic [3:0]        i_q,

    input  logic [9:0]        i_Bus_B_10,
    input  logic [2:0]        i_cfg,

    output logic signed [5:0] o_i_bb,
    output logic signed [5:0] o_q_bb,

    output logic signed [3:0] o_cos_test,
    output logic signed [3:0] o_sin_test,

    output logic [11:0]       o_Bus_B_12
);

    // =========================================================
    // Découpage bus de test
    // =========================================================

    logic [3:0] s_test_i;
    logic [3:0] s_test_q;
    logic signed [7:0] s_test_fir_in;

    assign s_test_i      = i_Bus_B_10[9:6];
    assign s_test_q      = i_Bus_B_10[3:0];
    assign s_test_fir_in = i_Bus_B_10[7:0];

    // =========================================================
    // MUX entrée démodulateur
    // =========================================================

    logic [3:0] s_demod_i_in;
    logic [3:0] s_demod_q_in;

    always_comb begin
        s_demod_i_in = i_i;
        s_demod_q_in = i_q;

        case (i_cfg)

            // Test cos + demod I
            3'b010: begin
                s_demod_i_in = s_test_i;
                s_demod_q_in = s_test_q;
            end

            // Test sin + demod Q
            3'b011: begin
                s_demod_i_in = s_test_i;
                s_demod_q_in = s_test_q;
            end

            // Test chaîne complète côté I uniquement
            3'b110: begin
                s_demod_i_in = s_test_i;
                s_demod_q_in = 4'b1000; // zéro en offset binary
            end

            // Test chaîne complète côté Q uniquement
            3'b111: begin
                s_demod_i_in = 4'b1000; // zéro en offset binary
                s_demod_q_in = s_test_q;
            end

            default: begin
                s_demod_i_in = i_i;
                s_demod_q_in = i_q;
            end

        endcase
    end

    // =========================================================
    // Démodulateur
    // =========================================================

    logic signed [7:0] s_demod_out_i;
    logic signed [7:0] s_demod_out_q;

    IQ_DEMOD u_iqdemod (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),

        .i_I_in     (s_demod_i_in),
        .i_Q_in     (s_demod_q_in),

        .o_I_out    (s_demod_out_i),
        .o_Q_out    (s_demod_out_q),

        .o_cos_test (o_cos_test),
        .o_sin_test (o_sin_test)
    );

    // =========================================================
    // MUX entrée FIR
    // =========================================================

    logic signed [7:0] s_fir_i_in;
    logic signed [7:0] s_fir_q_in;

    always_comb begin
        s_fir_i_in = s_demod_out_i;
        s_fir_q_in = s_demod_out_q;

        case (i_cfg)

            // Test FIR uniquement côté I
            3'b100: begin
                s_fir_i_in = s_test_fir_in;
                s_fir_q_in = 8'sd0;
            end

            // Test FIR uniquement côté Q
            3'b101: begin
                s_fir_i_in = 8'sd0;
                s_fir_q_in = s_test_fir_in;
            end

            default: begin
                s_fir_i_in = s_demod_out_i;
                s_fir_q_in = s_demod_out_q;
            end

        endcase
    end

    // =========================================================
    // FIR I / FIR Q
    // =========================================================

    fir_top u_fir_i (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_x_in   (s_fir_i_in),
        .o_y_out  (o_i_bb)
    );

    fir_top u_fir_q (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_x_in   (s_fir_q_in),
        .o_y_out  (o_q_bb)
    );

    // =========================================================
    // MUX sortie test 12 bits
    // =========================================================

    always_comb begin
        case (i_cfg)

            // Test cos seul
            3'b000: begin
                o_Bus_B_12 = {o_cos_test, s_demod_out_i};
            end

            // Test sin seul
            3'b001: begin
                o_Bus_B_12 = {o_sin_test, s_demod_out_q};
            end

            // Test cos + sortie I demod
            3'b010: begin
                o_Bus_B_12 = {o_cos_test, s_demod_out_i};
            end

            // Test sin + sortie Q demod
            3'b011: begin
                o_Bus_B_12 = {o_sin_test, s_demod_out_q};
            end

            // Test FIR I seul
            3'b100: begin
                o_Bus_B_12 = {o_i_bb, o_q_bb};
            end

            // Test FIR Q seul
            3'b101: begin
                o_Bus_B_12 = {o_i_bb, o_q_bb};
            end

            // Test chaîne complète côté I
            3'b110: begin
                o_Bus_B_12 = {o_i_bb, o_q_bb};
            end

            // Test chaîne complète côté Q
            3'b111: begin
                o_Bus_B_12 = {o_i_bb, o_q_bb};
            end

            default: begin
                o_Bus_B_12 = 12'b0;
            end

        endcase
    end

endmodule
