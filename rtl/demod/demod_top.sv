module demod_top (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic [2:0]        i_cfg,

    // Normal ADC inputs
    input  logic [3:0]        i_i,
    input  logic [3:0]        i_q,

    // Debug / test inputs from wrapper
    input  logic [3:0]        i_dbg_i,
    input  logic [3:0]        i_dbg_q,
    input  logic signed [7:0] i_dbg_fir_in,

    output logic signed [5:0] o_i_bb,
    output logic signed [5:0] o_q_bb,

    output logic signed [3:0] o_cos_test,
    output logic signed [3:0] o_sin_test,

    output logic signed [7:0] o_demod_out_i,
    output logic signed [7:0] o_demod_out_q
);

    localparam logic [2:0] MODE_0 = 3'b000;
    localparam logic [2:0] MODE_1 = 3'b001;
    localparam logic [2:0] MODE_2 = 3'b010;
    localparam logic [2:0] MODE_3 = 3'b011;
    localparam logic [2:0] MODE_4 = 3'b100;
    localparam logic [2:0] MODE_5 = 3'b101;
    localparam logic [2:0] MODE_6 = 3'b110;
    localparam logic [2:0] MODE_7 = 3'b111;

    logic [3:0] s_demod_i_in;
    logic [3:0] s_demod_q_in;

    logic signed [7:0] s_demod_out_i;
    logic signed [7:0] s_demod_out_q;

    logic signed [7:0] s_fir_i_in;
    logic signed [7:0] s_fir_q_in;

    // =========================================================
    // MUX entrée démodulateur
    // =========================================================
    always_comb begin
        s_demod_i_in = i_i;
        s_demod_q_in = i_q;

        unique case (i_cfg)

            MODE_0,
            MODE_1,
            MODE_2,
            MODE_3: begin
                s_demod_i_in = i_dbg_i;
                s_demod_q_in = i_dbg_q;
            end

            MODE_6: begin
                s_demod_i_in = i_dbg_i;
                s_demod_q_in = 4'b1000; // zéro ADC offset
            end

            MODE_7: begin
                s_demod_i_in = 4'b1000; // zéro ADC offset
                s_demod_q_in = i_dbg_q;
            end

            default: begin
                s_demod_i_in = i_i;
                s_demod_q_in = i_q;
            end

        endcase
    end

    // =========================================================
    // IQ DEMOD
    // =========================================================
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
    always_comb begin
        s_fir_i_in = s_demod_out_i;
        s_fir_q_in = s_demod_out_q;

        unique case (i_cfg)

            MODE_4: begin
                s_fir_i_in = i_dbg_fir_in;
                s_fir_q_in = 8'sd0;
            end

            MODE_5: begin
                s_fir_i_in = 8'sd0;
                s_fir_q_in = i_dbg_fir_in;
            end

            default: begin
                s_fir_i_in = s_demod_out_i;
                s_fir_q_in = s_demod_out_q;
            end

        endcase
    end

    // =========================================================
    // FIR I
    // =========================================================
    fir_top u_fir_i (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_x_in  (s_fir_i_in),
        .o_y_out (o_i_bb)
    );

    // =========================================================
    // FIR Q
    // =========================================================
    fir_top u_fir_q (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_x_in  (s_fir_q_in),
        .o_y_out (o_q_bb)
    );

    assign o_demod_out_i = s_demod_out_i;
    assign o_demod_out_q = s_demod_out_q;

endmodule
