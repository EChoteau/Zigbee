module decision_block 
#(
parameter resolution_in=6)

(
    input  wire signed [resolution_in-1:0] i_dphi_in,
    output wire o_decision_out
);

assign o_decision_out = (i_dphi_in > 6'sd5) ? 1'b1 :
                        (i_dphi_in < -6'sd5) ? 1'b0 :
                        1'b0;  // zone morte

endmodule
