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
    output logic [BUS_D_WIDTH-1:0] o_bus_d  // Test output bus D
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

    // Routing block implementing top configurations:
    // Modes requested by user:
    // 0: RX   (Demod -> Cordic -> CDR -> Interface)
    // 1: TX   (Interface -> MSK)
    // 2: IF
    // 3: MSK
    // 4: DEMOD
    // 5: CORDIC
    // 6: CDR
    // 7: MSK -> CORDIC -> CDR
    always_comb begin
        // Default: clear all wrapper inputs
        if_wr_i_bus_a     = '0;
        if_wr_i_bus_b     = '0;
        cdr_wr_i_bus_a    = '0;
        cdr_wr_i_bus_b    = '0;
        cordic_wr_i_bus_a = '0;
        cordic_wr_i_bus_b = '0;
        demod_wr_i_bus_a  = '0;
        demod_wr_i_bus_b  = '0;
        msk_wr_i_bus_a    = '0;
        msk_wr_i_bus_b    = '0;

        // Default pad outputs
        o_bus_c = '0;
        o_bus_d = '0;

        unique case (i_top_cfg)
            // 0: RX chain: Demod -> Cordic -> CDR -> Interface -> pads
            3'd0: begin
                // Demod gets bus B input
                demod_wr_i_bus_a  = '0;
                demod_wr_i_bus_b  = i_bus_b;

                // Cordic input A from Demod Bus C
                cordic_wr_i_bus_a = demod_wr_o_bus_c;
                cordic_wr_i_bus_b = '0;

                // CDR gets cordic Bus C into its Bus B (truncate)
                cdr_wr_i_bus_a    = '0;
                cdr_wr_i_bus_b    = cordic_wr_o_bus_c[BUS_B_WIDTH-1:0];

                // Interface observes CDR outputs and is driven by external bus A
                if_wr_i_bus_a     = i_bus_a;
                if_wr_i_bus_b     = cdr_wr_o_bus_c;

                // Drive pads from Interface
                o_bus_c = if_wr_o_bus_c;
                o_bus_d = if_wr_o_bus_d;
            end

            // 1: TX: Interface drives MSK, pads observe MSK outputs
            3'd1: begin
                // Interface receives external controls
                if_wr_i_bus_a = i_bus_a;
                if_wr_i_bus_b = i_bus_b;

                // MSK input comes from Interface outputs
                msk_wr_i_bus_a = '0;
                msk_wr_i_bus_b = if_wr_o_bus_c[BUS_B_WIDTH-1:0]; // Use part of IF output bus

                // Pads observe MSK
                o_bus_c = msk_wr_o_bus_c;
                o_bus_d = msk_wr_o_bus_d;
            end

            // 2: Interface only
            3'd2: begin
                if_wr_i_bus_a = i_bus_a;
                if_wr_i_bus_b = i_bus_b;
                o_bus_c = if_wr_o_bus_c;
                o_bus_d = if_wr_o_bus_d;
            end

            // 3: MSK only
            3'd3: begin
                msk_wr_i_bus_a = '0;
                msk_wr_i_bus_b = i_bus_b;
                o_bus_c = msk_wr_o_bus_c;
                o_bus_d = msk_wr_o_bus_d;
            end

            // 4: Demod only
            3'd4: begin
                demod_wr_i_bus_a = '0;
                demod_wr_i_bus_b = i_bus_b;
                o_bus_c = demod_wr_o_bus_c;
                o_bus_d = demod_wr_o_bus_d;
            end

            // 5: Cordic only
            3'd5: begin
                cordic_wr_i_bus_a = i_bus_a;
                cordic_wr_i_bus_b = '0;
                o_bus_c = cordic_wr_o_bus_c;
                o_bus_d = cordic_wr_o_bus_d;
            end

            // 6: CDR only
            3'd6: begin
                cdr_wr_i_bus_a = '0;
                cdr_wr_i_bus_b = i_bus_b;
                o_bus_c = cdr_wr_o_bus_c;
                o_bus_d = cdr_wr_o_bus_d;
            end

            // 7: MSK -> Cordic -> CDR chain, pads observe CDR
            3'd7: begin
                // MSK driven by external inputs
                msk_wr_i_bus_a = '0;
                msk_wr_i_bus_b = i_bus_b;

                // Cordic A from MSK Bus C
                cordic_wr_i_bus_a = msk_wr_o_bus_c;
                cordic_wr_i_bus_b = '0;

                // CDR Bus B from Cordic Bus C (truncated)
                cdr_wr_i_bus_a = '0;
                cdr_wr_i_bus_b = cordic_wr_o_bus_c[BUS_B_WIDTH-1:0];

                // Pads observe CDR outputs
                o_bus_c = cdr_wr_o_bus_c;
                o_bus_d = cdr_wr_o_bus_d;
            end

            default: begin
                // leave defaults (all zeros)
            end
        endcase
    end
endmodule
