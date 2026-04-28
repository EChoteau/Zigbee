module interface_test_wrapper #(
    parameter int APB_ADDR_WIDTH = 8,
    parameter int APB_DATA_WIDTH = 8,
    parameter int DATA_WIDTH     = 8,
    parameter int FIFO_DEPTH     = 8,
    parameter int DIV_WIDTH      = 8,
    parameter int N_TEST_IN  = 24,
    parameter int N_TEST_OUT = 12,
    parameter int CFG_WIDTH  = 3
)(
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg_local,
    input  logic [N_TEST_IN-1:0] i_test_in,
    output logic [N_TEST_OUT-1:0] o_test_out
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
    localparam logic [2:0] CFG_SERDES    = 3'b110;  // Serializer/deserializer chain + FIFO observability
    localparam logic [2:0] CFG_BAUD      = 3'b111;  // Baud rate generator control

    // ==========================================================================
    // APB CONTROL SIGNALS (from wrapper to interface_top)
    // ==========================================================================
    logic                       s_if_psel;
    logic                       s_if_penable;
    logic                       s_if_pwrite;
    logic [APB_ADDR_WIDTH-1:0]  s_if_paddr;
    logic [APB_DATA_WIDTH-1:0]  s_if_pwdata;
    // ==========================================================================
    // SERIAL/CDR SIGNALS (interconnect between CDR and deserializer)
    // ==========================================================================
    logic                       s_if_serial_rx;
    logic                       s_if_cdr_sample_valid;
    logic                       s_if_serial_tx;
    logic                       s_if_tx_valid;
    logic                       s_if_tx_sample_tick;

    // ==========================================================================
    // SERIALIZER OVERRIDE & OBSERVABILITY SIGNALS
    // ==========================================================================
    logic                       s_if_ser_override_en;
    logic [DATA_WIDTH-1:0]      s_if_ser_tx_data;
    logic                       s_if_ser_tx_data_valid;
    logic                       s_if_ser_tx_fifo_empty;
    logic                       s_if_ser_baud_tick;
    // Observability: serializer inputs and outputs
    logic [DATA_WIDTH-1:0]      s_dbg_ser_i_tx_data;
    logic                       s_dbg_ser_i_tx_data_valid;
    logic                       s_dbg_ser_i_tx_fifo_empty;
    logic                       s_dbg_ser_i_baud_tick;
    logic                       s_dbg_ser_i_path_en;
    logic                       s_dbg_ser_o_tx_fifo_pop;
    logic                       s_dbg_ser_o_tx_busy;
    logic                       s_dbg_ser_o_serial_data;
    logic                       s_dbg_ser_o_tx_sample_tick;

    // ==========================================================================
    // TX & RX FIFO OBSERVABILITY SIGNALS
    // ==========================================================================
    logic [DATA_WIDTH-1:0]      s_dbg_tx_fifo_data;
    logic                       s_dbg_tx_fifo_push;
    logic                       s_dbg_tx_fifo_full;
    logic                       s_dbg_tx_fifo_pop;
    logic [DATA_WIDTH-1:0]      s_dbg_tx_fifo_q;
    logic                       s_dbg_tx_fifo_rd_valid;
    logic                       s_dbg_tx_fifo_empty;

    logic [DATA_WIDTH-1:0]      s_dbg_rx_fifo_data;
    logic                       s_dbg_rx_fifo_push;
    logic                       s_dbg_rx_fifo_full;
    logic                       s_dbg_rx_fifo_pop;
    logic [DATA_WIDTH-1:0]      s_dbg_rx_fifo_q;
    logic                       s_dbg_rx_fifo_empty;
    logic                       s_dbg_rx_ovf_pulse;

    // ==========================================================================
    // APB CONTROL & STATUS OBSERVABILITY SIGNALS
    // ==========================================================================
    logic                       s_dbg_tx_tick;
    logic                       s_dbg_tx_path_en;
    logic                       s_dbg_rx_path_en;
    logic                       s_dbg_global_en;
    logic                       s_dbg_tx_start;
    logic                       s_dbg_rx_enable;
    logic [DIV_WIDTH-1:0]       s_dbg_div_val;
    logic                       s_dbg_tx_und_err;
    logic                       s_dbg_rx_ovf_err;

    // ==========================================================================
    // DESERIALIZER OVERRIDE & OBSERVABILITY SIGNALS
    // ==========================================================================
    logic                       s_if_des_override_en;
    logic                       s_if_des_serial_data;
    logic                       s_if_des_sample_valid;
    logic                       s_if_des_enable;
    logic                       s_if_des_fifo_full;
    logic                       s_dbg_des_i_serial_data;
    logic                       s_dbg_des_i_sample_valid;
    logic                       s_dbg_des_i_enable;
    logic                       s_dbg_des_i_fifo_full;
    logic [DATA_WIDTH-1:0]      s_dbg_des_o_para_data;
    logic                       s_dbg_des_o_push;
    logic                       s_dbg_des_o_ovf_pulse;

    // ==========================================================================
    // FIFO TX OVERRIDE & OBSERVABILITY SIGNALS
    // ==========================================================================
    logic                       s_if_fifo_tx_override_en;
    logic                       s_if_fifo_tx_wr_en;
    logic [DATA_WIDTH-1:0]      s_if_fifo_tx_data;
    logic                       s_if_fifo_tx_rd_en;
    logic                       s_dbg_fifo_tx_i_wr_en;
    logic [DATA_WIDTH-1:0]      s_dbg_fifo_tx_i_data;
    logic                       s_dbg_fifo_tx_i_rd_en;
    logic                       s_dbg_fifo_tx_o_full;
    logic [DATA_WIDTH-1:0]      s_dbg_fifo_tx_o_data;
    logic                       s_dbg_fifo_tx_o_rd_valid;
    logic                       s_dbg_fifo_tx_o_empty;

    // ==========================================================================
    // FIFO RX OVERRIDE & OBSERVABILITY SIGNALS
    // ==========================================================================
    logic                       s_if_fifo_rx_override_en;
    logic                       s_if_fifo_rx_wr_en;
    logic [DATA_WIDTH-1:0]      s_if_fifo_rx_data;
    logic                       s_if_fifo_rx_rd_en;
    logic                       s_dbg_fifo_rx_i_wr_en;
    logic [DATA_WIDTH-1:0]      s_dbg_fifo_rx_i_data;
    logic                       s_dbg_fifo_rx_i_rd_en;
    logic                       s_dbg_fifo_rx_o_full;
    logic [DATA_WIDTH-1:0]      s_dbg_fifo_rx_o_data;
    logic                       s_dbg_fifo_rx_o_empty;

    // ==========================================================================
    // BAUD RATE GENERATOR OVERRIDE & OBSERVABILITY SIGNALS
    // ==========================================================================
    logic                       s_if_baud_override_en;
    logic                       s_if_baud_enable;
    logic [DIV_WIDTH-1:0]       s_if_baud_div_val;
    logic                       s_dbg_baud_i_enable;
    logic [DIV_WIDTH-1:0]       s_dbg_baud_i_div_val;
    logic                       s_dbg_baud_o_tick;

    always_comb begin
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

        o_test_out            = '0;

        unique case (i_cfg_local)
            CFG_CLASSIC: begin
                s_if_psel             = i_test_in[0];
                s_if_penable          = i_test_in[1];
                s_if_pwrite           = i_test_in[2];
                s_if_paddr[7:0]       = i_test_in[10:3];
                s_if_pwdata[7:0]      = i_test_in[18:11];
                s_if_serial_rx        = i_test_in[19];
                s_if_cdr_sample_valid = i_test_in[20];

                o_test_out[7:0]       = s_if_prdata[7:0];
                o_test_out[8]         = s_if_serial_tx;
                o_test_out[9]         = s_if_tx_valid;
                o_test_out[10]        = s_if_tx_sample_tick;
                o_test_out[11]        = 1'b0;
            end

            CFG_TX_ONLY: begin
                s_if_psel             = i_test_in[0];
                s_if_penable          = i_test_in[1];
                s_if_pwrite           = i_test_in[2];
                s_if_paddr[7:0]       = i_test_in[10:3];
                s_if_pwdata[7:0]      = i_test_in[18:11];

                o_test_out[0]         = s_if_serial_tx;
                o_test_out[1]         = s_if_tx_valid;
                o_test_out[2]         = s_if_tx_sample_tick;
                o_test_out[3]         = s_dbg_tx_fifo_push;
                o_test_out[4]         = s_dbg_tx_fifo_pop;
                o_test_out[5]         = s_dbg_tx_fifo_full;
                o_test_out[6]         = s_dbg_tx_fifo_empty;
                o_test_out[7]         = s_if_tx_valid;
                o_test_out[8]         = s_dbg_tx_tick;
                o_test_out[9]         = s_dbg_tx_und_err;
                o_test_out[10]        = s_dbg_tx_path_en;
                o_test_out[11]        = s_dbg_global_en;
            end

            CFG_RX_ONLY: begin
                s_if_psel             = i_test_in[0];
                s_if_penable          = i_test_in[1];
                s_if_pwrite           = i_test_in[2];
                s_if_paddr[7:0]       = i_test_in[10:3];
                s_if_pwdata[7:0]      = i_test_in[18:11];
                s_if_serial_rx        = i_test_in[19];
                s_if_cdr_sample_valid = i_test_in[20];

                o_test_out[7:0]       = s_if_prdata[7:0];
                o_test_out[8]         = s_dbg_rx_fifo_push;
                o_test_out[9]         = s_dbg_rx_fifo_pop;
                o_test_out[10]        = s_dbg_rx_fifo_full;
                o_test_out[11]        = s_dbg_rx_fifo_empty;
            end

            CFG_LOOPBACK: begin
                s_if_psel             = i_test_in[0];
                s_if_penable          = i_test_in[1];
                s_if_pwrite           = i_test_in[2];
                s_if_paddr[7:0]       = i_test_in[10:3];
                s_if_pwdata[7:0]      = i_test_in[18:11];
                s_if_cdr_sample_valid = i_test_in[20];
                s_if_serial_rx        = s_if_serial_tx;

                o_test_out[7:0]       = s_if_prdata[7:0];
                o_test_out[8]         = s_if_serial_tx;
                o_test_out[9]         = s_dbg_tx_fifo_push;
                o_test_out[10]        = s_dbg_rx_fifo_push;
                o_test_out[11]        = s_dbg_rx_ovf_err;
            end

            CFG_FIFO_TX: begin
                s_if_psel             = i_test_in[0];
                s_if_penable          = i_test_in[1];
                s_if_pwrite           = i_test_in[2];
                s_if_paddr[7:0]       = i_test_in[10:3];
                s_if_pwdata[7:0]      = i_test_in[18:11];

                o_test_out[7:0]       = s_dbg_tx_fifo_q;
                o_test_out[8]         = s_dbg_tx_fifo_push;
                o_test_out[9]         = s_dbg_tx_fifo_pop;
                o_test_out[10]        = s_dbg_tx_fifo_full;
                o_test_out[11]        = s_dbg_tx_fifo_empty;
            end

            CFG_FIFO_RX: begin
                s_if_psel             = i_test_in[0];
                s_if_penable          = i_test_in[1];
                s_if_pwrite           = i_test_in[2];
                s_if_paddr[7:0]       = i_test_in[10:3];
                s_if_pwdata[7:0]      = i_test_in[18:11];
                s_if_serial_rx        = i_test_in[19];
                s_if_cdr_sample_valid = i_test_in[20];

                o_test_out[7:0]       = s_dbg_rx_fifo_q;
                o_test_out[8]         = s_dbg_rx_fifo_push;
                o_test_out[9]         = s_dbg_rx_fifo_pop;
                o_test_out[10]        = s_dbg_rx_fifo_full;
                o_test_out[11]        = s_dbg_rx_fifo_empty;
            end

            CFG_SERDES: begin
                // Test serializer and deserializer directly - no APB bus needed
                // SERIALIZER INPUTS (control the serializer TX path)
                s_if_ser_override_en  = 1'b1;
                s_if_ser_tx_data      = i_test_in[7:0];
                s_if_ser_tx_data_valid = i_test_in[8];
                s_if_ser_tx_fifo_empty = i_test_in[9];
                s_if_ser_baud_tick    = i_test_in[10];

                // DESERIALIZER INPUTS (inject serial data into RX path)
                s_if_serial_rx        = i_test_in[11];
                s_if_cdr_sample_valid = i_test_in[12];

                // SERIALIZER OUTPUTS (what serializer outputs)
                o_test_out[0]         = s_dbg_ser_o_serial_data;      // TX serial bit
                o_test_out[1]         = s_dbg_ser_o_tx_busy;          // Serializer busy
                o_test_out[2]         = s_dbg_ser_o_tx_fifo_pop;      // FIFO read control
                o_test_out[3]         = s_dbg_ser_o_tx_sample_tick;   // Sample timing

                // DESERIALIZER OUTPUTS (what deserializer outputs)
                o_test_out[7:4]       = s_dbg_des_o_para_data[3:0];  // Parallel data (4 LSBs)
                o_test_out[8]         = s_dbg_des_o_push;             // FIFO push valid
                o_test_out[9]         = s_dbg_des_o_ovf_pulse;        // Overflow indicator
                o_test_out[10]        = s_dbg_global_en;              // Global enable status
                o_test_out[11]        = 1'b0;                         // Unused
            end

            CFG_BAUD: begin
                s_if_psel             = i_test_in[0];
                s_if_penable          = i_test_in[1];
                s_if_pwrite           = i_test_in[2];
                s_if_paddr[7:0]       = i_test_in[10:3];
                s_if_pwdata[7:0]      = i_test_in[18:11];

                o_test_out[0]         = s_dbg_tx_tick;
                o_test_out[8:1]       = s_dbg_div_val[7:0];
                o_test_out[9]         = s_if_tx_valid;
                o_test_out[10]        = s_if_tx_sample_tick;
                o_test_out[11]        = s_dbg_global_en;
            end

            default: begin
                o_test_out = '0;
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

        .o_dbg_tx_fifo_data(s_dbg_tx_fifo_data),
        .o_dbg_tx_fifo_push(s_dbg_tx_fifo_push),
        .o_dbg_tx_fifo_full(s_dbg_tx_fifo_full),
        .o_dbg_tx_fifo_pop(s_dbg_tx_fifo_pop),
        .o_dbg_tx_fifo_q(s_dbg_tx_fifo_q),
        .o_dbg_tx_fifo_rd_valid(s_dbg_tx_fifo_rd_valid),
        .o_dbg_tx_fifo_empty(s_dbg_tx_fifo_empty),

        .o_dbg_rx_fifo_data(s_dbg_rx_fifo_data),
        .o_dbg_rx_fifo_push(s_dbg_rx_fifo_push),
        .o_dbg_rx_fifo_full(s_dbg_rx_fifo_full),
        .o_dbg_rx_fifo_pop(s_dbg_rx_fifo_pop),
        .o_dbg_rx_fifo_q(s_dbg_rx_fifo_q),
        .o_dbg_rx_fifo_empty(s_dbg_rx_fifo_empty),
        .o_dbg_rx_ovf_pulse(s_dbg_rx_ovf_pulse),

        .o_dbg_tx_tick(s_dbg_tx_tick),
        .o_dbg_tx_path_en(s_dbg_tx_path_en),
        .o_dbg_rx_path_en(s_dbg_rx_path_en),
        .o_dbg_global_en(s_dbg_global_en),
        .o_dbg_tx_start(s_dbg_tx_start),
        .o_dbg_rx_enable(s_dbg_rx_enable),
        .o_dbg_div_val(s_dbg_div_val),
        .o_dbg_tx_und_err(s_dbg_tx_und_err),
        .o_dbg_rx_ovf_err(s_dbg_rx_ovf_err),

        .o_dbg_ser_i_tx_data(s_dbg_ser_i_tx_data),
        .o_dbg_ser_i_tx_data_valid(s_dbg_ser_i_tx_data_valid),
        .o_dbg_ser_i_tx_fifo_empty(s_dbg_ser_i_tx_fifo_empty),
        .o_dbg_ser_i_baud_tick(s_dbg_ser_i_baud_tick),
        .o_dbg_ser_i_path_en(s_dbg_ser_i_path_en),
        .o_dbg_ser_o_tx_fifo_pop(s_dbg_ser_o_tx_fifo_pop),
        .o_dbg_ser_o_tx_busy(s_dbg_ser_o_tx_busy),
        .o_dbg_ser_o_serial_data(s_dbg_ser_o_serial_data),
        .o_dbg_ser_o_tx_sample_tick(s_dbg_ser_o_tx_sample_tick),
        
        .o_dbg_des_i_serial_data(s_dbg_des_i_serial_data),
        .o_dbg_des_i_sample_valid(s_dbg_des_i_sample_valid),
        .o_dbg_des_i_enable(s_dbg_des_i_enable),
        .o_dbg_des_i_fifo_full(s_dbg_des_i_fifo_full),
        .o_dbg_des_o_para_data(s_dbg_des_o_para_data),
        .o_dbg_des_o_push(s_dbg_des_o_push),
        .o_dbg_des_o_ovf_pulse(s_dbg_des_o_ovf_pulse),
        
        .o_dbg_fifo_tx_i_wr_en(s_dbg_fifo_tx_i_wr_en),
        .o_dbg_fifo_tx_i_data(s_dbg_fifo_tx_i_data),
        .o_dbg_fifo_tx_i_rd_en(s_dbg_fifo_tx_i_rd_en),
        .o_dbg_fifo_tx_o_full(s_dbg_fifo_tx_o_full),
        .o_dbg_fifo_tx_o_data(s_dbg_fifo_tx_o_data),
        .o_dbg_fifo_tx_o_rd_valid(s_dbg_fifo_tx_o_rd_valid),
        .o_dbg_fifo_tx_o_empty(s_dbg_fifo_tx_o_empty),
        
        .o_dbg_fifo_rx_i_wr_en(s_dbg_fifo_rx_i_wr_en),
        .o_dbg_fifo_rx_i_data(s_dbg_fifo_rx_i_data),
        .o_dbg_fifo_rx_i_rd_en(s_dbg_fifo_rx_i_rd_en),
        .o_dbg_fifo_rx_o_full(s_dbg_fifo_rx_o_full),
        .o_dbg_fifo_rx_o_data(s_dbg_fifo_rx_o_data),
        .o_dbg_fifo_rx_o_empty(s_dbg_fifo_rx_o_empty),
        
        .o_dbg_baud_i_enable(s_dbg_baud_i_enable),
        .o_dbg_baud_i_div_val(s_dbg_baud_i_div_val),
        .o_dbg_baud_o_tick(s_dbg_baud_o_tick)
    );

endmodule
