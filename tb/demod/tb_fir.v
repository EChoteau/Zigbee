`timescale 1ns/1ps

module tb_fir;

    // =========================
    // Parameters
    // =========================
    parameter CLK_PERIOD = 20;   // 50 MHz

    // =========================
    // Signals
    // =========================
    reg               i_clk;
    reg               i_rst_n;
    reg               i_sample_en;
    reg  signed [7:0] i_x_in;
    wire signed [7:0] o_y_out;

    reg signed [7:0] s_y_out_prev;

    integer i;
    integer period;
    integer nonzero_count;

    // =========================
    // DUT
    // =========================
    fir_top u_dut (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_sample_en(i_sample_en),
        .i_x_in     (i_x_in),
        .o_y_out    (o_y_out)
    );

    // =========================
    // Clock generation
    // =========================
    initial begin
        i_clk = 0;
        forever #(CLK_PERIOD/2) i_clk = ~i_clk;
    end

    // =========================
    // Save previous output
    // =========================
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            s_y_out_prev <= 0;
        else
            s_y_out_prev <= o_y_out;
    end

    // =========================
    // Assertions / checks
    // =========================

    // 1) Pas de X/Z après reset
    always @(posedge i_clk) begin
        if (i_rst_n) begin
            assert (!$isunknown(o_y_out))
            else $error("ERREUR: o_y_out contient X/Z à t=%0t", $time);
        end
    end

    // 2) Pendant reset, la sortie doit être nulle
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            assert (o_y_out == 0)
            else $error("ERREUR: o_y_out non nul pendant reset à t=%0t, o_y_out=%0d", $time, o_y_out);
        end
    end

    // 3) Si sample_en = 0, la sortie doit rester stable
    always @(posedge i_clk) begin
        if (i_rst_n && !i_sample_en) begin
            assert (o_y_out == s_y_out_prev)
            else $error("ERREUR: o_y_out a changé alors que i_sample_en=0 à t=%0t", $time);
        end
    end

    // =========================
    // Tasks
    // =========================
    task wait_clocks(input integer n);
        integer k;
        begin
            for (k = 0; k < n; k = k + 1)
                @(posedge i_clk);
        end
    endtask

    task send_sample(input signed [7:0] i_sample);
        begin
            @(negedge i_clk);
            i_x_in <= i_sample;
        end
    endtask

    // =========================
    // Stimulus
    // =========================
    initial begin

        // Init
        i_rst_n      = 0;
        i_sample_en  = 0;
        i_x_in       = 0;
        nonzero_count = 0;

        wait_clocks(5);

        // Vérification reset
        @(negedge i_clk);
        i_rst_n     <= 1;
        i_sample_en <= 1;

        wait_clocks(3);

        // =====================================
        // Test 0 : silence
        // =====================================
        $display("---- Silence Test ----");

        for (i = 0; i < 20; i = i + 1) begin
            send_sample(0);
            @(posedge i_clk);
        end

        assert (o_y_out > -2 && o_y_out < 2)
        else $error("ERREUR: o_y_out ne revient pas vers 0 après silence, t=%0t, o_y_out=%0d", $time, o_y_out);

        // =====================================
        // Test 1 : réponse impulsionnelle
        // =====================================
        $display("---- Impulse Response Test ----");

        send_sample(20);
        @(posedge i_clk);

        send_sample(0);

        nonzero_count = 0;
        for (i = 0; i < 40; i = i + 1) begin
            @(posedge i_clk);
            if (o_y_out != 0)
                nonzero_count = nonzero_count + 1;
        end

        assert (nonzero_count > 0)
        else $error("ERREUR: aucune réponse impulsionnelle détectée");

        // =====================================
        // Test 2 : stabilité quand sample_en = 0
        // =====================================
        $display("---- Hold Test (i_sample_en = 0) ----");

        @(negedge i_clk);
        i_sample_en <= 0;
        i_x_in      <= 50;

        wait_clocks(10);

        @(negedge i_clk);
        i_sample_en <= 1;
        i_x_in      <= 0;

        wait_clocks(5);

        // =====================================
        // Test 3 : sinus basse fréquence
        // =====================================
        $display("---- Low Frequency Sine Test ----");

        nonzero_count = 0;
        period = 80;

        for (i = 0; i < 200; i = i + 1) begin
            send_sample($rtoi(20.0 * $sin(2.0*3.14159*i/period)));
            @(posedge i_clk);
            if (o_y_out != 0)
                nonzero_count = nonzero_count + 1;
        end

        assert (nonzero_count > 20)
        else $error("ERREUR: la sortie semble inactive sur sinus basse fréquence");

        // =====================================
        // Test 4 : sweep fréquentiel
        // =====================================
        $display("---- Frequency Sweep Test ----");

        for (period = 80; period >= 4; period = period - 4) begin
            $display("Testing sine period = %0d", period);

            nonzero_count = 0;

            for (i = 0; i < 200; i = i + 1) begin
                send_sample($rtoi(20.0 * $sin(2.0*3.14159*i/period)));
                @(posedge i_clk);

                if (o_y_out != 0)
                    nonzero_count = nonzero_count + 1;
            end

            assert (nonzero_count > 10)
            else $error("ERREUR: sortie inactive pendant sweep, période=%0d", period);
        end

        // =====================================
        // Test 5 : retour au silence
        // =====================================
        $display("---- Return to Silence Test ----");

        for (i = 0; i < 30; i = i + 1) begin
            send_sample(0);
            @(posedge i_clk);
        end

        assert (o_y_out > -2 && o_y_out < 2)
        else $error("ERREUR: o_y_out ne revient pas vers 0 après retour au silence, o_y_out=%0d", o_y_out);

        $display("TB FIR : PASS");
        $stop;
    end

endmodule
