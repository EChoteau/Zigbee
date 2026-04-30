`timescale 1ns/1ps

module msk_system_tb();

    // -------------------------------------------------------------------------
    // PARAMÈTRES (10 MHz -> 10 pts/µs)
    // -------------------------------------------------------------------------
    parameter int SAMPLES_PER_HALF_SINE = 10; 
    parameter int MSK_RES               = 6;
    
    // Signaux
    logic s_clk;
    logic s_rst_n;
    logic s_enable_ech;
    logic s_flag_enable;
    logic s_b_in;
    logic signed [MSK_RES-1:0] s_I_BB;
    logic signed [MSK_RES-1:0] s_Q_BB;

    // Séquence de test (10 bits)
    logic s_sequence [0:9] = '{1, 0, 1, 1, 0, 0, 1, 1, 0, 1};

    // Instanciation
    msk_system #(
        .SAMPLES_PER_HALF_SINE(SAMPLES_PER_HALF_SINE),
        .MSK_RES(MSK_RES)
    ) DUT (
        .i_clk(s_clk),
        .i_rst_n(s_rst_n),
	.i_flag_enable(s_flag_enable),
        .i_enable_ech(s_enable_ech),
        .i_b_in(s_b_in),
        .o_I_BB(s_I_BB),
        .o_Q_BB(s_Q_BB)
    );

    // -------------------------------------------------------------------------
    // Horloge 10 MHz (Période = 100ns -> demi-période = 50ns)
    // -------------------------------------------------------------------------
    
    always #50 s_clk = ~s_clk;

    // -------------------------------------------------------------------------
    // Scénario
    // -------------------------------------------------------------------------
    initial begin
        $display("--- SIMULATION MSK @ 10 MHz (10 pts / arche) ---");
        
        s_clk		=0;
        s_rst_n       = 0;
        s_enable_ech  = 1; // Toujours à 1 car clk = freq echantillonnage
        s_flag_enable = 0;
        s_b_in        = 0;

        #125;
        s_rst_n = 1;
        @(posedge s_clk);

        foreach (s_sequence[i]) begin
            
            // Injection du bit
            s_b_in = s_sequence[i];
            s_flag_enable = 1; // Nouveau bit tous les 0.5 µs
            @(posedge s_clk);
            s_flag_enable = 0;
            
            // On attend 4 cycles pour faire 5 cycles au total (5 * 100ns = 500ns = Tb)
            repeat (4) @(posedge s_clk); 
        end

        repeat (20) @(posedge s_clk);
        $display("--- FIN DE TEST ---");
        $stop;
    end

    // Assertions (Amplitude max = 31 pour 6 bits)
    assert_lim_I: assert property (@(posedge s_clk) s_I_BB >= -31 && s_I_BB <= 31);
    assert_lim_Q: assert property (@(posedge s_clk) s_Q_BB >= -31 && s_Q_BB <= 31);

endmodule

