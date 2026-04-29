`timescale 1ns/1ps

module tb_demod_system;
    timeunit      1ns;
    timeprecision 1ps;

    // =========================================================
    // PARAMETRES
    // =========================================================
    localparam int CLK_PERIOD_NS = 100;   // 10 MHz
    localparam int FIR_SETTLE    = 20;

    localparam string I_FILENAME = "I_IF_data_IMG.txt";
    localparam string Q_FILENAME = "Q_IF_data_IMG.txt";

    // =========================================================
    // SIGNAUX TB
    // =========================================================
    logic              i_clk = 1'b0;
    logic              i_rst_n;

    logic [3:0]        i_I_in;
    logic [3:0]        i_Q_in;

    logic signed [5:0] o_I_BB;
    logic signed [5:0] o_Q_BB;
    logic signed [3:0] o_cos_test;
    logic signed [3:0] o_sin_test;


    integer iq_eod_pulse_count;
    integer xz_error_count;

    integer fd_i;
    integer fd_q;
    integer ret_i;
    integer ret_q;
    integer I_txt;
    integer Q_txt;
    integer sample_count;

    // =========================================================
    // DUT
    // =========================================================
    demod_system dut (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_i       (i_I_in),
        .i_q       (i_Q_in),
        .o_i_bb    (o_I_BB),
        .o_q_bb    (o_Q_BB),
	.o_cos_test (o_cos_test),
	.o_sin_test (o_sin_test)
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
        sample_count       = 0;

        #(4*CLK_PERIOD_NS);
        i_rst_n = 1'b1;
    end

    // =========================================================
    // TASKS
    // =========================================================
    task automatic wait_clk(input int n);
        int m;
        begin
            for (m = 0; m < n; m = m + 1)
                @(posedge i_clk);
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
            $display("[%0s] time=%0t  I_in=%0d  Q_in=%0d  -->  I_BB=%0d  Q_BB=%0d",
                     name, $time, i_I_in, i_Q_in, o_I_BB, o_Q_BB);
        end
    endtask

    // =========================================================
    // LECTURE DES FICHIERS I ET Q
    // =========================================================
    task automatic apply_samples_from_files(
        input string i_filename,
        input string q_filename
    );
        begin
            fd_i = $fopen("I_IF_data_IMG.txt", "r");
            fd_q = $fopen("Q_IF_data_IMG.txt", "r");

            if (fd_i == 0) begin
                $display("ERROR : impossible d'ouvrir le fichier I : %s", i_filename);
                $finish;
            end

            if (fd_q == 0) begin
                $display("ERROR : impossible d'ouvrir le fichier Q : %s", q_filename);
                $finish;
            end

            $display("Lecture fichier I : %s", i_filename);
            $display("Lecture fichier Q : %s", q_filename);

            while (!$feof(fd_i) && !$feof(fd_q)) begin
                ret_i = $fscanf(fd_i, "%d\n", I_txt);
                ret_q = $fscanf(fd_q, "%d\n", Q_txt);

                if ((ret_i == 1) && (ret_q == 1)) begin
                    if ((I_txt < 0) || (I_txt > 15)) begin
                        $display("ERROR @%t : valeur I hors range 4 bits : %0d", $time, I_txt);
                        xz_error_count = xz_error_count + 1;
                    end

                    if ((Q_txt < 0) || (Q_txt > 15)) begin
                        $display("ERROR @%t : valeur Q hors range 4 bits : %0d", $time, Q_txt);
                        xz_error_count = xz_error_count + 1;
                    end

                    @(negedge i_clk);
                    i_I_in <= I_txt[3:0];
                    i_Q_in <= Q_txt[3:0];

                    sample_count = sample_count + 1;

                    $display("SAMPLE %0d @%0t : I=%0d  Q=%0d",
                             sample_count, $time, I_txt[3:0], Q_txt[3:0]);
                end
            end

            if (!$feof(fd_i) || !$feof(fd_q)) begin
                $display("WARNING : les fichiers I et Q n'ont pas la meme longueur");
            end

            $fclose(fd_i);
            $fclose(fd_q);
        end
    endtask

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
    // MONITOR
    // =========================================================
    initial begin
        $timeformat(-9, 1, " ns", 12);

        $display("--------------------------------------------------------------------------------");
        $display(" time          rst | I_in Q_in | I_BB Q_BB");
        $display("--------------------------------------------------------------------------------");

        forever begin
            @(posedge i_clk);
            $display("%t   %0b | %2d   %2d | %4d %4d",
                     $time, i_rst_n, i_I_in, i_Q_in, o_I_BB, o_Q_BB);
        end
    end

    // =========================================================
    // STIMULI PRINCIPAUX
    // =========================================================
    initial begin : STIMULUS_MAIN
        wait(i_rst_n == 1'b1);

        report_case("LECTURE DES SIGNAUX I/Q DEPUIS FICHIERS TEXTE");

        apply_samples_from_files(I_FILENAME, Q_FILENAME);

        wait_clk(FIR_SETTLE);
        show_outputs("FIN FICHIER IQ");

        $display(" ");
        $display("============================================================");
        $display("FIN DE SIMULATION");
        $display("Nombre de samples lus            = %0d", sample_count);
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
    // TIMEOUT
    // =========================================================
    initial begin
        #(CLK_PERIOD_NS*30000);
        $display("TIMEOUT");
        $finish;
    end

endmodule

