module nco #

(
    parameter PHASE_WIDTH = 16,
    parameter  K_NOMINAL = 16'd2621
    //parameter K_NOMINAL = 16'd5242
)

(
    input wire clk,
    input wire rst,

    input wire signed [7:0] ctrl,

    output wire recovered_clk,
    output reg sample_enable
);
reg signed [PHASE_WIDTH-1:0] phase;
reg signed [PHASE_WIDTH-1:0] phase_next;
reg signed [PHASE_WIDTH-1:0] ctrl_normalised;

always @(posedge clk or negedge rst) begin

    if (~rst) begin

        phase <= 0;
        sample_enable <= 0;

    end
    else begin
        if (ctrl<0) ctrl_normalised = -{9'd0,ctrl[6:0]};
        else ctrl_normalised = {9'd0,ctrl[6:0]};
        phase_next = phase + K_NOMINAL + ctrl_normalised;

        sample_enable <= 0;
        if (phase_next[15] ==1'b0 && phase [15] ==1'b1) begin
            sample_enable <= 1;
            //recovered_clk <= ~recovered_clk;
        end

        phase <= phase_next;

    end

end
assign recovered_clk = phase[15];
endmodule
