`timescale 1ns/1ps

module tb_demod_wrapper;
    import tb_pkg::*;


    // signals
    logic i_clk;
    logic i_rst_n;
    logic i_out_en;

    logic [CFG_WIDTH-1:0]     d_cfg_local;
    logic [3:0]               tb_i;       // Renommé de d_i pour matcher les .svh
    logic [3:0]               tb_q;       // Renommé de d_q pour matcher les .svh
    logic [BUS_IN_WIDTH-1:0]  i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    // DUT
    demod_wrapper #(
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) demod_dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_out_en(i_out_en),
        .i_cfg(d_cfg_local),
        .i_i(tb_i),
        .i_q(tb_q),
        .i_bus_in(i_bus_in),
        .o_bus_out(o_bus_out)
    );

    // clock
    initial begin
        i_clk = 1'b0;
        forever #50 i_clk = ~i_clk;
    end

    `include "headers/demod_wrapper_normal.svh"
    `include "headers/demod_wrapper_debug_demod.svh"
    `include "headers/demod_wrapper_debug_fir.svh"
    `include "headers/demod_wrapper_debug_chain.svh"
    `include "headers/demod_wrapper_test_plan.svh"
    
    initial begin
        // init
        i_rst_n = 1'b0;
        i_out_en = 1'b1;
        d_cfg_local = '0;
        tb_i = '0; 
        tb_q = '0; 
        i_bus_in = '0;

        // reset initial
        repeat(5) @(posedge i_clk);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 10);

        $display("\n===== DEMOD WRAPPER TB START =====\n");
        run_demod_wrapper_test_plan();
        $display("\n===== DEMOD WRAPPER TB COMPLETE =====\n");

        repeat(10) @(posedge i_clk);
        $finish;
    end

endmodule