package interface_pkg;

    // =========================================================================
    // INTERFACE MODULE PARAMETERS
    // =========================================================================
    localparam int APB_ADDR_WIDTH = 8;
    localparam int APB_DATA_WIDTH = 8;
    localparam int DATA_WIDTH     = 8;
    localparam int FIFO_DEPTH     = 8;
    localparam int DIV_WIDTH      = 8;

    // =========================================================================
    // APB REGISTER ADDRESSES
    // =========================================================================
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DATA    = 8'h00;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_STATUS  = 8'h04;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_CONTROL = 8'h08;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DIVIDER = 8'h0C;

    // =========================================================================
    // BUS MAPPING (based on interface_wrapper.sv)
    // For CFG_RX_ONLY/CFG_TX_ONLY/CFG_LOOPBACK:
    //   IN[2:0]     = psel, penable, pwrite
    //   IN[10:3]    = paddr[7:0]
    //   IN[18:11]   = pwdata[7:0]
    //   IN[19]      = serial_rx (RX path)
    //   IN[20]      = cdr_sample_valid (RX path)
    // =========================================================================
    // Bus input bit positions (for clarity in test headers)
    localparam int BUS_PWRITE_BIT      = 0;
    localparam int BUS_PENABLE_BIT     = 1;
    localparam int BUS_PSEL_BIT        = 2;
    localparam int BUS_PADDR_MSB       = 10;
    localparam int BUS_PADDR_LSB       = 3;
    localparam int BUS_PWDATA_MSB      = 18;
    localparam int BUS_PWDATA_LSB      = 11;
    localparam int BUS_SERIAL_RX_BIT   = 19;
    localparam int BUS_CDR_SAMPLE_BIT  = 20;

    // Bus output bits (for CFG_RX_ONLY)
    localparam int BUS_OUT_PRDATA_MSB  = 7;
    localparam int BUS_OUT_PRDATA_LSB  = 0;
    localparam int BUS_OUT_RX_FIFO_FULL_BIT  = 8;
    localparam int BUS_OUT_RX_FIFO_EMPTY_BIT = 9;
    localparam int BUS_OUT_DES_PUSH_BIT      = 10;
    localparam int BUS_OUT_RX_FIFO_POP_BIT   = 11;

endpackage
