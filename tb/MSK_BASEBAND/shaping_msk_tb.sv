`timescale 1ns/1ps

module shaping_msk_tb(); // Règle 4.1 : Pas d'entrée/sortie

    // --------------------------------------------------------------------------
    // 1. DÉCLARATION DES SIGNAUX (Préfixe s_)
    // --------------------------------------------------------------------------
    logic s_clk;
    logic s_rst_n;
    logic s_enable_ech;
    logic s_a_I;
    logic s_a_Q;
    
    // Sorties du module (signées sur 6 bits)
    logic signed [5:0] s_I_BB;
    logic signed [5:0] s_Q_BB;

    // --------------------------------------------------------------------------
    // 2. INSTANCIATION DU DUT (Device Under Test)
    // --------------------------------------------------------------------------
    shaping_msk DUT (
        .i_clk(s_clk),
        .i_rst_n(s_rst_n),
        .i_enable_ech(s_enable_ech),
        .i_a_I(s_a_I),
        .i_a_Q(s_a_Q),
        .o_I_BB(s_I_BB),
        .o_Q_BB(s_Q_BB)
    );

    // --------------------------------------------------------------------------
    // 3. GÉNÉRATION DE L'HORLOGE (50 MHz)
    // --------------------------------------------------------------------------
    always #10 s_clk = ~s_clk;

    // --------------------------------------------------------------------------
    // 4. SCÉNARIO DE TEST AUTO-VÉRIFIÉ
    // --------------------------------------------------------------------------
    initial begin
        // ==========================================
        // ÉTAPE 1 : Initialisation
        // ==========================================
        $display("--- DEBUT DE LA SIMULATION SHAPING MSK ---");
        s_clk = 0;
        s_rst_n = 0; 
        s_enable_ech = 0;
        s_a_I = 1; // On commence par demander une arche positive sur I
        s_a_Q = 1; // Et une arche positive sur Q
        
        #25 s_rst_n = 1; // On relâche le reset
        @(posedge s_clk);

        // ==========================================
        // ÉTAPE 2 : Génération d'une arche POSITIVE (I=1, Q=1)
        // ==========================================
        $display("1. Test des arches positives (I=1, Q=1)...");
        for (int i = 0; i < 64; i++) begin
            s_enable_ech = 1;
            @(posedge s_clk);
            s_enable_ech = 0;
            repeat(2) @(posedge s_clk); 
            #1; 
            
            if (i == 31) assert (s_I_BB == 6'd31) else $error("Erreur : Pic I positif rate !");
            if (i == 63) assert (s_Q_BB == 6'd31) else $error("Erreur : Pic Q positif rate !");
        end

        // ==========================================
        // ÉTAPE 3 : Génération d'une arche NÉGATIVE (I=0, Q=0)
        // ==========================================
        $display("2. Test des arches negatives (I=0, Q=0)...");
        s_a_I = 0;
        s_a_Q = 0;
        
        for (int i = 0; i < 64; i++) begin
            s_enable_ech = 1;
            @(posedge s_clk);
            s_enable_ech = 0;
            repeat(2) @(posedge s_clk);
            #1;
            
            // On vérifie le complément à 2 (-31)
            if (i == 31) assert (s_I_BB == -6'sd31) else $error("Erreur : Pic I negatif rate !");
            if (i == 63) assert (s_Q_BB == -6'sd31) else $error("Erreur : Pic Q negatif rate !");
        end

        // ==========================================
        // ÉTAPE 4 : Génération MIXTE (I=0, Q=1)
        // ==========================================
        $display("3. Test du croisement Mixte (I=0, Q=1)...");
        s_a_I = 0; // I plonge vers le bas
        s_a_Q = 1; // Q monte vers le haut
        
        for (int i = 0; i < 64; i++) begin
            s_enable_ech = 1;
            @(posedge s_clk);
            s_enable_ech = 0;
            repeat(2) @(posedge s_clk);
            #1;
            
            // I doit être à -31 (négatif), et Q doit être à +31 (positif)
            if (i == 31) assert (s_I_BB == -6'sd31) else $error("Erreur : Pic I mixte rate !");
            if (i == 63) assert (s_Q_BB == 6'd31)   else $error("Erreur : Pic Q mixte rate !");
        end

        // ==========================================
        // ÉTAPE 5 : Test du Reset
        // ==========================================
        $display("4. Test du Reset asynchrone...");
        s_rst_n = 0; 
        #5; 
        assert (s_I_BB == 6'd0 && s_Q_BB == 6'd0) 
            else $error("Erreur FATALE : Les sorties ne retombent pas a 0 !");

        $display("--- TOUS LES TESTS SONT PASSES AVEC SUCCES ---");
        $stop; 
    end

endmodule