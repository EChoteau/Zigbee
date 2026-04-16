module nco #

(
    parameter PHASE_WIDTH = 16,
    parameter  K_NOMINAL = 16'd2621
    //parameter K_NOMINAL = 16'd5242
)

(
    input wire i_clk,
    input wire i_rst_n,

    input wire signed [7:0] i_ctrl,

    output wire o_recovered_clk,
    output reg o_sample_enable
);
reg signed [PHASE_WIDTH-1:0] s_phase;
reg signed [PHASE_WIDTH-1:0] s_phase_next;
reg signed [PHASE_WIDTH-1:0] s_ctrl_normalised;

always @(posedge i_clk or negedge i_rst_n) begin

    if (~i_rst_n) begin

        s_phase <= 0;
        o_sample_enable <= 0;

    end
    else begin
        if (i_ctrl<0) s_ctrl_normalised = -{9'd0,i_ctrl[6:0]};
        else s_ctrl_normalised = {9'd0,i_ctrl[6:0]};
        s_phase_next = s_phase + K_NOMINAL + s_ctrl_normalised;

        o_sample_enable <= 0;
        if (s_phase_next[15] ==1'b0 && s_phase [15] ==1'b1) begin
            o_sample_enable <= 1;
            //recovered_clk <= ~recovered_clk;
        end

        s_phase <= s_phase_next;

    end

end
assign o_recovered_clk = s_phase[15];
endmodule
