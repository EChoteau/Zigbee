package cordic_pkg;

    import tb_pkg::*;

    localparam logic [2:0] TOP_CFG_CORDIC = 3'd6;

    localparam logic [2:0] MODE_0_NORMAL        = 3'b000;
    localparam logic [2:0] MODE_1_CORDIC_ONLY   = 3'b001;
    localparam logic [2:0] MODE_2_DERIV_ONLY    = 3'b010;
    localparam logic [2:0] MODE_3_FILTER_ONLY   = 3'b011;
    localparam logic [2:0] MODE_4_CORDIC_DERIV  = 3'b100;
    localparam logic [2:0] MODE_5_FULL_CHAIN    = 3'b101;

endpackage : cordic_pkg
