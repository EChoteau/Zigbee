package msk_pkg;

    import tb_pkg::*;

    localparam logic [2:0] TOP_CFG_MSK = 3'd4;

    localparam logic [2:0] CFG_NORMAL         = 3'b000;
    localparam logic [2:0] CFG_DEBUG_ENC      = 3'b001;
    localparam logic [2:0] CFG_DEBUG_DEMUX    = 3'b010;
    localparam logic [2:0] CFG_DEBUG_SHAPING  = 3'b011;
    localparam logic [2:0] CFG_DEBUG_ALL      = 3'b100;

endpackage : msk_pkg