module decision_block #(
    parameter int resolution_in = 6
) (
    input  logic signed [resolution_in-1:0]  i_dphi_in,
    output logic                              o_decision_out
);

    // Dead zone: if |i_dphi_in| <= 5, maintain previous output
    // Use logic to break the combinational loop
    reg s_decision_r;
    
    always_comb begin
        if (i_dphi_in > $signed(6'sd5))
            s_decision_r = 1'b1;
        else if (i_dphi_in < -$signed(6'sd5))
            s_decision_r = 1'b0;
        // else: maintain (no assignment - synthesizer should optimize to mux)
    end
    
    assign o_decision_out = s_decision_r;

endmodule
