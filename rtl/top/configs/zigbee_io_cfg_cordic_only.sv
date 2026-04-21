module zigbee_io_cfg_cordic_only #(
    parameter int CORDIC_WIDTH_IN = 8
)(
    input  logic [37:0]                        i_io_in,
    input  logic signed [CORDIC_WIDTH_IN+1:0]  i_cordic_phase,

    output logic signed [CORDIC_WIDTH_IN-1:0]  o_cordic_i,
    output logic signed [CORDIC_WIDTH_IN-1:0]  o_cordic_q,

    output logic [37:0]                        o_io_out,
    output logic [37:0]                        o_io_oe
);

    always_comb begin
        // Inputs on pads [15:0].
        o_cordic_i = i_io_in[CORDIC_WIDTH_IN-1:0];
        o_cordic_q = i_io_in[(2*CORDIC_WIDTH_IN)-1:CORDIC_WIDTH_IN];

        // Outputs on pads [25:16], disjoint from inputs.
        o_io_out = '0;
        o_io_oe  = '0;
        o_io_out[25:16] = i_cordic_phase;
        o_io_oe[25:16]  = '1;
    end

endmodule
