module receiver_system (
    input  logic CLK,
    input  logic RSTn,
    input  logic adc_eoc,
    input  logic [5:0] I_in,  // Entrée brute ADC
    input  logic [5:0] Q_in,
    output logic signed [7:0] I_filtered,
    output logic signed [7:0] Q_filtered
);

    logic signed [12:0] I_demod, Q_demod;

    // 1. Démodulation IQ
    IQ_DEMOD u_demod (
        .CLK(CLK), .RSTn(RSTn), .adc_eoc(adc_eoc),
        .I_in(I_in), .Q_in(Q_in),
        .I_out(I_demod), .Q_out(Q_demod)
    );

    // 2. Filtrage FIR Voie I (On tronque l'entrée à 6 bits pour ton FIR)
    fir_top u_fir_i (
        .clk(CLK), .rstn(RSTn), .sample_en(adc_eoc),
        .x_in(I_demod), 
        .y_out(I_filtered)
    );

    // 3. Filtrage FIR Voie Q
    fir_top u_fir_q (
        .clk(CLK), .rstn(RSTn), .sample_en(adc_eoc),
        .x_in(Q_demod), 
        .y_out(Q_filtered)
    );

endmodule
