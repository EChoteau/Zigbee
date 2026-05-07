////////////////////////////////////////////////////////////////////////////////
// test_wrapper_tb.sv - Interface Wrapper Configuration Testing
// ============================================================================
// Testbench for interface_wrapper with 8 configuration modes
//
// Test Coverage via interface_wrapper_*.svh headers:
//   - CFG_CLASSIC:     APB + serial loopback
//   - CFG_TX_ONLY:     TX path testing
//   - CFG_RX_ONLY:     RX path testing
//   - CFG_LOOPBACK:    Serial loopback testing
//   - CFG_FIFO_TX:     TX FIFO direct control
//   - CFG_FIFO_RX:     RX FIFO direct control
//   - CFG_SERDES:      Serializer/Deserializer chain testing
//   - CFG_BAUD:        Baud rate generator control
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

import tb_pkg::*;

module test_wrapper_tb;

    // ==========================================================================
    // PARAMETERS
    // ==========================================================================
    localparam int APB_ADDR_WIDTH = 8;
    localparam int APB_DATA_WIDTH = 8;
    localparam int DATA_WIDTH     = 8;
    localparam int FIFO_DEPTH     = 8;
    localparam int DIV_WIDTH      = 8;
    localparam int CFG_WIDTH      = 3;
    localparam int BUS_IN_WIDTH   = 22;
    localparam int BUS_OUT_WIDTH  = 14;

    // Config modes
    localparam logic [CFG_WIDTH-1:0] CFG_CLASSIC    = 3'b000;
    localparam logic [CFG_WIDTH-1:0] CFG_TX_ONLY    = 3'b001;
    localparam logic [CFG_WIDTH-1:0] CFG_RX_ONLY    = 3'b010;
    localparam logic [CFG_WIDTH-1:0] CFG_LOOPBACK   = 3'b011;
    localparam logic [CFG_WIDTH-1:0] CFG_FIFO_TX    = 3'b100;
    localparam logic [CFG_WIDTH-1:0] CFG_FIFO_RX    = 3'b101;
    localparam logic [CFG_WIDTH-1:0] CFG_SERDES     = 3'b110;
    localparam logic [CFG_WIDTH-1:0] CFG_BAUD       = 3'b111;

    // ==========================================================================
    // TESTBENCH SIGNALS
    // ==========================================================================
    logic                       i_clk;
    logic                       i_rst_n;
    logic                       i_out_en;
    logic [CFG_WIDTH-1:0]       i_cfg_local;
    logic [BUS_IN_WIDTH-1:0]    i_bus_in;
    logic [BUS_OUT_WIDTH-1:0]   o_bus_out;

    // ==========================================================================
    // DUT INSTANTIATION (interface_wrapper)
    // ==========================================================================
    interface_wrapper #(
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_out_en(i_out_en),
        .i_cfg(i_cfg_local),
        .i_bus_in(i_bus_in),
        .o_bus_out(o_bus_out)
    );

    // ==========================================================================
    // CLOCK GENERATION
    // ==========================================================================
    always #50 i_clk = ~i_clk;

    // ==========================================================================
    // MINIMAL HELPER TASKS
    // ==========================================================================
    
    task automatic set_config(logic [CFG_WIDTH-1:0] cfg);
    begin
        i_cfg_local = cfg;
        @(posedge i_clk);
    end
    endtask

    task automatic set_bus(logic [BUS_IN_WIDTH-1:0] bus_val);
    begin
        i_bus_in = bus_val;
        @(posedge i_clk);
    end
    endtask

    task automatic apply_reset(int cycles);
    begin
        i_rst_n = 1'b0;
        repeat(cycles) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat(2) @(posedge i_clk);
    end
    endtask

    // ==========================================================================
    // MAIN TEST SEQUENCE (via .svh headers)
    // ==========================================================================
    initial begin
        // Initialize
        i_clk = 1'b0;
        i_rst_n = 1'b0;
        i_out_en = 1'b1;
        i_cfg_local = '0;
        i_bus_in = '0;

        // Reset
        repeat(5) @(posedge i_clk);
        apply_reset(10);

        // Run test suite from interface_wrapper config headers
        $display("\n========== INTERFACE_WRAPPER TEST SUITE ==========\n");

        `include "interface/interface_wrapper_classic.svh"
        apply_reset(5);

        `include "interface/interface_wrapper_tx_only.svh"
        apply_reset(5);

        `include "interface/interface_wrapper_rx_only.svh"
        apply_reset(5);

        `include "interface/interface_wrapper_loopback.svh"
        apply_reset(5);

        `include "interface/interface_wrapper_fifo_tx.svh"
        apply_reset(5);

        `include "interface/interface_wrapper_fifo_rx.svh"
        apply_reset(5);

        `include "interface/interface_wrapper_serdes.svh"
        apply_reset(5);

        `include "interface/interface_wrapper_baud.svh"

        $display("\n========== ALL WRAPPER TESTS COMPLETED SUCCESSFULLY ==========\n");

        repeat(20) @(posedge i_clk);
        $finish;
    end

endmodule
