`ifdef alexander_pd

module alexander_phase_detector (
    input  logic  i_clk,
    input  logic  i_rst_n,
    input  logic  i_sample_clk,
    input  logic  i_decision_in,
    output logic  o_decision_out,
    output logic  o_up,
    output logic  o_down
);

    logic s_a;  // Sample after transition
    logic s_b;  // Sample in middle
    logic s_c;  // Previous transition sample

    // Capture decision at different phases
    bascule b1 (
        .i_ck(i_clk),
        .i_en(i_sample_clk),
        .i_rst(i_rst_n),
        .i_D(i_decision_in),
        .o_Q(s_a)
    );  // transition

    bascule b2 (
        .i_ck(i_clk),
        .i_en(~i_sample_clk),
        .i_rst(i_rst_n),
        .i_D(i_decision_in),
        .o_Q(s_b)
    );  // middle

    bascule b3 (
        .i_ck(i_clk),
        .i_en(i_sample_clk),
        .i_rst(i_rst_n),
        .i_D(s_a),
        .o_Q(s_c)
    );  // previous transition

    assign o_decision_out = s_b;
    assign o_up   = (s_a ^ s_b) & ~(s_b ^ s_c);
    assign o_down = (s_b ^ s_c) & ~(s_a ^ s_b);

endmodule

`endif
