module cordic_step_tb();
    parameter WIDTH = 16;
    parameter WIDTH_PHASE = WIDTH;
    parameter signed [WIDTH_PHASE-1:0] ANGLE_VAL = 16'h1000;
    logic signed [WIDTH-1:0] i_i, i_q, i_phase, o_i_next, o_q_next, o_phase_next;
    int failures = 0;

    // Instance of a single step (Step 0: 45 degrees)
    cordic_step #(
        .WIDTH(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE),
        .ITER(0), 
        .ANGLE_VAL(ANGLE_VAL)
    ) dut (
        .i_i(i_i), .i_q(i_q), .i_phase(i_phase),
        .o_i_next(o_i_next), .o_q_next(o_q_next), .o_phase_next(o_phase_next)
    );

    function automatic void check_case(
        input string tc_name,
        input logic signed [WIDTH-1:0] exp_i,
        input logic signed [WIDTH-1:0] exp_q,
        input logic signed [WIDTH_PHASE-1:0] exp_phase
    );
        $display("%s: I_in=%0d Q_in=%0d P_in=0x%0h | I_out=%0d Q_out=%0d P_out=0x%0h | I_exp=%0d Q_exp=%0d P_exp=0x%0h",
                 tc_name, i_i, i_q, i_phase, o_i_next, o_q_next, o_phase_next, exp_i, exp_q, exp_phase);

        assert (o_i_next === exp_i)
        else begin
            failures++;
            $error("%s I mismatch: got %0d expected %0d", tc_name, o_i_next, exp_i);
        end

        assert (o_q_next === exp_q)
        else begin
            failures++;
            $error("%s Q mismatch: got %0d expected %0d", tc_name, o_q_next, exp_q);
        end

        assert (o_phase_next === exp_phase)
        else begin
            failures++;
            $error("%s phase mismatch: got 0x%0h expected 0x%0h", tc_name, o_phase_next, exp_phase);
        end
    endfunction

    initial begin
        $display("Testing CORDIC step (ITER=0)...");

        // Q positive: rotate down (Q decreases, phase increases)
        i_i = 16'h2000; i_q = 16'h1000; i_phase = 0; #10;
        check_case("STEP_Q_POS", 16'sh3000, 16'shF000, 16'sh1000);

        // Q negative: rotate up (Q increases, phase decreases)
        i_i = 16'h2000; i_q = -16'h1000; i_phase = 0; #10;
        check_case("STEP_Q_NEG", 16'sh3000, 16'sh1000, -16'sh1000);

        // Q == 0 follows non-negative branch (w_is_positive = 1)
        i_i = 16'sh0400; i_q = 16'sh0000; i_phase = 16'sh0200; #10;
        check_case("STEP_Q_ZERO", 16'sh0800, -16'sh0400, 16'sh1200);

        $display("cordic_step_tb completed with %0d failure(s)", failures);
        assert (failures == 0)
        else $fatal(1, "cordic_step_tb failed with %0d mismatch(es)", failures);

        $finish;
    end
endmodule
