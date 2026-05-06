////////////////////////////////////////////////////////////////////////////////
// tb_pkg.sv
// ============================================================================
// SystemVerilog package for testbench constants and parameters
////////////////////////////////////////////////////////////////////////////////

package tb_pkg;

    // ==========================================================================
    // INTERFACE WRAPPER PARAMETERS
    // ==========================================================================
    localparam int APB_ADDR_WIDTH = 8;
    localparam int APB_DATA_WIDTH = 8;
    localparam int DATA_WIDTH     = 8;
    localparam int FIFO_DEPTH     = 8;
    localparam int DIV_WIDTH      = 8;

    // ==========================================================================
    // APB REGISTER ADDRESSES
    // ==========================================================================
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DATA    = 8'h00;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_STATUS  = 8'h04;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_CONTROL = 8'h08;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DIVIDER = 8'h0C;

endpackage
