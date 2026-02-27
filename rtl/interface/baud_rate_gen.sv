//////////////////////////////////////////////////////////////////////////////////
// Module Name:    baud_rate_gen
// Description:    Générateur d'impulsions (Tick) pour la sérialisation TX.
//                 Divise l'horloge système (50 MHz) pour obtenir le Baud Rate.
//                 Design Low Power : S'arrête si i_enable est à 0.
//////////////////////////////////////////////////////////////////////////////////

module baud_rate_gen #(
    parameter DIV_WIDTH = 8  // Taille du registre de division (ex: 8 bits = max 255)
)(
    input  logic                 i_clk,      // Horloge système (50 MHz)
    input  logic                 i_rst_n,    // Reset asynchrone (actif bas)
    
    input  logic                 i_enable,   // Low Power Enable (1 = TX actif, 0 = Veille)
    input  logic [DIV_WIDTH-1:0] i_div_val,  // Valeur de division venant du registre APB
    
    output logic                 o_tick      // Impulsion d'un cycle d'horloge
);

    // Signal interne pour le compteur
    logic [DIV_WIDTH-1:0] s_counter;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset asynchrone
            s_counter <= '0;
            o_tick    <= 1'b0;
        end else begin
            // Si le bloc TX n'émet rien, on fige le compteur (LOW POWER)
            if (i_enable) begin
                
                // Si on atteint la valeur limite (i_div_val)
                if (s_counter >= i_div_val) begin
                    s_counter <= '0;       // On remet à zéro
                    o_tick    <= 1'b1;     // On génère le "Tick" pendant 1 cycle
                end else begin
                    s_counter <= s_counter + 1'b1; // On compte
                    o_tick    <= 1'b0;             // Pas de Tick
                end
                
            end else begin
                // Mode Veille : on force à 0 pour éviter toute commutation
                s_counter <= '0;
                o_tick    <= 1'b0;
            end
        end
    end

endmodule