module hogge_phase_detector (
    input  logic  i_clk,
    input  logic  i_rst_n,
    input  logic  i_sample_clk,
    input  logic  i_decision_in,
    output logic  o_decision_out,
    output logic  o_up,
    output logic  o_down
);

    logic s_a;  // Sample after clock edge
    logic s_b;  // Sample in between clock edges

    // Capture decision at different phases
    bascule b0 (
        .i_ck(i_clk),
        .i_en(i_sample_clk),
        .i_rst(i_rst_n),
        .i_D(i_decision_in),
        .o_Q(s_a)
    );

    bascule b1 (
        .i_ck(i_clk),
        .i_en(~i_sample_clk),
        .i_rst(i_rst_n),
        .i_D(s_a),
        .o_Q(s_b)
    );

    assign o_decision_out = s_b;
    assign o_up   = (i_decision_in ^ s_a);
    assign o_down = (s_a ^ s_b);

endmodule
