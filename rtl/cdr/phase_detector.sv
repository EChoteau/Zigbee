// Used phase detector: Hogge
module phase_detector #(
    parameter int DATA_WIDTH = 1
) (
    input  logic                 i_clk,
    input  logic                 i_rst_n,
    input  logic                 i_sample_clk,
    input  logic                 i_decision_in,
    output logic                 o_decision_out,
    output logic                 o_up,
    output logic                 o_down
);

`ifdef alexander_pd
    alexander_phase_detector u_apd (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_sample_clk(i_sample_clk),
        .i_decision_in(i_decision_in),
        .o_decision_out(o_decision_out),
        .o_up(o_up),
        .o_down(o_down)
    );
`else // hogge_pd
    hogge_phase_detector u_hpd (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_sample_clk(i_sample_clk),
        .i_decision_in(i_decision_in),
        .o_decision_out(o_decision_out),
        .o_up(o_up),
        .o_down(o_down)
    );
`endif

endmodule
