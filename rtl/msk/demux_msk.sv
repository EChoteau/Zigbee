


// ==============================================================================
// Module      : demux_msk
// Description : Aiguilleur (Démultiplexeur) pour séparer les voies I et Q
// ==============================================================================

module demux_msk (
    input  logic i_clk,         // 
    input  logic i_rst_n,       // Reset asynchrone ACTIF BAS
    input  logic i_flag_enable, // Autorisation d'aiguiller (rythme des bits)
    input  logic i_b_enc,       // Le bit qui sort de l'encodeur (b'k)
    output logic o_a_I,         // La voie I
    output logic o_a_Q          // La voie Q
);

    // Déclaration du signal interne avec préfixe s_ (pour séquentiel)
    logic s_tour; 

    // Bloc séquentiel synchrone avec reset asynchrone
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        
        if (i_rst_n == 1'b0) begin
            o_a_I  <= 1'b1; 
            o_a_Q  <= 1'b1; 
            s_tour <= 1'b1; // On décide que c'est la voie Q qui commence
            
        end else begin
            
            // On ne change l'aiguillage QUE si un bit est validé
            if (i_flag_enable == 1'b1) begin
                
                // On change de tour (0 devient 1, 1 devient 0)
                s_tour <= ~s_tour;

                // Aiguillage
                if (s_tour == 1'b0) begin
                    // C'est le tour de I
                    o_a_I <= i_b_enc; 
                    // o_a_Q n'est pas assigné, il garde sa valeur (durée 2Tb)
                    
                end else begin
                    // C'est le tour de Q
                    o_a_Q <= i_b_enc;
                    // o_a_I n'est pas assigné, il garde sa valeur (durée 2Tb)
                end
                
            end
            
        end
    end

endmodule
