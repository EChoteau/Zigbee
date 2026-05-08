module interface_wrapper #(
    parameter int APB_ADDR_WIDTH = 8,
    parameter int APB_DATA_WIDTH = 8,
    parameter int DATA_WIDTH     = 8,
    parameter int FIFO_DEPTH     = 8,
    parameter int DIV_WIDTH      = 8,
    parameter int BUS_IN_WIDTH = 22,
    parameter int BUS_OUT_WIDTH = 14,
    parameter int CFG_WIDTH  = 3      // Configuration selector width
)(
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_out_en,    // Output enable (1=drive bus, 0=tri-state)
    input  logic [CFG_WIDTH-1:0] i_cfg,
    input  logic [BUS_IN_WIDTH-1:0] i_bus_in,
    output logic [BUS_OUT_WIDTH-1:0] o_bus_out
);

    // ==========================================================================
    // Configuration modes: select which internal signals are routed to i_test_in
    // and which debug outputs are routed to o_test_out
    // ==========================================================================
    localparam logic [2:0] CFG_RX_ONLY   = 3'b000;  // RX path with FIFO control
    localparam logic [2:0] CFG_TX_ONLY   = 3'b001;  // TX path with FIFO control
    localparam logic [2:0] CFG_reserved  = 3'b010;  // RESERVED NOT USED YET
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
    logic                       s_tx_valid;
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
    // INPUT BUS DECODING (22 bits)
    // ==========================================================================
    // IN[0]:     s_if_psel (CFG: 0,1,2,3)
    // IN[1]:     s_if_penable (CFG: 0,1,2,3)
    // IN[2]:     s_if_pwrite (CFG: 0,1,2,3)
    // IN[9:3]:   s_if_paddr[6:0] (CFG: 0,1,2,3)
    // IN[18]:    s_if_paddr[7] (CFG: 0,1,2,3)
    // IN[17:10]: s_if_pwdata[7:0] (CFG: 0,1,2,3)
    // IN[19]:    s_if_serial_rx (CFG: 0,2,3,5,6)
    // IN[20]:    s_if_cdr_sample_valid (CFG: 0,2,3,5,6)
    // IN[0]:     s_if_fifo_tx_wr_en (CFG: 4)
    // IN[1]:     s_if_fifo_tx_rd_en (CFG: 4)
    // IN[17:10]: s_if_fifo_tx_data[7:0] (CFG: 4)
    // IN[0]:     s_if_fifo_rx_wr_en (CFG: 5)
    // IN[1]:     s_if_fifo_rx_rd_en (CFG: 5)
    // IN[7:0]:   s_if_ser_tx_data[7:0] (CFG: 6)
    // IN[8]:     s_if_ser_tx_data_valid (CFG: 6)
    // IN[9]:     s_if_ser_tx_fifo_empty (CFG: 6)
    // IN[0]:     s_if_baud_enable (CFG: 7)
    // IN[8:1]:   s_if_baud_div_val[7:0] (CFG: 7)
    
    // ==========================================================================
    // OUTPUT BUS PACKING (14 bits)
    // ==========================================================================
    // OUT[13]:   s_tx_valid (CFG: 0,1,4,7)
    // OUT[12]:   s_if_serial_tx (CFG: 0,1,4)
    // OUT[12]:   s_dbg_tx_fifo_pop (CFG: 6)
    // OUT[12]:   s_dbg_tx_tick (CFG: 7)
    // OUT[11]:   s_dbg_tx_fifo_pop (CFG: 0,1,4)
    // OUT[11]:   s_dbg_rx_fifo_pop (CFG: 2,5)
    // OUT[11]:   s_dbg_rx_ovf_err (CFG: 3)
    // OUT[11]:   s_tx_valid (CFG: 6)
    // OUT[10]:   s_dbg_tx_fifo_push (CFG: 0,1,4)
    // OUT[10]:   s_dbg_des_o_push (CFG: 2,3,5)
    // OUT[10]:   s_if_serial_tx (CFG: 6)
    // OUT[9]:    s_dbg_tx_fifo_empty (CFG: 0,1,4)
    // OUT[9]:    s_dbg_rx_fifo_empty (CFG: 2,5)
    // OUT[9]:    s_dbg_tx_fifo_push (CFG: 3)
    // OUT[9]:    s_dbg_des_o_ovf_pulse (CFG: 6)
    // OUT[8]:    s_dbg_tx_fifo_full (CFG: 0,1,4)
    // OUT[8]:    s_dbg_rx_fifo_full (CFG: 2,5)
    // OUT[8]:    s_if_serial_tx (CFG: 3)
    // OUT[8]:    s_dbg_des_o_push (CFG: 6)
    // OUT[7:0]:  s_if_prdata[7:0] (CFG: 0,2,3)
    // OUT[7:0]:  s_dbg_tx_fifo_q[7:0] (CFG: 1,4)
    // OUT[7:0]:  s_dbg_rx_fifo_q[7:0] (CFG: 5)
    // OUT[7:0]:  s_dbg_des_o_para_data[7:0] (CFG: 6)

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
        
        // Default: tie all outputs to 0
        o_bus_out = '0;

        // Only drive outputs if enabled
        if (i_out_en) begin
            unique case (i_cfg)

                // ====================================================================
                // CFG_TX_ONLY (0x1): TX path testing
                // ====================================================================
                CFG_TX_ONLY: begin
                    // Decode APB from bus
                    s_if_psel             = i_bus_in[0];
                    s_if_penable          = i_bus_in[1];
                    s_if_pwrite           = i_bus_in[2];
                    s_if_paddr[7:0]       = i_bus_in[10:3];
                    s_if_pwdata[7:0]      = i_bus_in[18:11];

                    // Pack FIFO status to output bus
                    o_bus_out[7:0]        = s_dbg_tx_fifo_q;
                    o_bus_out[8]          = s_dbg_tx_fifo_full;
                    o_bus_out[9]          = s_dbg_tx_fifo_empty;
                    o_bus_out[10]         = s_dbg_tx_fifo_push;
                    o_bus_out[11]         = s_dbg_tx_fifo_pop;
                    o_bus_out[12]         = s_if_serial_tx;
                    o_bus_out[13]         = s_tx_valid;
                end

                // ====================================================================
                // CFG_RX_ONLY (0x0): RX path testing
                // ====================================================================
                CFG_RX_ONLY: begin
                    // Decode APB and serial from bus
                    s_if_psel             = i_bus_in[0];
                    s_if_penable          = i_bus_in[1];
                    s_if_pwrite           = i_bus_in[2];
                    s_if_paddr[7:0]       = i_bus_in[10:3];
                    s_if_pwdata[7:0]      = i_bus_in[18:11];
                    s_if_serial_rx        = i_bus_in[19];
                    s_if_cdr_sample_valid = i_bus_in[20];

                    // Pack RX FIFO status to output bus
                    o_bus_out[7:0]        = s_if_prdata[7:0];
                    o_bus_out[8]          = s_dbg_rx_fifo_full;
                    o_bus_out[9]          = s_dbg_rx_fifo_empty;
                    o_bus_out[10]         = s_dbg_des_o_push;
                    o_bus_out[11]         = s_dbg_rx_fifo_pop;
                end

                // ====================================================================
                // CFG_LOOPBACK (0x3): Serial loopback testing
                // ====================================================================
                CFG_LOOPBACK: begin
                    // Decode APB from bus
                    s_if_psel             = i_bus_in[0];
                    s_if_penable          = i_bus_in[1];
                    s_if_pwrite           = i_bus_in[2];
                    s_if_paddr[7:0]       = i_bus_in[10:3];
                    s_if_pwdata[7:0]      = i_bus_in[18:11];
                    s_if_cdr_sample_valid = i_bus_in[20];
                    s_if_serial_rx        = s_if_serial_tx;  // Loopback TX to RX

                    // Pack APB readback and FIFO to output bus
                    o_bus_out[7:0]        = s_if_prdata[7:0];
                    o_bus_out[8]          = s_if_serial_tx;
                    o_bus_out[9]          = s_dbg_tx_fifo_push;
                    o_bus_out[10]         = s_dbg_des_o_push;
                    o_bus_out[11]         = s_dbg_rx_ovf_err;

                    o_bus_out[12]         = s_dbg_tx_tick;
                    o_bus_out[13]         = s_tx_valid;
                end

                // ====================================================================
                // CFG_FIFO_TX (0x4): TX FIFO direct control
                // ====================================================================
                CFG_FIFO_TX: begin
                    // FIFO TX control signals from bus
                    s_if_fifo_tx_override_en = 1'b1;
                    s_if_fifo_tx_wr_en      = i_bus_in[0];
                    s_if_fifo_tx_rd_en      = i_bus_in[1];
                    
                    // FIFO TX data from bus
                    s_if_fifo_tx_data[7:0]  = i_bus_in[17:10];

                    // Pack FIFO status to output bus
                    o_bus_out[7:0]        = s_dbg_tx_fifo_q;
                    o_bus_out[8]          = s_dbg_tx_fifo_full;
                    o_bus_out[9]          = s_dbg_tx_fifo_empty;
                    o_bus_out[10]         = s_dbg_tx_fifo_push;
                    o_bus_out[11]         = s_dbg_tx_fifo_pop;
                    o_bus_out[12]         = s_if_serial_tx;
                    o_bus_out[13]         = s_tx_valid;
                end

                // ====================================================================
                // CFG_FIFO_RX (0x5): RX FIFO direct control
                // ====================================================================
                CFG_FIFO_RX: begin
                    // FIFO RX control signals from bus
                    s_if_fifo_rx_override_en = 1'b1;
                    s_if_fifo_rx_wr_en      = i_bus_in[0];
                    s_if_fifo_rx_rd_en      = i_bus_in[1];
                    
                    // Serial RX from bus (fed to deserializer)
                    s_if_fifo_rx_data[7:0]  = i_bus_in[17:10];

                    // Pack RX FIFO data to output bus
                    o_bus_out[7:0]        = s_dbg_rx_fifo_q;
                    o_bus_out[8]          = s_dbg_rx_fifo_full;
                    o_bus_out[9]          = s_dbg_rx_fifo_empty;
                    o_bus_out[10]         = s_dbg_des_o_push;
                    o_bus_out[11]         = s_dbg_rx_fifo_pop;
                end

                // ====================================================================
                // CFG_SERDES (0x6): Serializer/Deserializer chain testing
                // ====================================================================
                CFG_SERDES: begin
                    // Serializer override from bus
                    s_if_ser_override_en    = 1'b1;
                    s_if_ser_tx_data[7:0]   = i_bus_in[7:0];
                    s_if_ser_tx_data_valid  = i_bus_in[8];
                    s_if_ser_tx_fifo_empty  = i_bus_in[9];

                    // Deserializer override from bus
                    s_if_des_override_en    = 1'b1;
                    s_if_serial_rx          = i_bus_in[19];
                    s_if_cdr_sample_valid   = i_bus_in[20];

                    // Pack deserializer output to output bus
                    o_bus_out[7:0]        = s_dbg_des_o_para_data[7:0];
                    o_bus_out[8]          = s_dbg_des_o_push;
                    o_bus_out[9]          = s_dbg_des_o_ovf_pulse;
                    o_bus_out[10]         = s_if_serial_tx;
                    o_bus_out[11]         = s_if_tx_sample_tick;
                    o_bus_out[12]         = s_dbg_tx_fifo_pop;
                    o_bus_out[13]         = s_tx_valid;
                end

                // ====================================================================
                // CFG_BAUD (0x7): Baud rate generator control
                // ====================================================================
                CFG_BAUD: begin
                    s_if_baud_override_en = 1'b1;
                    s_if_baud_enable      = i_bus_in[0];
                    s_if_baud_div_val     = i_bus_in[8:1];

                    o_bus_out[12]         = s_dbg_tx_tick;
                    o_bus_out[13]         = s_tx_valid;
                end

                default: begin
                    // Default: all inputs/outputs already initialized above
                end
            endcase
        end
        // When i_out_en = 0, o_bus_out stays 0 (tri-state)
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
        .o_tx_valid(s_tx_valid),
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
        
        .o_dbg_des_o_para_data(s_dbg_des_o_para_data),
        .o_dbg_des_o_push(s_dbg_des_o_push),
        .o_dbg_des_o_ovf_pulse(s_dbg_des_o_ovf_pulse)
    );

endmodule
