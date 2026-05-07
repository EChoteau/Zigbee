`ifdef meghelli_pd

module meghelli_phase_detector (
    input  logic  i_clk,
    input  logic  i_rst_n,
    input  logic  i_sample_clk,
    input  logic  i_decision_in,
    output logic  o_decision_out,
    output logic  o_up,
    output logic  o_down
);

    // Meghelli phase detector (simplified 3-sample version)
    logic s_a;  // Sample 1
    logic s_b;  // Sample 2
    logic s_c;  // Sample 3

    bascule b1 (
        .i_ck(i_clk),
        .i_en(i_sample_clk),
        .i_rst(i_rst_n),
        .i_D(i_decision_in),
        .o_Q(s_a)
    );

    bascule b2 (
        .i_ck(i_clk),
        .i_en(~i_sample_clk),
        .i_rst(i_rst_n),
        .i_D(i_decision_in),
        .o_Q(s_b)
    );

    bascule b3 (
        .i_ck(i_clk),
        .i_en(i_sample_clk),
        .i_rst(i_rst_n),
        .i_D(s_a),
        .o_Q(s_c)
    );

    assign o_decision_out = s_b;
    assign o_up   = (s_a ^ s_b);
    assign o_down = (s_b ^ s_c);

endmodule

`endif
