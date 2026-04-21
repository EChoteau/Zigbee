module receiver_system (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_adc_eoc,
    input  logic [3:0]        i_I_in,
    input  logic [3:0]        i_Q_in,
    output logic signed [7:0] o_I_BB,
    output logic signed [7:0] o_Q_BB,
    output logic              o_iq_eod
);

    logic signed [7:0] s_demod_out_i;
    logic signed [7:0] s_demod_out_q;

    IQ_DEMOD u_iqdemod (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_adc_eoc (i_adc_eoc),
        .i_I_in    (i_I_in),
        .i_Q_in    (i_Q_in),
        .o_I_out   (s_demod_out_i),
        .o_Q_out   (s_demod_out_q)
    );

    fir_top u_fir_i (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_adc_eoc (i_adc_eoc),
        .i_x_in    (s_demod_out_i),
        .o_y_out   (o_I_BB)
    );

    fir_top u_fir_q (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_adc_eoc (i_adc_eoc),
        .i_x_in    (s_demod_out_q),
        .o_y_out   (o_Q_BB)
    );

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_iq_eod <= 1'b0;
        else
            o_iq_eod <= i_adc_eoc;
    end

endmodule
