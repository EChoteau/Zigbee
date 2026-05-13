// ==============================================================
// tb_fir.sv — Testbench FIR avec package
// ==============================================================
`timescale 1ns/1ps

import demod_tasks_pkg::*;

module tb_fir;

    // ==========================================================
    // PARAMÈTRES
    // ==========================================================
    localparam int CLK_PERIOD = 100;

    // ==========================================================
    // CLOCK & RESET
    // ==========================================================
    logic clk   = 0;
    logic rst_n = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ==========================================================
    // BUS
    //   in_bus[7:0]  = i_x_in  (signed 8 bits)
    //   out_bus[7:0] = o_y_out (signed 8 bits)
    // ==========================================================
    logic signed [7:0] in_bus;
    logic signed [7:0] out_bus;

    // ==========================================================
    // DUT
    // ==========================================================
    fir_top u_dut (
        .i_clk   (clk),
        .i_rst_n (rst_n),
        .i_x_in  (in_bus),
        .o_y_out (out_bus)
    );

    // ==========================================================
    // ASSERTIONS EN CONTINU
    // ==========================================================
    logic signed [7:0] out_bus_prev;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) out_bus_prev <= 0;
        else        out_bus_prev <= out_bus;
    end

    always @(posedge clk) begin
        if (rst_n)
            check_fir_output(out_bus, "RUNNING");
        if (!rst_n)
            assert (out_bus == 0)
                else $error("out_bus non nul pendant reset t=%0t val=%0d", $time, out_bus);
    end

    // ==========================================================
    // SÉQUENCE PRINCIPALE
    // ==========================================================
    int nonzero_count;
    int period;

    initial begin

        // Reset via task
        in_bus = 8'sd0;
        apply_reset(rst_n, 5, clk);
        wait_clk(clk, 3);

        // --- Test 0 : silence ---
        report_case("SILENCE");
        for (int i = 0; i < 20; i++) begin
            send_sample(in_bus, clk, 8'sd0);
            wait_clk(clk, 1);
        end
        assert (out_bus > -8'sd2 && out_bus < 8'sd2)
            else $error("Sortie ne revient pas à 0 après silence : %0d", out_bus);

        // --- Test 1 : réponse impulsionnelle ---
        report_case("RÉPONSE IMPULSIONNELLE");
        send_sample(in_bus, clk, 8'sd20);
        wait_clk(clk, 1);
        send_sample(in_bus, clk, 8'sd0);

        nonzero_count = 0;
        for (int i = 0; i < 20; i++) begin
            wait_clk(clk, 1);
            if (out_bus != 0) nonzero_count++;
        end
        assert (nonzero_count > 0)
            else $error("Aucune réponse impulsionnelle détectée");
        $display("  Réponse impulsionnelle : %0d cycles non nuls", nonzero_count);

        // --- Test 2 : réponse échelon ---
        report_case("RÉPONSE ÉCHELON");
        for (int i = 0; i < 20; i++) begin
            send_sample(in_bus, clk, 8'sd30);
            wait_clk(clk, 1);
        end
        check_fir_output(out_bus, "ECHELON");

        for (int i = 0; i < 10; i++) begin
            send_sample(in_bus, clk, 8'sd0);
            wait_clk(clk, 1);
        end

        // --- Test 3 : sinus basse fréquence ---
        report_case("SINUS BASSE FRÉQUENCE (période=80)");
        nonzero_count = 0;
        period = 80;
        for (int i = 0; i < 200; i++) begin
            send_sample(in_bus, clk,
                $rtoi(20.0 * $sin(2.0 * 3.14159 * i / period)));
            wait_clk(clk, 1);
            if (out_bus != 0) nonzero_count++;
        end
        assert (nonzero_count > 20)
            else $error("Sortie inactive sur sinus BF");
        $display("  Sinus BF : %0d cycles non nuls", nonzero_count);

        // --- Test 4 : sweep fréquentiel ---
        report_case("SWEEP FRÉQUENTIEL");
        for (period = 80; period >= 4; period -= 4) begin
            $display("  Période = %0d", period);
            nonzero_count = 0;
            for (int i = 0; i < 120; i++) begin
                send_sample(in_bus, clk,
                    $rtoi(20.0 * $sin(2.0 * 3.14159 * i / period)));
                wait_clk(clk, 1);
                if (out_bus != 0) nonzero_count++;
            end
            assert (nonzero_count > 10)
                else $error("Sortie inactive pendant sweep, période=%0d", period);
        end

        // --- Test 5 : retour silence ---
        report_case("RETOUR AU SILENCE");
        for (int i = 0; i < 30; i++) begin
            send_sample(in_bus, clk, 8'sd0);
            wait_clk(clk, 1);
        end
        assert (out_bus > -8'sd2 && out_bus < 8'sd2)
            else $error("Sortie ne revient pas à 0 : %0d", out_bus);

        $display("============================================================");
        $display("TB FIR : PASS");
        $display("============================================================");
        $finish;
    end

endmodule
