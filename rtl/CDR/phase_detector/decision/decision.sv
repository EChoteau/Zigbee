module decision_block 
#(
parameter resolution_in=6)

(
    input  wire signed [5:0] dphi_in,
    output wire decision_out
);

assign decision_out = (dphi_in > 6'sd5) ? 1'b1 :
                      (dphi_in < -6'sd5) ? 1'b0 :
                      1'b0;  // zone morte

endmodule
