// if phase = 1 -> SIN
// if phase = 0 -> COS

module wave_generator #(parameter bit phase = 0) (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_adc_eoc,   // pulse  Fs = 10 MHz
    output logic signed [3:0] o_data_out
);

    logic signed [3:0] s_wave;
    logic [1:0]        s_prev_counter;
    logic [1:0]        s_next_counter;

    // ==================================================
    // Registres : reset asynchrone, front montant
    // ==================================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_data_out     <= 4'sd0;
            s_prev_counter <= 2'd0;
        end
        else if (i_adc_eoc) begin
            o_data_out     <= s_wave;
            s_prev_counter <= s_next_counter;
        end
    end

    // ==================================================
    // Logique combinatoire
    // Fs = 10 MHz, 4 points par période
    // donc fréquence générée = 10 MHz / 4 = 2.5 MHz
    // ==================================================
    always_comb begin
        // compteur modulo 4
        if (s_prev_counter == 2'd3)
            s_next_counter = 2'd0;
        else
            s_next_counter = s_prev_counter + 2'd1;

        // génération cos / sin
        if (phase == 1'b0) begin
            // COS : [-8, 0, +7, 0]
            case (s_prev_counter)
                2'd0:    s_wave = -4'sd8;
                2'd1:    s_wave =  4'sd0;
                2'd2:    s_wave =  4'sd7;
                2'd3:    s_wave =  4'sd0;
                default: s_wave =  4'sd0;
            endcase
        end
        else begin
            // SIN : [0, +7, 0, -8]
            case (s_prev_counter)
                2'd0:    s_wave =  4'sd0;
                2'd1:    s_wave =  4'sd7;
                2'd2:    s_wave =  4'sd0;
                2'd3:    s_wave = -4'sd8;
                default: s_wave =  4'sd0;
            endcase
        end
    end

endmodule
