module IQ_DEMOD (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_adc_eoc,
    input  logic [3:0]        i_I_in,
    input  logic [3:0]        i_Q_in,
    output logic signed [7:0] o_I_out,
    output logic signed [7:0] o_Q_out
);

    // =========================
    // Internal signals
    // =========================
    logic signed [7:0] s_II, s_IQ, s_QI, s_QQ;
    logic signed [3:0] s_IF_I, s_IF_Q;
    logic signed [3:0] s_I_tmpin, s_Q_tmpin;
    logic signed [7:0] s_I_tmp, s_Q_tmp;

    logic signed [4:0] s_I_conv, s_Q_conv;

    // =========================
    // Unsigned -> signed conversion
    // =========================
    always_comb begin
        s_I_conv = $signed({1'b0, i_I_in}) - 5'sd8;
        s_Q_conv = $signed({1'b0, i_Q_in}) - 5'sd8;
    end

    // =========================
    // Asynchronous reset + registers
    // =========================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_I_out   <= '0;
            o_Q_out   <= '0;
            s_I_tmpin <= '0;
            s_Q_tmpin <= '0;
        end 
        else if (i_adc_eoc) begin
            o_I_out   <= s_I_tmp;
            o_Q_out   <= s_Q_tmp;

            // keep only 4 bits explicitly
            s_I_tmpin <= s_I_conv[3:0];
            s_Q_tmpin <= s_Q_conv[3:0];
        end
    end

    // =========================
    // Sin / cos generators
    // =========================
    wave_generator #(0) u_cos_signal (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_adc_eoc  (i_adc_eoc),
        .o_data_out (s_IF_I)
    );

    wave_generator #(1) u_sin_signal (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_adc_eoc  (i_adc_eoc),
        .o_data_out (s_IF_Q)
    );

    // =========================
    // Combinational calculation
    // =========================
    always_comb begin
        s_II   = $signed(s_IF_I) * $signed(s_I_tmpin);
        s_IQ   = $signed(s_IF_Q) * $signed(s_I_tmpin);
        s_QI   = $signed(s_IF_I) * $signed(s_Q_tmpin);
        s_QQ   = $signed(s_IF_Q) * $signed(s_Q_tmpin);

        s_I_tmp = $signed(s_II) - $signed(s_QQ);
        s_Q_tmp = $signed(s_IQ) + $signed(s_QI);
    end

endmodule
