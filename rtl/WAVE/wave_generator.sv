module wave_generator #(parameter bit phase=0) (
    input  logic              CLK,      // Horloge Master (50 MHz)
    input  logic              RSTn,     // Reset asynchrone (actif bas)
    input  logic              adc_eoc,  // Gâchette de l'ADC (20 MHz)
    output logic signed [5:0] data_out  // Sortie Sinus ou Cosinus sur 6 bits
);
    // Déclarations
    logic signed [5:0] sine;
    logic [2:0]        prev_counter; // 3 bits suffisent pour 8 points (0 à 7)
    logic [2:0]        next_counter;

    // 1. PARTIE SÉQUENTIELLE (Reset Asynchrone Actif Bas)
    always_ff @(posedge CLK or negedge RSTn) begin
        if (!RSTn) begin
            data_out     <= 6'd0;
            prev_counter <= 3'd0;
        end else begin
            if (adc_eoc == 1) begin 
                data_out     <= sine;
                prev_counter <= next_counter;
            end
        end
    end
    // 2. PARTIE COMBINATOIRE 
    always_comb begin
        // --- Calcul du prochain état (Modulo 8) ---
        // On remet à zéro après 7
        if (prev_counter == 3'd7) begin
            next_counter = 3'd0;
        end else begin
            next_counter = prev_counter + 3'd1;
        end

        // --- LUT 8 points ---
        if (phase == 0) begin : cosinus_generation
            case(prev_counter)
                3'd0: sine = 6'd31;  3'd1: sine = 6'd22;
                3'd2: sine = 6'd0;   3'd3: sine = -6'd22;
                3'd4: sine = -6'd31; 3'd5: sine = -6'd22;
                3'd6: sine = 6'd0;   3'd7: sine = 6'd22;
                default: sine = 6'd0;
            endcase
        end else begin : sinus_generation
            case(prev_counter)
                3'd0: sine = 6'd0;   3'd1: sine = 6'd22;
                3'd2: sine = 6'd31;  3'd3: sine = 6'd22;
                3'd4: sine = 6'd0;   3'd5: sine = -6'd22;
                3'd6: sine = -6'd31; 3'd7: sine = -6'd22;
                default: sine = 6'd0;
            endcase
        end
    end

endmodule
