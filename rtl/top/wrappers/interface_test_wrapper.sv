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

    localparam logic [2:0] CFG_CLASSIC   = 3'b000;
    localparam logic [2:0] CFG_TX_ONLY   = 3'b001;
    localparam logic [2:0] CFG_RX_ONLY   = 3'b010;
    localparam logic [2:0] CFG_LOOPBACK  = 3'b011;
    localparam logic [2:0] CFG_FIFO_TX   = 3'b100;
    localparam logic [2:0] CFG_FIFO_RX   = 3'b101;
    localparam logic [2:0] CFG_SERDES    = 3'b110;
    localparam logic [2:0] CFG_BAUD      = 3'b111;

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
    logic                       s_if_ser_override_en;
    logic [DATA_WIDTH-1:0]      s_if_ser_tx_data;
    logic                       s_if_ser_tx_data_valid;
    logic                       s_if_ser_tx_fifo_empty;
    logic                       s_if_ser_baud_tick;
    logic                       s_if_serial_tx;
    logic                       s_if_tx_valid;
    logic                       s_if_tx_sample_tick;

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

    logic                       s_dbg_tx_tick;
    logic                       s_dbg_tx_path_en;
    logic                       s_dbg_rx_path_en;
    logic                       s_dbg_global_en;
    logic                       s_dbg_tx_start;
    logic                       s_dbg_rx_enable;
    logic [DIV_WIDTH-1:0]       s_dbg_div_val;
    logic                       s_dbg_tx_und_err;
    logic                       s_dbg_rx_ovf_err;

    logic [DATA_WIDTH-1:0]      s_dbg_ser_i_tx_data;
    logic                       s_dbg_ser_i_tx_data_valid;
    logic                       s_dbg_ser_i_tx_fifo_empty;
    logic                       s_dbg_ser_i_baud_tick;
    logic                       s_dbg_ser_i_path_en;
    logic                       s_dbg_ser_o_tx_fifo_pop;
    logic                       s_dbg_ser_o_tx_busy;
    logic                       s_dbg_ser_o_serial_data;
    logic                       s_dbg_ser_o_tx_sample_tick;

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
                s_if_psel             = i_test_in[0];
                s_if_penable          = i_test_in[1];
                s_if_pwrite           = i_test_in[2];
                s_if_paddr[7:0]       = i_test_in[10:3];
                s_if_pwdata[7:0]      = i_test_in[18:11];
                s_if_serial_rx        = i_test_in[19];
                s_if_cdr_sample_valid = i_test_in[20];
                s_if_ser_override_en  = 1'b1;
                s_if_ser_tx_data      = i_test_in[18:11];
                s_if_ser_tx_data_valid = i_test_in[21];
                s_if_ser_tx_fifo_empty = i_test_in[22];
                s_if_ser_baud_tick    = i_test_in[23];

                // Dedicated serializer/deserializer observability map.
                o_test_out[0]         = s_dbg_ser_o_serial_data;
                o_test_out[1]         = s_dbg_ser_i_tx_data_valid;
                o_test_out[2]         = s_dbg_ser_i_tx_fifo_empty;
                o_test_out[3]         = s_dbg_ser_i_baud_tick;
                o_test_out[4]         = s_dbg_ser_o_tx_fifo_pop;
                o_test_out[5]         = s_dbg_ser_o_tx_busy;
                o_test_out[6]         = s_dbg_ser_o_tx_sample_tick;
                o_test_out[7]         = s_dbg_rx_fifo_push;
                o_test_out[8]         = s_dbg_rx_ovf_pulse;
                o_test_out[9]         = s_dbg_rx_path_en;
                o_test_out[10]        = s_dbg_ser_i_path_en;
                o_test_out[11]        = s_dbg_global_en;
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
        .o_dbg_ser_o_tx_sample_tick(s_dbg_ser_o_tx_sample_tick)
    );

endmodule
