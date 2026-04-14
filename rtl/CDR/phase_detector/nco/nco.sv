module nco #

(
    parameter PHASE_WIDTH = 16,
    parameter  K_NOMINAL = 16'd2621
    //parameter K_NOMINAL = 16'd5242
)

(
    input wire clk,
    input wire rst,

    input wire signed [PHASE_WIDTH-1:0] ctrl,

    output reg recovered_clk,
    output reg sample_enable,

    output reg [PHASE_WIDTH-1:0] phase
);

reg [PHASE_WIDTH-1:0] phase_next;

always @(posedge clk or negedge rst) begin

    if (~rst) begin

        phase <= 0;
        recovered_clk <= 0;
        sample_enable <= 0;

    end
    else begin

        phase_next = phase + K_NOMINAL + ctrl;

        sample_enable <= 0;
        recovered_clk <= phase[15];
        if (phase_next < phase) begin
            sample_enable <= 1;
            //recovered_clk <= ~recovered_clk;
        end

        phase <= phase_next;

    end

end

endmodule
