module CDR_io (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [5:0]  i_dphi,
    output wire        o_data,
    output wire        o_enable
);

    // wires internes (côté core)
    wire        i_clk_P;
    wire        i_rst_n_P;
    wire [5:0]  i_dphi_P;
    wire        o_data_P;
    wire        o_enable_P;

    // instanciation du core CDR
    CDR u_cdr (
        .i_clk    (i_clk_P),
        .i_rst_n  (i_rst_n_P),
        .i_dphi   (i_dphi_P),
        .o_data   (o_data_P),
        .o_enable (o_enable_P)
    );

    // IOs d'entrée
    ITP io_i_clk   ( .PAD(i_clk),   .Y(i_clk_P)   );
    ITP io_i_rst_n ( .PAD(i_rst_n), .Y(i_rst_n_P) );

    ITP io_i_dphi_0 ( .PAD(i_dphi[0]), .Y(i_dphi_P[0]) );
    ITP io_i_dphi_1 ( .PAD(i_dphi[1]), .Y(i_dphi_P[1]) );
    ITP io_i_dphi_2 ( .PAD(i_dphi[2]), .Y(i_dphi_P[2]) );
    ITP io_i_dphi_3 ( .PAD(i_dphi[3]), .Y(i_dphi_P[3]) );
    ITP io_i_dphi_4 ( .PAD(i_dphi[4]), .Y(i_dphi_P[4]) );
    ITP io_i_dphi_5 ( .PAD(i_dphi[5]), .Y(i_dphi_P[5]) );

    // IOs de sortie
    BU12SP io_o_data   ( .A(o_data_P),   .PAD(o_data)   );
    BU12SP io_o_enable ( .A(o_enable_P), .PAD(o_enable) );

endmodule
