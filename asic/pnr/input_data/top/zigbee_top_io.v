`include "../input_data/zigbee_top_synth.v"

/////////////////////////////
//  Top-level module for IO PAD
/////////////////////////////

module top_io (
	// System signals
	input i_clk,
	input i_rst_n,

	// 6 dedicated configuration pins:
    input logic [2:0]   i_cfg_top,
    input logic [2:0]   i_cfg,

    // Test bus ports (external interface)
    input  logic [21:0] i_bus_in,
    output logic [13:0] o_bus_out

);



/////////////////////////////
//  Internal logic 
/////////////////////////////
// System signals
wire i_clk_P;
wire i_rst_n_P;

// 6 dedicated configuration pins:
wire	[2:0]	i_cfg_top_P;
wire	[2:0]	i_cfg_P;

// Test bus ports (external interface)
wire	[21:0] 	i_bus_in_P;
wire  	[13:0] 	o_bus_out_P;




//////////////////////////
//  Instantiation of the top module 
//////////////////////////

top top_inst(

	.i_clk(i_clk_P),
    .i_rst_n(i_rst_n_P),

	.i_cfg_top(i_cfg_top_P),
	.i_cfg(i_cfg_P),
	.i_bus_in(i_bus_in_P),
    .o_bus_out(o_bus_out_P),

);


////////////////////////////
//  IO PAD 
///////////////////////////

// --- INPUT ---
// System signals
ITP io_i_clk ( .PAD(i_clk), .Y(i_clk_P) );
ITP io_i_rst_n ( .PAD(i_rst_n), .Y(i_rst_n_P) );

// 6 dedicated configuration pins:
ITP	io_i_cfg_top_0 ( .PAD(i_cfg_top[0]), .Y(i_cfg_top_P[0]) );
ITP	io_i_cfg_top_1 ( .PAD(i_cfg_top[1]), .Y(i_cfg_top_P[1]) );
ITP	io_i_cfg_top_2 ( .PAD(i_cfg_top[2]), .Y(i_cfg_top_P[2]) );

ITP	io_i_cfg_0 ( .PAD(i_cfg[0]), .Y(i_cfg_P[0]) );
ITP	io_i_cfg_1 ( .PAD(i_cfg[1]), .Y(i_cfg_P[1]) );
ITP	io_i_cfg_2 ( .PAD(i_cfg[2]), .Y(i_cfg_P[2]) );

// Bus ports
ITP	io_i_bus_in_0  ( .PAD(i_bus_in[0]), 	.Y(i_bus_in_P[0]) );
ITP	io_i_bus_in_1  ( .PAD(i_bus_in[1]), 	.Y(i_bus_in_P[1]) );
ITP	io_i_bus_in_2  ( .PAD(i_bus_in[2]), 	.Y(i_bus_in_P[2]) );
ITP	io_i_bus_in_3  ( .PAD(i_bus_in[3]), 	.Y(i_bus_in_P[3]) );
ITP	io_i_bus_in_4  ( .PAD(i_bus_in[4]), 	.Y(i_bus_in_P[4]) );
ITP	io_i_bus_in_5  ( .PAD(i_bus_in[5]), 	.Y(i_bus_in_P[5]) );
ITP	io_i_bus_in_6  ( .PAD(i_bus_in[6]), 	.Y(i_bus_in_P[6]) );
ITP	io_i_bus_in_7  ( .PAD(i_bus_in[7]), 	.Y(i_bus_in_P[7]) );
ITP	io_i_bus_in_8  ( .PAD(i_bus_in[8]),	 	.Y(i_bus_in_P[8]) );
ITP	io_i_bus_in_9  ( .PAD(i_bus_in[9]), 	.Y(i_bus_in_P[9]) );
ITP	io_i_bus_in_10 ( .PAD(i_bus_in[10]), 	.Y(i_bus_in_P[10]) );
ITP	io_i_bus_in_11 ( .PAD(i_bus_in[11]), 	.Y(i_bus_in_P[11]) );
ITP	io_i_bus_in_12 ( .PAD(i_bus_in[12]), 	.Y(i_bus_in_P[12]) );
ITP	io_i_bus_in_13 ( .PAD(i_bus_in[13]), 	.Y(i_bus_in_P[13]) );
ITP	io_i_bus_in_14 ( .PAD(i_bus_in[14]), 	.Y(i_bus_in_P[14]) );
ITP	io_i_bus_in_15 ( .PAD(i_bus_in[15]), 	.Y(i_bus_in_P[15]) );
ITP	io_i_bus_in_16 ( .PAD(i_bus_in[16]), 	.Y(i_bus_in_P[16]) );
ITP	io_i_bus_in_17 ( .PAD(i_bus_in[17]), 	.Y(i_bus_in_P[17]) );
ITP	io_i_bus_in_18 ( .PAD(i_bus_in[18]), 	.Y(i_bus_in_P[18]) );
ITP	io_i_bus_in_19 ( .PAD(i_bus_in[19]), 	.Y(i_bus_in_P[19]) );
ITP	io_i_bus_in_20 ( .PAD(i_bus_in[20]), 	.Y(i_bus_in_P[20]) );
ITP	io_i_bus_in_21 ( .PAD(i_bus_in[21]), 	.Y(i_bus_in_P[21]) );


// --- OUTPUT ---
// Bus ports
BU12SP io_o_bus_out_0  ( .A(o_bus_out_P[0]), 	.PAD(o_bus_c[0]) );
BU12SP io_o_bus_out_1  ( .A(o_bus_out_P[1]), 	.PAD(o_bus_c[1]) );
BU12SP io_o_bus_out_2  ( .A(o_bus_out_P[2]), 	.PAD(o_bus_c[2]) );
BU12SP io_o_bus_out_3  ( .A(o_bus_out_P[3]), 	.PAD(o_bus_c[3]) );
BU12SP io_o_bus_out_4  ( .A(o_bus_out_P[4]), 	.PAD(o_bus_c[4]) );
BU12SP io_o_bus_out_5  ( .A(o_bus_out_P[5]), 	.PAD(o_bus_c[5]) );
BU12SP io_o_bus_out_6  ( .A(o_bus_out_P[6]), 	.PAD(o_bus_c[6]) );
BU12SP io_o_bus_out_7  ( .A(o_bus_out_P[7]), 	.PAD(o_bus_c[7]) );
BU12SP io_o_bus_out_8  ( .A(o_bus_out_P[8]), 	.PAD(o_bus_c[8]) );
BU12SP io_o_bus_out_9  ( .A(o_bus_out_P[9]), 	.PAD(o_bus_c[9]) );
BU12SP io_o_bus_out_10 ( .A(o_bus_out_P[10]), 	.PAD(o_bus_c[10]) );
BU12SP io_o_bus_out_11 ( .A(o_bus_out_P[11]), 	.PAD(o_bus_c[11]) );
BU12SP io_o_bus_out_12 ( .A(o_bus_out_P[12]), 	.PAD(o_bus_c[12]) );
BU12SP io_o_bus_out_13 ( .A(o_bus_out_P[13]), 	.PAD(o_bus_c[13]) );

// --- PAD constraints ---
//No constraints for now

endmodule
