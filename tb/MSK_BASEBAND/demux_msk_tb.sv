`timescale 1ns/1ps

module demux_msk_tb(); // Règle 4.1 : Aucune entrée/sortie

    // Déclaration des signaux internes au testbench (préfixe s_ selon la règle 2.2)
    logic s_clk;
    logic s_rst_n;
    logic s_flag_enable;
    logic s_b_enc;
    
    logic s_a_I;
    logic s_a_Q;

    // Instanciation du DUT (Device Under Test)
    demux_msk DUT (
        .i_clk(s_clk),
        .i_rst_n(s_rst_n),
        .i_flag_enable(s_flag_enable),
        .i_b_enc(s_b_enc),
        .o_a_I(s_a_I),
        .o_a_Q(s_a_Q)
    );

    // Génération de l'horloge (Règle 3.1 : Système synchrone)
    always #10 s_clk = ~s_clk;// 50Mhz

    // Scénario de test auto-vérifié
    initial begin
        // ==========================================
        // ETAPE 1 : Initialisation et Reset
        // ==========================================
        s_clk = 0;
        s_rst_n = 0; 
        s_flag_enable = 0;
        s_b_enc = 0;

        #25 s_rst_n = 1; // On relâche le reset
        
        // ==========================================
        // ETAPE 2 : Test nominal (Aiguillage I puis Q)
        // ==========================================
        @(posedge s_clk);
        
        // --- Envoi d'un '0' (devrait aller sur la voie I) ---
        s_b_enc = 0;
        s_flag_enable = 1;
        @(posedge s_clk);
        s_flag_enable = 0;
        #1; // On attend 1ps pour laisser le signal se propager
        
        // AUTO-VERIFICATION (Règle 4.2)
        assert (s_a_I == 1'b0) else $error("Erreur FATALE : La voie I devrait etre a 0 !");
        assert (s_a_Q == 1'b1) else $error("Erreur FATALE : La voie Q aurait du garder sa valeur par defaut (1) !");
        #39;

        // --- Envoi d'un '1' (devrait aller sur la voie Q) ---
        s_b_enc = 1;
        s_flag_enable = 1;
        @(posedge s_clk);
        s_flag_enable = 0;
        #1;
        
        // AUTO-VERIFICATION
        assert (s_a_Q == 1'b1) else $error("Erreur FATALE : La voie Q devrait etre a 1 !");
        assert (s_a_I == 1'b0) else $error("Erreur FATALE : La voie I aurait du garder son ancienne valeur (0) !");
        #39;

        // ==========================================
        // ETAPE 3 : Test du Reset en cours de route (Règle 4.3)
        // ==========================================
        $display("--- Test du Reset asynchrone en plein fonctionnement ---");
        s_rst_n = 0; // Coup de reset brutal !
        #5;          // On attend un tout petit peu (asynchrone, pas besoin d'attendre l'horloge)
        
        assert (s_a_I == 1'b1 && s_a_Q == 1'b1) 
            else $error("Erreur FATALE : Le module ne s'est pas re-initialise correctement avec le Reset !");
            
        #20 s_rst_n = 1; // On remet le système en marche

        // Fin propre
        $display("--- TOUS LES TESTS SONT PASSES AVEC SUCCES ---");
        $stop; 
    end

endmodule