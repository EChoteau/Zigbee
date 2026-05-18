`timescale 1ns/1ps

module encodeur_diff_bus_wrapper (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic [1:0]   i_bus_in,
    output logic [0:0]   o_bus_out
);

    logic i_flag_enable;
    logic i_b_in;
    logic o_b_out;

    assign i_flag_enable = i_bus_in[0];
    assign i_b_in       = i_bus_in[1];
    assign o_bus_out[0] = o_b_out;

    encodeur_diff DUT (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flag_enable(i_flag_enable),
        .i_b_in(i_b_in),
        .o_b_out(o_b_out)
    );

endmodule

module tb_encodeur_diff_bus;

    localparam int BUS_IN_WIDTH  = 2;
    localparam int BUS_OUT_WIDTH = 1;

    logic i_clk;
    logic i_rst_n;
    logic [BUS_IN_WIDTH-1:0]  i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    encodeur_diff_bus_wrapper wrapper (
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

    function automatic logic get_out();
        return o_bus_out[0];
    endfunction

    task automatic run_encodeur_test_plan();
    begin
        test_encodeur_reset();
        test_encodeur_no_change_with_one();
        test_encodeur_toggle_with_zero();
        test_encodeur_hold_when_disabled();
    end
    endtask

    task automatic test_encodeur_reset();
        logic [BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- ENCODEUR BUS TEST : reset ---");
        apply_reset(5);
        assert (get_out() == 1'b1)
            else $error("ENCODEUR FAIL: sortie reset incorrecte, attendu 1, obtenu %b", get_out());
        $display("ENCODEUR PASS: reset OK, sortie = %b", get_out());
    end
    endtask

    task automatic test_encodeur_no_change_with_one();
        logic [BUS_IN_WIDTH-1:0] bus_val;
        logic prev_out;
    begin
        $display("--- ENCODEUR BUS TEST : b_in = 1, pas de changement ---");
        bus_val = '0;
        bus_val[0] = 1'b1; // flag_enable
        bus_val[1] = 1'b1; // b_in
        prev_out = get_out();
        set_bus(bus_val);
        repeat (2) @(posedge i_clk);
        assert (get_out() == prev_out)
            else $error("ENCODEUR FAIL: sortie a change alors que b_in=1, prev=%b out=%b", prev_out, get_out());
        $display("ENCODEUR PASS: sortie stable avec b_in=1, out=%b", get_out());
    end
    endtask

    task automatic test_encodeur_toggle_with_zero();
        logic [BUS_IN_WIDTH-1:0] bus_val;
        logic prev_out;
    begin
        $display("--- ENCODEUR BUS TEST : b_in = 0, inversion attendue ---");
        bus_val = '0;
        bus_val[0] = 1'b1; // flag_enable
        bus_val[1] = 1'b0; // b_in
        prev_out = get_out();
        set_bus(bus_val);
        repeat (2) @(posedge i_clk);
        assert (get_out() != prev_out)
            else $error("ENCODEUR FAIL: sortie n'a pas inverse avec b_in=0, prev=%b out=%b", prev_out, get_out());
        $display("ENCODEUR PASS: inversion OK, prev=%b out=%b", prev_out, get_out());
    end
    endtask

    task automatic test_encodeur_hold_when_disabled();
        logic [BUS_IN_WIDTH-1:0] bus_val;
        logic prev_out;
    begin
        $display("--- ENCODEUR BUS TEST : flag_enable desactive ---");
        bus_val = '0;
        bus_val[0] = 1'b0; // flag_enable
        bus_val[1] = 1'b0; // b_in
        prev_out = get_out();
        set_bus(bus_val);
        repeat (4) @(posedge i_clk);
        assert (get_out() == prev_out)
            else $error("ENCODEUR FAIL: sortie a bouge quand flag_enable=0, prev=%b out=%b", prev_out, get_out());
        $display("ENCODEUR PASS: sortie stable sans flag_enable, out=%b", get_out());
    end
    endtask

    initial begin
        i_rst_n = 1'b0;
        i_bus_in = '0;
        apply_reset(5);

        $display("\n===== ENCODEUR BUS TB START =====");
        run_encodeur_test_plan();
        $display("===== ENCODEUR BUS TB COMPLETE =====\n");

        repeat (5) @(posedge i_clk);
        $finish;
    end

endmodule
