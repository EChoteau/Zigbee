module cordic_init_tb();
    parameter WIDTH = 8;
    parameter WIDTH_PHASE = WIDTH + 2;
    parameter WIDTH_INTERNAL = WIDTH+ 4;
    logic signed [WIDTH-1:0] i_i, i_q;
    logic signed [WIDTH_INTERNAL-1:0] o_i_init, o_q_init;
    logic signed [WIDTH_PHASE-1:0] o_phase_init;

    cordic_init #(
        .WIDTH_IN(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE),
        .WIDTH_INTERNAL(WIDTH_INTERNAL)
    ) dut (.*);

/*    task check_init(

    );
        assert ()
        else begin
            $error("ERROR: i");
        end
    endtask
*/
    initial begin
        $display("Testing INIT Quadrant Logic...");
        
        // Q1: (1, 1) -> No change, Phase 0
        i_i = 8'h20; i_q = 8'h20; #10;
        $display("Q1: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", i_i, i_q, o_i_init, o_q_init, o_phase_init);

        // Q2: (-1, 1) -> Rotate -90, Phase +0.5 (90 deg)
        i_i = -8'h20; i_q = 8'h20; #10;
        $display("Q2: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", i_i, i_q, o_i_init, o_q_init, o_phase_init);

        // Q3: (-1, -1) -> Rotate +90, Phase -0.5 (-90 deg)
        i_i = -8'h20; i_q = -8'h20; #10;
        $display("Q3: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", i_i, i_q, o_i_init, o_q_init, o_phase_init);

        // Q4: (0, 0) -> No change, Phase 0
        i_i = 8'h00; i_q = 8'h00; #10;
        $display("Q4: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", i_i, i_q, o_i_init, o_q_init, o_phase_init);

        // Q5: (0, 1) -> No change, Phase 0
        i_i = -8'h00; i_q = 8'h20; #10;
        $display("Q5: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", i_i, i_q, o_i_init, o_q_init, o_phase_init);

        // Q6: (0, -1) -> No change, Phase 0
        i_i = -8'h00; i_q = -8'h20; #10;
        $display("Q6: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", i_i, i_q, o_i_init, o_q_init, o_phase_init);

        // Q7: (1, 0) -> rotate -90, phase +0.5 
        i_i = 8'h20; i_q = 8'h00; #10;
        $display("Q7: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", i_i, i_q, o_i_init, o_q_init, o_phase_init);

        // Q8: (-1, 0) -> Rotate +90, Phase -0.5 
        i_i = -8'h20; i_q = 8'h00; #10;
        $display("Q8: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", i_i, i_q, o_i_init, o_q_init, o_phase_init);


    end
endmodule
