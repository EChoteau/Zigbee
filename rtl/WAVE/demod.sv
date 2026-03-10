module IQ_DEMOD (
  input                       CLK,
  input                       RSTn,
  input                       adc_eoc,

  input  logic [5:0]          I_in,
  input  logic [5:0]          Q_in,

  output logic signed [12:0]  I_out,
  output logic signed [12:0]  Q_out
);

logic signed [11:0] II, IQ, QI, QQ;
logic signed [5:0]  IF_I, IF_Q;
logic signed [5:0]  I_tmpin, Q_tmpin;

logic signed [12:0] I_tmp, Q_tmp;

//////////////////////////////////////////////////////
// RESET ASYNCHRONE
//////////////////////////////////////////////////////

always_ff @(posedge CLK or negedge RSTn) begin
    if (!RSTn) begin
        I_out   <= '0;
        Q_out   <= '0;
        I_tmpin <= '0;
        Q_tmpin <= '0;
    end
    else if (adc_eoc) begin
        I_out <= I_tmp;
        Q_out <= Q_tmp;

        // conversion ADC unsigned (0..63) -> signed (-32..31)
        I_tmpin <= $signed({1'b0, I_in}) - 7'sd32;
        Q_tmpin <= $signed({1'b0, Q_in}) - 7'sd32;
    end
end

//////////////////////////////////////////////////////
// GENERATEUR SIN / COS
//////////////////////////////////////////////////////

wave_generator #(0) cos_signal(
    .CLK(CLK),
    .data_out(IF_I),
    .RSTn(RSTn),
    .adc_eoc(adc_eoc)
);

wave_generator #(1) sin_signal(
    .CLK(CLK),
    .data_out(IF_Q),
    .RSTn(RSTn),
    .adc_eoc(adc_eoc)
);

//////////////////////////////////////////////////////
// DEMODULATION IQ
//////////////////////////////////////////////////////

always_comb begin

    II = IF_I * I_tmpin;
    IQ = IF_Q * I_tmpin;
    QI = IF_I * Q_tmpin;
    QQ = IF_Q * Q_tmpin;

    I_tmp = II - QQ;
    Q_tmp = IQ + QI;

end

endmodule
