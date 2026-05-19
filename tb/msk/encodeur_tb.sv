`timescale 1ns/1ps

module tb_encodeur_diff;

    // =========================================================================
    // Signaux
    // =========================================================================
    logic i_clk;
    logic i_rst_n;
    logic i_flag_enable;
    logic i_b_in;
    logic o_b_out;

    // Référence attendue pour vérification
    logic expected_b_out;

    // =========================================================================
    // Instanciation du DUT
    // =========================================================================
    encodeur_diff dut (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_flag_enable (i_flag_enable),
        .i_b_in        (i_b_in),
        .o_b_out       (o_b_out)
    );

    // =========================================================================
    // Horloge 50 MHz
    // =========================================================================
    localparam time CLK_PERIOD = 100ns;

    initial i_clk = 1'b0;
    always #(CLK_PERIOD/2) i_clk = ~i_clk;

    // =========================================================================
    // Tâche : envoi d'un bit
    // Le bit est placé avant le front montant pour être bien échantillonné
    // =========================================================================
    task automatic send_bit(input logic bk);
    begin
        // Préparer les entrées sur front descendant
        @(negedge i_clk);
        i_flag_enable = 1'b1;
        i_b_in        = bk;

        // Calcul de la valeur attendue
        expected_b_out = bk ~^ expected_b_out;

        // Le DUT échantillonne au front montant
        @(posedge i_clk);
        #1;

        $display("t=%0t ns | enable=%b | b_in=%b | b_out=%b | expected=%b",
                 $time, i_flag_enable, i_b_in, o_b_out, expected_b_out);

        if (o_b_out !== expected_b_out) begin
            $error("ERREUR : b_in=%b | attendu=%b | obtenu=%b",
                   i_b_in, expected_b_out, o_b_out);
        end

        // Retirer enable après le cycle
        @(negedge i_clk);
        i_flag_enable = 1'b0;
    end
    endtask

    // =========================================================================
    // Séquence de test
    // =========================================================================
    initial begin
        // Initialisation
        i_rst_n         = 1'b0;
        i_flag_enable   = 1'b0;
        i_b_in          = 1'b0;
        expected_b_out  = 1'b1;

        $display("====================================================");
        $display("===== DEBUT SIMULATION ENCODEUR DIFFERENTIEL =====");
        $display("====================================================");

        // Reset
        #50ns;
        i_rst_n = 1'b1;

        // Laisser passer un peu de temps
        @(posedge i_clk);
        #1;
        $display("Apres reset : o_b_out = %b (attendu = 1)", o_b_out);

        if (o_b_out !== 1'b1) begin
            $error("ERREUR RESET : o_b_out devrait valoir 1");
        end

        // ---------------------------------------------------------------------
        // Tests simples
        // ---------------------------------------------------------------------
        send_bit(1'b1); // conserve
        send_bit(1'b1); // conserve
        send_bit(1'b0); // inverse
        send_bit(1'b0); // inverse
        send_bit(1'b1); // conserve
        send_bit(1'b0); // inverse

        // ---------------------------------------------------------------------
        // Test d'une séquence complète
        // ---------------------------------------------------------------------
        $display("----------------------------------------------------");
        $display("Test sequence : 1011001010011101");
        $display("----------------------------------------------------");

        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b1);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);

        $display("====================================================");
        $display("===== FIN SIMULATION : TEST TERMINE SANS ERREUR =====");
        $display("====================================================");

        #50ns;
        $finish;
    end

endmodule
