////////////////////////////////////////////////////////////////////////////////
// tb_interface_wrapper.sv
// Per-block testbench for interface_wrapper
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

import tb_pkg::*;
import interface_wrapper_baud::*;

module tb_interface_wrapper;

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

    localparam logic [2:0] CFG_CLASSIC   = 3'b000;  // APB + serial loopback
    localparam logic [2:0] CFG_TX_ONLY   = 3'b001;  // TX path with FIFO control
    localparam logic [2:0] CFG_RX_ONLY   = 3'b010;  // RX path with FIFO control
    localparam logic [2:0] CFG_LOOPBACK  = 3'b011;  // Serializer output looped to deserializer input
    localparam logic [2:0] CFG_FIFO_TX   = 3'b100;  // Direct TX FIFO control
    localparam logic [2:0] CFG_FIFO_RX   = 3'b101;  // Direct RX FIFO control
    localparam logic [2:0] CFG_SERDES    = 3'b110;  // Serializer/deserializer chain testing
    localparam logic [2:0] CFG_BAUD      = 3'b111;  // Baud rate generator control

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
        test_interface_wrapper_baud();
        $display("\n===== INTERFACE WRAPPER TB COMPLETE =====\n");

        repeat(10) @(posedge i_clk);
        $finish;
    end

endmodule
