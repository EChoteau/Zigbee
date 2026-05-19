// ==============================================================
// tb_decision.sv
// i_bus_in[5:0]  = i_dphi_in (signed 6 bits)
// o_bus_out[0]   = o_decision_out
// DEAD_ZONE_WIDTH = 5 par défaut
// ==============================================================
`timescale 1ns/1ps

import cdr_tasks_pkg::*;

module tb_decision;

    // Module purement combinatoire -> pas de clock
    logic [21:0] i_bus_in;
    logic [13:0] o_bus_out;

    decision_block #(
        .resolution_in   (6),
        .DEAD_ZONE_WIDTH (5)
    ) dut (
        .i_dphi_in     (i_bus_in),
        .o_decision_out(o_bus_out[0])
    );

    // Pas de X/Z en sortie
    always @(i_bus_in)
        assert (!$isunknown(o_bus_out[0]))
            else $error("[DECISION] o_decision_out = X/Z pour dphi=%0d t=%0t",
                        i_bus_in, $time);

    // Séquence de vérification
    initial begin

        // --- Zone morte : -5 <= dphi <= +5 -> decision=0 ---
        report_case("DEAD ZONE [-5 .. +5] -> decision = 0");
        for (int d = -5; d <= 5; d++) begin
            decision_apply(i_bus_in, 6'(d));
            decision_check(o_bus_out[0], 1'b0, $sformatf("dphi=%0d", d));
            $display("  dphi=%3d -> decision=%0b (attendu=0)", d, o_bus_out[0]);
        end

        // --- Zone positive : dphi > +5 -> decision=1 ---
        report_case("ZONE POSITIVE (dphi > 5) -> decision = 1");
        for (int d = 6; d <= 31; d++) begin
            decision_apply(i_bus_in, 6'(d));
            decision_check(o_bus_out[0], 1'b1, $sformatf("dphi=%0d", d));
            $display("  dphi=%3d -> decision=%0b (attendu=1)", d, o_bus_out[0]);
        end

        // --- Zone négative : dphi < -5 -> decision=0 ---
        report_case("ZONE NEGATIVE (dphi < -5) -> decision = 0");
        for (int d = -6; d >= -32; d--) begin
            decision_apply(i_bus_in, 6'(d));
            decision_check(o_bus_out[0], 1'b0, $sformatf("dphi=%0d", d));
            $display("  dphi=%3d -> decision=%0b (attendu=0)", d, o_bus_out[0]);
        end

        // --- Frontières exactes ---
        report_case("FRONTIERES");
        // dphi = +5 -> dead zone -> 0
        decision_apply(i_bus_in, 6'sd5);
        decision_check(o_bus_out[0], 1'b0, "dphi=+5 (limite zone morte)");

        // dphi = +6 -> decision=1
        decision_apply(i_bus_in, 6'sd6);
        decision_check(o_bus_out[0], 1'b1, "dphi=+6 (premier actif positif)");

        // dphi = -5 -> dead zone -> 0
        decision_apply(i_bus_in, -6'sd5);
        decision_check(o_bus_out[0], 1'b0, "dphi=-5 (limite zone morte)");

        // dphi = -6 -> decision=0
        decision_apply(i_bus_in, -6'sd6);
        decision_check(o_bus_out[0], 1'b0, "dphi=-6 (premier actif negatif)");

        // --- Valeurs extrêmes ---
        report_case("VALEURS EXTREMES");
        decision_apply(i_bus_in, 6'sd31);
        decision_check(o_bus_out[0], 1'b1, "dphi=+31 (max)");

        decision_apply(i_bus_in, -6'sd32);
        decision_check(o_bus_out[0], 1'b0, "dphi=-32 (min)");

        $display("============================================================");
        $display("TB DECISION : PASS");
        $display("============================================================");
        $finish;
    end

endmodule
