`include "../input_data/top_synth.v"

/////////////////////////////
//  Top-level module for IO PAD
/////////////////////////////

module top_io (
	// System signals
	input i_clk,
	input i_rst_n,

	// 6 dedicated configuration pins:
    input logic [2:0]   i_top_cfg,
    input logic [2:0]   i_wrapper_cfg,

    // Test bus ports (external interface)
    input  logic [11:0] i_bus_a,  	// Bus A
    input  logic [9:0] i_bus_b,  	// Bus B
    output logic [11:0] o_bus_c,  	// Bus C
    output logic [1:0] o_bus_d  	// Bus D

);



/////////////////////////////
//  Internal logic 
/////////////////////////////
// System signals
wire i_clk_P;
wire i_rst_n_P;

// 6 dedicated configuration pins:
wire	[2:0]	i_top_cfg_P;
wire	[2:0]	i_wrapper_cfg_P;

// Test bus ports (external interface)
wire	[11:0] 	i_bus_a_P;  	// Bus A
wire  	[9:0] 	i_bus_b_P;  	// Bus B
wire  	[11:0] 	o_bus_c_P;  	// Bus C
wire  	[1:0] 	o_bus_d_P;  	// Bus D



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



// 6 dedicated configuration pins:
ITP	io_i_top_cfg_0 ( .PAD(i_top_cfg[0]), .Y(i_top_cfg_P[0]) );
ITP	io_i_top_cfg_1 ( .PAD(i_top_cfg[1]), .Y(i_top_cfg_P[1]) );
ITP	io_i_top_cfg_2 ( .PAD(i_top_cfg[2]), .Y(i_top_cfg_P[2]) );

ITP	io_i_wrapper_cfg_0 ( .PAD(i_wrapper_cfg[0]), .Y(i_wrapper_cfg_P[0]) );
ITP	io_i_wrapper_cfg_1 ( .PAD(i_wrapper_cfg[1]), .Y(i_wrapper_cfg_P[1]) );
ITP	io_i_wrapper_cfg_2 ( .PAD(i_wrapper_cfg[2]), .Y(i_wrapper_cfg_P[2]) );

// Bus ports
ITP	io_i_bus_a_0 ( .PAD(i_bus_a[0]), .Y(i_bus_a_P[0]) );
ITP	io_i_bus_a_1 ( .PAD(i_bus_a[1]), .Y(i_bus_a_P[1]) );
ITP	io_i_bus_a_2 ( .PAD(i_bus_a[2]), .Y(i_bus_a_P[2]) );
ITP	io_i_bus_a_3 ( .PAD(i_bus_a[3]), .Y(i_bus_a_P[3]) );
ITP	io_i_bus_a_4 ( .PAD(i_bus_a[4]), .Y(i_bus_a_P[4]) );
ITP	io_i_bus_a_5 ( .PAD(i_bus_a[5]), .Y(i_bus_a_P[5]) );
ITP	io_i_bus_a_6 ( .PAD(i_bus_a[6]), .Y(i_bus_a_P[6]) );
ITP	io_i_bus_a_7 ( .PAD(i_bus_a[7]), .Y(i_bus_a_P[7]) );
ITP	io_i_bus_a_8 ( .PAD(i_bus_a[8]), .Y(i_bus_a_P[8]) );
ITP	io_i_bus_a_9 ( .PAD(i_bus_a[9]), .Y(i_bus_a_P[9]) );
ITP	io_i_bus_a_10 ( .PAD(i_bus_a[10]), .Y(i_bus_a_P[10]) );
ITP	io_i_bus_a_11 ( .PAD(i_bus_a[11]), .Y(i_bus_a_P[11]) );

ITP	io_i_bus_b_0 ( .PAD(i_bus_b[0]), .Y(i_bus_b_P[0]) );
ITP	io_i_bus_b_1 ( .PAD(i_bus_b[1]), .Y(i_bus_b_P[1]) );
ITP	io_i_bus_b_2 ( .PAD(i_bus_b[2]), .Y(i_bus_b_P[2]) );
ITP	io_i_bus_b_3 ( .PAD(i_bus_b[3]), .Y(i_bus_b_P[3]) );
ITP	io_i_bus_b_4 ( .PAD(i_bus_b[4]), .Y(i_bus_b_P[4]) );
ITP	io_i_bus_b_5 ( .PAD(i_bus_b[5]), .Y(i_bus_b_P[5]) );
ITP	io_i_bus_b_6 ( .PAD(i_bus_b[6]), .Y(i_bus_b_P[6]) );
ITP	io_i_bus_b_7 ( .PAD(i_bus_b[7]), .Y(i_bus_b_P[7]) );
ITP	io_i_bus_b_8 ( .PAD(i_bus_b[8]), .Y(i_bus_b_P[8]) );
ITP	io_i_bus_b_9 ( .PAD(i_bus_b[9]), .Y(i_bus_b_P[9]) );


// --- OUTPUT ---
// Bus ports
BU12SP io_o_bus_c_0 ( .A(o_bus_c_P[0]), .PAD(o_bus_c[0]) );
BU12SP io_o_bus_c_1 ( .A(o_bus_c_P[1]), .PAD(o_bus_c[1]) );
BU12SP io_o_bus_c_2 ( .A(o_bus_c_P[2]), .PAD(o_bus_c[2]) );
BU12SP io_o_bus_c_3 ( .A(o_bus_c_P[3]), .PAD(o_bus_c[3]) );
BU12SP io_o_bus_c_4 ( .A(o_bus_c_P[4]), .PAD(o_bus_c[4]) );
BU12SP io_o_bus_c_5 ( .A(o_bus_c_P[5]), .PAD(o_bus_c[5]) );
BU12SP io_o_bus_c_6 ( .A(o_bus_c_P[6]), .PAD(o_bus_c[6]) );
BU12SP io_o_bus_c_7 ( .A(o_bus_c_P[7]), .PAD(o_bus_c[7]) );
BU12SP io_o_bus_c_8 ( .A(o_bus_c_P[8]), .PAD(o_bus_c[8]) );
BU12SP io_o_bus_c_9 ( .A(o_bus_c_P[9]), .PAD(o_bus_c[9]) );
BU12SP io_o_bus_c_10 ( .A(o_bus_c_P[10]), .PAD(o_bus_c[10]) );
BU12SP io_o_bus_c_11 ( .A(o_bus_c_P[11]), .PAD(o_bus_c[11]) );

BU12SP io_o_bus_d_0 ( .A(o_bus_d_P[0]), .PAD(o_bus_d[0]) );
BU12SP io_o_bus_d_1 ( .A(o_bus_d_P[1]), .PAD(o_bus_d[1]) );


// --- PAD constraints ---
//No constraints for now

endmodule
