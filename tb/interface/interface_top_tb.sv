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
    logic                      o_tx_sample_tick;

    logic                      tb_baud_enable;
    logic [DIV_WIDTH-1:0]      tb_baud_div;
    logic                      tb_baud_tick;

    logic [APB_DATA_WIDTH-1:0] rdata;

    logic                      u_ser_baud_tick;
    logic [DATA_WIDTH-1:0]     u_ser_tx_data;
    logic                      u_ser_tx_fifo_empty;
    logic                      u_ser_tx_data_valid;
    logic                      u_ser_tx_fifo_pop;
    logic                      u_ser_serial_data;
    logic                      u_ser_tx_busy;
    logic                      u_ser_tx_sample_tick;

    logic                      u_des_serial_data;
    logic                      u_des_sample_valid;
    logic                      u_des_enable;
    logic                      u_des_fifo_full;
    logic [DATA_WIDTH-1:0]     u_des_para_data;
    logic                      u_des_push;
    logic                      u_des_ovf_pulse;

    logic                      u_fifo_wr_en;
    logic [DATA_WIDTH-1:0]     u_fifo_din;
    logic                      u_fifo_full;
    logic                      u_fifo_rd_en;
    logic [DATA_WIDTH-1:0]     u_fifo_dout;
    logic                      u_fifo_rd_valid;
    logic                      u_fifo_empty;

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
        .i_dbg_ser_override_en(1'b0),
        .i_dbg_ser_tx_data('0),
        .i_dbg_ser_tx_data_valid(1'b0),
        .i_dbg_ser_tx_fifo_empty(1'b0),
        .i_dbg_ser_baud_tick(1'b0),
        .o_serial_tx(o_serial_tx),
        .o_tx_valid(o_tx_valid),
        .o_tx_sample_tick(o_tx_sample_tick)
    );

    baud_rate_gen #(
        .DIV_WIDTH(DIV_WIDTH)
    ) u_baud_rate_gen_tb (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_enable(tb_baud_enable),
        .i_div_val(tb_baud_div),
        .o_tick(tb_baud_tick)
    );

    serializer #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_serializer_tb (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_baud_tick(u_ser_baud_tick),
        .i_tx_data(u_ser_tx_data),
        .i_tx_fifo_empty(u_ser_tx_fifo_empty),
        .i_tx_data_valid(u_ser_tx_data_valid),
        .o_tx_fifo_pop(u_ser_tx_fifo_pop),
        .o_serial_data(u_ser_serial_data),
        .o_tx_busy(u_ser_tx_busy),
        .o_tx_sample_tick(u_ser_tx_sample_tick)
    );

    deserializer #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_deserializer_tb (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_serial_data(u_des_serial_data),
        .i_sample_valid(u_des_sample_valid),
        .i_enable(u_des_enable),
        .i_fifo_full(u_des_fifo_full),
        .o_para_data(u_des_para_data),
        .o_push(u_des_push),
        .o_ovf_pulse(u_des_ovf_pulse)
    );

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(FIFO_DEPTH)
    ) u_fifo_tb (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_wr_en(u_fifo_wr_en),
        .i_data(u_fifo_din),
        .o_full(u_fifo_full),
        .i_rd_en(u_fifo_rd_en),
        .o_data(u_fifo_dout),
        .o_rd_valid(u_fifo_rd_valid),
        .o_empty(u_fifo_empty)
    );

    always #10 i_clk = ~i_clk;

`include "include/apb_tasks.svh"
`include "include/reset_tasks.svh"
`include "tests/tc_t0_baud_gen_only.svh"
`include "tests/tc_t0_baud_gen_edges.svh"
`include "tests/tc_t0_reset_smoke.svh"
`include "tests/tc_t1_apb_regs.svh"
`include "tests/tc_t2_tx_nominal.svh"
`include "tests/tc_t3_rx_nominal.svh"
`include "tests/tc_t4_interface_errors.svh"
`include "tests/tc_u_fifo_basic.svh"
`include "tests/tc_u_fifo_full.svh"
`include "tests/tc_u_fifo_edges.svh"
`include "tests/tc_u_serializer_basic.svh"
`include "tests/tc_u_serializer_edges.svh"
`include "tests/tc_u_deserializer_basic.svh"
`include "tests/tc_u_deserializer_edges.svh"
`include "tests/tc_stress_tx_rx_noreset.svh"
`include "tests/test_plan_smoke.svh"
`include "tests/test_plan_full.svh"

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
        tb_baud_enable     = 1'b0;
        tb_baud_div        = '0;
        u_ser_baud_tick    = 1'b0;
        u_ser_tx_data      = '0;
        u_ser_tx_fifo_empty = 1'b1;
        u_ser_tx_data_valid = 1'b0;
        u_des_serial_data  = 1'b0;
        u_des_sample_valid = 1'b0;
        u_des_enable       = 1'b0;
        u_des_fifo_full    = 1'b0;
        u_fifo_wr_en       = 1'b0;
        u_fifo_din         = '0;
        u_fifo_rd_en       = 1'b0;

        run_test_plan_full();

        repeat (20) @(posedge i_clk);
        $finish;
    end

endmodule
