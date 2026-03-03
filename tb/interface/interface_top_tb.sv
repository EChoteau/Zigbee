`timescale 1ns/1ps

import tb_pkg::*;

module interface_top_tb;

    logic                      i_clk;
    logic                      i_rst_n;

    logic                      i_psel;
    logic                      i_penable;
    logic                      i_pwrite;
    logic [APB_ADDR_WIDTH-1:0] i_paddr;
    logic [APB_DATA_WIDTH-1:0] i_pwdata;
    logic [APB_DATA_WIDTH-1:0] o_prdata;
    logic                      o_pready;
    logic                      o_pslverr;

    logic                      i_serial_rx;
    logic                      i_cdr_sample_valid;
    logic                      o_serial_tx;
    logic                      o_tx_valid;

    logic [APB_DATA_WIDTH-1:0] rdata;

    interface_top #(
        .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
        .APB_DATA_WIDTH(APB_DATA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .DIV_WIDTH(DIV_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_psel(i_psel),
        .i_penable(i_penable),
        .i_pwrite(i_pwrite),
        .i_paddr(i_paddr),
        .i_pwdata(i_pwdata),
        .o_prdata(o_prdata),
        .o_pready(o_pready),
        .o_pslverr(o_pslverr),
        .i_serial_rx(i_serial_rx),
        .i_cdr_sample_valid(i_cdr_sample_valid),
        .o_serial_tx(o_serial_tx),
        .o_tx_valid(o_tx_valid)
    );

    always #10 i_clk = ~i_clk;

`include "include/apb_tasks.svh"
`include "include/reset_tasks.svh"
`include "tests/tc_t0_reset_smoke.svh"
`include "tests/tc_t1_apb_regs.svh"
`include "tests/tc_t2_tx_nominal.svh"
`include "tests/tc_t3_rx_nominal.svh"
`include "tests/test_plan_smoke.svh"

    initial begin
        i_clk              = 1'b0;
        i_rst_n            = 1'b0;
        i_psel             = 1'b0;
        i_penable          = 1'b0;
        i_pwrite           = 1'b0;
        i_paddr            = '0;
        i_pwdata           = '0;
        i_serial_rx        = 1'b1;
        i_cdr_sample_valid = 1'b0;

        run_test_plan_smoke();

        repeat (20) @(posedge i_clk);
        $finish;
    end

endmodule
