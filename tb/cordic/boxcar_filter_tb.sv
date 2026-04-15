module boxcar_filter_tb();
    parameter W = 16;
    parameter N = 4;
    logic i_clk = 0;
    logic i_rst_n = 0;
    logic signed [W-1:0] i_data;
    logic signed [W+$clog2(N)-1:0] o_data;

    boxcar_filter #(
        .WIDTH(W), 
        .N(N)
    ) dut (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_data(i_data), .o_data(o_data)
    );

    always #5 i_clk = ~i_clk;

    initial begin
        i_data = 10; // Constant input
        #12 i_rst_n = 1; 
	#3;
        #100;      // Output should reach 40
        i_data = 0;
        #100;      // Output should return to 0
        $finish;
    end
endmodule
