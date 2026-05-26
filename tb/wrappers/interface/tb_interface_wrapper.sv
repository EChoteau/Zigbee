`timescale 1ns/1ps

module tb_interface_wrapper;
    import tb_pkg::*;

    // INTERFACE WRAPPER PARAMETERS
    localparam int APB_ADDR_WIDTH = 8;
    localparam int APB_DATA_WIDTH = 8;
    localparam int DATA_WIDTH     = 8;
    localparam int FIFO_DEPTH     = 8;
    localparam int DIV_WIDTH      = 8;

    // APB REGISTER ADDRESSES
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DATA    = 8'h00;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_STATUS  = 8'h04;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_CONTROL = 8'h08;
    localparam logic [APB_ADDR_WIDTH-1:0] ADDR_DIVIDER = 8'h0C;
    // signals
    logic i_clk;
    logic i_rst_n;
    logic i_out_en;

    logic [CFG_WIDTH-1:0]    i_cfg_local;
    logic [BUS_IN_WIDTH-1:0] i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    `include "headers/interface_wrapper_baud.svh"
    `include "headers/interface_wrapper_fifo_rx.svh"
    `include "headers/interface_wrapper_fifo_tx.svh"
    `include "headers/interface_wrapper_loopback.svh"
    `include "headers/interface_wrapper_rx_only.svh"
    `include "headers/interface_wrapper_serdes.svh"
    `include "headers/interface_wrapper_tx_only.svh"
    `include "headers/interface_wrapper_test_plan.svh"

    localparam logic [2:0] CFG_RX_ONLY   = 3'b000;  // APB + serial loopback
    localparam logic [2:0] CFG_TX_ONLY   = 3'b001;  // TX path with FIFO control
    localparam logic [2:0] CFG_RESERVED  = 3'b010;  // RESERVED NOT USED YET
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
