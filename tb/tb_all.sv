`timescale 1ns/1ps

module system_tb();
    logic CLK, RSTn, adc_eoc;
    logic [5:0] I_in, Q_in;
    logic signed [22:0] I_out, Q_out;

    // Instanciation explicite 
    receiver_system dut (
        .CLK(CLK),
        .RSTn(RSTn),
        .adc_eoc(adc_eoc),
        .I_in(I_in),
        .Q_in(Q_in),
        .I_filtered(I_out), // On branche le port du top sur ton signal de TB
        .Q_filtered(Q_out)
    );

    // Horloge 50MHz
    always #10 CLK = ~CLK;

    initial begin
        // Initialisation
        CLK = 0; RSTn = 0; adc_eoc = 0;
        I_in = 6'd32; Q_in = 6'd32; // Valeur moyenne (0 signé)
        
        #100 RSTn = 1;
        #50;

        // Simulation de réception d'un signal
        // On envoie des valeurs qui changent pour simuler une entrée ADC
        repeat (200) begin
            @(posedge CLK);
            adc_eoc <= 1;
            // On simule une entrée qui oscille légèrement
            I_in <= I_in + 1; 
            Q_in <= Q_in - 1;
            
            @(posedge CLK);
            adc_eoc <= 0;
            #30; // Rythme 20MHz
        end

        $display("Simulation du système complet terminée.");
        $stop;
    end
endmodule
