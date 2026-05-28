`timescale 1ns/1ps

// Import generic testbench utilities
import tb_pkg::*;
import interface_pkg::*;
import interface_wrapper_tasks_pkg::*;
import interface_tasks_pkg::*;
import demod_pkg::*;
import demod_wrapper_tasks_pkg::*;
import demod_tasks_pkg::*;
import cdr_wrapper_tasks_pkg::*;
import cordic_wrapper_tasks_pkg::*;
import msk_wrapper_tasks_pkg::*;

module top_tb;
    // Clock and reset
    logic i_clk;
    logic i_rst_n;

    // Zigbee top configuration and bus signals
    logic [2:0] i_wrapper_cfg;
    logic [2:0] i_top_cfg;

    logic [21:0] i_bus_in;
    logic [13:0] o_bus_out;
    
    // For demod wrapper tests
    logic [3:0] tb_i;
    logic [3:0] tb_q;
    

    // TODO This has to go somewhere else
    // Alias for compatibility with wrapper test headers
    logic [2:0] i_cfg_local;
    assign i_cfg_local = i_wrapper_cfg;
    
    // Interface wrapper configuration constants
    localparam logic [2:0] CFG_RX_ONLY   = 3'b000;  // APB + serial loopback
    localparam logic [2:0] CFG_TX_ONLY   = 3'b001;  // TX path with FIFO control
    localparam logic [2:0] CFG_RESERVED  = 3'b010;  // RESERVED NOT USED YET
    localparam logic [2:0] CFG_LOOPBACK  = 3'b011;  // Serializer output looped to deserializer input
    localparam logic [2:0] CFG_FIFO_TX   = 3'b100;  // Direct TX FIFO control
    localparam logic [2:0] CFG_FIFO_RX   = 3'b101;  // Direct RX FIFO control
    localparam logic [2:0] CFG_SERDES    = 3'b110;  // Serializer/deserializer chain testing
    localparam logic [2:0] CFG_BAUD      = 3'b111;  // Baud rate generator control

    // =========================================================================
    // Include wrapper test headers
    // =========================================================================
    
    `include "tb/top/configs/top_0_rx.svh"
    `include "tb/top/configs/top_1_tx.svh"
    `include "tb/top/configs/top_2_internal.svh"
    `include "tb/top/configs/top_3_interface.svh"
    `include "tb/top/configs/top_4_msk.svh"
    `include "tb/top/configs/top_5_demod.svh"
    `include "tb/top/configs/top_6_cordic.svh"
    `include "tb/top/configs/top_7_cdr.svh"

    // Instantiate DUT
    zigbee_top uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_wrapper_cfg),
        .i_cfg_top(i_top_cfg),
        .i_bus_in(i_bus_in),
        .o_bus_out(o_bus_out)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #50 i_clk = ~i_clk;
    end

    // Test sequence
    initial begin
        // default values
        i_rst_n = 1;
        i_wrapper_cfg = 3'b000;
        i_top_cfg = 3'b000;
        i_bus_in = '0;
        tb_i = '0;
        tb_q = '0;

        $display("Starting top_tb at time %0t", $time);
        #10;

        $display("[TOP_TB] >>> test_0_rx");
        test_0_rx();
        $display("[TOP_TB] <<< test_0_rx");
        #100;
        $display("[TOP_TB] >>> test_1_tx");
        test_1_tx();
        $display("[TOP_TB] <<< test_1_tx");
        #100;
        $display("[TOP_TB] >>> test_2_internal");
        test_2_internal();
        $display("[TOP_TB] <<< test_2_internal");
        #100;
        $display("[TOP_TB] >>> test_3_interface");
        test_3_interface();
        $display("[TOP_TB] <<< test_3_interface");
        #100;
        $display("[TOP_TB] >>> test_4_msk");
        test_4_msk();
        $display("[TOP_TB] <<< test_4_msk");
        #100;
        $display("[TOP_TB] >>> test_5_demod");
        test_5_demod();
        $display("[TOP_TB] <<< test_5_demod");
        #100;
        $display("[TOP_TB] >>> test_6_cordic");
        test_6_cordic();
        $display("[TOP_TB] <<< test_6_cordic");
        #100;
        $display("[TOP_TB] >>> test_7_cdr");
        test_7_cdr();
        $display("[TOP_TB] <<< test_7_cdr");
        #100;

        $display("All config tests completed at time %0t", $time);
        $finish;
    end

endmodule
