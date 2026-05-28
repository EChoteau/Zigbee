package cdr_pkg;

    import tb_pkg::*;

    localparam logic [2:0] TOP_CFG_CDR = 3'd7;

    localparam logic [2:0] CFG_NORMAL         = 3'b000;
    localparam logic [2:0] CFG_DEBUG_DECISION = 3'b001;
    localparam logic [2:0] CFG_DEBUG_PD       = 3'b010;
    localparam logic [2:0] CFG_DEBUG_LF       = 3'b011;
    localparam logic [2:0] CFG_DEBUG_NCO      = 3'b100;

endpackage : cdr_pkg