module demod_io (
	input i_clk,
	input i_rst_n,
	input [3:0] i_i,
	input [3:0] i_q,
	output [5:0] o_i_bb,
	output [5:0] o_q_bb
);

wire i_clk_P;
wire i_rst_n_P;
wire [3:0] i_i_P;
wire [3:0] i_q_P;
wire [5:0] o_i_bb_P;
wire [5:0] o_q_bb_P;

demod_system_complete demod_system_complete_inst (
        .i_clk     (i_clk_P),
        .i_rst_n   (i_rst_n_P),
        .i_i       (i_i_P),
        .i_q       (i_q_P),
        .o_i_bb    (o_i_bb_P),
        .o_q_bb    (o_i_bb_P)
);

ITP io_i_clk ( .PAD(i_clk), .Y(i_clk_P) );
ITP io_i_rst_n ( .PAD(i_rst_n), .Y(i_rst_n_P) );

ITP io_i_i_0 ( .PAD(i_i[0]), .Y(i_i_P[0]) );
ITP io_i_i_1 ( .PAD(i_i[1]), .Y(i_i_P[1]) );
ITP io_i_i_2 ( .PAD(i_i[2]), .Y(i_i_P[2]) );
ITP io_i_i_3 ( .PAD(i_i[3]), .Y(i_i_P[3]) );

ITP io_i_q_0 ( .PAD(i_q[0]), .Y(i_q_P[0]) );
ITP io_i_q_1 ( .PAD(i_q[1]), .Y(i_q_P[1]) );
ITP io_i_q_2 ( .PAD(i_q[2]), .Y(i_q_P[2]) );
ITP io_i_q_3 ( .PAD(i_q[3]), .Y(i_q_P[3]) );

BU12SP io_o_i_bb_0 ( .A(o_i_bb_P[0]), .PAD(o_i_bb[0]) );
BU12SP io_o_i_bb_1 ( .A(o_i_bb_P[1]), .PAD(o_i_bb[1]) );
BU12SP io_o_i_bb_2 ( .A(o_i_bb_P[2]), .PAD(o_i_bb[2]) );
BU12SP io_o_i_bb_3 ( .A(o_i_bb_P[3]), .PAD(o_i_bb[3]) );
BU12SP io_o_i_bb_4 ( .A(o_i_bb_P[4]), .PAD(o_i_bb[4]) );
BU12SP io_o_i_bb_5 ( .A(o_i_bb_P[5]), .PAD(o_i_bb[5]) );
                        
BU12SP io_o_q_bb_0 ( .A(o_q_bb_P[0]), .PAD(o_q_bb[0]) );
BU12SP io_o_q_bb_1 ( .A(o_q_bb_P[1]), .PAD(o_q_bb[1]) );
BU12SP io_o_q_bb_2 ( .A(o_q_bb_P[2]), .PAD(o_q_bb[2]) );
BU12SP io_o_q_bb_3 ( .A(o_q_bb_P[3]), .PAD(o_q_bb[3]) );
BU12SP io_o_q_bb_4 ( .A(o_q_bb_P[4]), .PAD(o_q_bb[4]) );
BU12SP io_o_q_bb_5 ( .A(o_q_bb_P[5]), .PAD(o_q_bb[5]) );

endmodule
