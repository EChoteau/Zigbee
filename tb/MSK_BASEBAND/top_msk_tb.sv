 `timescale 1ns/1ps
    module top_msk_tb();
    // Signaux du testbench
    logic s_clk;
    logic s_rst_n;
    logic s_enable_ech;
    logic s_flag_enable;
    logic s_b_in; // <-- Modifié ici pour correspondre à ton entrée !
    logic signed [5:0] s_I_BB;
    logic signed [5:0] s_Q_BB;
    // Séquence de bits complexe pour tester l'encodeur et voir de belles courbes
    logic s_sequence [0:9] = '{1, 0, 1, 1, 0, 0, 1, 0, 1, 1};
    // Branchement de TON vrai TOP module complet
    top_msk DUT (
        .i_clk(s_clk),
        .i_rst_n(s_rst_n),
        .i_enable_ech(s_enable_ech),
        .i_flag_enable(s_flag_enable),
        .i_b_in(s_b_in), // <-- Modifié ici : on attaque l'encodeur directement !
        .o_I_BB(s_I_BB),
        .o_Q_BB(s_Q_BB)
    );
    // Horloge
    always #10 s_clk = ~s_clk;
    // Scénario
    initial begin
        // 1. Reset
        $display("--- DEBUT DE LA SIMULATION TOP MSK ---");
        s_clk = 0;
        s_rst_n = 0;
        s_enable_ech = 0;
        s_flag_enable = 0;
        s_b_in = 0;
        
        #25 s_rst_n = 1;
        @(posedge s_clk);
        // 2. Envoi de la séquence de bits brute
        for (int i = 0; i < 10; i++) begin
            
            // --- A. On envoie UN nouveau bit à l'encodeur ---
            s_b_in = s_sequence[i];
            s_flag_enable = 1;
            @(posedge s_clk);
            s_flag_enable = 0;
            
            // --- B. On laisse le Shaping dessiner l'arche pendant Tb ---
            // Une arche entière (2Tb) = 64 échantillons
            // Un seul bit (Tb) = 32 échantillons
            for (int ech = 0; ech < 32; ech++) begin
                s_enable_ech = 1;
                @(posedge s_clk);
                s_enable_ech = 0;
                
                // On simule l'attente entre chaque point de la courbe
                repeat(3) @(posedge s_clk);
            end
            
        end
        $display("--- SIMULATION TERMINEE ---");
        $stop;
    end
endmodule
