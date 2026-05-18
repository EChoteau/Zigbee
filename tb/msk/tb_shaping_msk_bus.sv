`timescale 1ns/1ps

module shaping_msk_bus_wrapper #(
    parameter int SAMPLES_PER_HALF_SINE = 10,
    parameter int MSK_RES               = 6
)(
    input  logic                     i_clk,
    input  logic                     i_rst_n,
    input  logic [2:0]               i_bus_in,
    output logic [2*MSK_RES-1:0]     o_bus_out
);

    logic                    i_enable_ech;
    logic                    i_a_I;
    logic                    i_a_Q;
    logic signed [MSK_RES-1:0] o_I_BB;
    logic signed [MSK_RES-1:0] o_Q_BB;

    assign i_enable_ech = i_bus_in[0];
    assign i_a_I        = i_bus_in[1];
    assign i_a_Q        = i_bus_in[2];
    assign o_bus_out[MSK_RES-1:0] = o_I_BB;
    assign o_bus_out[2*MSK_RES-1:MSK_RES] = o_Q_BB;

    shaping_msk #(
        .SAMPLES_PER_HALF_SINE(SAMPLES_PER_HALF_SINE),
        .MSK_RES(MSK_RES)
    ) DUT (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_enable_ech(i_enable_ech),
        .i_a_I(i_a_I),
        .i_a_Q(i_a_Q),
        .o_I_BB(o_I_BB),
        .o_Q_BB(o_Q_BB)
    );

endmodule

module tb_shaping_msk_bus;

    localparam int SAMPLES_PER_HALF_SINE = 10;
    localparam int MSK_RES               = 6;
    localparam int BUS_IN_WIDTH          = 3;
    localparam int BUS_OUT_WIDTH         = 2*MSK_RES;

    logic i_clk;
    logic i_rst_n;
    logic [BUS_IN_WIDTH-1:0]  i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    shaping_msk_bus_wrapper #(
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

    task automatic run_shaping_test_plan();
    begin
        test_shaping_reset();
        test_shaping_positive();
        test_shaping_negative();
    end
    endtask

    function automatic logic signed [MSK_RES-1:0] get_I();
        return o_bus_out[MSK_RES-1:0];
    endfunction

    function automatic logic signed [MSK_RES-1:0] get_Q();
        return o_bus_out[2*MSK_RES-1:MSK_RES];
    endfunction

    task automatic test_shaping_reset();
        logic [BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- SHAPING BUS TEST : reset ---");
        apply_reset(5);
        assert (o_bus_out == '0)
            else $error("SHAPING FAIL: reset non reinitialise, o_bus_out=%b", o_bus_out);
        $display("SHAPING PASS: reset OK");
    end
    endtask

    task automatic test_shaping_positive();
        logic [BUS_IN_WIDTH-1:0] bus_val;
        logic signed [MSK_RES-1:0] signed_I;
        logic signed [MSK_RES-1:0] signed_Q;
    begin
        $display("--- SHAPING BUS TEST : signe positif ---");
        bus_val = '0;
        bus_val[0] = 1'b1; // enable_ech
        bus_val[1] = 1'b1; // a_I = 1
        bus_val[2] = 1'b1; // a_Q = 1
        set_bus(bus_val);
        repeat (8) @(posedge i_clk);

        signed_I = get_I();
        signed_Q = get_Q();
        assert (signed_Q > 0)
            else $error("SHAPING FAIL: Q doit etre positif, Q=%0d", signed_Q);
        assert (signed_I >= -31 && signed_I <= 31)
            else $error("SHAPING FAIL: I hors limites, I=%0d", signed_I);
        $display("SHAPING PASS: I=%0d Q=%0d", signed_I, signed_Q);
    end
    endtask

    task automatic test_shaping_negative();
        logic [BUS_IN_WIDTH-1:0] bus_val;
        logic signed [MSK_RES-1:0] signed_I;
        logic signed [MSK_RES-1:0] signed_Q;
    begin
        $display("--- SHAPING BUS TEST : signe negatif ---");
        bus_val = '0;
        bus_val[0] = 1'b1; // enable_ech
        bus_val[1] = 1'b0; // a_I = 0
        bus_val[2] = 1'b0; // a_Q = 0
        set_bus(bus_val);
        repeat (10) @(posedge i_clk);

        signed_I = get_I();
        signed_Q = get_Q();
        

        assert (signed_I >= -31 && signed_I <= 31)
            else $error("SHAPING FAIL: I hors limites, I=%0d", signed_I);
        assert (signed_Q >= -31 && signed_Q<=31)
	    else $error("SHAPING FAIL: Q hors limites, Q=%0d", signed_Q);
	$display("shaping PASS : signe negatif - I=%0d Q=%0d", signed_I, signed_Q);
    end
    endtask

    initial begin
        i_rst_n = 1'b0;
        i_bus_in = '0;
        apply_reset(5);

        $display("\n===== SHAPING BUS TB START =====");
        run_shaping_test_plan();
        $display("===== SHAPING BUS TB COMPLETE =====\n");

        repeat (5) @(posedge i_clk);
        $finish;
    end

endmodule
