module zigbee_io_cfg_if_only #(
    parameter int APB_ADDR_WIDTH  = 8,
    parameter int APB_DATA_WIDTH  = 32
)(
    input  logic [37:0]                  i_io_in,

    input  logic                         i_if_serial_tx,
    input  logic                         i_if_tx_valid,
    input  logic                         i_if_tx_sample_tick,
    input  logic [APB_DATA_WIDTH-1:0]    i_if_prdata,
    input  logic                         i_if_pready,
    input  logic                         i_if_pslverr,

    output logic                         o_if_psel,
    output logic                         o_if_penable,
    output logic                         o_if_pwrite,
    output logic [APB_ADDR_WIDTH-1:0]    o_if_paddr,
    output logic [APB_DATA_WIDTH-1:0]    o_if_pwdata,
    output logic                         o_if_serial_rx,
    output logic                         o_if_cdr_sample_valid,

    output logic [37:0]                  o_io_out,
    output logic [37:0]                  o_io_oe
);

    always_comb begin
        // Inputs on pads [20:0]
        o_if_psel             = i_io_in[0];
        o_if_penable          = i_io_in[1];
        o_if_pwrite           = i_io_in[2];
        o_if_paddr            = i_io_in[10:3];
        o_if_pwdata           = '0;
        o_if_pwdata[7:0]      = i_io_in[18:11];
        o_if_serial_rx        = i_io_in[19];
        o_if_cdr_sample_valid = i_io_in[20];

        o_io_out              = '0;
        o_io_oe               = '0;
        // Outputs on pads [33:21], disjoint from inputs.
        o_io_out[21]          = i_if_serial_tx;
        o_io_out[22]          = i_if_tx_valid;
        o_io_out[23]          = i_if_tx_sample_tick;
        o_io_out[31:24]       = i_if_prdata[7:0];
        o_io_out[32]          = i_if_pready;
        o_io_out[33]          = i_if_pslverr;
        o_io_oe[33:21]        = '1;
    end

endmodule
