// ==============================================================
// demod_tasks_pkg.sv — Package de tasks réutilisables DEMOD
//
// Bus convention :
//
//   DEMOD SYSTEM (tb_demod.sv) :
//     in_bus  [7:0]  = { i_I_in[3:0], i_Q_in[3:0] }
//     out_bus [11:0] = { o_I_BB[5:0], o_Q_BB[5:0] }
//
//   FIR (tb_fir.sv) :
//     in_bus  [7:0]  = i_x_in  (signed 8 bits)
//     out_bus [7:0]  = o_y_out (signed 8 bits)
//
// Signaux attendus dans le module qui importe ce package :
//     ref logic        clk
//     ref logic        rst_n
//     ref logic [N:0]  in_bus
//     ref logic [M:0]  out_bus
// ==============================================================

package demod_tasks_pkg;

    // ----------------------------------------------------------
    // Attendre N fronts montants de clk
    // ----------------------------------------------------------
    task automatic wait_clk(
        ref   logic clk,
        input int   n
    );
        int i;
        for (i = 0; i < n; i++)
            @(posedge clk);
    endtask

    // ----------------------------------------------------------
    // Appliquer le reset
    // ----------------------------------------------------------
    task automatic apply_reset(
        ref   logic rst_n,
        input int   n_cycles,
        ref   logic clk
    );
        rst_n = 1'b0;
        wait_clk(clk, n_cycles);
        @(negedge clk);
        rst_n = 1'b1;
        $display("[RESET] Reset relâché à t=%0t", $time);
    endtask

    // ----------------------------------------------------------
    // Afficher un header de cas de test
    // ----------------------------------------------------------
    task automatic report_case(input string name);
        $display(" ");
        $display("============================================================");
        $display("CASE : %0s", name);
        $display("============================================================");
    endtask

    // ----------------------------------------------------------
    // DEMOD — Envoyer un échantillon I/Q sur in_bus
    //   in_bus[7:4] = I_in
    //   in_bus[3:0] = Q_in
    // ----------------------------------------------------------
    task automatic send_iq(
        ref   logic [7:0] in_bus,
        ref   logic       clk,
        input logic [3:0] i_val,
        input logic [3:0] q_val
    );
        @(negedge clk);
        in_bus = {i_val, q_val};
    endtask

    // ----------------------------------------------------------
    // DEMOD — Afficher les sorties depuis out_bus
    //   out_bus[11:6] = o_I_BB (signed 6 bits)
    //   out_bus[5:0]  = o_Q_BB (signed 6 bits)
    // ----------------------------------------------------------
    task automatic show_outputs(
        input string      name,
        input logic [7:0] in_bus,
        input logic [11:0] out_bus
    );
        $display("[%0s] t=%0t  I_in=%0d  Q_in=%0d  -->  I_BB=%0d  Q_BB=%0d",
                 name, $time,
                 in_bus[7:4], in_bus[3:0],
                 $signed(out_bus[11:6]), $signed(out_bus[5:0]));
    endtask

    // ----------------------------------------------------------
    // DEMOD — Vérifier l'absence de X/Z sur in_bus et out_bus
    // ----------------------------------------------------------
    task automatic check_xz(
        input logic [7:0]  in_bus,
        input logic [11:0] out_bus,
        inout int          xz_count
    );
        if ($isunknown(in_bus[7:4])) begin
            $display("ERROR @%t : i_I_in contient X/Z = %b", $time, in_bus[7:4]);
            xz_count++;
        end
        if ($isunknown(in_bus[3:0])) begin
            $display("ERROR @%t : i_Q_in contient X/Z = %b", $time, in_bus[3:0]);
            xz_count++;
        end
        if ($isunknown(out_bus[11:6])) begin
            $display("ERROR @%t : o_I_BB contient X/Z = %b", $time, out_bus[11:6]);
            xz_count++;
        end
        if ($isunknown(out_bus[5:0])) begin
            $display("ERROR @%t : o_Q_BB contient X/Z = %b", $time, out_bus[5:0]);
            xz_count++;
        end
    endtask

    // ----------------------------------------------------------
    // DEMOD — Lire et appliquer des échantillons I/Q depuis fichiers
    // ----------------------------------------------------------
    task automatic apply_samples_from_files(
        ref   logic [7:0] in_bus,
        ref   logic       clk,
        input string      i_filename,
        input string      q_filename,
        inout int         sample_count,
        inout int         xz_count
    );
        integer fd_i, fd_q;
        integer ret_i, ret_q;
        integer I_txt, Q_txt;

        fd_i = $fopen(i_filename, "r");
        fd_q = $fopen(q_filename, "r");

        if (fd_i == 0) begin
            $display("ERROR : impossible d'ouvrir %s", i_filename);
            $finish;
        end
        if (fd_q == 0) begin
            $display("ERROR : impossible d'ouvrir %s", q_filename);
            $finish;
        end

        $display("Lecture fichier I : %s", i_filename);
        $display("Lecture fichier Q : %s", q_filename);

        while (!$feof(fd_i) && !$feof(fd_q)) begin
            ret_i = $fscanf(fd_i, "%d\n", I_txt);
            ret_q = $fscanf(fd_q, "%d\n", Q_txt);

            if ((ret_i == 1) && (ret_q == 1)) begin
                if ((I_txt < 0) || (I_txt > 15)) begin
                    $display("ERROR @%t : I hors range [0,15] : %0d", $time, I_txt);
                    xz_count++;
                end
                if ((Q_txt < 0) || (Q_txt > 15)) begin
                    $display("ERROR @%t : Q hors range [0,15] : %0d", $time, Q_txt);
                    xz_count++;
                end

                send_iq(in_bus, clk, I_txt[3:0], Q_txt[3:0]);
                sample_count++;

                $display("SAMPLE %0d @%0t : I=%0d  Q=%0d",
                         sample_count, $time, I_txt[3:0], Q_txt[3:0]);
            end
        end

        if (!$feof(fd_i) || !$feof(fd_q))
            $display("WARNING : fichiers I et Q de longueurs différentes");

        $fclose(fd_i);
        $fclose(fd_q);
    endtask

    // ----------------------------------------------------------
    // FIR — Envoyer un échantillon sur in_bus
    //   in_bus[7:0] = i_x_in (signed 8 bits)
    // ----------------------------------------------------------
    task automatic send_sample(
        ref   logic signed [7:0] in_bus,
        ref   logic              clk,
        input logic signed [7:0] sample
    );
        @(negedge clk);
        in_bus = sample;
    endtask

    // ----------------------------------------------------------
    // FIR — Vérifier l'absence de X/Z sur out_bus
    // ----------------------------------------------------------
    task automatic check_fir_output(
        input logic signed [7:0] out_bus,
        input string             ctx
    );
        assert (!$isunknown(out_bus))
            else $error("[%s] out_bus contient X/Z à t=%0t : %b", ctx, $time, out_bus);
    endtask

endpackage
