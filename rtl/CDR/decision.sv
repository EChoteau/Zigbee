module decision #(
    parameter int resolution_in = 6,
    parameter int THRESHOLD     = 5    // seuil paramétrable
)(
    input  wire                          i_clk,
    input  wire                          i_rst_n,
    input  wire signed [resolution_in-1:0] i_dphi_in,
    output reg                           o_decision_out
);

// seuil signé sur la même largeur que i_dphi_in → comparaison toujours correcte
localparam signed [resolution_in-1:0] POS_THR =  THRESHOLD[resolution_in-1:0];
localparam signed [resolution_in-1:0] NEG_THR = -THRESHOLD[resolution_in-1:0];

always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n)
        o_decision_out <= 1'b0;
    else begin
        if      (i_dphi_in > POS_THR) o_decision_out <= 1'b1;
        else if (i_dphi_in < NEG_THR) o_decision_out <= 1'b0;
        // zone morte : maintien de la dernière décision
    end
end

endmodule
