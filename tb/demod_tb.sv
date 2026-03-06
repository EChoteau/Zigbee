`timescale 1ns/1ps

// Testbench pour IQ_DEMOD (ADC 6 bits unsigned, Fs=20 MHz via adc_eoc)
// CLK système = 50 MHz (20 ns). adc_eoc = pulse 1-cycle à ~20 MHz
module tb_IQ_DEMOD;

  // -------------------------
  // DUT I/O
  // -------------------------
  logic CLK;
  logic RSTn;
  logic adc_eoc;

  logic [5:0] I_in, Q_in;
  logic signed [12:0] I_out, Q_out;

  // -------------------------
  // Instantiate DUT
  // -------------------------
  IQ_DEMOD dut (
    .CLK(CLK),
    .RSTn(RSTn),
    .adc_eoc(adc_eoc),
    .I_in(I_in),
    .Q_in(Q_in),
    .I_out(I_out),
    .Q_out(Q_out)
  );

  // -------------------------
  // 50 MHz clock (20 ns)
  // -------------------------
  initial CLK = 1'b0;
  always #10 CLK = ~CLK;

  // -------------------------
  // Async reset sequence
  // -------------------------
  initial begin
    RSTn    = 1'b0;
    adc_eoc = 1'b0;
    I_in    = 6'd32;   // offset-binary midscale => 0 signed
    Q_in    = 6'd32;

    // reset asynchrone maintenu un peu
    #75;
    RSTn = 1'b1;
  end

  // ---------------------------------------------------------
  // Génération adc_eoc ~ 20 MHz à partir de CLK=50 MHz
  // 50/20 = 2.5 cycles -> on alterne attente 2 puis 3 cycles
  // adc_eoc est un pulse d'1 cycle de CLK
  // ---------------------------------------------------------
  int unsigned wait_cycles;
  bit alt_2_3;

  initial begin
    alt_2_3 = 1'b0;
    @(posedge RSTn);

    forever begin
      wait_cycles = (alt_2_3) ? 3 : 2;
      alt_2_3 = ~alt_2_3;

      repeat (wait_cycles) @(posedge CLK);

      adc_eoc <= 1'b1;
      @(posedge CLK);
      adc_eoc <= 1'b0;
    end
  end

  // ---------------------------------------------------------
  // LUT de sin/cos (doit matcher ton wave_generator 8 points, 6 bits)
  // sin: [0, 22, 31, 22, 0, -22, -31, -22]
  // cos: [31,22,0,-22,-31,-22,0,22]
  // ---------------------------------------------------------
  function automatic signed [5:0] lut_sin(input int idx);
    case (idx % 8)
      0: lut_sin =  6'sd0;
      1: lut_sin =  6'sd22;
      2: lut_sin =  6'sd31;
      3: lut_sin =  6'sd22;
      4: lut_sin =  6'sd0;
      5: lut_sin = -6'sd22;
      6: lut_sin = -6'sd31;
      7: lut_sin = -6'sd22;
    endcase
  endfunction

  function automatic signed [5:0] lut_cos(input int idx);
    case (idx % 8)
      0: lut_cos =  6'sd31;
      1: lut_cos =  6'sd22;
      2: lut_cos =  6'sd0;
      3: lut_cos = -6'sd22;
      4: lut_cos = -6'sd31;
      5: lut_cos = -6'sd22;
      6: lut_cos =  6'sd0;
      7: lut_cos =  6'sd22;
    endcase
  endfunction

  // ---------------------------------------------------------
  // Convert signed (-32..+31) -> ADC unsigned (0..63) via +32 + clip
  // ---------------------------------------------------------
  function automatic [5:0] to_adc_u6(input integer signed s);
    integer tmp;
    begin
      tmp = s + 32;
      if (tmp < 0)  tmp = 0;
      if (tmp > 63) tmp = 63;
      to_adc_u6 = tmp[5:0];
    end
  endfunction

  // ---------------------------------------------------------
  // Stimulus:
  // On veut tester que la démod "tourne" bien.
  //
  // Ton demod fait : (I + jQ) * (cos + j sin)
  //
  // Si on injecte : I = A*cos, Q = -A*sin
  // alors (I+jQ)*(cos+jsin) = A*(cos^2+sin^2) + j*0  ≈ constant, Q≈0
  //
  // NB: cos^2+sin^2 n'est pas exactement constant ici car LUT quantifiée,
  // mais Q_out doit rester proche de 0.
  // ---------------------------------------------------------
  int n;
  integer signed A;
  signed [5:0] c, s;
  integer signed I_sig, Q_sig;

  initial begin
    @(posedge RSTn);

    A = 20;   // amplitude choisie (<=31 conseillé)
    n = 0;

    // On applique de nouveaux samples uniquement sur adc_eoc
    repeat (200) begin
      @(posedge CLK);
      if (adc_eoc) begin
        c = lut_cos(n);
        s = lut_sin(n);

        // scale pour rester dans [-32..31]
        I_sig = (A * c) / 31;
        Q_sig = -(A * s) / 31;

        I_in <= to_adc_u6(I_sig);
        Q_in <= to_adc_u6(Q_sig);

        n++;
      end
    end

    $display("TB finished.");
    $finish;
  end

  // ---------------------------------------------------------
  // Monitor (affiche à chaque nouveau sample)
  // ---------------------------------------------------------
  always @(posedge CLK) begin
    if (RSTn && adc_eoc) begin
      $display("t=%0t ns | n=%0d | I_in=%0d Q_in=%0d | I_out=%0d Q_out=%0d",
               $time, n, I_in, Q_in, I_out, Q_out);
    end
  end

  // Dump waves
  initial begin
    $dumpfile("tb_IQ_DEMOD.vcd");
    $dumpvars(0, tb_IQ_DEMOD);
  end

endmodule
