module cordic_top_tb();
    parameter WIDTH = 8;
    parameter WIDTH_PHASE = WIDTH + 2;
    parameter NUM_STEPS = 8;
    parameter SCALE = 2**(WIDTH_PHASE-1)-1; // For fixed-point scaling
    
    logic signed [WIDTH-1:0] i_i, i_q;
    logic signed [WIDTH_PHASE-1:0] o_phase;

    // Clock and reset
    logic i_clk;
    logic i_rst_n;

    // Clock generator
    initial i_clk = 1'b0;
    always #5 i_clk = ~i_clk;

    // Reset sequence
    initial begin
        i_rst_n = 1'b0;
        // Hold reset for a few clock cycles
        repeat (4) @(posedge i_clk);
        i_rst_n = 1'b1;
    end

    cordic_top #(
        .WIDTH_IN(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE),
        .NUM_STEPS(NUM_STEPS)
    ) dut (.*);

    // Helper to display results
    task check_phase(string label, int i, int q, int expected_phase);
        i_i = i;
        i_q = q;
        // Wait for a couple of clock cycles for the output to settle
        @(posedge i_clk);
        @(posedge i_clk);
        //$display("%s | Input: (%d, %d) -> Phase Output: %h (%d)", label, i, q, o_phase, o_phase);
        assert (o_phase==expected_phase)
            $display("PASS: %s | Expected Phase: %h, Got Phase: %h", label, expected_phase, o_phase); 
        else 
            $display("ERROR: %s | Expected Phase: %h, Got Phase: %h", label, expected_phase, o_phase);
    endtask   

    initial begin
        // Wait for reset deassertion before starting tests
        @(posedge i_rst_n);
        $display("--- Starting Full CORDIC Phase Test ---");
        
        // Test 0 degrees (I=max, Q=0) -> Expected Phase: 0
        check_phase("0   Deg", 8'h40, 8'h00, 1);
        
        // Test 90 degrees (I=0, Q=max) -> Expected Phase: 0x4000 (your 0.5 scale)
        check_phase("90  Deg", 8'h00, 8'h40, SCALE/2);
        
        // Test -90 degrees (I=0, Q=-max) -> Expected Phase: 0xC000 (signed -0.5)
        check_phase("-90 Deg", 8'h00, -8'h40, -SCALE/2);
        
        // Test 45 degrees (I=Q) -> Expected Phase: 0x2000 (0.25 scale)
        check_phase("45  Deg", 8'h20, 8'h20, SCALE/4);
        
        // Test 180 degrees (I=-max, Q=0) -> Should rotate via Q2/Q3 logic
        check_phase("180 Deg", -8'h40, 8'h00, SCALE);

        $display("---------------------------------------");
        $finish;
    end
endmodule
