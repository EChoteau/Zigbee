module top #(
    // Wrapper bus widths
    parameter int BUS_A_WIDTH     = 12,
    parameter int BUS_B_WIDTH     = 10,
    parameter int BUS_C_WIDTH     = 12,
    parameter int BUS_D_WIDTH     = 2,
    parameter int TOP_CFG_WIDTH   = 3,
    parameter int WRP_CFG_WIDTH   = 3
)(
    input  logic         i_clk,
    input  logic         i_rst_n,

    // 6 dedicated configuration pins:
    // [2:0]  : Wrapper selector (0=IF, 1=CDR, 2=Cordic, 3=Demod, 4=MSK)
    // [5:3]  : Internal test config for selected wrapper
    input logic [TOP_CFG_WIDTH-1:0]   i_top_cfg,
    input logic [WRP_CFG_WIDTH-1:0]   i_wrapper_cfg,

    // Test bus ports (external interface)
    input  logic [BUS_A_WIDTH-1:0] i_bus_a,  // Test input bus A
    input  logic [BUS_B_WIDTH-1:0] i_bus_b,  // Test input bus B
    output logic [BUS_C_WIDTH-1:0] o_bus_c,  // Test output bus C
    output logic [BUS_D_WIDTH-1:0] o_bus_d,  // Test output bus D
);

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
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH),
        .CFG_WIDTH(WRP_CFG_WIDTH)
    ) u_if_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg_local(i_wrapper_cfg),
        .i_bus_a(if_wr_i_bus_a),
        .i_bus_b(if_wr_i_bus_b),
        .o_bus_c(if_wr_o_bus_c),
        .o_bus_d(if_wr_o_bus_d)
    );

    // CDR Wrapper
    cdr_wrapper #(
        .CFG_WIDTH(WRP_CFG_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH)
    ) u_cdr_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_wrapper_cfg),
        .i_bus_a(cdr_wr_i_bus_a),
        .i_bus_b(cdr_wr_i_bus_b),
        .o_bus_c(cdr_wr_o_bus_c),
        .o_bus_d(cdr_wr_o_bus_d)
    );

    // Cordic Wrapper
    cordic_wrapper #(
        .CFG_WIDTH(WRP_CFG_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH)
    ) u_cordic_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_wrapper_cfg),
        .i_bus_a(cordic_wr_i_bus_a),
        .i_bus_b(cordic_wr_i_bus_b),
        .o_bus_c(cordic_wr_o_bus_c),
        .o_bus_d(cordic_wr_o_bus_d)
    );

    // Demod Wrapper
    demod_wrapper #(
        .CFG_WIDTH(WRP_CFG_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH)
    ) u_demod_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_wrapper_cfg),
        .i_bus_a(demod_wr_i_bus_a),
        .i_bus_b(demod_wr_i_bus_b),
        .o_bus_c(demod_wr_o_bus_c),
        .o_bus_d(demod_wr_o_bus_d)
    );

    // MSK Wrapper
    msk_test_wrapper #(
        .CFG_WIDTH(WRP_CFG_WIDTH),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH)
    ) u_msk_wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_wrapper_cfg),
        .i_bus_a(msk_wr_i_bus_a),
        .i_bus_b(msk_wr_i_bus_b),
        .o_bus_c(msk_wr_o_bus_c),
        .o_bus_d(msk_wr_o_bus_d)
    );

    assign if_wr_i_bus_a      = i_bus_a;
    assign if_wr_i_bus_b      = i_bus_b;
    assign cdr_wr_i_bus_a     = i_bus_a;
    assign cdr_wr_i_bus_b     = i_bus_b;
    assign cordic_wr_i_bus_a  = i_bus_a;
    assign cordic_wr_i_bus_b  = i_bus_b;
    assign demod_wr_i_bus_a   = i_bus_a;
    assign demod_wr_i_bus_b   = i_bus_b;
    assign msk_wr_i_bus_a     = i_bus_a;
    assign msk_wr_i_bus_b     = i_bus_b;

    // =========================================================================
    // Output bus multiplexer (selects which wrapper output to route to pads)
    // =========================================================================
    always_comb begin
        unique case (w_wrapper_select)
            3'b000: begin  // Interface Wrapper
                o_bus_c = if_wr_o_bus_c;
                o_bus_d = if_wr_o_bus_d;
            end
            3'b001: begin  // CDR Wrapper
                o_bus_c = cdr_wr_o_bus_c;
                o_bus_d = cdr_wr_o_bus_d;
            end
            3'b010: begin  // Cordic Wrapper
                o_bus_c = cordic_wr_o_bus_c;
                o_bus_d = cordic_wr_o_bus_d;
            end
            3'b011: begin  // Demod Wrapper
                o_bus_c = demod_wr_o_bus_c;
                o_bus_d = demod_wr_o_bus_d;
            end
            3'b100: begin  // MSK Wrapper
                o_bus_c = msk_wr_o_bus_c;
                o_bus_d = msk_wr_o_bus_d;
            end
            default: begin
                o_bus_c = '0;
                o_bus_d = '0;
            end
        endcase
    end
endmodule
