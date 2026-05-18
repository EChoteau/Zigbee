`timescale 1ns/1ps

module demux_msk_bus_wrapper (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic [1:0]   i_bus_in,
    output logic [1:0]   o_bus_out
);

    logic        i_flag_enable;
    logic        i_b_enc;
    logic        o_a_I;
    logic        o_a_Q;

    assign i_flag_enable = i_bus_in[0];
    assign i_b_enc       = i_bus_in[1];
    assign o_bus_out[0]  = o_a_I;
    assign o_bus_out[1]  = o_a_Q;

    demux_msk DUT (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flag_enable(i_flag_enable),
        .i_b_enc(i_b_enc),
        .o_a_I(o_a_I),
        .o_a_Q(o_a_Q)
    );

endmodule

module tb_demux_msk_bus;

    localparam int BUS_IN_WIDTH  = 2;
    localparam int BUS_OUT_WIDTH = 2;

    logic i_clk;
    logic i_rst_n;
    logic [BUS_IN_WIDTH-1:0]  i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    demux_msk_bus_wrapper wrapper (
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

    task automatic run_demux_test_plan();
    begin
        test_demux_route_I();
        test_demux_route_Q();
        test_demux_reset();
    end
    endtask

    task automatic test_demux_route_I();
        logic [BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- DEMUX BUS TEST : route vers I ---");
        bus_val = '0;
        bus_val[1] = 1'b0; // b_enc = 0
        bus_val[0] = 1'b1; // flag_enable = 1
        set_bus(bus_val);
        repeat (2) @(posedge i_clk);

        assert (o_bus_out == 2'b10)
            else $error("DEMUX FAIL: attendu I=0,Q=1, obtenu o_bus_out=%b", o_bus_out);
        $display("DEMUX PASS: route I effectuee, o_bus_out=%b", o_bus_out);
    end
    endtask

    task automatic test_demux_route_Q();
        logic [BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- DEMUX BUS TEST : route vers Q ---");
        bus_val = '0;
        bus_val[1] = 1'b1; // b_enc = 1
        bus_val[0] = 1'b1; // flag_enable = 1
        set_bus(bus_val);
        repeat (2) @(posedge i_clk);

        assert (o_bus_out == 2'b01)
            else $error("DEMUX FAIL: attendu I=0,Q=1 apres Q, obtenu o_bus_out=%b", o_bus_out);
        $display("DEMUX PASS: route Q effectuee, o_bus_out=%b", o_bus_out);
    end
    endtask

    task automatic test_demux_reset();
    begin
        $display("--- DEMUX BUS TEST : verification reset ---");
        apply_reset(5);
        assert (o_bus_out == 2'b11)
            else $error("DEMUX FAIL: reset invalide, expected 11, obtenu %b", o_bus_out);
        $display("DEMUX PASS: reset OK, o_bus_out=%b", o_bus_out);
    end
    endtask

    initial begin
        i_rst_n = 1'b0;
        i_bus_in = '0;
        apply_reset(5);

        $display("\n===== DEMUX BUS TB START =====");
        run_demux_test_plan();
        $display("===== DEMUX BUS TB COMPLETE =====\n");

        repeat (5) @(posedge i_clk);
        $finish;
    end

endmodule
