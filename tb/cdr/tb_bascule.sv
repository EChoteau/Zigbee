// ==============================================================
// tb_bascule.sv
// i_bus_in[2:0] = {i_en, i_rst, i_D}
// o_bus_out[0]  = o_Q
// ==============================================================
`timescale 1ns/1ps

import cdr_tasks_pkg::*;

module tb_bascule;

    logic clk = 0;
    always #10 clk = ~clk;

    logic [21:0] i_bus_in  = 3'b010;  // {i_en, i_rst=1, i_D}
    logic [13:0] o_bus_out;

    bascule dut (
        .i_ck  (clk),
        .i_en  (i_bus_in[2]),
        .i_rst (i_bus_in[1]),
        .i_D   (i_bus_in[0]),
        .o_Q   (o_bus_out[0])
    );

    // Pendant reset -> sortie = 0
    always @(posedge clk)
        if (!i_bus_in[1])
            assert (o_bus_out[0] === 1'b0)
                else $error("[BASCULE] o_Q non nul pendant reset t=%0t", $time);

    // Pas de X/Z
    always @(posedge clk)
        if (i_bus_in[1])
            assert (!$isunknown(o_bus_out[0]))
                else $error("[BASCULE] o_Q = X/Z t=%0t", $time);

    initial begin

        // Reset
        report_case("RESET");
        bascule_reset(i_bus_in, clk, 4);
        wait_clk(clk, 2);
        bascule_check(o_bus_out[0], 1'b0, "APRES RESET");

        // Capture D=1 avec enable
        report_case("CAPTURE D=1 AVEC ENABLE");
        bascule_send(i_bus_in, clk, 1'b1, 1'b1);
        wait_clk(clk, 2);
        bascule_check(o_bus_out[0], 1'b1, "D=1 EN=1");

        // Hold si enable=0
        report_case("HOLD SANS ENABLE");
        bascule_send(i_bus_in, clk, 1'b0, 1'b0);
        wait_clk(clk, 2);
        bascule_check(o_bus_out[0], 1'b1, "HOLD Q=1");

        // Capture D=0
        report_case("CAPTURE D=0 AVEC ENABLE");
        bascule_send(i_bus_in, clk, 1'b0, 1'b0);
        wait_clk(clk, 1);
        bascule_send(i_bus_in, clk, 1'b0, 1'b1);  // front montant en
        wait_clk(clk, 2);
        bascule_check(o_bus_out[0], 1'b0, "D=0 EN=1");

        // Reset en cours de fonctionnement
        report_case("RESET EN COURS");
        bascule_send(i_bus_in, clk, 1'b1, 1'b1);
        wait_clk(clk, 2);
        bascule_reset(i_bus_in, clk, 2);
        bascule_check(o_bus_out[0], 1'b0, "RESET FORCE Q=0");

        // Séquence aléatoire
        report_case("SEQUENCE ALEATOIRE");
        for (int i = 0; i < 30; i++) begin
            bascule_send(i_bus_in, clk, logic'($random), logic'($random));
            wait_clk(clk, 2);
            assert (!$isunknown(o_bus_out[0]))
                else $error("[BASCULE] X/Z iter=%0d", i);
        end

        $display("============================================================");
        $display("TB BASCULE : PASS");
        $display("============================================================");
        $finish;
    end

endmodule
