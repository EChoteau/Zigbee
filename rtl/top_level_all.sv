module receiver_system (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_adc_eoc,
    input  logic [3:0]        i_I_in,
    input  logic [3:0]        i_Q_in,
    output logic signed [7:0] o_I_filtered,
    output logic signed [7:0] o_Q_filtered
);

    // =========================
    // Signaux internes
    // =========================
    logic signed [7:0] s_I_demod;
    logic signed [7:0] s_Q_demod;

    // =========================
    // Démodulation IQ
    // =========================
    IQ_DEMOD u_demod (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_adc_eoc(i_adc_eoc),
        .i_I_in   (i_I_in),
        .i_Q_in   (i_Q_in),
        .o_I_out  (s_I_demod),
        .o_Q_out  (s_Q_demod)
    );

    // =========================
    // FIR voie I
    // =========================
    fir_top u_fir_i (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_sample_en(i_adc_eoc),
        .i_x_in     (s_I_demod),
        .o_y_out    (o_I_filtered)
    );

    // =========================
    // FIR voie Q
    // =========================
    fir_top u_fir_q (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_sample_en(i_adc_eoc),
        .i_x_in     (s_Q_demod),
        .o_y_out    (o_Q_filtered)
    );

endmodule
