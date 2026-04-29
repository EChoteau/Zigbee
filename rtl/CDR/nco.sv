module nco #(
    parameter PHASE_WIDTH = 16,
    parameter K_NOMINAL   = 5,    // nombre de cycles i_clk par bit
    parameter CTRL_W      = 8
)(
    input  wire                   i_clk,
    input  wire                   i_rst_n,
    input  wire signed [CTRL_W-1:0] i_ctrl,
    output wire                   o_recovered_clk,
    output reg                    o_sample_enable,
    output reg o_ctrl_ack
);

// Période ajustée : bornée entre 23 et 27
reg [5:0] s_period;
reg [5:0] s_cnt;

// Calcul de la période avec saturation

always @(posedge i_clk or negedge i_rst_n) begin  // ← posedge
    if (~i_rst_n) begin
        s_cnt           <= 0;
        s_period        <= K_NOMINAL;
        o_sample_enable <= 0;
        o_ctrl_ack      <= 0;
    end
    else begin
        o_sample_enable <= 0;
        o_ctrl_ack      <= 0;

        if (s_cnt == s_period - 1) begin
            s_cnt           <= 0;
            o_sample_enable <= 1;
            o_ctrl_ack      <= 1;  // ← ack mis à 1

            if      (i_ctrl > 0 && s_period < 6) s_period <= s_period + 1;  // ← bornes cohérentes
            else if (i_ctrl < 0 && s_period > 4)  s_period <= s_period - 1;
            else s_period <= K_NOMINAL;
        end
        else begin
            s_cnt <= s_cnt + 1;
        end
    end
end
// horloge récupérée = MSB du compteur (50% duty cycle)
assign o_recovered_clk = s_cnt < (s_period >> 1);

endmodule
