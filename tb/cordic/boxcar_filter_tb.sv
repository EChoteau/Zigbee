module boxcar_filter_tb();
    parameter int W = 16;
    parameter int N = 4;

    logic i_clk = 0;
    logic i_rst_n = 0;
    logic signed [W-1:0] i_data;
    logic signed [W-1:0] o_data;
    int failures = 0;

    boxcar_filter #(
        .WIDTH(W), 
        .N(N)
    ) dut (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_data(i_data), .o_data(o_data)
    );

    always #5 i_clk = ~i_clk;

    task automatic check_output(
        input string tc_name,
        input logic signed [W-1:0] expected
    );
        assert (o_data === expected)
        else begin
            failures++;
            $error("%s mismatch: got %0d expected %0d", tc_name, o_data, expected);
        end
    endtask

    initial begin
        $display("Testing boxcar_filter running-sum behavior...");

        i_data = '0;
        i_rst_n = 0;

        // Hold reset long enough to clear the internal state.
        #12;
        check_output("reset", '0);

        i_rst_n = 1;
        #1;

        // Constant positive input: the running sum should ramp up to N * input.
        i_data = 10;
        @(posedge i_clk); #1; check_output("const_1", 10);
        @(posedge i_clk); #1; check_output("const_2", 20);
        @(posedge i_clk); #1; check_output("const_3", 30);
        @(posedge i_clk); #1; check_output("const_4", 40);
        @(posedge i_clk); #1; check_output("const_5", 40);

        // Removing the input should make the delay line drain out one sample per cycle.
        i_data = 0;
        @(posedge i_clk); #1; check_output("decay_1", 30);
        @(posedge i_clk); #1; check_output("decay_2", 20);
        @(posedge i_clk); #1; check_output("decay_3", 10);
        @(posedge i_clk); #1; check_output("decay_4", 0);

        // Verify negative values are accumulated correctly.
        i_data = -5;
        @(posedge i_clk); #1; check_output("neg_1", -5);
        @(posedge i_clk); #1; check_output("neg_2", -10);
        @(posedge i_clk); #1; check_output("neg_3", -15);
        @(posedge i_clk); #1; check_output("neg_4", -20);

        $display("boxcar_filter_tb completed with %0d failure(s)", failures);
        assert (failures == 0)
        else $fatal(1, "boxcar_filter_tb failed with %0d mismatch(es)", failures);

        $finish;
    end
endmodule
