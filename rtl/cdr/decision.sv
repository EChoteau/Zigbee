module decision_block #(
    parameter int resolution_in = 6,
    parameter int DEAD_ZONE_WIDTH = 5
) (
    input  logic signed [resolution_in-1:0]  i_dphi_in,
    output logic                              o_decision_out
);

    // Pure combinational threshold comparator with dead zone
    // If phase error > +DEAD_ZONE_WIDTH -> advance clock
    // If phase error < -DEAD_ZONE_WIDTH -> delay clock
    // Otherwise -> no change (output = 0)
    
    always_comb begin
        if (i_dphi_in > $signed(resolution_in'(DEAD_ZONE_WIDTH)))
            o_decision_out = 1'b1;  // Phase advance
        else if (i_dphi_in < -$signed(resolution_in'(DEAD_ZONE_WIDTH)))
            o_decision_out = 1'b0;  // Phase delay
        else
            o_decision_out = 1'b0;  // Dead zone: no change
    end

endmodule
