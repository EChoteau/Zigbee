`include "../input_data/TOP_netlist.v"

/////////////////////////////
//  Top-level module for IO PAD
/////////////////////////////

module top_io #(
	parameter APB_ADDR_WIDTH = 8,
	parameter APB_DATA_WIDTH = 32,
	parameter DATA_WIDTH     = 8
)(
	// System signals
	input i_clk,
	input i_rst_n,

	// APB signals input
	input i_psel,
	input i_penable,
	input i_pwrite,
	input [APB_ADDR_WIDTH-1:0] i_paddr,
	input [DATA_WIDTH-1:0] i_pwdata,

	// APB signals output
	output o_pready,
	output o_pslverr,
	output o_tx_valid,
	output [DATA_WIDTH-1:0] o_prdata,

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
wire [APB_ADDR_WIDTH-1:0] i_paddr_P;
wire [APB_DATA_WIDTH-1:0] i_pwdata_P;

// APB signals output
wire o_pready_P;
wire o_pslverr_P;
wire o_tx_valid_P;
wire [APB_DATA_WIDTH-1:0] o_prdata_P;

// Serial interface input (from CDR)
wire i_serial_rx_P;
wire i_cdr_sample_valid_P;

// Serial interface output (to MODULATION)
wire o_serial_tx_P;
wire o_tx_sample_tick_P;

// Generate variable for loops
genvar i;


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
generate
    // APB address input 
	    for (i = 0; i < APB_ADDR_WIDTH; i = i + 1) begin : gen_paddr
        ITP io_i_paddr ( .PAD(i_paddr[i]), .Y(i_paddr_P[i]) );
    end

    // APB write data input
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_pwdata
        ITP io_i_pwdata ( .PAD(i_pwdata[i]), .Y(i_pwdata_P[i]) );
    end
endgenerate

// --- OUTPUT ---
// Serial interface output (to MODULATION)
BU12SP io_o_serial_tx ( .A(o_serial_tx_P), .PAD(o_serial_tx) );
BU12SP io_o_tx_sample_tick ( .A(o_tx_sample_tick_P), .PAD(o_tx_sample_tick) );

// Static APB signals output
BU12SP io_o_pready ( .A(o_pready_P), .PAD(o_pready) );
BU12SP io_o_pslverr ( .A(o_pslverr_P), .PAD(o_pslverr) );
BU12SP io_o_tx_valid ( .A(o_tx_valid_P), .PAD(o_tx_valid) );

// Dynamic APB signals output
generate
    // APB read data output
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_prdata
        BU12SP io_o_prdata ( .A(o_prdata_P[i]), .PAD(o_prdata[i]) );
    end
endgenerate

// --- PAD constraints ---
// Padding for unused bits
assign i_pwdata_P[APB_DATA_WIDTH-1 : DATA_WIDTH] = 0;
// o_prdata_P[APB_DATA_WIDTH-1 : DATA_WIDTH] --> High-Z

endmodule
