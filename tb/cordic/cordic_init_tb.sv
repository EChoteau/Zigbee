module cordic_init_tb();
    parameter WIDTH = 8;
    parameter WIDTH_PHASE = WIDTH + 2;
    parameter WIDTH_INTERNAL = WIDTH+ 4;
    logic signed [WIDTH-1:0] i_i, i_q;
    logic signed [WIDTH_INTERNAL-1:0] o_i_init, o_q_init;
    logic signed [WIDTH_PHASE-1:0] o_phase_init;
    int failures = 0;

    localparam logic signed [WIDTH_PHASE-1:0] PHASE_05  = (1 << (WIDTH_PHASE-2));
    localparam logic signed [WIDTH_PHASE-1:0] PHASE_M05 = -(1 << (WIDTH_PHASE-2));

    cordic_init #(
        .WIDTH_IN(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE),
        .WIDTH_INTERNAL(WIDTH_INTERNAL)
    ) dut (.*);

    function automatic void check_case(
        input string tc_name,
        input logic signed [WIDTH_INTERNAL-1:0] exp_i,
        input logic signed [WIDTH_INTERNAL-1:0] exp_q,
        input logic signed [WIDTH_PHASE-1:0] exp_phase
    );
        $display("%s: I_in=%0d Q_in=%0d | I_out=%0d Q_out=%0d P_out=%0h | I_exp=%0d Q_exp=%0d P_exp=%0h",
                 tc_name, i_i, i_q, o_i_init, o_q_init, o_phase_init, exp_i, exp_q, exp_phase);

        assert (o_i_init === exp_i)
        else begin
            failures++;
            $error("%s I mismatch: got %0d expected %0d", tc_name, o_i_init, exp_i);
        end

        assert (o_q_init === exp_q)
        else begin
            failures++;
            $error("%s Q mismatch: got %0d expected %0d", tc_name, o_q_init, exp_q);
        end

        assert (o_phase_init === exp_phase)
        else begin
            failures++;
            $error("%s phase mismatch: got 0x%0h expected 0x%0h", tc_name, o_phase_init, exp_phase);
        end
    endfunction

    initial begin
        $display("Testing INIT Quadrant Logic...");
        
        // Q1: (1, 1) -> No change, Phase 0
        i_i = 8'h20; i_q = 8'h20; #10;
        check_case("Q1", 12'sd256, 12'sd256, 10'sd0);

        // Q2: (-1, 1) -> Rotate -90, Phase +0.5 (90 deg)
        i_i = -8'h20; i_q = 8'h20; #10;
        check_case("Q2", 12'sd256, 12'sd256, PHASE_05);

        // Q3: (-1, -1) -> Rotate +90, Phase -0.5 (-90 deg)
        i_i = -8'h20; i_q = -8'h20; #10;
        check_case("Q3", 12'sd256, -12'sd256, PHASE_M05);

        // Q4: (0, 0) -> No change, Phase 0
        i_i = 8'h00; i_q = 8'h00; #10;
        check_case("Q4", 12'sd0, 12'sd0, 10'sd0);

        // Q5: (0, 1) -> No change, Phase 0
        i_i = -8'h00; i_q = 8'h20; #10;
        check_case("Q5", 12'sd0, 12'sd256, 10'sd0);

        // Q6: (0, -1) -> No change, Phase 0
        i_i = -8'h00; i_q = -8'h20; #10;
        check_case("Q6", 12'sd0, -12'sd256, 10'sd0);

        // Q7: (1, 0) -> No change, Phase 0
        i_i = 8'h20; i_q = 8'h00; #10;
        check_case("Q7", 12'sd256, 12'sd0, 10'sd0);

        // Q8: (-1, 0) -> Rotate -90, Phase +0.5
        i_i = -8'h20; i_q = 8'h00; #10;
        check_case("Q8", 12'sd0, 12'sd256, PHASE_05);

        $display("cordic_init_tb completed with %0d failure(s)", failures);
        assert (failures == 0)
        else $fatal(1, "cordic_init_tb failed with %0d mismatch(es)", failures);

        $finish;

    end
endmodule
