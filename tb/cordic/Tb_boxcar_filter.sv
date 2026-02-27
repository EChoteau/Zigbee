module tb_boxcar_filter();
    parameter W = 16;
    parameter N = 4;
    logic clk = 0;
    logic rst_n = 0;
    logic signed [W-1:0] d_in;
    logic signed [W+$clog2(N)-1:0] d_out;

    boxcar_filter #(W, N) dut (.*);

    always #5 clk = ~clk;

    initial begin
        #15 rst_n = 1;
        d_in = 10; // Constant input
        #100;      // Output should reach 40
        d_in = 0;
        #100;      // Output should return to 0
        $finish;
    end
endmodule


