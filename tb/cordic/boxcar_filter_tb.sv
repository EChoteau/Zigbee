module boxcar_filter_tb();
    parameter W = 16;
    parameter N = 4;
    logic i_clk = 0;
    logic i_rst_n = 0;
    logic signed [W-1:0] i_data_in;
    logic signed [W+$clog2(N)-1:0] o_data_out;

    boxcar_filter #(
        .WIDTH(W), 
        .N(N)
    ) dut (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_data_in(i_data_in), .o_data_out(o_data_out)
    );

    always #5 i_clk = ~i_clk;

    initial begin
        i_data_in = 10; // Constant input
        #12 i_rst_n = 1; 
	#3;
        #100;      // Output should reach 40
        i_data_in = 0;
        #100;      // Output should return to 0
        $finish;
    end
endmodule
