////////////////////////////////////////////////////////////////////////////////
// test_wrapper_tb.sv - Unified Wrapper Configuration Testing
// ============================================================================
// Central testbench for wrapper-level tests.
// It pulls in the Interface and Demod wrapper suites so they can be run from
// one entry point, with one clock/reset and one simulation harness.
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

import tb_pkg::*;

module test_wrapper_tb;

`include "interface/interface_wrapper_classic.svh"
`include "interface/interface_wrapper_tx_only.svh"
`include "interface/interface_wrapper_rx_only.svh"
`include "interface/interface_wrapper_loopback.svh"
`include "interface/interface_wrapper_fifo_tx.svh"
`include "interface/interface_wrapper_fifo_rx.svh"
`include "interface/interface_wrapper_serdes.svh"
`include "interface/interface_wrapper_baud.svh"

`include "demod/demod_wrapper_normal.svh"
`include "demod/demod_wrapper_debug_demod_i.svh"
`include "demod/demod_wrapper_debug_demod_q.svh"
`include "demod/demod_wrapper_reserved.svh"
`include "demod/demod_wrapper_debug_fir_i.svh"
`include "demod/demod_wrapper_debug_fir_q.svh"
`include "demod/demod_wrapper_debug_firc_i.svh"
`include "demod/demod_wrapper_debug_firc_q.svh"

`include "interface_wrapper_test_plan.svh"
`include "demod_wrapper_test_plan.svh"

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

    // Interface config modes
    localparam logic [CFG_WIDTH-1:0] CFG_CLASSIC    = 3'b000;
    localparam logic [CFG_WIDTH-1:0] CFG_TX_ONLY    = 3'b001;
    localparam logic [CFG_WIDTH-1:0] CFG_RX_ONLY    = 3'b010;
    localparam logic [CFG_WIDTH-1:0] CFG_LOOPBACK   = 3'b011;
    localparam logic [CFG_WIDTH-1:0] CFG_FIFO_TX    = 3'b100;
    localparam logic [CFG_WIDTH-1:0] CFG_FIFO_RX    = 3'b101;
    localparam logic [CFG_WIDTH-1:0] CFG_SERDES     = 3'b110;
    localparam logic [CFG_WIDTH-1:0] CFG_BAUD       = 3'b111;

    // Demod config modes
    localparam logic [CFG_WIDTH-1:0] CFG_DEMOD_NORMAL        = 3'b000;
    localparam logic [CFG_WIDTH-1:0] CFG_DEMOD_DEBUG_I       = 3'b001;
    localparam logic [CFG_WIDTH-1:0] CFG_DEMOD_DEBUG_Q       = 3'b010;
    localparam logic [CFG_WIDTH-1:0] CFG_DEMOD_RESERVED      = 3'b011;
    localparam logic [CFG_WIDTH-1:0] CFG_DEMOD_DEBUG_FIR_I   = 3'b100;
    localparam logic [CFG_WIDTH-1:0] CFG_DEMOD_DEBUG_FIR_Q   = 3'b101;
    localparam logic [CFG_WIDTH-1:0] CFG_DEMOD_DEBUG_FIRC_I  = 3'b110;
    localparam logic [CFG_WIDTH-1:0] CFG_DEMOD_DEBUG_FIRC_Q  = 3'b111;

    // ==========================================================================
    // TESTBENCH SIGNALS
    // ==========================================================================
    logic                       i_clk;
    logic                       i_rst_n;
    logic                       i_out_en;

    // Interface wrapper signals
    logic [CFG_WIDTH-1:0]       i_cfg_local;
    logic [BUS_IN_WIDTH-1:0]    i_bus;
    logic [BUS_OUT_WIDTH-1:0]   o_bus;

    // Demod wrapper signals
    logic [CFG_WIDTH-1:0]       d_cfg_local;
    logic [3:0]                 d_i;
    logic [3:0]                 d_q;
    logic [BUS_IN_WIDTH-1:0]    d_bus_in;
    logic [BUS_OUT_WIDTH-1:0]   d_bus_out;

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
        .i_bus_in(i_bus),
        .o_bus_out(o_bus)
    );

    demod_wrapper #(
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) demod_dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_out_en(i_out_en),
        .i_cfg(d_cfg_local),
        .i_i(d_i),
        .i_q(d_q),
        .i_bus_in(d_bus_in),
        .o_bus_out(d_bus_out)
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
        i_bus = bus_val;
        @(posedge i_clk);
    end
    endtask

    task automatic set_demod_config(logic [CFG_WIDTH-1:0] cfg);
    begin
        d_cfg_local = cfg;
        @(posedge i_clk);
    end
    endtask

    task automatic set_demod_bus(logic [BUS_IN_WIDTH-1:0] bus_val);
    begin
        d_bus_in = bus_val;
        @(posedge i_clk);
    end
    endtask

    task automatic set_demod_adc(logic [3:0] adc_i, logic [3:0] adc_q);
    begin
        d_i = adc_i;
        d_q = adc_q;
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

    // Demod wrapper helpers live here so the demod SVH files stay limited to
    // one file per configuration.
    task automatic clear_demod_inputs();
    begin
        d_i      = '0;
        d_q      = '0;
        d_bus_in = '0;
    end
    endtask

    task automatic apply_demod_reset(int cycles);
    begin
        i_rst_n = 1'b0;
        clear_demod_inputs();
        repeat (cycles) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat (2) @(posedge i_clk);
    end
    endtask

    task automatic drive_normal_sample(
        input logic [3:0] adc_i,
        input logic [3:0] adc_q
    );
    begin
        @(negedge i_clk);
        d_i      = adc_i;
        d_q      = adc_q;
        d_bus_in = '0;
    end
    endtask

    task automatic drive_debug_iq_sample(
        input logic [3:0] dbg_i,
        input logic [3:0] dbg_q
    );
    begin
        @(negedge i_clk);
        d_i      = '0;
        d_q      = '0;
        d_bus_in = '0;
        d_bus_in[17:14] = dbg_i;
        d_bus_in[13:10] = dbg_q;
    end
    endtask

    task automatic drive_fir_sample(input logic signed [7:0] sample);
    begin
        @(negedge i_clk);
        d_i      = '0;
        d_q      = '0;
        d_bus_in = '0;
        d_bus_in[17:10] = sample;
    end
    endtask

    task automatic wait_demod_cycles(input int cycles);
    begin
        repeat (cycles) @(posedge i_clk);
    end
    endtask

    task automatic expect_demod_bus_valid(input string label);
    begin
        assert (d_bus_out !== 14'bx && d_bus_out !== 14'bz)
            else $fatal(1, "[%s] d_bus_out has X/Z", label);
    end
    endtask

    task automatic expect_demod_bus_zero(input string label);
    begin
        assert (d_bus_out == '0)
            else $fatal(1, "[%s] d_bus_out expected zero, got=%0h", label, d_bus_out);
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
        i_bus = '0;
        d_cfg_local = '0;
        d_i = '0;
        d_q = '0;
        d_bus_in = '0;

        // Reset
        repeat(5) @(posedge i_clk);
        apply_reset(10);

        // Run interface wrapper suite
        $display("\n========== INTERFACE_WRAPPER TEST SUITE ==========\n");

        run_interface_wrapper_test_plan();

        // Run demod wrapper suite
        $display("\n========== DEMOD_WRAPPER TEST SUITE ==========\n");

        run_demod_wrapper_test_plan();

        $display("\n========== ALL WRAPPER TESTS COMPLETED SUCCESSFULLY ==========\n");

        repeat(20) @(posedge i_clk);
        $finish;
    end

endmodule
