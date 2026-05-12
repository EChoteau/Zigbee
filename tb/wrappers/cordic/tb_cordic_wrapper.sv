`timescale 1ns/1ps

module tb_cordic_wrapper;

    localparam int CFG_WIDTH     = 3;
    localparam int BUS_IN_WIDTH  = 22;
    localparam int BUS_OUT_WIDTH = 14;

    logic i_clk, i_rst_n, i_out_en;
    logic [CFG_WIDTH-1:0]     i_cfg_local;
    logic [BUS_IN_WIDTH-1:0]  i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    cordic_wrapper #(
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_cfg_local),
        .i_out_en(i_out_en),
        .i_bus_in(i_bus_in),
        .o_bus_out(o_bus_out)
    );

    initial begin
        i_clk = 0;
        forever #50 i_clk = ~i_clk;
    end

    task automatic set_config(logic [CFG_WIDTH-1:0] cfg);
    begin
        i_cfg_local = cfg;
        @(posedge i_clk);
    end
    endtask

    task automatic set_bus(logic [BUS_IN_WIDTH-1:0] val);
    begin
        i_bus_in = val;
        @(posedge i_clk);
    end
    endtask

    task automatic apply_reset(int cycles);
    begin
        i_rst_n = 0;
        i_bus_in = '0;
        repeat(cycles) @(posedge i_clk);
        i_rst_n = 1;
        repeat(2) @(posedge i_clk);
    end
    endtask

        // --- Inclusions ---
    `include "headers/cordic_wrapper_debug_cordic.svh"
    `include "headers/cordic_wrapper_debug_deriv.svh"
    `include "headers/cordic_wrapper_debug_filter.svh"
    `include "headers/cordic_wrapper_normal.svh"
    `include "headers/cordic_wrapper_test_plan.svh"

    initial begin
        i_rst_n = 0; i_out_en = 1; i_cfg_local = 0; i_bus_in = 0;
        apply_reset(10);

        $display("\n========================================================");
        $display("===== CORDIC WRAPPER TB START =====");
        $display("========================================================\n");

        run_cordic_wrapper_test_plan();

        $display("\n========================================================");
        $display("===== CORDIC WRAPPER TB COMPLETE =====");
        $display("========================================================\n");
        
        repeat(10) @(posedge i_clk);
        $finish;
    end
endmodule