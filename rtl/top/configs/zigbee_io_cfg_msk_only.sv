module zigbee_io_cfg_msk_only (
    input  logic [37:0]       i_io_in,
    input  logic signed [5:0] i_msk_i_bb,
    input  logic signed [5:0] i_msk_q_bb,

    output logic              o_msk_b_in,
    output logic              o_msk_flag_enable,
    output logic              o_msk_enable_ech,

    output logic [37:0]       o_io_out,
    output logic [37:0]       o_io_oe
);

    always_comb begin
        // Inputs on pads [2:0].
        o_msk_b_in        = i_io_in[0];
        o_msk_flag_enable = i_io_in[1];
        o_msk_enable_ech  = i_io_in[2];

        // Outputs on pads [14:3], disjoint from inputs.
        o_io_out          = '0;
        o_io_oe           = '0;
        o_io_out[8:3]     = i_msk_i_bb;
        o_io_out[14:9]    = i_msk_q_bb;
        o_io_oe[14:3]     = '1;
    end

endmodule
