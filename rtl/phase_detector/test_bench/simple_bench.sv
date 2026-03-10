`timescale 1ns/1ps

module tb_cdr;

    //---------------------------------
    // Clock 50 MHz
    //---------------------------------
    reg clk = 0;
    always #10 clk = ~clk;   // 20ns period → 50 MHz

    //---------------------------------
    // Reset
    //---------------------------------
    reg rst;
    
    //---------------------------------
    // Inputs to CDR
    //---------------------------------
    reg  signed [5:0] dphi;
    
    //---------------------------------
    // Outputs
    //---------------------------------
    wire decision_out;
    wire clk_rec;

    //---------------------------------
    // Instantiate DUT
    //---------------------------------
    cdr_top dut (
        .clk(clk),
        .rst(rst),
        .dphi(dphi),
        .data(decision_out),
        .enable(clk_rec)
    );

    //---------------------------------
    // Generate 2 MHz data (25 cycles of 50MHz)
    //---------------------------------
    reg data_bit;
    integer cnt;

    initial begin
        data_bit = 0;
        cnt = 0;
    end

    always @(posedge clk) begin
        if (cnt == 25) begin   // 50MHz / 2MHz = 25 cycles //24 pour vrai valeur
            cnt <= 0;
            data_bit <= $random;
        end
        else
            cnt <= cnt + 1;
    end

    //---------------------------------
    // Generate derivative phase model
    // Simple model:
    // If clock not aligned → produce +/- 8
    //---------------------------------
    always @(posedge clk) begin
        if (data_bit)
            dphi <= 6'sd8;     // positive slope
        else
            dphi <= -6'sd8;    // negative slope
    end

    //---------------------------------
    // Reset sequence
    //---------------------------------
    initial begin
        rst = 0;
        #200;
        rst = 1;
    end

    //---------------------------------
    // Simulation time
    //---------------------------------
    initial begin
        #20000000;
        $stop;
    end

endmodule
