`timescale 1ns/1ps
module top_tb;
    // Clock and reset
    logic clk;
    logic rst_n;

    // Top config signals
    logic [2:0] i_top_cfg;
    logic [2:0] i_wrapper_cfg;

    logic [11:0] i_bus_a;
    logic [9:0]  i_bus_b;
    logic [11:0] o_bus_c;
    logic [1:0]  o_bus_d;

    `include "tb/top/configs/top_0_rx.svh"
    `include "tb/top/configs/top_1_tx.svh"
    `include "tb/top/configs/top_2_interface.svh"
    `include "tb/top/configs/top_3_msk.svh"
    `include "tb/top/configs/top_4_demod.svh"
    `include "tb/top/configs/top_5_cordic.svh"
    `include "tb/top/configs/top_6_cdr.svh"
    `include "tb/top/configs/top_7_internal.svh"

    // Instantiate DUT
    top uut (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_top_cfg(i_top_cfg),
        .i_wrapper_cfg(i_wrapper_cfg),
        .i_bus_a(i_bus_a),
        .i_bus_b(i_bus_b),
        .o_bus_c(o_bus_c),
        .o_bus_d(o_bus_d)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end

    // Test sequence
    initial begin
        // default values
        rst_n = 1;
        i_top_cfg = 3'b000;
        i_wrapper_cfg = 3'b000;
        i_bus_a = '0;
        i_bus_b = '0;

        $display("Starting top_tb at time %0t", $time);
        #10;

        test_0_rx();
        #100;
        test_1_tx();
        #100;
        test_2_interface();
        #100;
        test_3_msk();
        #100;
        test_4_demod();
        #100;
        test_5_cordic();
        #100;
        test_6_cdr();
        #100;
        test_7_internal();
        #100;

        $display("All config tests completed at time %0t", $time);
        $finish;
    end

endmodule
