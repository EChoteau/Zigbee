`timescale 1ns/1ps
module top_tb;
    // Clock and reset
    logic i_clk;
    logic i_rst_n;

    // Zigbee top configuration and bus signals
    logic [2:0] i_wrapper_cfg;
    logic [2:0] i_top_cfg;

    logic [21:0] i_bus_in;
    logic [13:0] o_bus_out;
    
    // For demod wrapper tests
    logic [3:0] tb_i;
    logic [3:0] tb_q;

    // =========================================================================
    // Helper tasks for wrapper tests
    // =========================================================================
    
    task automatic set_config(logic [2:0] cfg);
    begin
        i_wrapper_cfg = cfg;
        @(posedge i_clk);
    end
    endtask

    task automatic set_bus(logic [21:0] bus_val);
    begin
        i_bus_in = bus_val;
        @(posedge i_clk);
    end
    endtask

    task automatic apply_reset(int cycles);
    begin
        i_rst_n = 1'b0;
        i_bus_in = '0;
        repeat(cycles) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat(2) @(posedge i_clk);
    end
    endtask
    
    task automatic apply_demod_reset(int cycles);
    begin
        i_rst_n = 1'b0;
        tb_i = '0;
        tb_q = '0;
        i_bus_in = '0;
        repeat(cycles) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat(2) @(posedge i_clk);
    end
    endtask

    // =========================================================================
    // Include wrapper test headers
    // =========================================================================
    
    // CDR Wrapper tests
    `include "tb/wrappers/cdr/headers/cdr_wrapper_normal.svh"
    `include "tb/wrappers/cdr/headers/cdr_wrapper_debug_decision.svh"
    `include "tb/wrappers/cdr/headers/cdr_wrapper_debug_pd.svh"
    `include "tb/wrappers/cdr/headers/cdr_wrapper_debug_lf.svh"
    `include "tb/wrappers/cdr/headers/cdr_wrapper_debug_nco.svh"
    `include "tb/wrappers/cdr/headers/cdr_wrapper_test_plan.svh"
    
    // DEMOD Wrapper tests
    `include "tb/wrappers/demod/headers/demod_wrapper_normal.svh"
    `include "tb/wrappers/demod/headers/demod_wrapper_debug_demod.svh"
    `include "tb/wrappers/demod/headers/demod_wrapper_debug_fir.svh"
    `include "tb/wrappers/demod/headers/demod_wrapper_debug_chain.svh"
    `include "tb/wrappers/demod/headers/demod_wrapper_test_plan.svh"
    
    // INTERFACE Wrapper tests
    `include "tb/wrappers/interface/headers/interface_wrapper_baud.svh"
    `include "tb/wrappers/interface/headers/interface_wrapper_fifo_rx.svh"
    `include "tb/wrappers/interface/headers/interface_wrapper_fifo_tx.svh"
    `include "tb/wrappers/interface/headers/interface_wrapper_loopback.svh"
    `include "tb/wrappers/interface/headers/interface_wrapper_rx_only.svh"
    `include "tb/wrappers/interface/headers/interface_wrapper_serdes.svh"
    `include "tb/wrappers/interface/headers/interface_wrapper_tx_only.svh"
    `include "tb/wrappers/interface/headers/interface_wrapper_test_plan.svh"
    
    // MSK Wrapper tests
    `include "tb/wrappers/msk/headers/msk_wrapper_normal.svh"
    `include "tb/wrappers/msk/headers/msk_wrapper_debug_enc.svh"
    `include "tb/wrappers/msk/headers/msk_wrapper_debug_demux.svh"
    `include "tb/wrappers/msk/headers/msk_wrapper_debug_shaping.svh"
    `include "tb/wrappers/msk/headers/msk_wrapper_debug_all.svh"
    `include "tb/wrappers/msk/headers/msk_wrapper_test_plan.svh"

    `include "tb/top/configs/top_0_rx.svh"
    `include "tb/top/configs/top_1_tx.svh"
    `include "tb/top/configs/top_2_internal.svh"
    `include "tb/top/configs/top_3_interface.svh"
    `include "tb/top/configs/top_4_msk.svh"
    `include "tb/top/configs/top_5_demod.svh"
    `include "tb/top/configs/top_6_cordic.svh"
    `include "tb/top/configs/top_7_cdr.svh"

    // Instantiate DUT
    zigbee_top uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_wrapper_cfg),
        .i_cfg_top(i_top_cfg),
        .i_bus_in(i_bus_in),
        .o_bus_out(o_bus_out)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #50 i_clk = ~i_clk;
    end

    // Test sequence
    initial begin
        // default values
        i_rst_n = 1;
        i_wrapper_cfg = 3'b000;
        i_top_cfg = 3'b000;
        i_bus_in = '0;

        $display("Starting top_tb at time %0t", $time);
        #10;

        test_0_rx();
        #100;
        test_1_tx();
        #100;
        test_2_internal();
        #100;
        test_3_interface();
        #100;
        test_4_msk();
        #100;
        test_5_demod();
        #100;
        test_6_cordic();
        #100;
        test_7_cdr();
        #100;

        $display("All config tests completed at time %0t", $time);
        $finish;
    end

endmodule
