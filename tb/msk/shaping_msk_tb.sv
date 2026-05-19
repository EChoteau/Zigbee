`timescale 1ns/1ps

module shaping_msk_tb();

    // -------------------------------------------------------------------------
    // 1. Signaux internes au Testbench
    // -------------------------------------------------------------------------
    logic s_clk;
    logic s_rst_n;
    logic s_enable_ech;
    logic s_a_I;
    logic s_a_Q;
    logic signed [5:0] s_I_BB;
    logic signed [5:0] s_Q_BB;

    // -------------------------------------------------------------------------
    // 2. Instanciation du composant (Le "DUT")
    // -------------------------------------------------------------------------
    shaping_msk DUT (
        .i_clk(s_clk),
        .i_rst_n(s_rst_n),
        .i_enable_ech(s_enable_ech),
        .i_a_I(s_a_I),
        .i_a_Q(s_a_Q),
        .o_I_BB(s_I_BB),
        .o_Q_BB(s_Q_BB)
    );

    // -------------------------------------------------------------------------
    // 3. Horloge (50 MHz = 20 ns de période)
    // -------------------------------------------------------------------------
    always #50 s_clk = ~s_clk;

    // -------------------------------------------------------------------------
    // 4. Scénario de Test Unitaire
    // -------------------------------------------------------------------------
    initial begin
        $display("--- DEBUT DE LA SIMULATION SHAPING MSK SEUL ---");

        // Initialisation propre
        s_clk        = 0;
        s_rst_n      = 0;
        s_enable_ech = 0;
        s_a_I        = 0;
        s_a_Q        = 0;

        // On lâche le Reset après 25 ns
        #25 s_rst_n = 1;
        @(posedge s_clk);

        // On active l'échantillonnage en continu (1 point par coup d'horloge)
        s_enable_ech = 1'b1;

        // --- SCÉNARIO 1 : Bosses Positives (I=1, Q=1) ---
        $display(">> Test 1 : Bosses vers le haut");
        s_a_I = 1'b1;
        s_a_Q = 1'b1;
        // On attend 50 coups d'horloge (le temps d'une arche entière)
        repeat (50) @(posedge s_clk);

        // --- SCÉNARIO 2 : Bosses Négatives (I=0, Q=0) ---
        $display(">> Test 2 : Bosses vers le bas");
        s_a_I = 1'b0;
        s_a_Q = 1'b0;
        repeat (50) @(posedge s_clk);

        // --- SCÉNARIO 3 : Mixte (I=1, Q=0) ---
        $display(">> Test 3 : Croisement (I=1, Q=0)");
        s_a_I = 1'b1;
        s_a_Q = 1'b0;
        // On attend un peu plus longtemps pour bien voir les ondes se croiser
        repeat (75) @(posedge s_clk);

        // Fin propre
        s_enable_ech = 1'b0;
        repeat (5) @(posedge s_clk);
        
        $display("--- SIMULATION TERMINEE ---");
        $stop;
    end

    // -------------------------------------------------------------------------
    // 5. ASSERTIONS (Vigiles de sécurité)
    // -------------------------------------------------------------------------

    // A. Vérification du comportement au Reset
    property p_check_reset;
        @(posedge s_clk) (!s_rst_n |=> (s_I_BB == 0 && s_Q_BB == 0));
    endproperty
    
    assert_reset: assert property(p_check_reset)
        else $error("[ASSERT FAILED] Les sorties I/Q ne sont pas à 0 pendant le Reset !");

    // B. Vérification du non-débordement de la Voie I (Entre -31 et +31)
    property p_limites_I;
        @(posedge s_clk) disable iff (!s_rst_n) (s_I_BB >= -6'sd31 && s_I_BB <= 6'sd31);
    endproperty
    
    assert_limite_I: assert property(p_limites_I)
        else $error("[ASSERT FAILED] Amplitude Voie I hors limites: %d", s_I_BB);

    // C. Vérification du non-débordement de la Voie Q
    property p_limites_Q;
        @(posedge s_clk) disable iff (!s_rst_n) (s_Q_BB >= -6'sd31 && s_Q_BB <= 6'sd31);
    endproperty
    
    assert_limite_Q: assert property(p_limites_Q)
        else $error("[ASSERT FAILED] Amplitude Voie Q hors limites: %d", s_Q_BB);

endmodule
