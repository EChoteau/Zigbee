

// ==============================================================================
// Module      : encodeur_diff
// Description : Encodeur differentiel pour modulation MSK
// ==============================================================================

module encodeur_diff (
    input  logic i_clk,         //  (50 MHz)
    input  logic i_rst_n,       // Reset asynchrone ACTIF BAS
    input  logic i_flag_enable, // Flag de la FIFO (1 = un nouveau bit bk arrive)
    input  logic i_b_in,        // Bit entrant (bk)
    output logic o_b_out        // Bit encodé sortant (b'k) mémorisé
);

    // Bloc séquentiel synchrone avec reset asynchrone
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        
        if (i_rst_n == 1'b0) begin
            o_b_out <= 1'b1; 
            
        end else begin
            // On ne travaille que si le flag est à 1
            if (i_flag_enable == 1'b1) begin
                // Fonction XNOR : 
                // Si i_b_in = 1 -> garde le même signe
                // Si i_b_in = 0 -> s'inverse par rapport au précédent
                o_b_out <= ~(i_b_in ^ o_b_out); 
            end
        end
        
    end

endmodule


