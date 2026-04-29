module interface_wrapper #(
    parameter int APB_ADDR_WIDTH = 8,
    parameter int APB_DATA_WIDTH = 8,
    parameter int DATA_WIDTH     = 8,
    parameter int FIFO_DEPTH     = 8,
    parameter int DIV_WIDTH      = 8,
    parameter int BUS_A_WIDTH = 10,
    parameter int BUS_B_WIDTH = 12,
    parameter int BUS_C_WIDTH = 12,
    parameter int BUS_D_WIDTH = 2,
    parameter int CFG_WIDTH  = 3      // Configuration selector width
)(
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg_local,
    input  logic [BUS_A_WIDTH-1:0] i_bus_a,
    input  logic [BUS_B_WIDTH-1:0] i_bus_b,
    output logic [BUS_C_WIDTH-1:0] o_bus_c,
    output logic [BUS_D_WIDTH-1:0] o_bus_d
);

    // ==========================================================================
    // Configuration modes: select which internal signals are routed to i_test_in
    // and which debug outputs are routed to o_test_out
    // ==========================================================================
    localparam logic [2:0] CFG_CLASSIC   = 3'b000;  // APB + serial loopback
    localparam logic [2:0] CFG_TX_ONLY   = 3'b001;  // TX path with FIFO control
    localparam logic [2:0] CFG_RX_ONLY   = 3'b010;  // RX path with FIFO control
    localparam logic [2:0] CFG_LOOPBACK  = 3'b011;  // Serializer output looped to deserializer input
    localparam logic [2:0] CFG_FIFO_TX   = 3'b100;  // Direct TX FIFO control
    localparam logic [2:0] CFG_FIFO_RX   = 3'b101;  // Direct RX FIFO control
    localparam logic [2:0] CFG_SERDES    = 3'b110;  // Serializer/deserializer chain testing
    localparam logic [2:0] CFG_BAUD      = 3'b111;  // Baud rate generator control

    // ==========================================================================
    // SHARED CONTROL SIGNALS (used across all configs)
    // ==========================================================================
    logic                       s_if_psel;
    logic                       s_if_penable;
    logic                       s_if_pwrite;
    logic [APB_ADDR_WIDTH-1:0]  s_if_paddr;
    logic [APB_DATA_WIDTH-1:0]  s_if_pwdata;
    logic [APB_DATA_WIDTH-1:0]  s_if_prdata;
    logic                       s_if_pready;
    logic                       s_if_pslverr;
    
    logic                       s_if_serial_rx;
    logic                       s_if_cdr_sample_valid;
    logic                       s_if_serial_tx;
    logic                       s_if_tx_valid;
    logic                       s_if_tx_sample_tick;

    // ==========================================================================
    // CFG_TX_ONLY, CFG_RX_ONLY, CFG_LOOPBACK, CFG_FIFO_TX, CFG_FIFO_RX
    // Debug outputs: TX & RX FIFO observability + Control status
    // ==========================================================================
    logic [DATA_WIDTH-1:0]      s_dbg_tx_fifo_q;
    logic                       s_dbg_tx_fifo_push;
    logic                       s_dbg_tx_fifo_pop;
    logic                       s_dbg_tx_fifo_full;
    logic                       s_dbg_tx_fifo_empty;
    logic                       s_dbg_tx_fifo_rd_valid;

    logic [DATA_WIDTH-1:0]      s_dbg_rx_fifo_q;
    logic                       s_dbg_rx_fifo_pop;
    logic                       s_dbg_rx_fifo_full;
    logic                       s_dbg_rx_fifo_empty;

    logic                       s_dbg_tx_tick;
    logic                       s_dbg_tx_path_en;
    logic                       s_dbg_global_en;
    logic                       s_dbg_tx_und_err;
    logic                       s_dbg_rx_ovf_err;

    // ==========================================================================
    // CFG_SERDES: Serializer/Deserializer chain testing
    // Override controls + chain outputs
    // ==========================================================================
    logic                       s_if_ser_override_en;
    logic [DATA_WIDTH-1:0]      s_if_ser_tx_data;
    logic                       s_if_ser_tx_data_valid;
    logic                       s_if_ser_tx_fifo_empty;
    logic                       s_if_ser_baud_tick;
    logic                       s_dbg_ser_o_tx_busy;

    logic [DATA_WIDTH-1:0]      s_dbg_des_o_para_data;
    logic                       s_dbg_des_o_push;
    logic                       s_dbg_des_o_ovf_pulse;

    // ==========================================================================
    // CFG_BAUD: Baud rate generator control
    // Override enable + divisor value
    // ==========================================================================
    logic                       s_if_baud_override_en;
    logic                       s_if_baud_enable;
    logic [DIV_WIDTH-1:0]       s_if_baud_div_val;

    // ==========================================================================
    // DESERIALIZER, FIFO_TX, FIFO_RX override inputs (tied to 0 in non-debug)
    // ==========================================================================
    logic                       s_if_des_override_en;
    logic                       s_if_des_serial_data;
    logic                       s_if_des_sample_valid;
    logic                       s_if_des_enable;
    logic                       s_if_des_fifo_full;
    
    logic                       s_if_fifo_tx_override_en;
    logic                       s_if_fifo_tx_wr_en;
    logic [DATA_WIDTH-1:0]      s_if_fifo_tx_data;
    logic                       s_if_fifo_tx_rd_en;
    
    logic                       s_if_fifo_rx_override_en;
    logic                       s_if_fifo_rx_wr_en;
    logic [DATA_WIDTH-1:0]      s_if_fifo_rx_data;
    logic                       s_if_fifo_rx_rd_en;

    // ==========================================================================
    // INPUT BUS DECODING
    // ==========================================================================
    // Bus A (input): APB control signals
    // [0]: psel
    // [1]: penable
    // [2]: pwrite
    // [9:3]: paddr[6:0]
    
    // Bus B (input): APB data + serial signals
    // [7:0]: pwdata[7:0]
    // [8]: paddr[7]
    // [9]: serial_rx
    // [10]: cdr_sample_valid
    // [11]: reserved
    
    // ==========================================================================
    // OUTPUT BUS PACKING
    // ==========================================================================
    // Bus C (output): APB readback + FIFO status
    // [7:0]: prdata[7:0]
    // [8]: tx_fifo_full
    // [9]: tx_fifo_empty
    // [10]: tx_fifo_push
    // [11]: tx_fifo_pop
    
    // Bus D (output, 2 bits): Serial signals (config-dependent)
    // [0]: serial_tx / des_o_push / tx_fifo_pop / tx_tick (depends on config)
    // [1]: tx_valid / des_o_ovf_pulse / tx_sample_tick / tx_valid (depends on config)

    always_comb begin
        // Default: tie all controls to safe state
        s_if_psel             = 1'b0;
        s_if_penable          = 1'b0;
        s_if_pwrite           = 1'b0;
        s_if_paddr            = '0;
        s_if_pwdata           = '0;
        s_if_serial_rx        = 1'b0;
        s_if_cdr_sample_valid = 1'b0;
        s_if_ser_override_en  = 1'b0;
        s_if_ser_tx_data      = '0;
        s_if_ser_tx_data_valid = 1'b0;
        s_if_ser_tx_fifo_empty = 1'b0;
        s_if_ser_baud_tick    = 1'b0;
        s_if_des_override_en  = 1'b0;
        s_if_des_serial_data  = 1'b0;
        s_if_des_sample_valid = 1'b0;
        s_if_des_enable       = 1'b0;
        s_if_des_fifo_full    = 1'b0;
        s_if_fifo_tx_override_en = 1'b0;
        s_if_fifo_tx_wr_en    = 1'b0;
        s_if_fifo_tx_data     = '0;
        s_if_fifo_tx_rd_en    = 1'b0;
        s_if_fifo_rx_override_en = 1'b0;
        s_if_fifo_rx_wr_en    = 1'b0;
        s_if_fifo_rx_data     = '0;
        s_if_fifo_rx_rd_en    = 1'b0;
        s_if_baud_override_en = 1'b0;
        s_if_baud_enable      = 1'b0;
        s_if_baud_div_val     = '0;

        unique case (i_cfg_local)
            // ====================================================================
            // CFG_CLASSIC (0x0): APB + serial loopback
            // Test: APB register writes, serial TX via CDR, loopback to RX
            // Inputs: Bus A (APB control) + Bus B (APB data + serial)
            // Outputs: Bus C (APB readback + FIFO) + Bus D (serial + debug)
            // ====================================================================
            CFG_CLASSIC: begin
                // Decode inputs from buses
                s_if_psel             = i_bus_a[0];
                s_if_penable          = i_bus_a[1];
                s_if_pwrite           = i_bus_a[2];
                s_if_paddr[6:0]       = i_bus_a[9:3];
                s_if_paddr[7]         = i_bus_b[8];
                s_if_pwdata[7:0]      = i_bus_b[7:0];
                s_if_serial_rx        = i_bus_b[9];
                s_if_cdr_sample_valid = i_bus_b[10];

                // Pack outputs to buses
                o_bus_c[7:0]          = s_if_prdata[7:0];
                o_bus_c[8]            = s_dbg_tx_fifo_full;
                o_bus_c[9]            = s_dbg_tx_fifo_empty;
                o_bus_c[10]           = s_dbg_tx_fifo_push;
                o_bus_c[11]           = s_dbg_tx_fifo_pop;

                o_bus_d[0]            = s_if_serial_tx;
                o_bus_d[1]            = s_if_tx_valid;
            end

            // ====================================================================
            // CFG_TX_ONLY (0x1): TX path testing
            // Test: APB to TX FIFO to Serializer
            // Inputs: Bus A (APB control) + Bus B (APB data)
            // Outputs: Bus C (FIFO status) + Bus D (serial output)
            // ====================================================================
            CFG_TX_ONLY: begin
                // Decode APB from buses
                s_if_psel             = i_bus_a[0];
                s_if_penable          = i_bus_a[1];
                s_if_pwrite           = i_bus_a[2];
                s_if_paddr[6:0]       = i_bus_a[9:3];
                s_if_paddr[7]         = i_bus_b[8];
                s_if_pwdata[7:0]      = i_bus_b[7:0];

                // Pack FIFO status to Bus C
                o_bus_c[7:0]          = s_dbg_tx_fifo_q;
                o_bus_c[8]            = s_dbg_tx_fifo_full;
                o_bus_c[9]            = s_dbg_tx_fifo_empty;
                o_bus_c[10]           = s_dbg_tx_fifo_push;
                o_bus_c[11]           = s_dbg_tx_fifo_pop;

                // Pack serial output to Bus D
                o_bus_d[0]            = s_if_serial_tx;
                o_bus_d[1]            = s_if_tx_valid;
            end

            // ====================================================================
            // CFG_RX_ONLY (0x2): RX path testing
            // Test: CDR to Deserializer to RX FIFO to APB
            // Inputs: Bus A (APB control) + Bus B (APB data + serial RX)
            // Outputs: Bus C (APB readback + RX FIFO)
            // ====================================================================
            CFG_RX_ONLY: begin
                // Decode APB and serial from buses
                s_if_psel             = i_bus_a[0];
                s_if_penable          = i_bus_a[1];
                s_if_pwrite           = i_bus_a[2];
                s_if_paddr[6:0]       = i_bus_a[9:3];
                s_if_paddr[7]         = i_bus_b[8];
                s_if_pwdata[7:0]      = i_bus_b[7:0];
                s_if_serial_rx        = i_bus_b[9];
                s_if_cdr_sample_valid = i_bus_b[10];

                // Pack RX FIFO status to Bus C
                o_bus_c[7:0]          = s_if_prdata[7:0];
                o_bus_c[8]            = s_dbg_rx_fifo_full;
                o_bus_c[9]            = s_dbg_rx_fifo_empty;
                o_bus_c[10]           = s_dbg_rx_fifo_push;
                o_bus_c[11]           = s_dbg_rx_fifo_pop;

                o_bus_d[1:0]          = '0;  // Not used in RX_ONLY
            end

            // ====================================================================
            // CFG_LOOPBACK (0x3): Serial loopback testing
            // Test: TX serial output looped back to RX deserializer
            // Validates serializer -> CDR -> deserializer chain
            // ====================================================================
            CFG_LOOPBACK: begin
                // Decode APB from Bus A
                s_if_psel             = i_bus_a[0];
                s_if_penable          = i_bus_a[1];
                s_if_pwrite           = i_bus_a[2];
                s_if_paddr[6:0]       = i_bus_a[9:3];
                s_if_paddr[7]         = i_bus_b[8];
                s_if_pwdata[7:0]      = i_bus_b[7:0];
                s_if_cdr_sample_valid = i_bus_b[10];
                s_if_serial_rx        = s_if_serial_tx;  // Loopback TX to RX

                // Pack APB readback and FIFO to Bus C
                o_bus_c[7:0]          = s_if_prdata[7:0];
                o_bus_c[8]            = s_if_serial_tx;
                o_bus_c[9]            = s_dbg_tx_fifo_push;
                o_bus_c[10]           = s_dbg_rx_fifo_push;
                o_bus_c[11]           = s_dbg_rx_ovf_err;

                // Pack debug to Bus D
                o_bus_d[0]            = s_dbg_des_o_push;
                o_bus_d[1]            = s_dbg_des_o_ovf_pulse;
            end

            // ====================================================================
            // CFG_FIFO_TX (0x4): TX FIFO direct control
            // Test: Direct write to TX FIFO bypassing APB
            // Inputs: Bus B (FIFO write data + controls)
            // Outputs: Bus C (FIFO status) + Bus D (serial output)
            // ====================================================================
            CFG_FIFO_TX: begin
                // FIFO TX data and control from Bus B
                s_if_fifo_tx_override_en = 1'b1;
                s_if_fifo_tx_data[7:0]  = i_bus_b[7:0];

                // Pack FIFO status to Bus C
                o_bus_c[7:0]          = s_dbg_tx_fifo_q;
                o_bus_c[8]            = s_dbg_tx_fifo_full;
                o_bus_c[9]            = s_dbg_tx_fifo_empty;
                o_bus_c[10]           = s_dbg_tx_fifo_push;
                o_bus_c[11]           = s_dbg_tx_fifo_pop;

                // Pack serial output to Bus D
                o_bus_d[0]            = s_if_serial_tx;
                o_bus_d[1]            = s_if_tx_valid;
            end

            // ====================================================================
            // CFG_FIFO_RX (0x5): RX FIFO direct control
            // Test: Direct read from RX FIFO bypassing APB
            // Inputs: Bus B (CDR serial signals)
            // Outputs: Bus C (RX FIFO data) + Bus D (RX status)
            // ====================================================================
            CFG_FIFO_RX: begin
                // Serial RX from Bus B
                s_if_serial_rx        = i_bus_b[9];
                s_if_cdr_sample_valid = i_bus_b[10];

                // Pack RX FIFO data to Bus C
                o_bus_c[7:0]          = s_dbg_rx_fifo_q;
                o_bus_c[8]            = s_dbg_rx_fifo_full;
                o_bus_c[9]            = s_dbg_rx_fifo_empty;
                o_bus_c[10]           = s_dbg_rx_fifo_push;
                o_bus_c[11]           = s_dbg_rx_fifo_pop;

                // Pack RX status to Bus D
                o_bus_d[0]            = s_dbg_des_o_push;
                o_bus_d[1]            = s_dbg_des_o_ovf_pulse;
            end

            // ====================================================================
            // CFG_SERDES (0x6): Serializer/Deserializer chain testing
            // Test: Direct control of serializer inputs + deserializer outputs
            // Inputs: Bus A (serializer data) + Bus B (deserializer serial)
            // Outputs: Bus C (deserializer para data) + Bus D (ser/des status)
            // ====================================================================
            CFG_SERDES: begin
                // Serializer override from Bus A
                s_if_ser_override_en   = 1'b1;
                s_if_ser_tx_data[7:0] = i_bus_a[7:0];
                s_if_ser_tx_data_valid = i_bus_a[8];
                s_if_ser_tx_fifo_empty = i_bus_a[9];

                // Deserializer override from Bus B
                s_if_des_override_en   = 1'b1;
                s_if_serial_rx         = i_bus_b[9];
                s_if_cdr_sample_valid  = i_bus_b[10];

                // Pack deserializer output to Bus C
                o_bus_c[7:0]          = s_dbg_des_o_para_data[7:0];
                o_bus_c[8]            = s_dbg_des_o_push;
                o_bus_c[9]            = s_dbg_des_o_ovf_pulse;
                o_bus_c[10]           = s_if_serial_tx;
                o_bus_c[11]           = s_dbg_ser_o_tx_busy;

                // Pack ser/des status to Bus D
                o_bus_d[0]            = s_dbg_tx_fifo_pop;
                o_bus_d[1]            = s_if_tx_sample_tick;
            end

            // ====================================================================
            // CFG_BAUD (0x7): Baud rate generator control
            // Test: Divisor configuration and tick generation
            // Inputs: Bus A (baud divisor control)
            // Outputs: Bus D (baud tick and status)
            // ====================================================================
            CFG_BAUD: begin
                s_if_baud_override_en = 1'b1;
                s_if_baud_enable      = i_bus_a[0];
                s_if_baud_div_val     = i_bus_a[8:1];

                o_bus_c[11:0]         = '0;  // Not used in BAUD

                o_bus_d[0]            = s_dbg_tx_tick;
                o_bus_d[1]            = s_if_tx_valid;
            end

            default: begin
                // Default: all inputs/outputs already initialized above
                // This covers any undefined configuration values
            end
        endcase
    end

    interface_top #(
        .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
        .APB_DATA_WIDTH(APB_DATA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .DIV_WIDTH(DIV_WIDTH)
    ) u_interface_top (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_psel(s_if_psel),
        .i_penable(s_if_penable),
        .i_pwrite(s_if_pwrite),
        .i_paddr(s_if_paddr),
        .i_pwdata(s_if_pwdata),
        .o_prdata(s_if_prdata),
        .o_pready(s_if_pready),
        .o_pslverr(s_if_pslverr),
        .i_serial_rx(s_if_serial_rx),
        .i_cdr_sample_valid(s_if_cdr_sample_valid),
        .i_dbg_ser_override_en(s_if_ser_override_en),
        .i_dbg_ser_tx_data(s_if_ser_tx_data),
        .i_dbg_ser_tx_data_valid(s_if_ser_tx_data_valid),
        .i_dbg_ser_tx_fifo_empty(s_if_ser_tx_fifo_empty),
        .i_dbg_ser_baud_tick(s_if_ser_baud_tick),
        .i_dbg_des_override_en(s_if_des_override_en),
        .i_dbg_des_serial_data(s_if_des_serial_data),
        .i_dbg_des_sample_valid(s_if_des_sample_valid),
        .i_dbg_des_enable(s_if_des_enable),
        .i_dbg_des_fifo_full(s_if_des_fifo_full),
        .i_dbg_fifo_tx_override_en(s_if_fifo_tx_override_en),
        .i_dbg_fifo_tx_wr_en(s_if_fifo_tx_wr_en),
        .i_dbg_fifo_tx_data(s_if_fifo_tx_data),
        .i_dbg_fifo_tx_rd_en(s_if_fifo_tx_rd_en),
        .i_dbg_fifo_rx_override_en(s_if_fifo_rx_override_en),
        .i_dbg_fifo_rx_wr_en(s_if_fifo_rx_wr_en),
        .i_dbg_fifo_rx_data(s_if_fifo_rx_data),
        .i_dbg_fifo_rx_rd_en(s_if_fifo_rx_rd_en),
        .i_dbg_baud_override_en(s_if_baud_override_en),
        .i_dbg_baud_enable(s_if_baud_enable),
        .i_dbg_baud_div_val(s_if_baud_div_val),
        .o_serial_tx(s_if_serial_tx),
        .o_tx_valid(s_if_tx_valid),
        .o_tx_sample_tick(s_if_tx_sample_tick),

        .o_dbg_tx_fifo_q(s_dbg_tx_fifo_q),
        .o_dbg_tx_fifo_push(s_dbg_tx_fifo_push),
        .o_dbg_tx_fifo_pop(s_dbg_tx_fifo_pop),
        .o_dbg_tx_fifo_full(s_dbg_tx_fifo_full),
        .o_dbg_tx_fifo_empty(s_dbg_tx_fifo_empty),
        .o_dbg_tx_fifo_rd_valid(s_dbg_tx_fifo_rd_valid),

        .o_dbg_rx_fifo_q(s_dbg_rx_fifo_q),
        .o_dbg_rx_fifo_pop(s_dbg_rx_fifo_pop),
        .o_dbg_rx_fifo_full(s_dbg_rx_fifo_full),
        .o_dbg_rx_fifo_empty(s_dbg_rx_fifo_empty),

        .o_dbg_tx_tick(s_dbg_tx_tick),
        .o_dbg_tx_path_en(s_dbg_tx_path_en),
        .o_dbg_global_en(s_dbg_global_en),
        .o_dbg_tx_und_err(s_dbg_tx_und_err),
        .o_dbg_rx_ovf_err(s_dbg_rx_ovf_err),

        .o_dbg_ser_o_tx_busy(s_dbg_ser_o_tx_busy),
        
        .o_dbg_des_o_para_data(s_dbg_des_o_para_data),
        .o_dbg_des_o_push(s_dbg_des_o_push),
        .o_dbg_des_o_ovf_pulse(s_dbg_des_o_ovf_pulse)
    );

endmodule
