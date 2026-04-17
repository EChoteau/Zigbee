`include "../input_data/TOP_netlist.v"

/////////////////////////////
//  Top-level module for IO PAD
/////////////////////////////

module top_io (
	// System signals
	input i_clk,
	input i_rst_n,

	// APB signals input
	input i_psel,
	input i_penable,
	input i_pwrite,
	input [7:0] i_paddr,
	input [7:0] i_pwdata,

	// APB signals output
	output o_pready,
	output o_pslverr,
	output o_tx_valid,
	output [7:0] o_prdata,

	// Serial interface input (from CDR)
	input i_serial_rx,
	input i_cdr_sample_valid,

	// Serial interface output (to MODULATION)
	output o_serial_tx,
	output o_tx_sample_tick
);



/////////////////////////////
//  Internal logic 
/////////////////////////////
// System signals
wire i_clk_P;
wire i_rst_n_P;

// APB signals input
wire i_psel_P;
wire i_penable_P;
wire i_pwrite_P;
wire [7:0] i_paddr_P;
wire [31:0] i_pwdata_P;

// APB signals output
wire o_pready_P;
wire o_pslverr_P;
wire o_tx_valid_P;
wire [31:0] o_prdata_P;

// Serial interface input (from CDR)
wire i_serial_rx_P;
wire i_cdr_sample_valid_P;

// Serial interface output (to MODULATION)
wire o_serial_tx_P;
wire o_tx_sample_tick_P;


//////////////////////////
//  Instantiation of the top module 
//////////////////////////

interface_top interface_top_inst(
	// System signals
	.i_clk(i_clk_P),
    .i_rst_n(i_rst_n_P),

	// APB signals input
	.i_psel(i_psel_P),
	.i_penable(i_penable_P),
	.i_pwrite(i_pwrite_P),
    .i_paddr(i_paddr_P),
    .i_pwdata(i_pwdata_P),

	// APB signals output
	.o_pready(o_pready_P),
	.o_pslverr(o_pslverr_P),
	.o_tx_valid(o_tx_valid_P),
    .o_prdata(o_prdata_P),

	// Serial interface input (from CDR)
	.i_serial_rx(i_serial_rx_P),
	.i_cdr_sample_valid(i_cdr_sample_valid_P),

	// Serial interface output (to MODULATION)
	.o_serial_tx(o_serial_tx_P),
	.o_tx_sample_tick(o_tx_sample_tick_P)
);



////////////////////////////
//  IO PAD 
///////////////////////////

// --- INPUT ---
// System signals
ITP io_i_clk ( .PAD(i_clk), .Y(i_clk_P) );
ITP io_i_rst_n ( .PAD(i_rst_n), .Y(i_rst_n_P) );

// Serial interface input (from CDR)
ITP io_i_serial_rx ( .PAD(i_serial_rx), .Y(i_serial_rx_P) );
ITP io_i_cdr_sample_valid ( .PAD(i_cdr_sample_valid), .Y(i_cdr_sample_valid_P) );

// Static APB signals input
ITP io_i_psel ( .PAD(i_psel), .Y(i_psel_P) );
ITP io_i_penable ( .PAD(i_penable), .Y(i_penable_P) );
ITP io_i_pwrite ( .PAD(i_pwrite), .Y(i_pwrite_P) );

// Dynamic APB signals input
ITP io_i_paddr_0 ( .PAD(i_paddr[0]), .Y(i_paddr_P[0]) );
ITP io_i_paddr_1 ( .PAD(i_paddr[1]), .Y(i_paddr_P[1]) );
ITP io_i_paddr_2 ( .PAD(i_paddr[2]), .Y(i_paddr_P[2]) );
ITP io_i_paddr_3 ( .PAD(i_paddr[3]), .Y(i_paddr_P[3]) );
ITP io_i_paddr_4 ( .PAD(i_paddr[4]), .Y(i_paddr_P[4]) );
ITP io_i_paddr_5 ( .PAD(i_paddr[5]), .Y(i_paddr_P[5]) );
ITP io_i_paddr_6 ( .PAD(i_paddr[6]), .Y(i_paddr_P[6]) );
ITP io_i_paddr_7 ( .PAD(i_paddr[7]), .Y(i_paddr_P[7]) );

ITP io_i_pwdata_0 ( .PAD(i_pwdata[0]), .Y(i_pwdata_P[0]) );
ITP io_i_pwdata_1 ( .PAD(i_pwdata[1]), .Y(i_pwdata_P[1]) );
ITP io_i_pwdata_2 ( .PAD(i_pwdata[2]), .Y(i_pwdata_P[2]) );
ITP io_i_pwdata_3 ( .PAD(i_pwdata[3]), .Y(i_pwdata_P[3]) );
ITP io_i_pwdata_4 ( .PAD(i_pwdata[4]), .Y(i_pwdata_P[4]) );
ITP io_i_pwdata_5 ( .PAD(i_pwdata[5]), .Y(i_pwdata_P[5]) );
ITP io_i_pwdata_6 ( .PAD(i_pwdata[6]), .Y(i_pwdata_P[6]) );
ITP io_i_pwdata_7 ( .PAD(i_pwdata[7]), .Y(i_pwdata_P[7]) );

// --- OUTPUT ---
// Serial interface output (to MODULATION)
BU12SP io_o_serial_tx ( .A(o_serial_tx_P), .PAD(o_serial_tx) );
BU12SP io_o_tx_sample_tick ( .A(o_tx_sample_tick_P), .PAD(o_tx_sample_tick) );

// Static APB signals output
BU12SP io_o_pready ( .A(o_pready_P), .PAD(o_pready) );
BU12SP io_o_pslverr ( .A(o_pslverr_P), .PAD(o_pslverr) );
BU12SP io_o_tx_valid ( .A(o_tx_valid_P), .PAD(o_tx_valid) );

// Dynamic APB signals output
BU12SP io_o_prdata_0 ( .A(o_prdata_P[0]), .PAD(o_prdata[0]) );
BU12SP io_o_prdata_1 ( .A(o_prdata_P[1]), .PAD(o_prdata[1]) );
BU12SP io_o_prdata_2 ( .A(o_prdata_P[2]), .PAD(o_prdata[2]) );
BU12SP io_o_prdata_3 ( .A(o_prdata_P[3]), .PAD(o_prdata[3]) );
BU12SP io_o_prdata_4 ( .A(o_prdata_P[4]), .PAD(o_prdata[4]) );
BU12SP io_o_prdata_5 ( .A(o_prdata_P[5]), .PAD(o_prdata[5]) );
BU12SP io_o_prdata_6 ( .A(o_prdata_P[6]), .PAD(o_prdata[6]) );
BU12SP io_o_prdata_7 ( .A(o_prdata_P[7]), .PAD(o_prdata[7]) );

// --- PAD constraints ---
// Padding for unused bits
assign i_pwdata_P[31:8] = 24'b0;
// o_prdata_P[APB_DATA_WIDTH-1 : DATA_WIDTH] --> High-Z

endmodule
