////////////////////////////////////////////////////////////////////////////////
// tb_demod_wrapper.sv
// Per-block testbench for demod_wrapper
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

import tb_pkg::*;

module tb_demod_wrapper;

`include "demod_wrapper_normal.svh"
`include "demod_wrapper_debug_demod_i.svh"
`include "demod_wrapper_debug_demod_q.svh"
`include "demod_wrapper_reserved.svh"
`include "demod_wrapper_debug_fir_i.svh"
`include "demod_wrapper_debug_fir_q.svh"
`include "demod_wrapper_debug_firc_i.svh"
`include "demod_wrapper_debug_firc_q.svh"

`include "../demod_wrapper_test_plan.svh"

    // localparams
    localparam int CFG_WIDTH      = 3;
    localparam int BUS_IN_WIDTH   = 22;
    localparam int BUS_OUT_WIDTH  = 14;

    // signals
    logic i_clk;
    logic i_rst_n;
    logic i_out_en;

    logic [CFG_WIDTH-1:0]    d_cfg_local;
    logic [3:0]              d_i;
    logic [3:0]              d_q;
    logic [BUS_IN_WIDTH-1:0] d_bus_in;
    logic [BUS_OUT_WIDTH-1:0] d_bus_out;

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

    // clock
    initial begin
        i_clk = 1'b0;
        forever #50 i_clk = ~i_clk;
    end

    // minimal helpers
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

    task automatic apply_demod_reset(int cycles);
    begin
        i_rst_n = 1'b0;
        d_i = '0; d_q = '0; d_bus_in = '0;
        repeat(cycles) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat(2) @(posedge i_clk);
    end
    endtask

    initial begin
        // init
        i_rst_n = 1'b0;
        i_out_en = 1'b1;
        d_cfg_local = '0;
        d_i = '0; d_q = '0; d_bus_in = '0;

        // reset
        repeat(5) @(posedge i_clk);
        apply_demod_reset(10);

        $display("\n===== DEMOD WRAPPER TB START =====\n");
        run_demod_wrapper_test_plan();
        $display("\n===== DEMOD WRAPPER TB COMPLETE =====\n");

        repeat(10) @(posedge i_clk);
        $finish;
    end

endmodule
