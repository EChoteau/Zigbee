// ==============================================================
// tb_phase_detector.sv — Refactoring de pd_bench.sv
// i_bus_in[1:0]  = {i_sample_clk, i_decision_in}
// o_bus_out[2:0] = {o_decision_out, o_up, o_down}
// ==============================================================
`timescale 1ns/1ps

import cdr_tasks_pkg::*;

module tb_phase_detector;

    // ----------------------------------------------------------
    // CLOCK
    // ----------------------------------------------------------
    logic clk = 0;
    always #50 clk = ~clk;   // 50 MHz

    // ----------------------------------------------------------
    // BUS
    // ----------------------------------------------------------
    logic       i_rst_n;
    logic [21:0] i_bus_in;    // {i_sample_clk, i_decision_in}
    logic [13:0] o_bus_out;   // {o_decision_out, o_up, o_down}

    wire i_sample_clk  = i_bus_in[1];
    wire i_decision_in = i_bus_in[0];
    wire o_decision    = o_bus_out[2];
    wire o_up          = o_bus_out[1];
    wire o_down        = o_bus_out[0];

    // ----------------------------------------------------------
    // DUT
    // ----------------------------------------------------------
    phase_detector dut (
        .i_clk        (clk),
        .i_rst_n      (i_rst_n),
        .i_sample_clk (i_bus_in[1]),
        .i_decision_in(i_bus_in[0]),
        .o_decision_out(o_bus_out[2]),
        .o_up          (o_bus_out[1]),
        .o_down        (o_bus_out[0])
    );

    // ----------------------------------------------------------
    // ASSERTIONS EN CONTINU
    // ----------------------------------------------------------

    // UP et DOWN jamais simultanés
    always @(posedge clk)
        if (i_rst_n)
            pd_check_no_conflict(o_bus_out, "CONTINU");

    // Pas de X/Z sur les sorties
    always @(posedge clk)
        if (i_rst_n)
            assert (!$isunknown(o_bus_out[2:0]))
                else $error("[PD] Sortie X/Z : %03b à t=%0t", o_bus_out, $time);

    // ----------------------------------------------------------
    // MONITOR
    // ----------------------------------------------------------
    initial begin
        $display("time           sample_clk decision_in | decision_out up down");
        forever begin
            @(posedge clk);
            $display("%t   %0b          %0b           |   %0b            %0b  %0b",
                     $time, i_sample_clk, i_decision_in,
                     o_decision, o_up, o_down);
        end
    end

    // ----------------------------------------------------------
    // SÉQUENCE PRINCIPALE
    // ----------------------------------------------------------
    logic prev_decision;

    initial begin

        // Reset
        report_case("RESET");
        pd_reset(i_rst_n, i_bus_in, clk, 5);
        wait_clk(clk, 2);

        // --- Test 1 : séquence fixe de bits ---
        report_case("SEQUENCE FIXE");
        // Transition 0->1 : attend UP
        prev_decision = 1'b0;
        pd_send(i_bus_in, clk, 1'b0);   // décision = 0 (référence)
        wait_clk(clk, 10);
        pd_send(i_bus_in, clk, 1'b1);   // transition 0->1
        wait_clk(clk, 10);
        pd_check_up(o_bus_out, "TRANSITION 0->1");

        // Transition 1->0 : attend DOWN
        pd_send(i_bus_in, clk, 1'b1);
        wait_clk(clk, 1);
        pd_send(i_bus_in, clk, 1'b0);   // transition 1->0
        wait_clk(clk, 1);
        pd_check_down(o_bus_out, "TRANSITION 1->0");

        // Pas de transition -> ni UP ni DOWN
        report_case("PAS DE TRANSITION -> AUCUN UP/DOWN");
        pd_send(i_bus_in, clk, 1'b0);
        wait_clk(clk, 1);
        pd_send(i_bus_in, clk, 1'b0);   // 0->0
        wait_clk(clk, 1);
        assert (o_bus_out[1] === 1'b0 && o_bus_out[0] === 1'b0)
            else $error("[PD] UP ou DOWN actif sans transition");

        pd_send(i_bus_in, clk, 1'b1);
        wait_clk(clk, 1);
        pd_send(i_bus_in, clk, 1'b1);   // 1->1
        wait_clk(clk, 1);
        assert (o_bus_out[1] === 1'b0 && o_bus_out[0] === 1'b0)
            else $error("[PD] UP ou DOWN actif sans transition");

        // --- Test 2 : séquence aléatoire avec vérification ---
        report_case("SEQUENCE ALEATOIRE (50 bits)");
        begin
            logic cur, prv;
            prv = 1'b0;
            for (int i = 0; i < 50; i++) begin
                cur = logic'($random);
                pd_send(i_bus_in, clk, cur);
                wait_clk(clk, 1);
                pd_check_no_conflict(o_bus_out, $sformatf("iter=%0d", i));
                if (prv == 1'b0 && cur == 1'b1)
                    pd_check_up(o_bus_out, $sformatf("0->1 iter=%0d", i));
                if (prv == 1'b1 && cur == 1'b0)
                    pd_check_down(o_bus_out, $sformatf("1->0 iter=%0d", i));
                prv = cur;
            end
        end

        // --- Test 3 : reset en cours de fonctionnement ---
        report_case("RESET EN COURS");
        pd_send(i_bus_in, clk, 1'b1);
        wait_clk(clk, 2);
        pd_reset(i_rst_n, i_bus_in, clk, 3);
        assert (!$isunknown(o_bus_out[2:0]))
            else $error("[PD] X/Z après reset");

        $display("============================================================");
        $display("TB PHASE DETECTOR : PASS");
        $display("============================================================");
        $finish;
    end

endmodule
