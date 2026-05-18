// ==============================================================
// tb_demod.sv — Testbench système DEMOD via demod_wrapper
// ==============================================================
`timescale 1ns/1ps

import demod_tasks_pkg::*;

module tb_demod_system;
    timeunit      1ns;
    timeprecision 1ps;

    // ==========================================================
    // PARAMÈTRES
    // ==========================================================
    localparam int CLK_PERIOD_NS = 100;
    localparam int FIR_SETTLE    = 20;
    localparam string I_FILENAME = "I_IF_data_IMG.txt";
    localparam string Q_FILENAME = "Q_IF_data_IMG.txt";

    
    localparam int CFG_WIDTH   = 3;
    localparam int BUS_A_WIDTH = 10;
    localparam int BUS_B_WIDTH = 12;
    localparam int BUS_C_WIDTH = 12;
    localparam int BUS_D_WIDTH = 2;

    // CFG modes 
    localparam logic [2:0] MODE_IQ_BB = 3'b100; // MODE_4: o_bus_c = {s_i_bb, s_q_bb}

    // ==========================================================
    // CLOCK & RESET
    // ==========================================================
    logic clk   = 1'b0;
    logic rst_n;
    always #(CLK_PERIOD_NS/2) clk = ~clk;

    // ==========================================================
    // WRAPPER PORTS
    // ==========================================================
    logic [CFG_WIDTH-1:0]   i_cfg;
    logic [BUS_A_WIDTH-1:0] i_bus_a;   // unused by wrapper 
    logic [BUS_B_WIDTH-1:0] i_bus_b;   // [11:8] unused | [7:4]=I | [3:0]=Q
    logic [BUS_C_WIDTH-1:0] o_bus_c;
    logic [BUS_D_WIDTH-1:0] o_bus_d;

    // ----------------------------------------------------------
    // 
    //   in_bus[7:4] → i_bus_b[7:4]  (i_I_in)
    //   in_bus[3:0] → i_bus_b[3:0]  (i_Q_in)
    //   out_bus value depends on i_cfg:
    //     MODE_4-7  → o_bus_c[11:6] = s_i_bb, o_bus_c[5:0] = s_q_bb
    // ----------------------------------------------------------
    
    logic [7:0] in_bus;
    assign i_bus_b = {4'b0, in_bus};   // [11:8]=0, [7:0]=in_bus

    wire [3:0]        i_I_in = in_bus[7:4];
    wire [3:0]        i_Q_in = in_bus[3:0];

    // Output aliases valid when i_cfg selects MODE_4..7
    wire signed [5:0] o_I_BB = o_bus_c[11:6];
    wire signed [5:0] o_Q_BB = o_bus_c[5:0];

    // out_bus unchanged
    logic [11:0] out_bus;
    assign out_bus = o_bus_c;

    // ==========================================================
    // DUT — demod_wrapper
    // ==========================================================
    demod_wrapper #(
        .CFG_WIDTH   (CFG_WIDTH),
        .BUS_A_WIDTH (BUS_A_WIDTH),
        .BUS_B_WIDTH (BUS_B_WIDTH),
        .BUS_C_WIDTH (BUS_C_WIDTH),
        .BUS_D_WIDTH (BUS_D_WIDTH)
    ) dut (
        .i_clk   (clk),
        .i_rst_n (rst_n),
        .i_cfg   (i_cfg),
        .i_bus_a (i_bus_a),
        .i_bus_b (i_bus_b),
        .o_bus_c (o_bus_c),
        .o_bus_d (o_bus_d)
    );

    // ==========================================================
    // VARIABLES DE STATISTIQUES
    // ==========================================================
    int sample_count   = 0;
    int xz_error_count = 0;

    // ==========================================================
    // CHECK X/Z EN CONTINU
    // ==========================================================
    always @(posedge clk) begin
        if (rst_n)
            check_xz(in_bus, out_bus, xz_error_count);
    end

    // ==========================================================
    // MONITOR
    // ==========================================================
    initial begin
        $timeformat(-9, 1, " ns", 12);
        $display("---------------------------------------------------------------");
        $display(" time           rst cfg | I_in Q_in |  I_BB  Q_BB");
        $display("---------------------------------------------------------------");
        forever begin
            @(posedge clk);
            $display("%t  %0b  %03b | %2d   %2d  | %4d  %4d",
                     $time, rst_n, i_cfg, i_I_in, i_Q_in, o_I_BB, o_Q_BB);
        end
    end

    // ==========================================================
    // SÉQUENCE PRINCIPALE
    // ==========================================================
    initial begin : STIMULUS_MAIN

        // Static port defaults
        i_bus_a = '0;
        i_cfg   = MODE_IQ_BB;   // route s_i_bb/s_q_bb to o_bus_c throughout

        // Reset via task
        in_bus = 8'h88;         // I=8, Q=8 par défaut
        apply_reset(rst_n, 4, clk);

        // --- Test 1 : valeur fixe I=8, Q=8 ---
        report_case("TEST FIXE I=8 Q=8");
        send_iq(in_bus, clk, 4'd8, 4'd8);
        wait_clk(clk, 5);
        show_outputs("FIXE", in_bus, out_bus);

        // --- Test 2 : balayage des valeurs I/Q ---
        report_case("SWEEP I/Q [0..15]");
        for (int i = 0; i < 16; i++) begin
            send_iq(in_bus, clk, i[3:0], i[3:0]);
            wait_clk(clk, 2);
            show_outputs("SWEEP", in_bus, out_bus);
        end

        // --- Test 3 : lecture fichiers I/Q ---
        report_case("LECTURE FICHIERS I/Q");
        apply_samples_from_files(
            in_bus, clk,
            I_FILENAME, Q_FILENAME,
            sample_count, xz_error_count
        );
        wait_clk(clk, FIR_SETTLE);
        show_outputs("FIN FICHIER IQ", in_bus, out_bus);

        // --- Résultats finaux ---
        $display(" ");
        $display("============================================================");
        $display("FIN DE SIMULATION");
        $display("  Samples lus   : %0d", sample_count);
        $display("  Erreurs X/Z   : %0d", xz_error_count);
        $display("  Résultat      : %s",
                 (xz_error_count == 0) ? "PASS — PAS DE X/Z" : "FAIL — X/Z DÉTECTÉ");
        $display("============================================================");

        $finish;
    end

    // ==========================================================
    // TIMEOUT
    // ==========================================================
    initial begin
        #(CLK_PERIOD_NS * 30000);
        $display("TIMEOUT");
        $finish;
    end

endmodule
