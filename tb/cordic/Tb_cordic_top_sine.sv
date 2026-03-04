`timescale 1ns / 1ps

module tb_cordic_top_sine;

    // Parameters
    parameter WIDTH = 8;
    parameter WIDTH_PHASE = WIDTH + 2;
    parameter NUM_STEPS = 8;
    parameter real PI = 3.14159265359;

    // Clock
    logic clk;

    // DUT Inputs (Registered)
    logic signed [WIDTH-1:0] I_in_reg;
    logic signed [WIDTH-1:0] Q_in_reg;

    // DUT Output (Registered)
    logic signed [WIDTH_PHASE-1:0] Phase_out_reg;
    
    // --- Fix: Declare raw output wire here ---
    wire signed [WIDTH_PHASE-1:0] Phase_out_raw;

    // --- Instantiate the Device Under Test (DUT) ---
    cordic_top #(
        .WIDTH_IN(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE),
        .NUM_STEPS(NUM_STEPS)
    ) dut (
        .I_in(I_in_reg),
        .Q_in(Q_in_reg),
        .Phase_out(Phase_out_raw) // Connected to wire declared above
    );

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- Input Generation (Rotating Vector) ---
    real angle;
    real i_val, q_val;
    
    // Fixed-point scaling factor
    localparam real SCALE = 2**(WIDTH-1)-1; 

    initial begin
        // Initialize
        I_in_reg = 0;
        Q_in_reg = 0;
        angle = 0.0;
        
        @(posedge clk);
        
        // Generate a full rotation
        for (int i = 0; i < 720; i = i + 1) begin
            @(posedge clk);
            
            // Calculate cos/sin in simulation
            angle = (i * 2.0 * PI) / 360.0;
            i_val = $cos(angle);
            q_val = $sin(angle);
            
            // Assign to registered inputs
            I_in_reg <= $rtoi(i_val * SCALE);
            Q_in_reg <= $rtoi(q_val * SCALE);
        end
        #100;
        $finish;
    end
endmodule
