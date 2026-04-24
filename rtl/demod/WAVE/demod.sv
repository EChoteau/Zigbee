module IQ_DEMOD (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic [3:0]        i_I_in,
    input  logic [3:0]        i_Q_in,
    output logic signed [7:0] o_I_out,
    output logic signed [7:0] o_Q_out
);

    logic signed [7:0] s_II, s_IQ, s_QI, s_QQ;
    logic signed [3:0] s_IF_I, s_IF_Q, s_I_tmpin, s_Q_tmpin;
    logic signed [7:0] s_I_tmp, s_Q_tmp;

    // =========================================
    // Registres : reset asynchrone, front montant
    // =========================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_I_out   <= 8'sd0;
            o_Q_out   <= 8'sd0;
            s_I_tmpin <= 4'sd0;
            s_Q_tmpin <= 4'sd0;
        end
        else begin
            o_I_out   <= s_I_tmp;
            o_Q_out   <= s_Q_tmp;

            // Conversion non signé -> signé
            s_I_tmpin <= i_I_in + 4'b1000;
            s_Q_tmpin <= i_Q_in + 4'b1000;
        end
    end

    // =========================================
    // Générateurs LO cos / sin
    // =========================================
    wave_generator #(0) u_cos_signal (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .o_data_out (s_IF_I)
    );

    wave_generator #(1) u_sin_signal (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .o_data_out (s_IF_Q)
    );

    // =========================================
    // Calcul combinatoire
    // =========================================
    always_comb begin
        s_II = s_IF_I * s_I_tmpin;
        s_IQ = s_IF_Q * s_I_tmpin;
        s_QI = s_IF_I * s_Q_tmpin;
        s_QQ = s_IF_Q * s_Q_tmpin;

        s_I_tmp = s_II - s_QQ;
        s_Q_tmp = s_IQ + s_QI;
    end

endmodule
