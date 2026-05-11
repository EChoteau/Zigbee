module demod_top (
    input  logic              i_clk,
    input  logic              i_rst_n,

    // Normal ADC inputs
    input  logic [3:0]        i_i,
    input  logic [3:0]        i_q,

    // Override / debug inputs from wrapper
    input  logic              i_dbg_demod_override_en,
    input  logic [3:0]        i_dbg_demod_i,
    input  logic [3:0]        i_dbg_demod_q,
    
    input  logic              i_dbg_fir_override_en,
    input  logic signed [7:0] i_dbg_fir_i_in,
    input  logic signed [7:0] i_dbg_fir_q_in,

    // Outputs
    output logic signed [5:0] o_i_bb,
    output logic signed [5:0] o_q_bb,

    output logic signed [3:0] o_cos_test,
    output logic signed [3:0] o_sin_test,

    output logic signed [7:0] o_demod_out_i,
    output logic signed [7:0] o_demod_out_q
);

    logic [3:0] s_demod_i_in;
    logic [3:0] s_demod_q_in;
    logic signed [7:0] s_demod_out_i;
    logic signed [7:0] s_demod_out_q;
    logic signed [7:0] s_fir_i_in;
    logic signed [7:0] s_fir_q_in;

    // =========================================================
    // MUX OVERRIDE : Entree Demodulateur
    // =========================================================
    assign s_demod_i_in = i_dbg_demod_override_en ? i_dbg_demod_i : i_i;
    assign s_demod_q_in = i_dbg_demod_override_en ? i_dbg_demod_q : i_q;

    // =========================================================
    // MUX OVERRIDE : Entree FIR
    // =========================================================
    assign s_fir_i_in = i_dbg_fir_override_en ? i_dbg_fir_i_in : s_demod_out_i;
    assign s_fir_q_in = i_dbg_fir_override_en ? i_dbg_fir_q_in : s_demod_out_q;

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