module demod_wrapper #(
    parameter int CFG_WIDTH   = 3,
    parameter int BUS_A_WIDTH = 10,
    parameter int BUS_B_WIDTH = 12,
    parameter int BUS_C_WIDTH = 12,
    parameter int BUS_D_WIDTH = 2
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg,

    input  logic [BUS_A_WIDTH-1:0] i_bus_a,
    input  logic [BUS_B_WIDTH-1:0] i_bus_b,

    output logic [BUS_C_WIDTH-1:0] o_bus_c,
    output logic [BUS_D_WIDTH-1:0] o_bus_d
);

    localparam logic [2:0] MODE_0 = 3'b000;
    localparam logic [2:0] MODE_1 = 3'b001;
    localparam logic [2:0] MODE_2 = 3'b010;
    localparam logic [2:0] MODE_3 = 3'b011;
    localparam logic [2:0] MODE_4 = 3'b100;
    localparam logic [2:0] MODE_5 = 3'b101;
    localparam logic [2:0] MODE_6 = 3'b110;
    localparam logic [2:0] MODE_7 = 3'b111;

    logic [3:0]        s_test_i;
    logic [3:0]        s_test_q;
    logic signed [7:0] s_test_fir_in;

    assign s_test_i      = i_bus_b[7:4];
    assign s_test_q      = i_bus_b[3:0];
    assign s_test_fir_in = i_bus_b[7:0];

    logic signed [5:0] s_i_bb;
    logic signed [5:0] s_q_bb;

    logic signed [3:0] s_cos_test;
    logic signed [3:0] s_sin_test;

    logic signed [7:0] s_demod_out_i;
    logic signed [7:0] s_demod_out_q;

    demod_top u_demod_top (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_cfg         (i_cfg),

        // Normal inputs unused in wrapper test mode
        .i_i           (4'b1000),
        .i_q           (4'b1000),

        // Debug/test inputs from package bus
        .i_dbg_i       (s_test_i),
        .i_dbg_q       (s_test_q),
        .i_dbg_fir_in  (s_test_fir_in),

        .o_i_bb        (s_i_bb),
        .o_q_bb        (s_q_bb),

        .o_cos_test    (s_cos_test),
        .o_sin_test    (s_sin_test),

        .o_demod_out_i (s_demod_out_i),
        .o_demod_out_q (s_demod_out_q)
    );

    always_comb begin
        o_bus_c = '0;
        o_bus_d = '0;

        unique case (i_cfg)

            MODE_0: begin
                o_bus_c = {s_cos_test, s_demod_out_i};
            end

            MODE_1: begin
                o_bus_c = {s_sin_test, s_demod_out_q};
            end

            MODE_2: begin
                o_bus_c = {s_cos_test, s_demod_out_i};
            end

            MODE_3: begin
                o_bus_c = {s_sin_test, s_demod_out_q};
            end

            MODE_4: begin
                o_bus_c = {s_i_bb, s_q_bb};
            end

            MODE_5: begin
                o_bus_c = {s_i_bb, s_q_bb};
            end

            MODE_6: begin
                o_bus_c = {s_i_bb, s_q_bb};
            end

            MODE_7: begin
                o_bus_c = {s_i_bb, s_q_bb};
            end

            default: begin
                o_bus_c = '0;
            end

        endcase

        o_bus_d = {s_i_bb[5], s_q_bb[5]};
    end

endmodule
