// ==============================================================
// tb_nco.sv
// i_bus_in[7:0]  = i_ctrl (signed 8 bits)
// o_bus_out[2:0] = {o_recovered_clk, o_sample_enable, o_ctrl_ack}
// K_NOMINAL = 5 -> sample_enable toutes les 5 cycles
// ==============================================================
`timescale 1ns/1ps

import cdr_tasks_pkg::*;

module tb_nco;

    logic clk   = 0;
    logic i_rst_n;
    always #10 clk = ~clk;

    logic [21:0] i_bus_in;
    logic [13:0] o_bus_out;

    wire o_recovered_clk = o_bus_out[2];
    wire o_sample_enable = o_bus_out[1];
    wire o_ctrl_ack      = o_bus_out[0];

    nco #(
        .PHASE_WIDTH(16),
        .K_NOMINAL  (5),
        .CTRL_W     (8)
    ) dut (
        .i_clk          (clk),
        .i_rst_n        (i_rst_n),
        .i_ctrl         (i_bus_in),
        .o_recovered_clk(o_bus_out[2]),
        .o_sample_enable(o_bus_out[1]),
        .o_ctrl_ack     (o_bus_out[0])
    );

    // Pas de X/Z après reset
    always @(posedge clk)
        if (i_rst_n)
            nco_check_no_xz(o_bus_out, "RUNNING");

    // sample_enable et ctrl_ack toujours simultanés
    always @(posedge clk)
        if (i_rst_n)
            assert (o_bus_out[1] === o_bus_out[0])
                else $error("[NCO] sample_enable=%0b != ctrl_ack=%0b à t=%0t",
                            o_bus_out[1], o_bus_out[0], $time);

    // Pendant reset -> sorties = 0
    always @(posedge clk)
        if (!i_rst_n)
            assert (o_bus_out[1:0] === 2'b00)
                else $error("[NCO] sorties non nulles pendant reset t=%0t", $time);

    int pulse_count;

    initial begin

        i_bus_in = 8'sd0;

        // Reset
        report_case("RESET");
        nco_reset(i_rst_n, clk, 4);
        wait_clk(clk, 2);
        nco_check_no_xz(o_bus_out, "APRES RESET");

        // ctrl=0 -> période nominale = 5 cycles -> 20 pulses en 100 cycles
        report_case("CTRL=0 : PERIODE NOMINALE (5 cycles)");
        nco_set_ctrl(i_bus_in, 8'sd0);
        nco_count_pulses(o_bus_out, clk, 100, pulse_count);
        $display("  Pulses en 100 cycles (attendu ~20) : %0d", pulse_count);
        assert (pulse_count >= 18 && pulse_count <= 22)
            else $error("[NCO] Nombre de pulses inattendu ctrl=0: %0d", pulse_count);

        // ctrl>0 -> période augmente à 6 -> moins de pulses
        report_case("CTRL=+1 : PERIODE AUGMENTEE (6 cycles)");
        nco_set_ctrl(i_bus_in, 8'sd1);
        nco_count_pulses(o_bus_out, clk, 100, pulse_count);
        $display("  Pulses en 100 cycles (attendu ~16) : %0d", pulse_count);
        assert (pulse_count >= 14 && pulse_count <= 18)
            else $error("[NCO] Nombre de pulses inattendu ctrl=+1: %0d", pulse_count);

        // ctrl<0 -> période diminue à 4 -> plus de pulses
        report_case("CTRL=-1 : PERIODE DIMINUEE (4 cycles)");
        nco_set_ctrl(i_bus_in, -8'sd1);
        nco_count_pulses(o_bus_out, clk, 100, pulse_count);
        $display("  Pulses en 100 cycles (attendu ~25) : %0d", pulse_count);
        assert (pulse_count >= 23 && pulse_count <= 27)
            else $error("[NCO] Nombre de pulses inattendu ctrl=-1: %0d", pulse_count);

        // Retour ctrl=0 -> période nominale
        report_case("RETOUR CTRL=0 : PERIODE NOMINALE");
        nco_set_ctrl(i_bus_in, 8'sd0);
        nco_count_pulses(o_bus_out, clk, 100, pulse_count);
        $display("  Pulses en 100 cycles (attendu ~20) : %0d", pulse_count);
        assert (pulse_count >= 18 && pulse_count <= 22)
            else $error("[NCO] Période nominale non restaurée: %0d", pulse_count);

        // Reset en cours de fonctionnement
        report_case("RESET EN COURS");
        nco_set_ctrl(i_bus_in, 8'sd1);
        wait_clk(clk, 10);
        nco_reset(i_rst_n, clk, 3);
        // Après reset -> ctrl_ack et sample_enable doivent être à 0
        @(posedge clk);
        assert (o_bus_out[1:0] === 2'b00)
            else $error("[NCO] Sorties non remises à 0 après reset");

        // ctrl très grand -> bornage à 6
        report_case("CTRL GRAND (bornage periode max=6)");
        nco_set_ctrl(i_bus_in, 8'sd127);
        nco_count_pulses(o_bus_out, clk, 100, pulse_count);
        $display("  Pulses en 100 cycles (attendu ~16, borné à 6) : %0d", pulse_count);
        assert (pulse_count >= 14 && pulse_count <= 18)
            else $error("[NCO] Bornage max non respecté: %0d", pulse_count);

        // ctrl très négatif -> bornage à 4
        report_case("CTRL NEGATIF (bornage periode min=4)");
        nco_set_ctrl(i_bus_in, -8'sd128);
        nco_count_pulses(o_bus_out, clk, 100, pulse_count);
        $display("  Pulses en 100 cycles (attendu ~25, borné à 4) : %0d", pulse_count);
        assert (pulse_count >= 23 && pulse_count <= 27)
            else $error("[NCO] Bornage min non respecté: %0d", pulse_count);

        $display("============================================================");
        $display("TB NCO : PASS");
        $display("============================================================");
        $finish;
    end

endmodule
