module cordic_step_tb();
    parameter WIDTH = 16;
    logic signed [WIDTH-1:0] i_i_in, i_q_in, i_phase_in, o_i_next, o_q_next, o_phase_next;

    // Instance of a single step (Step 0: 45 degrees)
    cordic_step #(
        .WIDTH(WIDTH),
	.WIDTH_PHASE(WIDTH),
        .ITER(0), 
        .ANGLE_VAL(16'h1000) // Arbitrary test angle
    ) dut (
        .i_i_in(i_i_in), .i_q_in(i_q_in), .i_phase_in(i_phase_in),
        .o_i_next(o_i_next), .o_q_next(o_q_next), .o_phase_next(o_phase_next)
    );

    initial begin
        // If Q is positive, it should rotate "down" (subtract from Q, add to phase)
        i_i_in = 16'h2000; i_q_in = 16'h1000; i_phase_in = 0; #10;
        $display("Step Positive Q: Q_next=%d, Phase_next=%h", o_q_next, o_phase_next);

        // If Q is negative, it should rotate "up" (add to Q, subtract from phase)
        i_i_in = 16'h2000; i_q_in = -16'h1000; i_phase_in = 0; #10;
        $display("Step Negative Q: Q_next=%d, Phase_next=%h", o_q_next, o_phase_next);
    end
endmodule
