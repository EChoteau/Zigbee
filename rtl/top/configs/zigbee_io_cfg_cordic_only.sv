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
        o_cordic_i = i_io_in[CORDIC_WIDTH_IN-1:0];
        o_cordic_q = i_io_in[(2*CORDIC_WIDTH_IN)-1:CORDIC_WIDTH_IN];

        o_io_out = '0;
        o_io_oe  = '0;
        o_io_out[CORDIC_WIDTH_IN+1:0] = i_cordic_phase;
        o_io_oe[CORDIC_WIDTH_IN+1:0]  = '1;
    end

endmodule
