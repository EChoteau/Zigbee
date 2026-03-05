module interface_top #(
	parameter APB_ADDR_WIDTH = 8,
	parameter APB_DATA_WIDTH = 32,
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
	output logic                       o_serial_tx,
	output logic                       o_tx_valid,
	output logic                       o_tx_sample_tick
);

	logic [DATA_WIDTH-1:0] w_tx_fifo_data;
	logic                  w_tx_fifo_push;
	logic                  w_tx_fifo_full;
	logic                  w_tx_fifo_pop;
	logic [DATA_WIDTH-1:0] w_tx_fifo_q;
	logic                  w_tx_fifo_rd_valid;
	logic                  w_tx_fifo_empty;

	logic [DATA_WIDTH-1:0] w_rx_fifo_data;
	logic                  w_rx_fifo_push;
	logic                  w_rx_fifo_full;
	logic                  w_rx_fifo_pop;
	logic [DATA_WIDTH-1:0] w_rx_fifo_q;
	logic                  w_rx_fifo_empty;

	logic                  w_global_en;
	logic                  w_sw_reset;
	logic                  w_clear_err;
	logic                  w_tx_start;
	logic                  w_rx_enable;
	logic [DIV_WIDTH-1:0]  w_div_val;

	logic                  w_tx_tick;
	logic                  w_tx_busy;
	logic                  w_rx_ovf_pulse;
	logic                  s_rx_ovf_err;
	logic                  s_tx_und_err;
	logic                  s_tx_busy_d;
	logic                  s_tx_path_en_d;

	logic                  w_tx_path_en;
	logic                  w_rx_path_en;

	assign w_tx_path_en = w_global_en & w_tx_start;
	assign w_rx_path_en = w_global_en & w_rx_enable;

	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			s_rx_ovf_err <= 1'b0;
			s_tx_und_err <= 1'b0;
			s_tx_busy_d  <= 1'b0;
			s_tx_path_en_d <= 1'b0;
		end else begin
			s_tx_busy_d    <= w_tx_busy;
			s_tx_path_en_d <= w_tx_path_en;

			if (w_sw_reset || w_clear_err) begin
				s_rx_ovf_err <= 1'b0;
				s_tx_und_err <= 1'b0;
			end else begin
				if (w_rx_ovf_pulse) begin
					s_rx_ovf_err <= 1'b1;
				end
				if ((w_tx_path_en && !s_tx_path_en_d && !w_tx_busy && w_tx_fifo_empty) ||
					(s_tx_busy_d && !w_tx_busy && w_tx_path_en && w_tx_fifo_empty)) begin
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
		.i_rst_n(i_rst_n & ~w_sw_reset),
		.i_wr_en(w_tx_fifo_push),
		.i_data(w_tx_fifo_data),
		.o_full(w_tx_fifo_full),
		.i_rd_en(w_tx_fifo_pop),
		.o_data(w_tx_fifo_q),
		.o_rd_valid(w_tx_fifo_rd_valid),
		.o_empty(w_tx_fifo_empty)
	);

	fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(FIFO_DEPTH)
	) u_fifo_rx (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n & ~w_sw_reset),
		.i_wr_en(w_rx_fifo_push),
		.i_data(w_rx_fifo_data),
		.o_full(w_rx_fifo_full),
		.i_rd_en(w_rx_fifo_pop),
		.o_data(w_rx_fifo_q),
		.o_rd_valid(),
		.o_empty(w_rx_fifo_empty)
	);

	serializer #(
		.DATA_WIDTH(DATA_WIDTH)
	) u_serializer (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n & ~w_sw_reset),
		.i_baud_tick(w_tx_tick),
		.i_tx_data(w_tx_fifo_q),
		.i_tx_fifo_empty(w_tx_fifo_empty | ~w_tx_path_en),
		.i_tx_data_valid(w_tx_fifo_rd_valid),
		.o_tx_fifo_pop(w_tx_fifo_pop),
		.o_serial_data(o_serial_tx),
		.o_tx_busy(w_tx_busy),
		.o_tx_sample_tick(o_tx_sample_tick)
	);

	deserializer #(
		.DATA_WIDTH(DATA_WIDTH)
	) u_deserializer (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n & ~w_sw_reset),
		.i_serial_data(i_serial_rx),
		.i_sample_valid(i_cdr_sample_valid),
		.i_enable(w_rx_path_en),
		.i_fifo_full(w_rx_fifo_full),
		.o_para_data(w_rx_fifo_data),
		.o_push(w_rx_fifo_push),
		.o_ovf_pulse(w_rx_ovf_pulse)
	);

	baud_rate_gen #(
		.DIV_WIDTH(DIV_WIDTH)
	) u_tx_baud_rate_gen (
		.i_clk(i_clk),
		.i_rst_n(i_rst_n & ~w_sw_reset),
		.i_enable(w_global_en & w_tx_busy),
		.i_div_val(w_div_val),
		.o_tick(w_tx_tick)
	);

	assign o_tx_valid = w_tx_busy;

endmodule
