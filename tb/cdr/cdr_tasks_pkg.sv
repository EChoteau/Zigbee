// ==============================================================
// cdr_tasks_pkg.sv — Package de tasks réutilisables pour CDR
//
// Utilisation dans un testbench :
//   import cdr_tasks_pkg::*;
//
// Les signaux (in_bus, out_bus, clk, rst) sont passés en
// argument ref au lieu d'être implicitement référencés.
// ==============================================================

package cdr_tasks_pkg;

    // ----------------------------------------------------------
    // Envoyer la dérivée de phase sur in_bus
    // ----------------------------------------------------------
    task automatic send_dphi(
        ref   logic signed [5:0] in_bus,
        input logic               data_in
    );
        if (data_in) in_bus = 6'sd8;
        else         in_bus = -6'sd8;
    endtask

    // ----------------------------------------------------------
    // Lire et décoder les signaux depuis out_bus
    // ----------------------------------------------------------
    task automatic read_output(
        ref   logic [1:0] out_bus,
        ref   logic       clk,
        output logic      data_out,
        output logic      clk_out
    );
        @(posedge clk);
        data_out = out_bus[0];
        clk_out  = out_bus[1];
    endtask

    // ----------------------------------------------------------
    // Appliquer le reset
    // ----------------------------------------------------------
    task automatic apply_reset(
        ref   logic               rst,
        ref   logic signed [5:0]  in_bus,
        input int                 duration_ns
    );
        rst    = 0;
        in_bus = 6'sd0;
        #(duration_ns);
        rst = 1;
        $display("[RESET] Reset relâché à t=%0t", $time);
    endtask

    // ----------------------------------------------------------
    // Attendre N fronts montants de clk
    // ----------------------------------------------------------
    task automatic wait_cycles(
        ref   logic clk,
        input int   n
    );
        int i;
        for (i = 0; i < n; i++)
            @(posedge clk);
    endtask

    // ----------------------------------------------------------
    // Envoyer N bits aléatoires avec contrainte run-length
    // ----------------------------------------------------------
    task automatic run_random_sequence(
        ref   logic signed [5:0] in_bus,
        ref   logic [1:0]        out_bus,
        ref   logic              clk,
        input int                n_bits,
        output int               errors
    );
        logic [2:0] same_count = 0;
        logic       data_bit   = 0;
        logic       data_bit_p = 0;
        logic       new_data;
        logic       cap_data, cap_clk;
        int         sent = 0;
        int         cnt  = 0;

        errors = 0;

        while (sent < n_bits) begin
            @(posedge clk);

            if (cnt == 2) begin
                new_data = $random;

                if (new_data == data_bit) same_count = same_count + 1;
                else                      same_count = 0;

                if (same_count >= 7) begin
                    data_bit   = ~data_bit;
                    same_count = 0;
                end else begin
                    data_bit = new_data;
                end

                data_bit_p = data_bit;
                sent       = sent + 1;
                send_dphi(in_bus, data_bit);
            end

            if (cnt == 4) cnt = 0;
            else          cnt = cnt + 1;
        end

        // Vérification finale
        read_output(out_bus, clk, cap_data, cap_clk);
        if (cap_data !== data_bit_p) begin
            errors = errors + 1;
            $display("[ERR] decision=%0b attendu=%0b", cap_data, data_bit_p);
        end
    endtask

endpackage
