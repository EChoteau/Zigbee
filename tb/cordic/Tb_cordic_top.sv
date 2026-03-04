module tb_cordic_top();
    parameter WIDTH = 8;
    parameter WIDTH_PHASE = WIDTH + 2;
    parameter NUM_STEPS = 8;
    
    logic signed [WIDTH-1:0] I_in, Q_in;
    logic signed [WIDTH_PHASE-1:0] Phase_out;

    cordic_top #(
        .WIDTH_IN(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE),
        .NUM_STEPS(NUM_STEPS)
    ) dut (.*);

    // Helper to display results
    task check_phase(string label, int i, int q);
        I_in = i; Q_in = q;
        #10;
        $display("%s | Input: (%d, %d) -> Phase Output: %h (%d)", label, i, q, Phase_out, Phase_out);
    endtask

    initial begin
        $display("--- Starting Full CORDIC Phase Test ---");
        
        // Test 0 degrees (I=max, Q=0) -> Expected Phase: 0
        check_phase("0   Deg", 8'h40, 8'h00);
        
        // Test 90 degrees (I=0, Q=max) -> Expected Phase: 0x4000 (your 0.5 scale)
        check_phase("90  Deg", 8'h00, 8'h40);
        
        // Test -90 degrees (I=0, Q=-max) -> Expected Phase: 0xC000 (signed -0.5)
        check_phase("-90 Deg", 8'h00, -8'h40);
        
        // Test 45 degrees (I=Q) -> Expected Phase: 0x2000 (0.25 scale)
        check_phase("45  Deg", 8'h20, 8'h20);
        
        // Test 180 degrees (I=-max, Q=0) -> Should rotate via Q2/Q3 logic
        check_phase("180 Deg", -8'h40, 8'h01);

        $display("---------------------------------------");
    end
endmodule

