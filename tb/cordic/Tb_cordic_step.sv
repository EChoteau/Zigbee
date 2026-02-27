module tb_cordic_step();
    parameter WIDTH = 16;
    logic signed [WIDTH-1:0] i_in, q_in, p_in, i_next, q_next, p_next;

    // Instance of a single step (Step 0: 45 degrees)
    cordic_step #(
        .WIDTH(WIDTH), 
        .ITER(0), 
        .ANGLE_VAL(16'h1000) // Arbitrary test angle
    ) dut (
        .I_in(i_in), .Q_in(q_in), .PHASE_in(p_in),
        .I_next(i_next), .Q_next(q_next), .PHASE_next(p_next)
    );

    initial begin
        // If Q is positive, it should rotate "down" (subtract from Q, add to phase)
        i_in = 16'h2000; q_in = 16'h1000; p_in = 0; #10;
        $display("Step Positive Q: Q_next=%d, Phase_next=%h", q_next, p_next);

        // If Q is negative, it should rotate "up" (add to Q, subtract from phase)
        i_in = 16'h2000; q_in = -16'h1000; p_in = 0; #10;
        $display("Step Negative Q: Q_next=%d, Phase_next=%h", q_next, p_next);
    end
endmodule

