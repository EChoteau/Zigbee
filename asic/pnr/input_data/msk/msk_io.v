module msk_io (
    input        i_clk,
    input        i_rst_n,
    input        i_flag_enable,
    input        i_enable_ech,
    input        i_b_in,
    output [5:0] o_I_BB,
    output [5:0] o_Q_BB
);

wire i_clk_P;
wire i_rst_n_P;
wire i_flag_enable_P;
wire i_enable_ech_P;
wire i_b_in_P;
wire signed [5:0] o_I_BB_P;
wire signed [5:0] o_Q_BB_P;

top_msk top_msk_inst (
	.i_clk(i_clk_P),
	.i_rst_n(i_rst_n_P),
	.i_flag_enable(i_flag_enable_P),
	.i_enable_ech(i_enable_ech_P),
	.i_b_in(i_b_in_P),
	.o_I_BB(o_I_BB_P),
	.o_Q_BB(o_Q_BB_P)
);

ITP io_i_clk ( .PAD(i_clk), .Y(i_clk_P) );
ITP io_i_rst_n ( .PAD(i_rst_n), .Y(i_rst_n_P) );
ITP io_i_flag_enable ( .PAD(i_flag_enable), .Y(i_flag_enable_P) );
ITP io_i_enable_ech ( .PAD(i_enable_ech), .Y(i_enable_ech_P) );
ITP io_i_b_in ( .PAD(i_b_in), .Y(i_b_in_P) );

BU12SP io_o_I_BB_0 ( .A(o_I_BB_P[0]), .PAD(o_I_BB[0]) );
BU12SP io_o_I_BB_1 ( .A(o_I_BB_P[1]), .PAD(o_I_BB[1]) );
BU12SP io_o_I_BB_2 ( .A(o_I_BB_P[2]), .PAD(o_I_BB[2]) );
BU12SP io_o_I_BB_3 ( .A(o_I_BB_P[3]), .PAD(o_I_BB[3]) );
BU12SP io_o_I_BB_4 ( .A(o_I_BB_P[4]), .PAD(o_I_BB[4]) );
BU12SP io_o_I_BB_5 ( .A(o_I_BB_P[5]), .PAD(o_I_BB[5]) );

BU12SP io_o_Q_BB_0 ( .A(o_Q_BB_P[0]), .PAD(o_Q_BB[0]) );
BU12SP io_o_Q_BB_1 ( .A(o_Q_BB_P[1]), .PAD(o_Q_BB[1]) );
BU12SP io_o_Q_BB_2 ( .A(o_Q_BB_P[2]), .PAD(o_Q_BB[2]) );
BU12SP io_o_Q_BB_3 ( .A(o_Q_BB_P[3]), .PAD(o_Q_BB[3]) );
BU12SP io_o_Q_BB_4 ( .A(o_Q_BB_P[4]), .PAD(o_Q_BB[4]) );
BU12SP io_o_Q_BB_5 ( .A(o_Q_BB_P[5]), .PAD(o_Q_BB[5]) );

endmodule
