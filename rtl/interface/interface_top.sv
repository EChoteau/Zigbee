module interface_top #(
	parameter APB_ADDR_WIDTH = 8,
	parameter APB_DATA_WIDTH = 8,
	parameter DATA_WIDTH     = 8,
	parameter FIFO_DEPTH     = 8,
	parameter DIV_WIDTH      = 8
)(
	input  logic                       i_clk,
	input  logic                       i_rst_n,

	input  logic                       i_psel,
	input  logic                       i_penable,
	input  logic                       i_pwrite,
	input  logic [APB_ADDR_WIDTH-1:0]  i_paddr,
	input  logic [APB_DATA_WIDTH-1:0]  i_pwdata,
	output logic [APB_DATA_WIDTH-1:0]  o_prdata,
	output logic                       o_pready,
	output logic                       o_pslverr,

	input  logic                       i_serial_rx,
	input  logic                       i_cdr_sample_valid,
	input  logic                       i_dbg_ser_override_en,
	input  logic [DATA_WIDTH-1:0]      i_dbg_ser_tx_data,
	input  logic                       i_dbg_ser_tx_data_valid,
	input  logic                       i_dbg_ser_tx_fifo_empty,
	input  logic                       i_dbg_ser_baud_tick,
	
	input  logic                       i_dbg_des_override_en,
	input  logic                       i_dbg_des_serial_data,
	input  logic                       i_dbg_des_sample_valid,
	input  logic                       i_dbg_des_enable,
	input  logic                       i_dbg_des_fifo_full,
	
	input  logic                       i_dbg_fifo_tx_override_en,
	input  logic                       i_dbg_fifo_tx_wr_en,
	input  logic [DATA_WIDTH-1:0]      i_dbg_fifo_tx_data,
	input  logic                       i_dbg_fifo_tx_rd_en,
	
	input  logic                       i_dbg_fifo_rx_override_en,
	input  logic                       i_dbg_fifo_rx_wr_en,
	input  logic [DATA_WIDTH-1:0]      i_dbg_fifo_rx_data,
	input  logic                       i_dbg_fifo_rx_rd_en,
	
	input  logic                       i_dbg_baud_override_en,
	input  logic                       i_dbg_baud_enable,
	input  logic [DIV_WIDTH-1:0]       i_dbg_baud_div_val,
	
	output logic                       o_serial_tx,
	output logic                       o_tx_valid,
	output logic                       o_tx_sample_tick,

	// Debug outputs - essential observability only
	output logic [DATA_WIDTH-1:0]      o_dbg_tx_fifo_q,
	output logic                       o_dbg_tx_fifo_push,
	output logic                       o_dbg_tx_fifo_pop,
	output logic                       o_dbg_tx_fifo_full,
	output logic                       o_dbg_tx_fifo_empty,
	output logic                       o_dbg_tx_fifo_rd_valid,

	output logic [DATA_WIDTH-1:0]      o_dbg_rx_fifo_q,
	output logic                       o_dbg_rx_fifo_pop,
	output logic                       o_dbg_rx_fifo_full,
	output logic                       o_dbg_rx_fifo_empty,

	output logic                       o_dbg_tx_tick,
	output logic                       o_dbg_tx_path_en,
	output logic                       o_dbg_global_en,
	output logic                       o_dbg_tx_und_err,
	output logic                       o_dbg_rx_ovf_err,

	// Deserializer chain outputs only
	output logic [DATA_WIDTH-1:0]      o_dbg_des_o_para_data,
	output logic                       o_dbg_des_o_push,
	output logic                       o_dbg_des_o_ovf_pulse
);

	// ==========================================================================
	// TX FIFO INTERCONNECTS: APB -> TX FIFO -> Serializer
	// ==========================================================================
	// APB writes data into TX FIFO; Serializer reads from TX FIFO
	logic [DATA_WIDTH-1:0] w_tx_fifo_data;    // Data from APB to FIFO write port
	logic                  w_tx_fifo_push;    // Write enable from APB
	logic                  w_tx_fifo_full;    // Status: FIFO full
	logic                  w_tx_fifo_pop;     // Read enable from Serializer
	logic [DATA_WIDTH-1:0] w_tx_fifo_q;       // Data from FIFO to Serializer
	logic                  w_tx_fifo_rd_valid;// Status: FIFO has valid data
	logic                  w_tx_fifo_empty;   // Status: FIFO empty

	// ==========================================================================
	// RX FIFO INTERCONNECTS: Deserializer -> RX FIFO -> APB
	// ==========================================================================
	// Deserializer writes data into RX FIFO; APB reads from RX FIFO
	logic [DATA_WIDTH-1:0] w_rx_fifo_data;    // Data from Deserializer to FIFO write port
	logic                  w_rx_fifo_push;    // Write enable from Deserializer
	logic                  w_rx_fifo_full;    // Status: FIFO full
	logic                  w_rx_fifo_pop;     // Read enable from APB
	logic [DATA_WIDTH-1:0] w_rx_fifo_q;       // Data from FIFO to APB
	logic                  w_rx_fifo_empty;   // Status: FIFO empty

	// ==========================================================================
	// APB REGISTER OUTPUTS: Control signals from APB slave register controller
	// ==========================================================================
	// These outputs come from APB register reads/writes, controlling the system
	logic                  w_global_en;       // Global enable flag
	logic                  w_sw_reset;        // Software reset flag
	logic                  w_clear_err;       // Error flag clear command
	logic                  w_tx_start;        // TX start trigger
	logic                  w_rx_enable;       // RX enable flag
	logic [DIV_WIDTH-1:0]  w_div_val;         // Baud rate divisor value

	// ==========================================================================
	// TIMING & CONTROL SIGNALS: Baud generator, TX/RX control, error tracking
	// ==========================================================================
	logic                  w_tx_tick;         // Baud rate tick from baud generator
	logic                  w_tx_busy;         // Serializer busy (transmitting)
	logic                  w_rx_ovf_pulse;    // Overflow pulse from Deserializer
	logic                  s_rx_ovf_err;      // Latched RX overflow error flag (FF)
	logic                  s_tx_und_err;      // Latched TX underrun error flag (FF)
	logic                  s_tx_path_en_d;    // Delayed TX path enable (for edge detection)
	logic                  s_tx_run;          // TX running state machine (FF)

	// ==========================================================================
	// PATH ENABLE SIGNALS: Control which paths are active based on global enable
	// ==========================================================================
	// Gated by global_en + status from control logic
	logic                  w_tx_path_en;      // TX path active: global_en & tx_run
	logic                  w_rx_path_en;      // RX path active: global_en & rx_enable

	// ==========================================================================
	// SERIALIZER OVERRIDE MUX INPUTS
	// ==========================================================================
	// Multiplexer controls: select between normal path and test override
	// Override mux: normal (FIFO path) vs test (direct injection via i_dbg_ser_*)
	logic                  w_ser_tx_fifo_empty;    // FIFO empty OR path disabled
	logic [DATA_WIDTH-1:0] w_ser_tx_data_in;      // Data to serializer (after mux)
	logic                  w_ser_tx_data_valid_in;// Data valid (after mux)
	logic                  w_ser_tx_fifo_empty_in;// FIFO empty (after mux)
	logic                  w_ser_baud_tick_in;    // Baud tick (after mux)
	
	// ==========================================================================
	// DESERIALIZER OVERRIDE MUX INPUTS
	// ==========================================================================
	// Multiplexer controls: select between normal path and test override
	// Override mux: normal (CDR path) vs test (direct injection via i_dbg_des_*)
	logic                  w_des_serial_data_in;  // Serial data (after mux)
	logic                  w_des_sample_valid_in; // Sample valid (after mux)
	logic                  w_des_enable_in;       // Enable signal (after mux)
	logic                  w_des_fifo_full_in;    // FIFO full flag (after mux)
	
	// ==========================================================================
	// FIFO TX OVERRIDE MUX INPUTS
	// ==========================================================================
	// Multiplexer controls: select between normal path and test override
	// Override mux: normal (APB -> FIFO) vs test (direct control via i_dbg_fifo_tx_*)
	logic                  w_fifo_tx_wr_en_in;    // Write enable (after mux)
	logic [DATA_WIDTH-1:0] w_fifo_tx_data_in;    // Write data (after mux)
	logic                  w_fifo_tx_rd_en_in;    // Read enable (after mux)
	
	// ==========================================================================
	// FIFO RX OVERRIDE MUX INPUTS
	// ==========================================================================
	// Multiplexer controls: select between normal path and test override
	// Override mux: normal (Deserializer -> FIFO) vs test (direct control via i_dbg_fifo_rx_*)
	logic                  w_fifo_rx_wr_en_in;    // Write enable (after mux)
	logic [DATA_WIDTH-1:0] w_fifo_rx_data_in;    // Write data (after mux)
	logic                  w_fifo_rx_rd_en_in;    // Read enable (after mux)
	
	// ==========================================================================
	// BAUD RATE GENERATOR OVERRIDE MUX INPUTS
	// ==========================================================================
	// Multiplexer controls: select between normal path and test override
	// Override mux: normal (APB-controlled) vs test (direct control via i_dbg_baud_*)
	logic                  w_baud_enable_in;      // Enable signal (after mux)
	logic [DIV_WIDTH-1:0]  w_baud_div_val_in;    // Divisor value (after mux)

	// ==========================================================================
	// PATH ENABLE COMPUTATION: Control signal routing
	// ==========================================================================
	// TX path active only if globally enabled AND TX is in "run" state
	// RX path active only if globally enabled AND RX is enabled
	// w_ser_tx_fifo_empty: special handling for FIFO empty (empty OR path not enabled)
	assign w_tx_path_en = w_global_en & s_tx_run;
	assign w_rx_path_en = w_global_en & w_rx_enable;
	assign w_ser_tx_fifo_empty = w_tx_fifo_empty | ~w_tx_path_en;
	
	// ==========================================================================
	// SERIALIZER OVERRIDE & MUX LOGIC (4 inputs)
	// ==========================================================================
	// Purpose: Allow direct test injection into serializer while maintaining
	// normal APB->FIFO->Serializer datapath when not in test mode
	// Normal: Data from TX FIFO -> Serializer
	// Test (override_en=1): Data from test port -> Serializer
	assign w_ser_tx_data_in = i_dbg_ser_override_en ? i_dbg_ser_tx_data : w_tx_fifo_q;
	assign w_ser_tx_data_valid_in = i_dbg_ser_override_en ? i_dbg_ser_tx_data_valid : w_tx_fifo_rd_valid;
	assign w_ser_tx_fifo_empty_in = i_dbg_ser_override_en ? i_dbg_ser_tx_fifo_empty : w_ser_tx_fifo_empty;
	assign w_ser_baud_tick_in = i_dbg_ser_override_en ? i_dbg_ser_baud_tick : w_tx_tick;
	
	// ==========================================================================
	// DESERIALIZER OVERRIDE & MUX LOGIC (4 inputs)
	// ==========================================================================
	// Purpose: Allow direct test injection into deserializer while maintaining
	// normal CDR->Deserializer->RX_FIFO datapath when not in test mode
	// Normal: Serial data from CDR -> Deserializer
	// Test (override_en=1): Serial data from test port -> Deserializer
	assign w_des_serial_data_in = i_dbg_des_override_en ? i_dbg_des_serial_data : i_serial_rx;
	assign w_des_sample_valid_in = i_dbg_des_override_en ? i_dbg_des_sample_valid : i_cdr_sample_valid;
	assign w_des_enable_in = i_dbg_des_override_en ? i_dbg_des_enable : w_rx_path_en;
	assign w_des_fifo_full_in = i_dbg_des_override_en ? i_dbg_des_fifo_full : w_rx_fifo_full;
	
	// ==========================================================================
	// FIFO TX OVERRIDE & MUX LOGIC (3 inputs)
	// ==========================================================================
	// Purpose: Allow direct FIFO control in test mode while maintaining
	// normal APB->FIFO->Serializer datapath in production
	// Normal: APB writes to TX FIFO, Serializer reads from TX FIFO
	// Test (override_en=1): Direct write/read control from test port
	assign w_fifo_tx_wr_en_in = i_dbg_fifo_tx_override_en ? i_dbg_fifo_tx_wr_en : w_tx_fifo_push;
	assign w_fifo_tx_data_in = i_dbg_fifo_tx_override_en ? i_dbg_fifo_tx_data : w_tx_fifo_data;
	assign w_fifo_tx_rd_en_in = i_dbg_fifo_tx_override_en ? i_dbg_fifo_tx_rd_en : w_tx_fifo_pop;
	
	// ==========================================================================
	// FIFO RX OVERRIDE & MUX LOGIC (3 inputs)
	// ==========================================================================
	// Purpose: Allow direct FIFO control in test mode while maintaining
	// normal Deserializer->FIFO->APB datapath in production
	// Normal: Deserializer writes to RX FIFO, APB reads from RX FIFO
	// Test (override_en=1): Direct write/read control from test port
	assign w_fifo_rx_wr_en_in = i_dbg_fifo_rx_override_en ? i_dbg_fifo_rx_wr_en : w_rx_fifo_push;
	assign w_fifo_rx_data_in = i_dbg_fifo_rx_override_en ? i_dbg_fifo_rx_data : w_rx_fifo_data;
	assign w_fifo_rx_rd_en_in = i_dbg_fifo_rx_override_en ? i_dbg_fifo_rx_rd_en : w_rx_fifo_pop;
	
	// ==========================================================================
	// BAUD RATE GENERATOR OVERRIDE & MUX LOGIC (2 inputs)
	// ==========================================================================
	// Purpose: Allow direct baud generator control in test mode while maintaining
	// normal APB-controlled configuration in production
	// Normal: Enable/divisor from APB registers (only active when TX is busy)
	// Test (override_en=1): Enable/divisor from test port
	assign w_baud_enable_in = i_dbg_baud_override_en ? i_dbg_baud_enable : (w_global_en & w_tx_busy);
	assign w_baud_div_val_in = i_dbg_baud_override_en ? i_dbg_baud_div_val : w_div_val;

	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			s_rx_ovf_err <= 1'b0;
			s_tx_und_err <= 1'b0;
			s_tx_path_en_d <= 1'b0;
			s_tx_run <= 1'b0;
		end else begin
			s_tx_path_en_d <= w_tx_path_en;

			if (w_sw_reset || !w_global_en) begin
				s_tx_run <= 1'b0;
			end else begin
				if (w_tx_start) begin
					s_tx_run <= 1'b1;
				end else if (s_tx_run && !w_tx_busy && w_tx_fifo_empty) begin
					s_tx_run <= 1'b0;
				end
			end

			if (w_sw_reset || w_clear_err) begin
				s_rx_ovf_err <= 1'b0;
				s_tx_und_err <= 1'b0;
			end else begin
				if (w_rx_ovf_pulse) begin
					s_rx_ovf_err <= 1'b1;
				end
				if (w_tx_path_en && !s_tx_path_en_d && !w_tx_busy && w_tx_fifo_empty) begin
					s_tx_und_err <= 1'b1;
				end
			end
		end
	end

	apb_slave_regs #(
		.ADDR_WIDTH(APB_ADDR_WIDTH),
		.DATA_WIDTH(APB_DATA_WIDTH)
	) u_apb_slave_regs (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_psel(i_psel),
		.i_penable(i_penable),
		.i_pwrite(i_pwrite),
		.i_paddr(i_paddr),
		.i_pwdata(i_pwdata),
		.o_prdata(o_prdata),
		.o_pready(o_pready),
		.o_pslverr(o_pslverr),
		.o_tx_data(w_tx_fifo_data),
		.o_tx_push(w_tx_fifo_push),
		.i_tx_full(w_tx_fifo_full),
		.i_tx_busy(w_tx_busy),
		.i_tx_und_err(s_tx_und_err),
		.i_rx_data(w_rx_fifo_q),
		.o_rx_pop(w_rx_fifo_pop),
		.i_rx_empty(w_rx_fifo_empty),
		.i_rx_ovf_err(s_rx_ovf_err),
		.o_global_en(w_global_en),
		.o_sw_reset(w_sw_reset),
		.o_clear_err(w_clear_err),
		.o_tx_start(w_tx_start),
		.o_rx_enable(w_rx_enable),
		.o_div_val(w_div_val)
	);

	fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(FIFO_DEPTH)
	) u_fifo_tx (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_wr_en(w_fifo_tx_wr_en_in),
		.i_data(w_fifo_tx_data_in),
		.o_full(w_tx_fifo_full),
		.i_rd_en(w_fifo_tx_rd_en_in),
		.o_data(w_tx_fifo_q),
		.o_rd_valid(w_tx_fifo_rd_valid),
		.o_empty(w_tx_fifo_empty)
	);

	fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(FIFO_DEPTH)
	) u_fifo_rx (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_wr_en(w_fifo_rx_wr_en_in),
		.i_data(w_fifo_rx_data_in),
		.o_full(w_rx_fifo_full),
		.i_rd_en(w_fifo_rx_rd_en_in),
		.o_data(w_rx_fifo_q),
		.o_rd_valid(),
		.o_empty(w_rx_fifo_empty)
	);

	serializer #(
		.DATA_WIDTH(DATA_WIDTH)
	) u_serializer (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_baud_tick(w_ser_baud_tick_in),
		.i_tx_data(w_ser_tx_data_in),
		.i_tx_fifo_empty(w_ser_tx_fifo_empty_in),
		.i_tx_data_valid(w_ser_tx_data_valid_in),
		.o_tx_fifo_pop(w_tx_fifo_pop),
		.o_serial_data(o_serial_tx),
		.o_tx_busy(w_tx_busy),
		.o_tx_sample_tick(o_tx_sample_tick)
	);

	deserializer #(
		.DATA_WIDTH(DATA_WIDTH)
	) u_deserializer (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_serial_data(w_des_serial_data_in),
		.i_sample_valid(w_des_sample_valid_in),
		.i_enable(w_des_enable_in),
		.i_fifo_full(w_des_fifo_full_in),
		.o_para_data(w_rx_fifo_data),
		.o_push(w_rx_fifo_push),
		.o_ovf_pulse(w_rx_ovf_pulse)
	);

	baud_rate_gen #(
		.DIV_WIDTH(DIV_WIDTH)
	) u_tx_baud_rate_gen (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_enable(w_baud_enable_in),
		.i_div_val(w_baud_div_val_in),
		.o_tick(w_tx_tick)
	);

	assign o_tx_valid = w_tx_busy;

	// ==========================================================================
	// TX FIFO OBSERVABILITY OUTPUTS
	// ==========================================================================
	assign o_dbg_tx_fifo_q = w_tx_fifo_q;
	assign o_dbg_tx_fifo_push = w_tx_fifo_push;
	assign o_dbg_tx_fifo_pop = w_tx_fifo_pop;
	assign o_dbg_tx_fifo_full = w_tx_fifo_full;
	assign o_dbg_tx_fifo_empty = w_tx_fifo_empty;
	assign o_dbg_tx_fifo_rd_valid = w_tx_fifo_rd_valid;

	// ==========================================================================
	// RX FIFO OBSERVABILITY OUTPUTS
	// ==========================================================================
	assign o_dbg_rx_fifo_q = w_rx_fifo_q;
	assign o_dbg_rx_fifo_pop = w_rx_fifo_pop;
	assign o_dbg_rx_fifo_full = w_rx_fifo_full;
	assign o_dbg_rx_fifo_empty = w_rx_fifo_empty;

	// ==========================================================================
	// CONTROL & STATUS OBSERVABILITY OUTPUTS
	// ==========================================================================
	assign o_dbg_tx_tick = w_tx_tick;
	assign o_dbg_tx_path_en = w_tx_path_en;
	assign o_dbg_global_en = w_global_en;
	assign o_dbg_tx_und_err = s_tx_und_err;
	assign o_dbg_rx_ovf_err = s_rx_ovf_err;

	// ==========================================================================
	// DESERIALIZER CHAIN OBSERVABILITY OUTPUTS
	// ==========================================================================
	assign o_dbg_des_o_para_data = w_rx_fifo_data;
	assign o_dbg_des_o_push = w_rx_fifo_push;
	assign o_dbg_des_o_ovf_pulse = w_rx_ovf_pulse;

endmodule
