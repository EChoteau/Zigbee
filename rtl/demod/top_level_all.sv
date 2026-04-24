module demod_system_complete (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic [3:0]        i_i,
    input  logic [3:0]        i_q,
    output logic signed [5:0] o_i_bb,
    output logic signed [5:0] o_q_bb
);

    logic signed [7:0] s_demod_out_i;
    logic signed [7:0] s_demod_out_q;

    IQ_DEMOD u_iqdemod (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_I_in    (i_i),
        .i_Q_in    (i_q),
        .o_I_out   (s_demod_out_i),
        .o_Q_out   (s_demod_out_q)
    );

    fir_top u_fir_i (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_x_in    (s_demod_out_i),
        .o_y_out   (o_i_bb)
    );

    fir_top u_fir_q (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_x_in    (s_demod_out_q),
        .o_y_out   (o_q_bb)
    );


endmodule
