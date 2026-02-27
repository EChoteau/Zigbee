module tb_cordic_init();
    parameter WIDTH = 16;
    logic signed [WIDTH-1:0] I_in, Q_in;
    logic signed [WIDTH-1:0] I_init, Q_init, PHASE_init;

    cordic_init #(.WIDTH(WIDTH)) dut (.*);

    initial begin
        $display("Testing INIT Quadrant Logic...");
        
        // Q1: (1, 1) -> No change, Phase 0
        I_in = 16'h2000; Q_in = 16'h2000; #10;
        $display("Q1: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", I_in, Q_in, I_init, Q_init, PHASE_init);

        // Q2: (-1, 1) -> Rotate -90, Phase +0.5 (90 deg)
        I_in = -16'h2000; Q_in = 16'h2000; #10;
        $display("Q2: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", I_in, Q_in, I_init, Q_init, PHASE_init);

        // Q3: (-1, -1) -> Rotate +90, Phase -0.5 (-90 deg)
        I_in = -16'h2000; Q_in = -16'h2000; #10;
        $display("Q3: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", I_in, Q_in, I_init, Q_init, PHASE_init);

        // Q4: (0, 0) -> No change, Phase 0
        I_in = 16'h0000; Q_in = 16'h0000; #10;
        $display("Q4: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", I_in, Q_in, I_init, Q_init, PHASE_init);

        // Q5: (0, 1) -> No change, Phase 0
        I_in = -16'h0000; Q_in = 16'h2000; #10;
        $display("Q5: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", I_in, Q_in, I_init, Q_init, PHASE_init);

        // Q6: (0, -1) -> No change, Phase 0
        I_in = -16'h0000; Q_in = -16'h2000; #10;
        $display("Q6: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", I_in, Q_in, I_init, Q_init, PHASE_init);

        // Q7: (1, 0) -> rotate -90, phase +0.5 
        I_in = 16'h2000; Q_in = 16'h0000; #10;
        $display("Q7: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", I_in, Q_in, I_init, Q_init, PHASE_init);

        // Q8: (-1, 0) -> Rotate +90, Phase -0.5 
        I_in = -16'h2000; Q_in = 16'h0000; #10;
        $display("Q8: I=%d, Q=%d -> I_out=%d, Q_out=%d, P=%h", I_in, Q_in, I_init, Q_init, PHASE_init);


    end
endmodule

