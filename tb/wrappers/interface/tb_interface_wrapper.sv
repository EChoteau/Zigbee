////////////////////////////////////////////////////////////////////////////////
// tb_interface_wrapper.sv
// Per-block testbench for interface_wrapper
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

import tb_pkg::*;

module tb_interface_wrapper;

`include "interface_wrapper_classic.svh"
`include "interface_wrapper_tx_only.svh"
`include "interface_wrapper_rx_only.svh"
`include "interface_wrapper_loopback.svh"
`include "interface_wrapper_fifo_tx.svh"
`include "interface_wrapper_fifo_rx.svh"
`include "interface_wrapper_serdes.svh"
`include "interface_wrapper_baud.svh"

`include "interface_wrapper_test_plan.svh"

    // localparams (keep consistent with wrappers)
    localparam int CFG_WIDTH      = 3;
    localparam int BUS_IN_WIDTH   = 22;
    localparam int BUS_OUT_WIDTH  = 14;

    // signals
    logic i_clk;
    logic i_rst_n;
    logic i_out_en;

    logic [CFG_WIDTH-1:0]    i_cfg_local;
    logic [BUS_IN_WIDTH-1:0] i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    // DUT
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

    // clock
    initial begin
        i_clk = 1'b0;
        forever #50 i_clk = ~i_clk;
    end

    // minimal helpers (subset of previous)
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

    initial begin
        // init
        i_rst_n = 1'b0;
        i_out_en = 1'b1;
        i_cfg_local = '0;
        i_bus_in = '0;

        // reset
        repeat(5) @(posedge i_clk);
        apply_reset(10);

        $display("\n===== INTERFACE WRAPPER TB START =====\n");
        run_interface_wrapper_test_plan();
        $display("\n===== INTERFACE WRAPPER TB COMPLETE =====\n");

        repeat(10) @(posedge i_clk);
        $finish;
    end

endmodule
