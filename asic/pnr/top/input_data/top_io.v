`include "../input_data/TOP_netlist.v"

module top_io (
	input i_clk,
	input i_rst_n,
	input signed [7:0] i_phase,
	output signed [7:0] o_phase_deriv
);

wire i_clk_P;
wire i_rst_n_P;
wire signed [7:0] i_phase_P;
wire signed [7:0] o_phase_deriv_P;

derivative #(
	.WIDTH(8)
) derivative_inst (
	.i_clk(i_clk_P),
	.i_rst_n(i_rst_n_P),
	.i_phase(i_phase_P),
	.o_phase_deriv(o_phase_deriv_P)
);

ITP io_i_clk ( .PAD(i_clk), .Y(i_clk_P) );
ITP io_i_rst_n ( .PAD(i_rst_n), .Y(i_rst_n_P) );

ITP io_i_phase_0 ( .PAD(i_phase[0]), .Y(i_phase_P[0]) );
ITP io_i_phase_1 ( .PAD(i_phase[1]), .Y(i_phase_P[1]) );
ITP io_i_phase_2 ( .PAD(i_phase[2]), .Y(i_phase_P[2]) );
ITP io_i_phase_3 ( .PAD(i_phase[3]), .Y(i_phase_P[3]) );
ITP io_i_phase_4 ( .PAD(i_phase[4]), .Y(i_phase_P[4]) );
ITP io_i_phase_5 ( .PAD(i_phase[5]), .Y(i_phase_P[5]) );
ITP io_i_phase_6 ( .PAD(i_phase[6]), .Y(i_phase_P[6]) );
ITP io_i_phase_7 ( .PAD(i_phase[7]), .Y(i_phase_P[7]) );

BU12SP io_o_phase_deriv_0 ( .A(o_phase_deriv_P[0]), .PAD(o_phase_deriv[0]) );
BU12SP io_o_phase_deriv_1 ( .A(o_phase_deriv_P[1]), .PAD(o_phase_deriv[1]) );
BU12SP io_o_phase_deriv_2 ( .A(o_phase_deriv_P[2]), .PAD(o_phase_deriv[2]) );
BU12SP io_o_phase_deriv_3 ( .A(o_phase_deriv_P[3]), .PAD(o_phase_deriv[3]) );
BU12SP io_o_phase_deriv_4 ( .A(o_phase_deriv_P[4]), .PAD(o_phase_deriv[4]) );
BU12SP io_o_phase_deriv_5 ( .A(o_phase_deriv_P[5]), .PAD(o_phase_deriv[5]) );
BU12SP io_o_phase_deriv_6 ( .A(o_phase_deriv_P[6]), .PAD(o_phase_deriv[6]) );
BU12SP io_o_phase_deriv_7 ( .A(o_phase_deriv_P[7]), .PAD(o_phase_deriv[7]) );

endmodule
