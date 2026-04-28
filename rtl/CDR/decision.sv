module decision_block 
#(
parameter resolution_in=6)

(
    input  wire signed [resolution_in-1:0] i_dphi_in,
    input wire  i_clk,
    input wire i_rst_n,
    output reg o_decision_out
);
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n)
    begin 
    o_decision_out <= 1'b0;
    end
    else
    begin
    if (i_dphi_in > 6'sd5) o_decision_out <= 1'b1;
    else if (i_dphi_in < -6'sd5) o_decision_out <= 1'b0 ;
    else o_decision_out <= o_decision_out;  // zone morte
    end
    end

endmodule
