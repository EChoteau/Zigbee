module zigbee_chip_top #(
    parameter int APB_ADDR_WIDTH  = 8,
    parameter int APB_DATA_WIDTH  = 32,
    parameter int IF_DATA_WIDTH   = 8,
    parameter int IF_FIFO_DEPTH   = 8,
    parameter int IF_DIV_WIDTH    = 8,
    parameter int CORDIC_WIDTH_IN = 8
)(
    input  logic         i_clk,
    input  logic         i_rst_n,

    // 4 dedicated configuration pins (outside the configurable IO bank).
    input  logic [3:0]   i_cfg_mode_pins,

    // 38 configurable bidirectional physical digital pins.
    inout  wire  [37:0]  io_pad
);

    import zigbee_top_cfg_pkg::*;

    // ---------------------------------------------------------------------
    // Mode decode
    // ---------------------------------------------------------------------
    logic [1:0] w_cfg_mode;
    assign w_cfg_mode = i_cfg_mode_pins[1:0];

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

    // ---------------------------------------------------------------------
    // Internal logical variables (block-facing signals)
    // ---------------------------------------------------------------------
    logic                        v_if_psel;
    logic                        v_if_penable;
    logic                        v_if_pwrite;
    logic [APB_ADDR_WIDTH-1:0]   v_if_paddr;
    logic [APB_DATA_WIDTH-1:0]   v_if_pwdata;
    logic [APB_DATA_WIDTH-1:0]   v_if_prdata;
    logic                        v_if_pready;
    logic                        v_if_pslverr;
    logic                        v_if_serial_rx;
    logic                        v_if_cdr_sample_valid;
    logic                        v_if_serial_tx;
    logic                        v_if_tx_valid;
    logic                        v_if_tx_sample_tick;

    logic                        v_msk_enable_ech;
    logic                        v_msk_b_in;
    logic                        v_msk_flag_enable;
    logic signed [5:0]           w_msk_i_bb;
    logic signed [5:0]           w_msk_q_bb;

    logic signed [CORDIC_WIDTH_IN-1:0] v_cordic_i;
    logic signed [CORDIC_WIDTH_IN-1:0] v_cordic_q;
    logic signed [CORDIC_WIDTH_IN+1:0] w_cordic_phase;

    logic                      if_only_if_psel;
    logic                      if_only_if_penable;
    logic                      if_only_if_pwrite;
    logic [APB_ADDR_WIDTH-1:0] if_only_if_paddr;
    logic [APB_DATA_WIDTH-1:0] if_only_if_pwdata;
    logic                      if_only_if_serial_rx;
    logic                      if_only_if_cdr_sample_valid;
    logic [37:0]               if_only_io_out;
    logic [37:0]               if_only_io_oe;

    logic                      msk_only_msk_b_in;
    logic                      msk_only_msk_flag_enable;
    logic                      msk_only_msk_enable_ech;
    logic [37:0]               msk_only_io_out;
    logic [37:0]               msk_only_io_oe;

    logic signed [CORDIC_WIDTH_IN-1:0] cordic_only_i;
    logic signed [CORDIC_WIDTH_IN-1:0] cordic_only_q;
    logic [37:0]                         cordic_only_io_out;
    logic [37:0]                         cordic_only_io_oe;

    // ---------------------------------------------------------------------
    // Block instances
    // ---------------------------------------------------------------------
    interface_top #(
        .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
        .APB_DATA_WIDTH(APB_DATA_WIDTH),
        .DATA_WIDTH(IF_DATA_WIDTH),
        .FIFO_DEPTH(IF_FIFO_DEPTH),
        .DIV_WIDTH(IF_DIV_WIDTH)
    ) u_interface_top (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_psel(v_if_psel),
        .i_penable(v_if_penable),
        .i_pwrite(v_if_pwrite),
        .i_paddr(v_if_paddr),
        .i_pwdata(v_if_pwdata),
        .o_prdata(v_if_prdata),
        .o_pready(v_if_pready),
        .o_pslverr(v_if_pslverr),
        .i_serial_rx(v_if_serial_rx),
        .i_cdr_sample_valid(v_if_cdr_sample_valid),
        .o_serial_tx(v_if_serial_tx),
        .o_tx_valid(v_if_tx_valid),
        .o_tx_sample_tick(v_if_tx_sample_tick)
    );

    msk_system u_top_msk (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flag_enable(v_msk_flag_enable),
        .i_enable_ech(v_msk_enable_ech),
        .i_b_in(v_msk_b_in),
        .o_I_BB(w_msk_i_bb),
        .o_Q_BB(w_msk_q_bb)
    );

    // Kept instantiated but not connected to the integration chain yet.
    cordic_top #(
        .WIDTH_IN(CORDIC_WIDTH_IN)
    ) u_cordic_top (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_i(v_cordic_i),
        .i_q(v_cordic_q),
        .o_phase(w_cordic_phase)
    );

    // ---------------------------------------------------------------------
    // Per-configuration I/O mapping modules
    // ---------------------------------------------------------------------
    zigbee_io_cfg_if_only #(
        .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
        .APB_DATA_WIDTH(APB_DATA_WIDTH)
    ) u_cfg_if_only (
        .i_io_in(i_io_in),
        .i_if_serial_tx(v_if_serial_tx),
        .i_if_tx_valid(v_if_tx_valid),
        .i_if_tx_sample_tick(v_if_tx_sample_tick),
        .i_if_prdata(v_if_prdata),
        .i_if_pready(v_if_pready),
        .i_if_pslverr(v_if_pslverr),
        .o_if_psel(if_only_if_psel),
        .o_if_penable(if_only_if_penable),
        .o_if_pwrite(if_only_if_pwrite),
        .o_if_paddr(if_only_if_paddr),
        .o_if_pwdata(if_only_if_pwdata),
        .o_if_serial_rx(if_only_if_serial_rx),
        .o_if_cdr_sample_valid(if_only_if_cdr_sample_valid),
        .o_io_out(if_only_io_out),
        .o_io_oe(if_only_io_oe)
    );

    zigbee_io_cfg_msk_only u_cfg_msk_only (
        .i_io_in(i_io_in),
        .i_msk_i_bb(w_msk_i_bb),
        .i_msk_q_bb(w_msk_q_bb),
        .o_msk_b_in(msk_only_msk_b_in),
        .o_msk_flag_enable(msk_only_msk_flag_enable),
        .o_msk_enable_ech(msk_only_msk_enable_ech),
        .o_io_out(msk_only_io_out),
        .o_io_oe(msk_only_io_oe)
    );

    zigbee_io_cfg_cordic_only #(
        .CORDIC_WIDTH_IN(CORDIC_WIDTH_IN)
    ) u_cfg_cordic_only (
        .i_io_in(i_io_in),
        .i_cordic_phase(w_cordic_phase),
        .o_cordic_i(cordic_only_i),
        .o_cordic_q(cordic_only_q),
        .o_io_out(cordic_only_io_out),
        .o_io_oe(cordic_only_io_oe)
    );

    // ---------------------------------------------------------------------
    // Runtime selector for active configuration
    always_comb begin
        v_if_psel             = if_only_if_psel;
        v_if_penable          = if_only_if_penable;
        v_if_pwrite           = if_only_if_pwrite;
        v_if_paddr            = if_only_if_paddr;
        v_if_pwdata           = if_only_if_pwdata;
        v_if_serial_rx        = if_only_if_serial_rx;
        v_if_cdr_sample_valid = if_only_if_cdr_sample_valid;
        v_msk_b_in            = 1'b0;
        v_msk_flag_enable     = 1'b0;
        v_msk_enable_ech      = 1'b0;
        v_cordic_i            = '0;
        v_cordic_q            = '0;

        o_io_out              = if_only_io_out;
        o_io_oe               = if_only_io_oe;

        unique case (zigbee_cfg_mode_e'(w_cfg_mode))
            CFG_IF_ONLY: begin
                v_if_psel             = if_only_if_psel;
                v_if_penable          = if_only_if_penable;
                v_if_pwrite           = if_only_if_pwrite;
                v_if_paddr            = if_only_if_paddr;
                v_if_pwdata           = if_only_if_pwdata;
                v_if_serial_rx        = if_only_if_serial_rx;
                v_if_cdr_sample_valid = if_only_if_cdr_sample_valid;
                v_msk_b_in            = 1'b0;
                v_msk_flag_enable     = 1'b0;
                v_msk_enable_ech      = 1'b0;
                v_cordic_i            = '0;
                v_cordic_q            = '0;
                o_io_out              = if_only_io_out;
                o_io_oe               = if_only_io_oe;
            end

            CFG_MSK_ONLY: begin
                v_if_psel             = 1'b0;
                v_if_penable          = 1'b0;
                v_if_pwrite           = 1'b0;
                v_if_paddr            = '0;
                v_if_pwdata           = '0;
                v_if_serial_rx        = 1'b0;
                v_if_cdr_sample_valid = 1'b0;
                v_msk_b_in            = msk_only_msk_b_in;
                v_msk_flag_enable     = msk_only_msk_flag_enable;
                v_msk_enable_ech      = msk_only_msk_enable_ech;
                v_cordic_i            = '0;
                v_cordic_q            = '0;
                o_io_out              = msk_only_io_out;
                o_io_oe               = msk_only_io_oe;
            end

            CFG_CORDIC_ONLY: begin
                v_if_psel             = 1'b0;
                v_if_penable          = 1'b0;
                v_if_pwrite           = 1'b0;
                v_if_paddr            = '0;
                v_if_pwdata           = '0;
                v_if_serial_rx        = 1'b0;
                v_if_cdr_sample_valid = 1'b0;
                v_msk_b_in            = 1'b0;
                v_msk_flag_enable     = 1'b0;
                v_msk_enable_ech      = 1'b0;
                v_cordic_i            = cordic_only_i;
                v_cordic_q            = cordic_only_q;
                o_io_out              = cordic_only_io_out;
                o_io_oe               = cordic_only_io_oe;
            end

            default: begin
                v_if_psel             = if_only_if_psel;
                v_if_penable          = if_only_if_penable;
                v_if_pwrite           = if_only_if_pwrite;
                v_if_paddr            = if_only_if_paddr;
                v_if_pwdata           = if_only_if_pwdata;
                v_if_serial_rx        = if_only_if_serial_rx;
                v_if_cdr_sample_valid = if_only_if_cdr_sample_valid;
                v_msk_b_in            = 1'b0;
                v_msk_flag_enable     = 1'b0;
                v_msk_enable_ech      = 1'b0;
                v_cordic_i            = '0;
                v_cordic_q            = '0;
                o_io_out              = if_only_io_out;
                o_io_oe               = if_only_io_oe;
            end
        endcase
    end

endmodule
