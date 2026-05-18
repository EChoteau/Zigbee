`timescale 1ns/1ps

module tb_msk_wrapper;

    import tb_pkg::*;
    `include "headers/msk_wrapper_normal.svh"
    `include "headers/msk_wrapper_debug_enc.svh"
    `include "headers/msk_wrapper_debug_demux.svh"
    `include "headers/msk_wrapper_debug_shaping.svh"
    `include "headers/msk_wrapper_debug_all.svh"
    `include "headers/msk_wrapper_test_plan.svh"

    // Paramètres locaux 
    localparam int SAMPLES_PER_HALF_SINE = 10;
    localparam int MSK_RES               = 6;

    // Signaux de test
    logic i_clk;
    logic i_rst_n;
    logic i_out_en;

    logic [CFG_WIDTH-1:0]     i_cfg_local;
    logic [BUS_IN_WIDTH-1:0]  i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    // Instanciation du DUT
    msk_wrapper #(
        .SAMPLES_PER_HALF_SINE(SAMPLES_PER_HALF_SINE),
        .MSK_RES(MSK_RES),
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) msk_dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_cfg_local),
        .i_out_en(i_out_en),
        .i_bus_in(i_bus_in),
        .o_bus_out(o_bus_out)
    );

    // Génération de l'horloge
    initial begin
        i_clk = 1'b0;
        forever #50 i_clk = ~i_clk;
    end

    initial begin
        // Initialisation des signaux
        i_rst_n = 1'b0;
        i_out_en = 1'b1;
        i_cfg_local = '0;
        i_bus_in = '0;

        // Reset initial
        repeat(5) @(posedge i_clk);
        apply_reset(10);

        $display("\n========================================================");
        $display("===== MSK WRAPPER TB START =====");
        $display("========================================================\n");
        
        run_msk_wrapper_test_plan();
        
        $display("\n========================================================");
        $display("===== MSK WRAPPER TB COMPLETE =====");
        $display("========================================================\n");

        repeat(10) @(posedge i_clk);
        $finish;
    end

endmodule