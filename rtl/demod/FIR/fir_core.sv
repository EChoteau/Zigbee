module FIR_filter (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic signed [7:0] i_inputData,
    output logic signed [5:0] o_outputData
);

    // Coefficients 
    localparam logic signed [7:0] C0 = 8'sd14;
    localparam logic signed [7:0] C1 = 8'sd34;
    localparam logic signed [7:0] C2 = 8'sd43;

    logic signed [7:0] s_delay_buffer [0:4];

    logic signed [8:0]  s_sum0;
    logic signed [8:0]  s_sum1;

    logic signed [16:0] s_prod0;
    logic signed [16:0] s_prod1;
    logic signed [15:0] s_prod2;

    logic signed [18:0] s_filterOut;

    // Delay line
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            s_delay_buffer[0] <= '0;
            s_delay_buffer[1] <= '0;
            s_delay_buffer[2] <= '0;
            s_delay_buffer[3] <= '0;
            s_delay_buffer[4] <= '0;
        end else begin
            s_delay_buffer[0] <= i_inputData;
            s_delay_buffer[1] <= s_delay_buffer[0];
            s_delay_buffer[2] <= s_delay_buffer[1];
            s_delay_buffer[3] <= s_delay_buffer[2];
            s_delay_buffer[4] <= s_delay_buffer[3];
        end
    end

    // Sommes symétriques élargies
    always_comb begin
        s_sum0 = $signed({s_delay_buffer[0][7], s_delay_buffer[0]})
               + $signed({s_delay_buffer[4][7], s_delay_buffer[4]});

        s_sum1 = $signed({s_delay_buffer[1][7], s_delay_buffer[1]})
               + $signed({s_delay_buffer[3][7], s_delay_buffer[3]});
    end

    // Multiplications
    always_comb begin
        s_prod0 = C0 * s_sum0;
        s_prod1 = C1 * s_sum1;
        s_prod2 = C2 * s_delay_buffer[2];
    end

    // Somme finale
    always_comb begin
        s_filterOut = s_prod0 + s_prod1 + s_prod2;
    end

    // output
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_outputData <= '0;
        else
            o_outputData <= $signed( (s_filterOut >>> 9) );
//s_filterOut[12:7]; // division par 128
    end

endmodule

/*module FIR_filter (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_adc_eoc,
    input  logic signed [7:0] i_inputData,
    output logic signed [7:0] o_outputData
);

    localparam logic signed [7:0] C0 = 8'shF2; // -14
    localparam logic signed [7:0] C1 = 8'sh0C; //  12
    localparam logic signed [7:0] C2 = 8'sh3E; //  62

    logic signed [7:0] s_delay_buffer [0:4];

    logic signed [8:0]  s_sum0;
    logic signed [8:0]  s_sum1;

    logic signed [16:0] s_prod0;
    logic signed [16:0] s_prod1;
    logic signed [16:0] s_prod2;

    logic signed [18:0] s_filterOut;

    // Delay line
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            s_delay_buffer[0] <= '0;
            s_delay_buffer[1] <= '0;
            s_delay_buffer[2] <= '0;
            s_delay_buffer[3] <= '0;
            s_delay_buffer[4] <= '0;
        end else begin
            s_delay_buffer[0] <= i_inputData;
            s_delay_buffer[1] <= s_delay_buffer[0];
            s_delay_buffer[2] <= s_delay_buffer[1];
            s_delay_buffer[3] <= s_delay_buffer[2];
            s_delay_buffer[4] <= s_delay_buffer[3];
        end
    end

    // Widened symmetric sums
    always_comb begin
        s_sum0 = $signed({s_delay_buffer[0][7], s_delay_buffer[0]})
               + $signed({s_delay_buffer[4][7], s_delay_buffer[4]});

        s_sum1 = $signed({s_delay_buffer[1][7], s_delay_buffer[1]})
               + $signed({s_delay_buffer[3][7], s_delay_buffer[3]});
    end

    // Products
    always_comb begin
        s_prod0 = C0 * s_sum0;
        s_prod1 = C1 * s_sum1;
        s_prod2 = C2 * s_delay_buffer[2];
    end

    // Final sum
    always_comb begin
        s_filterOut = s_prod0 + s_prod1 + s_prod2;
    end

    // Output scaling
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_outputData <= '0;
        else
            o_outputData <= s_filterOut[13:6];   // meilleur choix que [18:11]
    end

endmodule
*/

