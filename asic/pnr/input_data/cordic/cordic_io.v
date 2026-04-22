module cordic_io (
	input i_clk,
	input i_rst_n,
	input [7:0] i_i,
	input [7:0] i_q,
	output [12:0] o_phase
);

wire i_clk_P;
wire i_rst_n_P;
wire [7:0] i_i_P;
wire [7:0] i_q_P;
wire [12:0] o_phase_P;

cordic_system_complete cordic_system_complete_inst (
	.i_clk(i_clk_P),
	.i_rst_n(i_rst_n_P),
	.i_i(i_i_P),
	.i_q(i_q_P),
	.o_phase(o_phase_P)
);

ITP io_i_clk ( .PAD(i_clk), .Y(i_clk_P) );
ITP io_i_rst_n ( .PAD(i_rst_n), .Y(i_rst_n_P) );

ITP io_i_i_0 ( .PAD(i_i[0]), .Y(i_i_P[0]) );
ITP io_i_i_1 ( .PAD(i_i[1]), .Y(i_i_P[1]) );
ITP io_i_i_2 ( .PAD(i_i[2]), .Y(i_i_P[2]) );
ITP io_i_i_3 ( .PAD(i_i[3]), .Y(i_i_P[3]) );
ITP io_i_i_4 ( .PAD(i_i[4]), .Y(i_i_P[4]) );
ITP io_i_i_5 ( .PAD(i_i[5]), .Y(i_i_P[5]) );
ITP io_i_i_6 ( .PAD(i_i[6]), .Y(i_i_P[6]) );
ITP io_i_i_7 ( .PAD(i_i[7]), .Y(i_i_P[7]) );

ITP io_i_q_0 ( .PAD(i_q[0]), .Y(i_q_P[0]) );
ITP io_i_q_1 ( .PAD(i_q[1]), .Y(i_q_P[1]) );
ITP io_i_q_2 ( .PAD(i_q[2]), .Y(i_q_P[2]) );
ITP io_i_q_3 ( .PAD(i_q[3]), .Y(i_q_P[3]) );
ITP io_i_q_4 ( .PAD(i_q[4]), .Y(i_q_P[4]) );
ITP io_i_q_5 ( .PAD(i_q[5]), .Y(i_q_P[5]) );
ITP io_i_q_6 ( .PAD(i_q[6]), .Y(i_q_P[6]) );
ITP io_i_q_7 ( .PAD(i_q[7]), .Y(i_q_P[7]) );

BU12SP io_o_phase_0 ( .A(o_phase_P[0]), .PAD(o_phase[0]) );
BU12SP io_o_phase_1 ( .A(o_phase_P[1]), .PAD(o_phase[1]) );
BU12SP io_o_phase_2 ( .A(o_phase_P[2]), .PAD(o_phase[2]) );
BU12SP io_o_phase_3 ( .A(o_phase_P[3]), .PAD(o_phase[3]) );
BU12SP io_o_phase_4 ( .A(o_phase_P[4]), .PAD(o_phase[4]) );
BU12SP io_o_phase_5 ( .A(o_phase_P[5]), .PAD(o_phase[5]) );
BU12SP io_o_phase_6 ( .A(o_phase_P[6]), .PAD(o_phase[6]) );
BU12SP io_o_phase_7 ( .A(o_phase_P[7]), .PAD(o_phase[7]) );
BU12SP io_o_phase_8 ( .A(o_phase_P[8]), .PAD(o_phase[8]) );
BU12SP io_o_phase_9 ( .A(o_phase_P[9]), .PAD(o_phase[9]) );
BU12SP io_o_phase_10 ( .A(o_phase_P[10]), .PAD(o_phase[10]) );
BU12SP io_o_phase_11 ( .A(o_phase_P[11]), .PAD(o_phase[11]) );
BU12SP io_o_phase_12 ( .A(o_phase_P[12]), .PAD(o_phase[12]) );

endmodule
