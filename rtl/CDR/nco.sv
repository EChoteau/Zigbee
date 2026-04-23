module nco #(
    parameter K_NOMINAL = 10,
    parameter CTRL_W    = 8
)(
    input  wire                     i_clk,
    input  wire                     i_rst_n,
    input  wire signed [CTRL_W-1:0] i_ctrl,
    output wire                     o_recovered_clk,
    output reg                      o_sample_enable,
    output reg                      o_ctrl_ack
);

reg [5:0] s_period;
reg [5:0] s_cnt_pos;
reg [5:0] s_cnt_neg;

wire [5:0] s_cnt      = i_clk ? s_cnt_pos : s_cnt_neg;
wire [5:0] s_cnt_next = (s_cnt == s_period - 1) ? 6'd0 : s_cnt + 1;
wire       s_end      = (s_cnt == s_period - 1);

//---------------------------------------------------
// Front montant : logique principale + s_period
//---------------------------------------------------
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        s_cnt_pos       <= 0;
        s_period        <= K_NOMINAL;
        o_sample_enable <= 0;
        o_ctrl_ack      <= 0;
    end
    else begin
        o_sample_enable <= 0;
        o_ctrl_ack      <= 0;
        s_cnt_pos       <= s_cnt_next;

        if (s_end) begin
            o_sample_enable <= 1;
            o_ctrl_ack      <= 1;

            // correction petit à petit, retour à K_NOMINAL si ctrl=0
            if      (i_ctrl > 0 && s_period < 11) s_period <= s_period + 1;
            else if (i_ctrl < 0 && s_period > 9)  s_period <= s_period - 1;
            else                                   s_period <= K_NOMINAL; // ✅ retour au nominal
        end
    end
end

//---------------------------------------------------
// Front descendant : compteur uniquement
//---------------------------------------------------
always @(negedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n)
        s_cnt_neg <= 0;
    else
        s_cnt_neg <= s_cnt_next;
end

assign o_recovered_clk = (s_cnt < (s_period >> 1));

endmodule
