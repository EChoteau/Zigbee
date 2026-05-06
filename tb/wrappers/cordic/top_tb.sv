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

    // Include shared test tasks
    `include "tb/top/generic/apply_reset.svh"
    `include "tb/top/generic/run_tc_wrapper_reset.svh"
    `include "tb/top/generic/run_tc_wrapper_tx_path.svh"
    `include "tb/top/generic/run_tc_wrapper_config_000.svh"

    `include "tb/top/configs/0_rx/config_header.svh"
    `include "tb/top/configs/1_tx/config_header.svh"
    `include "tb/top/configs/2_interface/config_header.svh"
    `include "tb/top/configs/3_msk/config_header.svh"
    `include "tb/top/configs/4_demod/config_header.svh"
    `include "tb/top/configs/5_cordic/config_header.svh"
    `include "tb/top/configs/6_cdr/config_header.svh"
    `include "tb/top/configs/7_internal/config_header.svh"

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
