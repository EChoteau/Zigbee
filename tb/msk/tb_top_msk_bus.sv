`timescale 1ns/1ps

module top_msk_bus_wrapper #(
    parameter int SAMPLES_PER_HALF_SINE = 10,
    parameter int MSK_RES               = 6
)(
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic [9:0]             i_bus_in,
    output logic [26:0]            o_bus_out
);

    logic                    i_flag_enable;
    logic                    i_enable_ech;
    logic                    i_b_in;
    logic                    i_dbg_enc_override_en;
    logic                    i_dbg_enc_b_in;
    logic                    i_dbg_demux_override_en;
    logic                    i_dbg_demux_b_enc;
    logic                    i_dbg_shaping_override_en;
    logic                    i_dbg_shaping_a_I;
    logic                    i_dbg_shaping_a_Q;

    logic signed [MSK_RES-1:0] o_I_BB;
    logic signed [MSK_RES-1:0] o_Q_BB;
    logic                    o_dbg_b_enc;
    logic                    o_dbg_a_I;
    logic                    o_dbg_a_Q;
    logic signed [MSK_RES-1:0] o_dbg_I_BB;
    logic signed [MSK_RES-1:0] o_dbg_Q_BB;

    assign i_flag_enable            = i_bus_in[0];
    assign i_enable_ech             = i_bus_in[1];
    assign i_b_in                   = i_bus_in[2];
    assign i_dbg_enc_override_en    = i_bus_in[3];
    assign i_dbg_enc_b_in           = i_bus_in[4];
    assign i_dbg_demux_override_en  = i_bus_in[5];
    assign i_dbg_demux_b_enc        = i_bus_in[6];
    assign i_dbg_shaping_override_en= i_bus_in[7];
    assign i_dbg_shaping_a_I        = i_bus_in[8];
    assign i_dbg_shaping_a_Q        = i_bus_in[9];

    assign o_bus_out[5:0]   = o_I_BB;
    assign o_bus_out[11:6]  = o_Q_BB;
    assign o_bus_out[12]    = o_dbg_b_enc;
    assign o_bus_out[13]    = o_dbg_a_I;
    assign o_bus_out[14]    = o_dbg_a_Q;
    assign o_bus_out[20:15] = o_dbg_I_BB;
    assign o_bus_out[26:21] = o_dbg_Q_BB;

    top_msk #(
        .SAMPLES_PER_HALF_SINE(SAMPLES_PER_HALF_SINE),
        .MSK_RES(MSK_RES)
    ) DUT (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flag_enable(i_flag_enable),
        .i_enable_ech(i_enable_ech),
        .i_b_in(i_b_in),
        .i_dbg_enc_override_en(i_dbg_enc_override_en),
        .i_dbg_enc_b_in(i_dbg_enc_b_in),
        .i_dbg_demux_override_en(i_dbg_demux_override_en),
        .i_dbg_demux_b_enc(i_dbg_demux_b_enc),
        .i_dbg_shaping_override_en(i_dbg_shaping_override_en),
        .i_dbg_shaping_a_I(i_dbg_shaping_a_I),
        .i_dbg_shaping_a_Q(i_dbg_shaping_a_Q),
        .o_I_BB(o_I_BB),
        .o_Q_BB(o_Q_BB),
        .o_dbg_b_enc(o_dbg_b_enc),
        .o_dbg_a_I(o_dbg_a_I),
        .o_dbg_a_Q(o_dbg_a_Q),
        .o_dbg_I_BB(o_dbg_I_BB),
        .o_dbg_Q_BB(o_dbg_Q_BB)
    );

endmodule

module tb_top_msk_bus;

    localparam int SAMPLES_PER_HALF_SINE = 10;
    localparam int MSK_RES               = 6;
    localparam int BUS_IN_WIDTH          = 10;
    localparam int BUS_OUT_WIDTH         = 27;

    logic i_clk;
    logic i_rst_n;
    logic [BUS_IN_WIDTH-1:0]  i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    top_msk_bus_wrapper #(
        .SAMPLES_PER_HALF_SINE(SAMPLES_PER_HALF_SINE),
        .MSK_RES(MSK_RES)
    ) wrapper (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_bus_in(i_bus_in),
        .o_bus_out(o_bus_out)
    );

    initial begin
        i_clk = 1'b0;
        forever #10 i_clk = ~i_clk;
    end

    task automatic set_bus(logic [BUS_IN_WIDTH-1:0] bus_val);
    begin
        i_bus_in = bus_val;
        @(posedge i_clk);
    end
    endtask

    task automatic apply_reset(int cycles);
    begin
        i_rst_n = 1'b0;
        i_bus_in = '0;
        repeat(cycles) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat(2) @(posedge i_clk);
    end
    endtask

    function automatic logic signed [MSK_RES-1:0] get_I();
        return logic signed [MSK_RES-1:0]'(o_bus_out[5:0]);
    endfunction

    function automatic logic signed [MSK_RES-1:0] get_Q();
        return logic signed [MSK_RES-1:0]'(o_bus_out[11:6]);
    endfunction

    task automatic run_top_test_plan();
    begin
        test_top_basic_operation();
        test_top_debug_bypass();
    end
    endtask

    task automatic test_top_basic_operation();
        logic [BUS_IN_WIDTH-1:0] bus_val;
        logic signed [MSK_RES-1:0] signed_I;
        logic signed [MSK_RES-1:0] signed_Q;
    begin
        $display("--- TOP BUS TEST : operation normale ---");
        bus_val = '0;
        bus_val[0] = 1'b1; // flag_enable
        bus_val[1] = 1'b1; // enable_ech
        bus_val[2] = 1'b1; // b_in
        set_bus(bus_val);
        repeat (8) @(posedge i_clk);

        signed_I = get_I();
        signed_Q = get_Q();
        assert (signed_I >= -31 && signed_I <= 31)
            else $error("TOP FAIL: I hors limites, I=%0d", signed_I);
        assert (signed_Q >= -31 && signed_Q <= 31)
            else $error("TOP FAIL: Q hors limites, Q=%0d", signed_Q);
        $display("TOP PASS: sorties I=%0d Q=%0d", signed_I, signed_Q);
    end
    endtask

    task automatic test_top_debug_bypass();
        logic [BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- TOP BUS TEST : debug bypass encodeur ---");
        bus_val = '0;
        bus_val[0] = 1'b1; // flag_enable
        bus_val[1] = 1'b1; // enable_ech
        bus_val[3] = 1'b1; // dbg_enc_override_en
        bus_val[4] = 1'b0; // dbg_enc_b_in
        set_bus(bus_val);
        repeat (4) @(posedge i_clk);

        assert (o_bus_out[12] !== 1'bx)
            else $error("TOP FAIL: debug bus enc non initialise");
        $display("TOP PASS: debug output presente, o_dbg_b_enc=%b", o_bus_out[12]);
    end
    endtask

    initial begin
        i_rst_n = 1'b0;
        i_bus_in = '0;
        apply_reset(5);

        $display("\n===== TOP BUS TB START =====");
        run_top_test_plan();
        $display("===== TOP BUS TB COMPLETE =====\n");

        repeat (5) @(posedge i_clk);
        $finish;
    end

endmodule
