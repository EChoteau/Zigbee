`timescale 1ns/1ps

module wave_generator_tb();

    // 1. Signaux
    logic        clk;
    logic        rstn;
    logic        adc_eoc;
    logic signed [5:0] data_out_cos;
    logic signed [5:0] data_out_sin;

    // 2. Instanciation
    wave_generator #(.phase(0)) dut_cos (
        .i_clk(clk), .i_rst_n(rstn), .adc_eoc(adc_eoc), .data_out(data_out_cos)
    );

    wave_generator #(.phase(1)) dut_sin (
        .i_clk(clk), .i_rst_n(rstn), .adc_eoc(adc_eoc), .data_out(data_out_sin)
    );

    // 3. Horloge 50 MHz (20ns)
    always #10 clk = ~clk;

    // 4. Scénario : 2 cycles -> Reset -> 2 cycles -> Reset
    initial begin
        // --- Initialisation ---
        clk = 0; rstn = 0; adc_eoc = 0;
        #60 rstn = 1; 

        // --- PREMIER BLOC : 2 périodes (16 échantillons) ---
        $display("Generation de 2 periodes...");
        repeat (16) begin
            @(posedge clk); adc_eoc <= 1; 
            @(posedge clk); adc_eoc <= 0;
            #30; 
        end

        // --- PREMIER RESET (au milieu) ---
        $display("Premier Reset de securite...");
        #5 rstn <= 0;   
        #100; rstn <= 1;

        // --- DEUXIÈME BLOC : 2 périodes (16 échantillons) ---
        $display("Reprise : Generation de 2 periodes supplementaires...");
        repeat (16) begin
            @(posedge clk); adc_eoc <= 1; 
            @(posedge clk); adc_eoc <= 0;
            #30; 
        end

        // --- DEUXIÈME RESET (final) ---
        $display("Deuxieme Reset final...");
        #5 rstn <= 0;
        
        #100;
        $display("Simulation terminee.");
        $stop; 
    end

endmodule
