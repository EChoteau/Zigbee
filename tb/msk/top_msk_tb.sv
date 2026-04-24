`timescale 1ns/1ps

module top_msk_tb();

    // -------------------------------------------------------------------------
    // Signaux du testbench
    // -------------------------------------------------------------------------
    logic s_clk;
    logic s_rst_n;
    logic s_enable_ech;
    logic s_flag_enable;
    logic s_b_in;
    logic signed [5:0] s_I_BB;
    logic signed [5:0] s_Q_BB;

    // Séquence de bits complexe pour tester l'encodeur et voir de belles courbes
    logic s_sequence [0:9] = '{0, 0, 1, 1, 0, 0, 1, 0, 1, 1};

    // -------------------------------------------------------------------------
    // Branchement du TOP module complet
    // -------------------------------------------------------------------------
    msk_system DUT (
        .i_clk(s_clk),
        .i_rst_n(s_rst_n),
        .i_enable_ech(s_enable_ech),
        .i_flag_enable(s_flag_enable),
        .i_b_in(s_b_in),
        .o_I_BB(s_I_BB),
        .o_Q_BB(s_Q_BB)
    );

    // -------------------------------------------------------------------------
    // Horloge 50 MHz
    // -------------------------------------------------------------------------
    always #10 s_clk = ~s_clk;

    // -------------------------------------------------------------------------
    // Scénario de test
    // -------------------------------------------------------------------------
    initial begin
        $display("--- DEBUT DE LA SIMULATION TOP MSK (50 points / arche) ---");

        // Initialisation
        s_clk         = 0;
        s_rst_n       = 0;
        s_enable_ech  = 0;
        s_flag_enable = 0;
        s_b_in        = 0;

        // Reset
        #25;
        s_rst_n = 1;
        @(posedge s_clk);

        // Envoi de la séquence de bits brute
        for (int i = 0; i < 10; i++) begin

            // --- A. On envoie UN nouveau bit à l'encodeur ---
            // (La duplication a été supprimée ici)
            s_b_in = s_sequence[i];
            s_flag_enable = 1;
            @(posedge s_clk);
            s_flag_enable = 0;

            // --- B. On laisse le shaping dessiner un bit = 25 points ---
            // Une arche entière = 50 points = 2 bits
            // Un seul bit = 25 points
            for (int ech = 0; ech < 25; ech++) begin
                s_enable_ech = 1;
                @(posedge s_clk);
                s_enable_ech = 0;

                // Attente entre deux ticks d'échantillonnage
                repeat (3) @(posedge s_clk);
            end
        end

        // Laisser finir proprement la dernière forme
        repeat (50) @(posedge s_clk);

        $display("--- SIMULATION TERMINEE ---");
        $stop;
    end

    // -------------------------------------------------------------------------
    // ASSERTIONS (Surveillance Automatique)
    // -------------------------------------------------------------------------

    // 1. Vérification du Reset :
    // Vérifie que si rst_n est à 0, au coup d'horloge suivant, I et Q sont à 0.
    property p_check_reset;
        @(posedge s_clk) (!s_rst_n |=> (s_I_BB == 0 && s_Q_BB == 0));
    endproperty
    
    assert_reset: assert property(p_check_reset)
        else $error("[ASSERT FAILED] Le Reset actif bas ne met pas I et Q à 0 !");

    // 2. Vérification des limites d'amplitude (Voie I) :
    // Vérifie que la valeur reste bien confinée entre -31 et +31 (sur 6 bits signés)
    property p_limites_I;
        @(posedge s_clk) disable iff (!s_rst_n) (s_I_BB >= -6'sd31 && s_I_BB <= 6'sd31);
    endproperty
    
    assert_limite_I: assert property(p_limites_I)
        else $error("[ASSERT FAILED] Débordement d'amplitude sur I: %d", s_I_BB);

    // 3. Vérification des limites d'amplitude (Voie Q) :
    property p_limites_Q;
        @(posedge s_clk) disable iff (!s_rst_n) (s_Q_BB >= -6'sd31 && s_Q_BB <= 6'sd31);
    endproperty
    
    assert_limite_Q: assert property(p_limites_Q)
        else $error("[ASSERT FAILED] Débordement d'amplitude sur Q: %d", s_Q_BB);

endmodule
