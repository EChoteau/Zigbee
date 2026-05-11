`timescale 1ns/1ps

module tb_cdr_wrapper;

    // Paramètres locaux (doivent correspondre au wrapper)
    localparam int CFG_WIDTH      = 3;
    localparam int BUS_IN_WIDTH   = 22;
    localparam int BUS_OUT_WIDTH  = 14;

    // Signaux de test
    logic i_clk;
    logic i_rst_n;
    logic i_out_en;

    logic [CFG_WIDTH-1:0]     i_cfg_local;
    logic [BUS_IN_WIDTH-1:0]  i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    // Instanciation du DUT (Design Under Test)
    cdr_wrapper #(
        .CFG_WIDTH(CFG_WIDTH),
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) cdr_dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_cfg_local),
        .i_out_en(i_out_en),
        .i_bus_in(i_bus_in),
        .o_bus_out(o_bus_out)
    );

    // Génération de l'horloge (10 MHz -> période de 100ns)
    initial begin
        i_clk = 1'b0;
        forever #50 i_clk = ~i_clk;
    end

    // =========================================================================
    // Helpers (Tâches utilitaires)
    // =========================================================================
    
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
        i_bus_in = '0;
        repeat(cycles) @(posedge i_clk);
        i_rst_n = 1'b1;
        repeat(2) @(posedge i_clk);
    end
    endtask

    `include "headers/cdr_wrapper_normal.svh"
    `include "headers/cdr_wrapper_debug_decision.svh"
    `include "headers/cdr_wrapper_debug_pd.svh"
    `include "headers/cdr_wrapper_debug_lf.svh"
    `include "headers/cdr_wrapper_debug_nco.svh"
    `include "headers/cdr_wrapper_test_plan.svh"

    // =========================================================================
    // Séquence principale
    // =========================================================================
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
        $display("===== CDR WRAPPER TB START =====");
        $display("========================================================\n");
        
        // Appel de ta tâche personnalisée !
        run_cdr_wrapper_test_plan();
        
        $display("\n========================================================");
        $display("===== CDR WRAPPER TB COMPLETE =====");
        $display("========================================================\n");

        repeat(10) @(posedge i_clk);
        $finish;
    end

endmodule