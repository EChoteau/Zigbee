// ==============================================================
// simple_bench.sv — Testbench CDR avec import du package
// ==============================================================
`timescale 1ns/1ps

import cdr_tasks_pkg::*;

module tb_cdr;

    // ==========================================================================
    // CLOCK & RESET
    // ==========================================================================
    logic clk = 0;
    always #50 clk = ~clk;  // 100ns → 10 MHz

    logic rst ;

    // ========in_bus==================================================================
    // BUS
    //   i_bus_in[5:0]  → dphi (phase derivative, signed 6 bits)
    //   o_bus_out[0]   → decision_out
    //   o_bus_out[1]   → clk_rec
    // ==========================================================================
    localparam BUS_IN_WIDTH =22;
    localparam BUS_OUT_WIDTH = 14;
    logic [BUS_IN_WIDTH-1:0]       i_bus_in;
    logic [BUS_OUT_WIDTH-1:0] o_bus_out;

    wire decision_out = o_bus_out[0];
    wire clk_rec      = o_bus_out[1];

    // ==========================================================================
    // DUT
    // ==========================================================================
    cdr_top dut (
        .i_clk    (clk),
        .i_rst_n  (rst),
        .i_dphi   (i_bus_in[7:0]),
        .o_data   (o_bus_out[0]),
        .o_enable (o_bus_out[1]),
        .i_recovered_clk_d      ('0),
        .i_decision_d           ('0),
        .i_up_d                 ('0),
        .i_down_d               ('0),
        .i_ack_d                ('0),
        .i_control_d            ('0),
        .i_phase_detector_debug ('0),
        .i_loop_filter_debug    ('0),
        .i_nco_debug            ('0)
    );

    // ==========================================================================
    // VÉRIFICATION CONTINUE
    // ==========================================================================
    int nb_data = 0;
    int nb_err  = 0;

    always @(posedge clk_rec) begin
        nb_data++;
        assert (o_bus_out[0] !== 1'bx)
            else $error("[t=%0t] o_bus_out[0] indéfini (X)", $time);
    end

    // ==========================================================================
    // SÉQUENCE PRINCIPALE
    // ==========================================================================
    int seq_errors;

    initial begin
        // Reset
        apply_reset(rst, i_bus_in, 500);
        wait_cycles(clk, 5);

        // --- Test 1 : séquence fixe ---
        $display("\n--- Test 1: Séquence fixe ---");
        send_dphi(i_bus_in, 1); #500;
        send_dphi(i_bus_in, 0); #500;
        send_dphi(i_bus_in, 1); #500;
        send_dphi(i_bus_in, 0); #500;

        // --- Test 2 : séquence aléatoire ---
        $display("\n--- Test 2: Séquence aléatoire (20000 bits) ---");
        run_random_sequence(i_bus_in, o_bus_out, clk, 20000, seq_errors);
        nb_err += seq_errors;

        // --- Résultats ---
        $display("\n=== Résultats ===");
        $display("  Données reçues : %0d", nb_data);
        $display("  Erreurs        : %0d", nb_err);
        if (nb_data > 0)
            $display("  TEB            : %0e", real'(nb_err) / real'(nb_data));
        $display("finish");
        $finish;
    end

endmodule
