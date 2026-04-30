module zigbee_chip_top #(
    parameter int APB_ADDR_WIDTH  = 8,
    parameter int APB_DATA_WIDTH  = 32,
    parameter int IF_DATA_WIDTH   = 8,
    parameter int IF_FIFO_DEPTH   = 8,
    parameter int IF_DIV_WIDTH    = 8,
    parameter int CORDIC_WIDTH_IN = 8,
    // Wrapper bus widths
    parameter int BUS_A_WIDTH     = 12,
    parameter int BUS_B_WIDTH     = 12,
    parameter int BUS_C_WIDTH     = 12,
    parameter int BUS_D_WIDTH     = 2,
    parameter int CFG_WIDTH       = 3
)(
    input  logic         i_clk,
    input  logic         i_rst_n,

    // 6 dedicated configuration pins:
    // [2:0]  : Wrapper selector (0=IF, 1=CDR, 2=Cordic, 3=Demod, 4=MSK)
    // [5:3]  : Internal test config for selected wrapper
    input  logic [5:0]   i_cfg_pins,

    // Test bus ports (external interface)
    input  logic [BUS_A_WIDTH-1:0] i_bus_a,  // Test input bus A
    input  logic [BUS_B_WIDTH-1:0] i_bus_b,  // Test input bus B
    output logic [BUS_C_WIDTH-1:0] o_bus_c,  // Test output bus C
    output logic [BUS_D_WIDTH-1:0] o_bus_d,  // Test output bus D

    // 38 configurable bidirectional physical digital pins.
    inout  wire  [37:0]  io_pad
);

    // =========================================================================
    // Configuration decoder
    // =========================================================================
    logic [CFG_WIDTH-1:0] w_wrapper_select;
    logic [CFG_WIDTH-1:0] w_cfg_internal;
    
    assign w_wrapper_select = i_cfg_pins[CFG_WIDTH-1:0];
    assign w_cfg_internal   = i_cfg_pins[5:3];

    // =========================================================================
    // Pad mapping
    // =========================================================================
    logic [37:0] i_io_in;
    logic [37:0] o_io_out;
    logic [37:0] o_io_oe;

    genvar pad_i;
    generate
        for (pad_i = 0; pad_i < 38; pad_i = pad_i + 1) begin : gen_io_pad
            assign io_pad[pad_i] = o_io_oe[pad_i] ? o_io_out[pad_i] : 1'bz;
            assign i_io_in[pad_i] = io_pad[pad_i];
        end
    endgenerate

    // =========================================================================
    // Wrapper instance signals
    // =========================================================================
    // Interface wrapper
    logic [BUS_A_WIDTH-1:0] if_wr_i_bus_a;
    logic [BUS_B_WIDTH-1:0] if_wr_i_bus_b;
    logic [BUS_C_WIDTH-1:0] if_wr_o_bus_c;
    logic [BUS_D_WIDTH-1:0] if_wr_o_bus_d;

    // CDR wrapper
    logic [BUS_A_WIDTH-1:0] cdr_wr_i_bus_a;
    logic [BUS_B_WIDTH-1:0] cdr_wr_i_bus_b;
    logic [BUS_C_WIDTH-1:0] cdr_wr_o_bus_c;
    logic [BUS_D_WIDTH-1:0] cdr_wr_o_bus_d;

    // Cordic wrapper
    logic [BUS_A_WIDTH-1:0] cordic_wr_i_bus_a;
    logic [BUS_B_WIDTH-1:0] cordic_wr_i_bus_b;
    logic [BUS_C_WIDTH-1:0] cordic_wr_o_bus_c;
    logic [BUS_D_WIDTH-1:0] cordic_wr_o_bus_d;

    // Demod wrapper
    logic [BUS_A_WIDTH-1:0] demod_wr_i_bus_a;
    logic [BUS_B_WIDTH-1:0] demod_wr_i_bus_b;
    logic [BUS_C_WIDTH-1:0] demod_wr_o_bus_c;
    logic [BUS_D_WIDTH-1:0] demod_wr_o_bus_d;

    // MSK wrapper
    logic [BUS_A_WIDTH-1:0] msk_wr_i_bus_a;
    logic [BUS_B_WIDTH-1:0] msk_wr_i_bus_b;
    logic [BUS_C_WIDTH-1:0] msk_wr_o_bus_c;
    logic [BUS_D_WIDTH-1:0] msk_wr_o_bus_d;

    // Mux outputs
    logic [BUS_A_WIDTH-1:0] mux_i_bus_a;
    logic [BUS_B_WIDTH-1:0] mux_i_bus_b;
    logic [BUS_C_WIDTH-1:0] mux_o_bus_c;
    logic [BUS_D_WIDTH-1:0] mux_o_bus_d;

    // =========================================================================
    // Wrapper instantiations
    // =========================================================================

    // Interface Wrapper
    interface_wrapper #(
        .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
        .APB_DATA_WIDTH(APB_DATA_WIDTH),
        .DATA_WIDTH(IF_DATA_WIDTH),
        .FIFO_DEPTH(IF_FIFO_DEPTH),
        .DIV_WIDTH(IF_DIV_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH),
        .CFG_WIDTH(CFG_WIDTH)
    ) u_if_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg_local(w_cfg_internal),
        .i_bus_a(if_wr_i_bus_a),
        .i_bus_b(if_wr_i_bus_b),
        .o_bus_c(if_wr_o_bus_c),
        .o_bus_d(if_wr_o_bus_d)
    );

    // CDR Wrapper
    cdr_wrapper #(
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH)
    ) u_cdr_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(w_cfg_internal),
        .i_bus_a(cdr_wr_i_bus_a),
        .i_bus_b(cdr_wr_i_bus_b),
        .o_bus_c(cdr_wr_o_bus_c),
        .o_bus_d(cdr_wr_o_bus_d)
    );

    // Cordic Wrapper
    cordic_wrapper #(
        .WIDTH_IN(CORDIC_WIDTH_IN),
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH)
    ) u_cordic_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(w_cfg_internal),
        .i_bus_a(cordic_wr_i_bus_a),
        .i_bus_b(cordic_wr_i_bus_b),
        .o_bus_c(cordic_wr_o_bus_c),
        .o_bus_d(cordic_wr_o_bus_d)
    );

    // Demod Wrapper
    demod_wrapper #(
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH)
    ) u_demod_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(w_cfg_internal),
        .i_bus_a(demod_wr_i_bus_a),
        .i_bus_b(demod_wr_i_bus_b),
        .o_bus_c(demod_wr_o_bus_c),
        .o_bus_d(demod_wr_o_bus_d)
    );

    // MSK Wrapper
    msk_test_wrapper #(
        .SAMPLES_PER_HALF_SINE(10),
        .MSK_RES(6),
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH)
    ) u_msk_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(w_cfg_internal),
        .i_flag_enable(1'b0),  // TODO: connect from pads if needed
        .i_enable_ech(1'b0),   // TODO: connect from pads if needed
        .i_b_in(1'b0),         // TODO: connect from pads if needed
        .o_I_BB(),             // Not used in test mode
        .o_Q_BB(),             // Not used in test mode
        .io_bus_a(msk_wr_i_bus_a[BUS_A_WIDTH-1:0]),
        .o_bus_b(msk_wr_i_bus_b[BUS_B_WIDTH-1:0]),
        .o_bus_c(msk_wr_o_bus_c),
        .o_bus_d(msk_wr_o_bus_d)
    );

    // =========================================================================
    // Input bus routing (from external ports and pads)
    // =========================================================================
    // Buses can come from either external test ports or from io_pads
    // For test mode, we use the external ports; for normal operation, we can use pads
    
    assign mux_i_bus_a = i_bus_a;
    assign mux_i_bus_b = i_bus_b;

    // Route to all wrappers (they always get the same input)
    assign if_wr_i_bus_a      = mux_i_bus_a;
    assign if_wr_i_bus_b      = mux_i_bus_b;
    assign cdr_wr_i_bus_a     = mux_i_bus_a;
    assign cdr_wr_i_bus_b     = mux_i_bus_b;
    assign cordic_wr_i_bus_a  = mux_i_bus_a;
    assign cordic_wr_i_bus_b  = mux_i_bus_b;
    assign demod_wr_i_bus_a   = mux_i_bus_a;
    assign demod_wr_i_bus_b   = mux_i_bus_b;
    assign msk_wr_i_bus_a     = mux_i_bus_a;
    assign msk_wr_i_bus_b     = mux_i_bus_b;

    // =========================================================================
    // Output bus multiplexer (selects which wrapper output to route to pads)
    // =========================================================================
    always_comb begin
        mux_o_bus_c = '0;
        mux_o_bus_d = '0;

        unique case (w_wrapper_select)
            3'b000: begin  // Interface Wrapper
                mux_o_bus_c = if_wr_o_bus_c;
                mux_o_bus_d = if_wr_o_bus_d;
            end
            3'b001: begin  // CDR Wrapper
                mux_o_bus_c = cdr_wr_o_bus_c;
                mux_o_bus_d = cdr_wr_o_bus_d;
            end
            3'b010: begin  // Cordic Wrapper
                mux_o_bus_c = cordic_wr_o_bus_c;
                mux_o_bus_d = cordic_wr_o_bus_d;
            end
            3'b011: begin  // Demod Wrapper
                mux_o_bus_c = demod_wr_o_bus_c;
                mux_o_bus_d = demod_wr_o_bus_d;
            end
            3'b100: begin  // MSK Wrapper
                mux_o_bus_c = msk_wr_o_bus_c;
                mux_o_bus_d = msk_wr_o_bus_d;
            end
            default: begin
                mux_o_bus_c = '0;
                mux_o_bus_d = '0;
            end
        endcase
    end

    // =========================================================================
    // Output bus routing (external ports)
    // =========================================================================
    // Route selected wrapper outputs to external test bus ports
    assign o_bus_c = mux_o_bus_c;
    assign o_bus_d = mux_o_bus_d;

    // Also route to pads for direct physical access
    assign o_io_out[35:24] = mux_o_bus_c;
    assign o_io_out[37:36] = mux_o_bus_d;
    assign o_io_out[23:0]  = '0;  // Lower pads are inputs only
    
    assign o_io_oe = '0;  // All pads are in high-impedance (tristate)

endmodule
