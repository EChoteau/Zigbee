// ==========================================================================
// cdr_tasks.vh
// Tasks réutilisables pour les testbenches CDR
//
// Signaux attendus dans le module qui inclut ce fichier :
//   - logic signed [5:0] in_bus   → entrée dphi vers le DUT
//   - logic        [1:0] out_bus  → sorties du DUT (decision, clk_rec)
//   - logic              clk      → horloge système
// ==========================================================================

// --------------------------------------------------------------------------
// Envoyer la dérivée de phase sur in_bus
//   data_in = 1 → dphi = +8
//   data_in = 0 → dphi = -8
// --------------------------------------------------------------------------
task automatic send_dphi;
    input logic data_in;
    begin
        if (data_in)
            in_bus <= in_bus_w'sd8;
        else
            in_bus <= -in_bus_w'sd8;
    end
endtask

// --------------------------------------------------------------------------
// Lire et décoder les signaux depuis out_bus
//   data_out → out_bus[0] (decision)
//   clk_out  → out_bus[1] (clk_rec)
// --------------------------------------------------------------------------
task automatic read_output;
    output logic data_out;
    output logic clk_out;
    begin
        @(posedge clk);
        data_out = out_bus[0];
        clk_out  = out_bus[1];
    end
endtask

// --------------------------------------------------------------------------
// Envoyer une séquence fixe de bits
//   bits[]   → tableau de bits à envoyer
//   n        → nombre de bits
//   delay_ns → délai entre chaque bit (en ns)
// --------------------------------------------------------------------------
task automatic send_sequence;
    input logic  bits  [];
    input int    n;
    input int    delay_ns;
    int i;
    begin
        for (i = 0; i < n; i++) begin
            send_dphi(bits[i]);
            #(delay_ns);
        end
    end
endtask

// --------------------------------------------------------------------------
// Envoyer N bits aléatoires avec contrainte run-length (max 7 bits identiques)
//   n_bits  → nombre de bits à envoyer
//   errors  → nombre d'erreurs détectées (retour)
// --------------------------------------------------------------------------
task automatic run_random_sequence;
    input  int n_bits;
    output int errors;

    reg        data_bit;
    reg        data_bit_p;
    reg  [2:0] same_count;
    reg        new_data;
    logic      captured_data;
    logic      captured_clk;
    int        sent;
    integer    cnt;

    begin
        data_bit   = 0;
        data_bit_p = 0;
        same_count = 0;
        errors     = 0;
        sent       = 0;
        cnt        = 0;

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

                send_dphi(data_bit);
            end

            if (cnt == 4) cnt = 0;
            else          cnt = cnt + 1;
        end

        // Vérification finale
        read_output(captured_data, captured_clk);
        if (captured_data !== data_bit_p) begin
            errors = errors + 1;
            $display("[ERR] decision=%0b attendu=%0b", captured_data, data_bit_p);
        end
    end
endtask

// --------------------------------------------------------------------------
// Appliquer le reset
//   duration_ns → durée du reset en ns
// --------------------------------------------------------------------------
task automatic apply_reset;
    input int duration_ns;
    begin
        rst    = 0;
        in_bus = in_bus_w'sd0;
        #(duration_ns);
        rst = 1;
        $display("[RESET] Reset relâché à t=%0t", $time);
    end
endtask

// --------------------------------------------------------------------------
// Attendre N fronts montants de clk
// --------------------------------------------------------------------------
task automatic wait_cycles;
    input int n;
    int i;
    begin
        for (i = 0; i < n; i++)
            @(posedge clk);
    end
endtask