/*module FIR_filter (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_adc_eoc,
    input  logic signed [7:0] i_inputData,
    output logic signed [7:0] o_outputData
);

    localparam logic signed [2:0][7:0] filterCoefficients = {8'hF2, 8'h0C, 8'h3E};
    // Filtre symétrique : {F2, 0C, 3E, 0C, F2}

    logic signed [5:0][7:0] s_delay_buffer;

    logic [1:0] s_counter;
    logic       s_counter_enable;

    logic signed [7:0] s_mult_even;
    logic signed [7:0] s_mult_odd;
    logic signed [7:0] s_mult_evencoeff;
    logic signed [7:0] s_mult_oddcoeff;

    logic signed [7:0] s_mult_even_reg;
    logic signed [7:0] s_mult_odd_reg;
    logic signed [7:0] s_mult_evencoeff_reg;
    logic signed [7:0] s_mult_oddcoeff_reg;

    logic signed [14:0] s_multiplier_even;
    logic signed [14:0] s_multiplier_odd;

    logic signed [14:0] s_multiplier_even_reg;
    logic signed [14:0] s_multiplier_odd_reg;

    logic signed [18:0] s_add;
    logic signed [18:0] s_filterOut;
    logic signed [18:0] s_filterOut_ff;

    // =========================================
    // Delay line
    // =========================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            s_delay_buffer <= '0;
        end
        else if (i_adc_eoc) begin
            s_delay_buffer[5]   <= i_inputData;
            s_delay_buffer[4:0] <= s_delay_buffer[5:1];
        end
    end

    // =========================================
    // Multiplexers
    // =========================================
    always_comb begin
        case (s_counter)
            2'b00: begin
                s_mult_even      = s_delay_buffer[5];
                s_mult_odd       = s_delay_buffer[4];
                s_mult_evencoeff = filterCoefficients[2];
                s_mult_oddcoeff  = filterCoefficients[1];
            end
            2'b01: begin
                s_mult_even      = s_delay_buffer[3];
                s_mult_odd       = s_delay_buffer[2];
                s_mult_evencoeff = filterCoefficients[0];
                s_mult_oddcoeff  = filterCoefficients[0];
            end
            2'b10: begin
                s_mult_even      = s_delay_buffer[1];
                s_mult_odd       = s_delay_buffer[0];
                s_mult_evencoeff = filterCoefficients[1];
                s_mult_oddcoeff  = filterCoefficients[2];
            end
            default: begin
                s_mult_even      = '0;
                s_mult_odd       = '0;
                s_mult_evencoeff = '0;
                s_mult_oddcoeff  = '0;
            end
        endcase
    end

    // =========================================
    // Multipliers
    // =========================================
    always_comb begin
        s_multiplier_even = s_mult_even_reg * s_mult_evencoeff_reg;
        s_multiplier_odd  = s_mult_odd_reg  * s_mult_oddcoeff_reg;
    end

    // =========================================
    // Adder
    // =========================================
    always_comb begin
        s_add = s_multiplier_even_reg + s_multiplier_odd_reg;
    end

    // =========================================
    // Accumulator
    // =========================================
    always_comb begin
        s_filterOut = s_filterOut_ff + s_add;
    end

    // =========================================
    // Filter accumulator register
    // =========================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            s_filterOut_ff <= '0;
        else if (i_adc_eoc)
            s_filterOut_ff <= '0;
        else
            s_filterOut_ff <= s_filterOut;
    end

    // =========================================
    // Counter
    // =========================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            s_counter <= 2'b00;
        else if (i_adc_eoc)
            s_counter <= 2'b00;
        else if (s_counter_enable)
            s_counter <= s_counter + 2'b01;
    end

    // =========================================
    // Pipeline registers
    // =========================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            s_mult_even_reg       <= '0;
            s_mult_odd_reg        <= '0;
            s_mult_evencoeff_reg  <= '0;
            s_mult_oddcoeff_reg   <= '0;
            s_multiplier_even_reg <= '0;
            s_multiplier_odd_reg  <= '0;
        end
        else if (s_counter_enable) begin
            s_mult_even_reg       <= s_mult_even;
            s_mult_odd_reg        <= s_mult_odd;
            s_mult_evencoeff_reg  <= s_mult_evencoeff;
            s_mult_oddcoeff_reg   <= s_mult_oddcoeff;
            s_multiplier_even_reg <= s_multiplier_even;
            s_multiplier_odd_reg  <= s_multiplier_odd;
        end
    end

    // =========================================
    // Counter enable
    // =========================================
    always_comb begin
        if (s_counter == 2'b11)
            s_counter_enable = 1'b0;
        else
            s_counter_enable = 1'b1;
    end

    // =========================================
    // Output register
    // =========================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_outputData <= '0;
        else if (i_adc_eoc)
            o_outputData <= s_filterOut_ff[18:13];
    end

endmodule */
