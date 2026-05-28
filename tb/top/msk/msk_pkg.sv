package msk_pkg;

    import tb_pkg::*;

    localparam logic [2:0] TOP_CFG_MSK = 3'd4;

    localparam logic [2:0] CFG_NORMAL         = 3'b000;
    localparam logic [2:0] CFG_DEBUG_ENC      = 3'b001;
    localparam logic [2:0] CFG_DEBUG_DEMUX    = 3'b010;
    localparam logic [2:0] CFG_DEBUG_SHAPING  = 3'b011;
    localparam logic [2:0] CFG_DEBUG_ALL      = 3'b100;

    `define MSK_ARGS \
        ref logic i_clk, \
        ref logic i_rst_n, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_wrapper_cfg, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_top_cfg, \
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in, \
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out

endpackage : msk_pkg