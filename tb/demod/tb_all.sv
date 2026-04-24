`timescale 1ns/1ps

module tb_demod_system_complete;
    timeunit      1ns;
    timeprecision 1ps;

    // =========================================================
    // PARAMETRES
    // =========================================================
    localparam int CLK_PERIOD_NS = 100;   // 10 MHz
    localparam int FIR_SETTLE    = 20;

    // =========================================================
    // SIGNAUX TB
    // =========================================================
    logic              i_clk = 1'b0;
    logic              i_rst_n;
    logic [3:0]        i_I_in;
    logic [3:0]        i_Q_in;
    logic signed [5:0] o_I_BB;
    logic signed [5:0] o_Q_BB;
    integer iq_eod_pulse_count;
    integer xz_error_count;

    // =========================================================
    // DUT
    // =========================================================
    demod_system_complete dut (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_i       (i_I_in),
        .i_q       (i_Q_in),
        .o_i_bb    (o_I_BB),
        .o_q_bb    (o_Q_BB)
    );

    // =========================================================
    // CLOCK
    // =========================================================
    always #(CLK_PERIOD_NS/2) i_clk = ~i_clk;

    // =========================================================
    // RESET
    // =========================================================
    initial begin
        i_rst_n = 1'b0;
        i_I_in  = 4'd8;
        i_Q_in  = 4'd8;

        iq_eod_pulse_count = 0;
        xz_error_count     = 0;

        #(4*CLK_PERIOD_NS);
        i_rst_n = 1'b1;
    end


    // =========================================================
    // CHECK X/Z
    // =========================================================
    always @(posedge i_clk) begin
        if (i_rst_n) begin
            if ($isunknown(i_I_in)) begin
                $display("ERROR @%t : i_I_in contains X/Z = %b", $time, i_I_in);
                xz_error_count = xz_error_count + 1;
            end
            if ($isunknown(i_Q_in)) begin
                $display("ERROR @%t : i_Q_in contains X/Z = %b", $time, i_Q_in);
                xz_error_count = xz_error_count + 1;
            end
            if ($isunknown(o_I_BB)) begin
                $display("ERROR @%t : o_I_BB contains X/Z = %b", $time, o_I_BB);
                xz_error_count = xz_error_count + 1;
            end
            if ($isunknown(o_Q_BB)) begin
                $display("ERROR @%t : o_Q_BB contains X/Z = %b", $time, o_Q_BB);
                xz_error_count = xz_error_count + 1;
            end
        end
    end

    // =========================================================
    // TACHES
    // =========================================================
    task automatic wait_clk(input int n);
        int m;
        begin
            for (m = 0; m < n; m = m + 1)
                @(posedge i_clk);
        end
    endtask

    task automatic apply_sample(input logic [3:0] Ival, input logic [3:0] Qval);
        begin
            @(posedge i_clk);
            i_I_in <= Ival;
            i_Q_in <= Qval;
        end
    endtask

    task automatic report_case(input [8*40-1:0] name);
        begin
            $display(" ");
            $display("============================================================");
            $display("CASE : %0s", name);
            $display("============================================================");
        end
    endtask

    task automatic show_outputs(input [8*40-1:0] name);
        begin
            $display("[%0s] time=%0t  I_in=%0d  Q_in=%0d  -->  I_BB=%0d  Q_BB=%0d ",
                     name, $time, i_I_in, i_Q_in, o_I_BB, o_Q_BB);
        end
    endtask

    // =========================================================
    // MONITOR
    // =========================================================
    initial begin
        $timeformat(-9, 1, " ns", 12);
        $display("--------------------------------------------------------------------------------");
        $display(" time      rst | I_in Q_in | I_BB Q_BB | iq_eod");
        $display("--------------------------------------------------------------------------------");
        forever begin
            @(posedge i_clk);
            $display("%t   %0b | %2d   %2d | %4d %4d",    
                     $time, i_rst_n, i_I_in, i_Q_in, o_I_BB, o_Q_BB );
        end
    end

    // =========================================================
    // STIMULI PRINCIPAUX
    // =========================================================
    initial begin : STIMULUS_MAIN
        wait(i_rst_n == 1'b1);

        // -----------------------------------------------------
        // 1) REPOS
        // -----------------------------------------------------
        report_case("REPOS : I=8, Q=8");
        repeat (12) apply_sample(4'd8, 4'd8);
        wait_clk(FIR_SETTLE);
        show_outputs("REPOS");

        // -----------------------------------------------------
        // 2) I seul positif
        // -----------------------------------------------------
        report_case("I SEUL POSITIF : I=12, Q=8");
        repeat (16) apply_sample(4'd12, 4'd8);
        wait_clk(FIR_SETTLE);
        show_outputs("I SEUL POSITIF");

        // -----------------------------------------------------
        // 3) I seul negatif
        // -----------------------------------------------------
        report_case("I SEUL NEGATIF : I=4, Q=8");
        repeat (16) apply_sample(4'd4, 4'd8);
        wait_clk(FIR_SETTLE);
        show_outputs("I SEUL NEGATIF");

        // -----------------------------------------------------
        // 4) Q seul positif
        // -----------------------------------------------------
        report_case("Q SEUL POSITIF : I=8, Q=12");
        repeat (16) apply_sample(4'd8, 4'd12);
        wait_clk(FIR_SETTLE);
        show_outputs("Q SEUL POSITIF");

        // -----------------------------------------------------
        // 5) Q seul negatif
        // -----------------------------------------------------
        report_case("Q SEUL NEGATIF : I=8, Q=4");
        repeat (16) apply_sample(4'd8, 4'd4);
        wait_clk(FIR_SETTLE);
        show_outputs("Q SEUL NEGATIF");

        // -----------------------------------------------------
        // 6) Sequence IF 4 points
        // -----------------------------------------------------
        report_case("SEQUENCE IF 4 POINTS");
        apply_sample(4'd15, 4'd8 );
        apply_sample(4'd8 , 4'd15);
        apply_sample(4'd0 , 4'd8 );
        apply_sample(4'd8 , 4'd0 );
        apply_sample(4'd15, 4'd8 );
        apply_sample(4'd8 , 4'd15);
        apply_sample(4'd0 , 4'd8 );
        apply_sample(4'd8 , 4'd0 );
        wait_clk(FIR_SETTLE);
        show_outputs("SEQUENCE IF");

        // -----------------------------------------------------
        // 7) Test croise
        // -----------------------------------------------------
        report_case("TEST CROISE");
        apply_sample(4'd12, 4'd12);
        apply_sample(4'd4 , 4'd12);
        apply_sample(4'd4 , 4'd4 );
        apply_sample(4'd12, 4'd4 );
        wait_clk(FIR_SETTLE);
        show_outputs("TEST CROISE");

        // -----------------------------------------------------
        // FIN
        // -----------------------------------------------------
        $display(" ");
        $display("============================================================");
        $display("FIN DE SIMULATION");
        $display("Nombre de pulses iq_eod observes = %0d", iq_eod_pulse_count);
        $display("Nombre d'erreurs X/Z observees   = %0d", xz_error_count);
        $display("============================================================");

        if (xz_error_count == 0)
            $display("RESULTAT : PAS DE X/Z DETECTE");
        else
            $display("RESULTAT : ATTENTION, X/Z DETECTE");

        $finish;
    end

    // =========================================================
    // CHECKS SIMPLES
    // =========================================================
    always @(posedge i_clk) begin
        if (i_rst_n) begin
            if ((i_I_in == 4'd12) && (i_Q_in == 4'd8)) begin
                if ((o_I_BB == 0) && (o_Q_BB == 0))
                    $display("WARNING @%t : test I seul positif mais sorties nulles", $time);
            end
            if ((i_I_in == 4'd8) && (i_Q_in == 4'd12)) begin
                if ((o_I_BB == 0) && (o_Q_BB == 0))
                    $display("WARNING @%t : test Q seul positif mais sorties nulles", $time);
            end
        end
    end

    // =========================================================
    // TIMEOUT
    // =========================================================
    initial begin
        #(CLK_PERIOD_NS*30000);
        $display("TIMEOUT");
        $finish;
    end

endmodule
