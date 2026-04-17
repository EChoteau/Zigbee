`timescale 1ns/1ps

module tb_receiver_system;

    // =========================================================
    // Paramètres
    // =========================================================
    localparam int CLK_PERIOD_NS = 20;   // 50 MHz
    localparam int SAMPLE_DIV    = 5;    // 10 MHz
    localparam int N_BURST       = 120;

    localparam int ADC_MID = 8;
    localparam int AMP     = 5;

    // =========================================================
    // Signaux TB
    // =========================================================
    logic              i_clk;
    logic              i_rst_n;
    logic              i_adc_eoc;
    logic [3:0]        i_I_in, i_Q_in;
    logic signed [7:0] o_I_filtered, o_Q_filtered;

    // =========================================================
    // DUT
    // =========================================================
    receiver_system dut (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_adc_eoc   (i_adc_eoc),
        .i_I_in      (i_I_in),
        .i_Q_in      (i_Q_in),
        .o_I_filtered(o_I_filtered),
        .o_Q_filtered(o_Q_filtered)
    );

    // Signaux internes observés
    wire signed [7:0] s_I_demod = dut.s_I_demod;
    wire signed [7:0] s_Q_demod = dut.s_Q_demod;

    // =========================================================
    // Horloge
    // =========================================================
    initial i_clk = 0;
    always #(CLK_PERIOD_NS/2) i_clk = ~i_clk;

    // =========================================================
    // Variables de test
    // =========================================================
    integer error_count;
    integer activity_count;
    integer quiet_count;
    integer k;
    integer noise_i, noise_q;
    integer sample_i, sample_q;

    // =========================================================
    // Fonctions utiles
    // =========================================================
    function automatic [3:0] sat4(input int v);
        if (v < 0)       sat4 = 4'd0;
        else if (v > 15) sat4 = 4'd15;
        else             sat4 = v[3:0];
    endfunction

    task automatic wait_clocks(input int n);
        int i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge i_clk);
        end
    endtask

    task automatic send_sample(input [3:0] i_i_s, input [3:0] i_q_s);
        begin
            repeat (SAMPLE_DIV-1) begin
                @(negedge i_clk);
                i_adc_eoc <= 0;
            end

            @(negedge i_clk);
            i_I_in    <= i_i_s;
            i_Q_in    <= i_q_s;
            i_adc_eoc <= 1;

            @(negedge i_clk);
            i_adc_eoc <= 0;
        end
    endtask

    // =========================================================
    // Compteur de silence
    // =========================================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            quiet_count <= 0;
        else if ((i_I_in == 4'd8) && (i_Q_in == 4'd8))
            quiet_count <= quiet_count + 1;
        else
            quiet_count <= 0;
    end

    // =========================================================
    // Assertions simples et robustes
    // =========================================================
/*
    // Pas de X/Z
    always @(posedge i_clk) begin
        if (i_rst_n) begin
            if ($isunknown(s_I_demod)) begin
                error_count++;
                $error("s_I_demod X/Z à t=%0t", $time);
            end

            if ($isunknown(s_Q_demod)) begin
                error_count++;
                $error("s_Q_demod X/Z à t=%0t", $time);
            end

            if ($isunknown(o_I_filtered)) begin
                error_count++;
                $error("o_I_filtered X/Z à t=%0t", $time);
            end

            if ($isunknown(o_Q_filtered)) begin
                error_count++;
                $error("o_Q_filtered X/Z à t=%0t", $time);
            end
        end
    end

    // Reset correct
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            if (s_I_demod !== 0) begin
                error_count++;
                $error("s_I_demod != 0 pendant reset");
            end
            if (s_Q_demod !== 0) begin
                error_count++;
                $error("s_Q_demod != 0 pendant reset");
            end
            if (o_I_filtered !== 0) begin
                error_count++;
                $error("o_I_filtered != 0 pendant reset");
            end
            if (o_Q_filtered !== 0) begin
                error_count++;
                $error("o_Q_filtered != 0 pendant reset");
            end
        end
    end

    // Valeurs bornées
    always @(posedge i_clk) begin
        if (i_rst_n) begin
            if (($signed(o_I_filtered) < -127) || ($signed(o_I_filtered) > 127)) begin
                error_count++;
                $error("o_I_filtered overflow");
            end
            if (($signed(o_Q_filtered) < -127) || ($signed(o_Q_filtered) > 127)) begin
                error_count++;
                $error("o_Q_filtered overflow");
            end
        end
    end

    // Retour au silence (moins strict)
    always @(negedge i_clk) begin
        if (i_rst_n && quiet_count > 50) begin
            if (!(($signed(o_I_filtered) > -25 && $signed(o_I_filtered) < 25) &&
                  ($signed(o_Q_filtered) > -25 && $signed(o_Q_filtered) < 25))) begin
                error_count++;
                $error("Pas retour au silence correct : I=%0d Q=%0d",
                       $signed(o_I_filtered), $signed(o_Q_filtered));
            end
        end
    end
*/
    // =========================================================
    // Stimulus principal
    // =========================================================
    initial begin
        error_count    = 0;
        activity_count = 0;
        k              = 0;

        i_rst_n   = 0;
        i_adc_eoc = 0;
        i_I_in    = 4'd8;
        i_Q_in    = 4'd8;

        wait_clocks(5);
        @(negedge i_clk);
        i_rst_n <= 1;

        wait_clocks(3);

        // ------------------------------
        // Test 1 : silence
        // ------------------------------
        $display("---- Test 1 : Silence ----");
        repeat (20) send_sample(4'd8, 4'd8);

        // ------------------------------
        // Test 2 : burst IQ
        // ------------------------------
        $display("---- Test 2 : Burst IQ ----");

        repeat (N_BURST) begin
            noise_i = $urandom_range(-1, 1);
            noise_q = $urandom_range(-1, 1);

            case (k)
                0: begin sample_i = ADC_MID + AMP + noise_i; sample_q = ADC_MID       + noise_q; end
                1: begin sample_i = ADC_MID       + noise_i; sample_q = ADC_MID + AMP + noise_q; end
                2: begin sample_i = ADC_MID - AMP + noise_i; sample_q = ADC_MID       + noise_q; end
                3: begin sample_i = ADC_MID       + noise_i; sample_q = ADC_MID - AMP + noise_q; end
            endcase

            send_sample(sat4(sample_i), sat4(sample_q));
            k = (k + 1) % 4;

            if ((o_I_filtered != 0) || (o_Q_filtered != 0))
                activity_count++;
        end

        if (activity_count < 20) begin
            error_count++;
            $error("Pas assez d'activité pendant burst");
        end

        // ------------------------------
        // Test 3 : retour au silence
        // ------------------------------
        $display("---- Test 3 : Retour silence ----");

        repeat (40) send_sample(4'd8, 4'd8);
        wait_clocks(30);

        if (!(($signed(o_I_filtered) > -25 && $signed(o_I_filtered) < 25) &&
              ($signed(o_Q_filtered) > -25 && $signed(o_Q_filtered) < 25))) begin
            error_count++;
            $error("Sortie finale pas proche de 0");
        end

        // ------------------------------
        // Résultat final
        // ------------------------------
        if (error_count == 0)
            $display("TB receiver_system : PASS");
        else
            $display("TB receiver_system : FAIL (%0d erreurs)", error_count);

        $stop;
    end

endmodule
