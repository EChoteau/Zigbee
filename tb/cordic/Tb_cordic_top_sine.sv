`timescale 1ns / 1ps

module tb_cordic_top_sine;

    // Parameters
    parameter int WIDTH = 16;
    parameter int NUM_STEPS = 6;
    parameter real PI = 3.14159265359;

    // Clock
    logic clk;

    // DUT Inputs (Registered)
    logic signed [WIDTH-1:0] I_in_reg;
    logic signed [WIDTH-1:0] Q_in_reg;

    // DUT Output (Registered)
    logic signed [WIDTH-1:0] Phase_out_reg;
    
    // --- Fix: Declare raw output wire here ---
    wire signed [WIDTH-1:0] Phase_out_raw;

    // --- Instantiate the Device Under Test (DUT) ---
    cordic_top #(
        .WIDTH(WIDTH),
        .NUM_STEPS(NUM_STEPS)
    ) dut (
        .I_in(I_in_reg),
        .Q_in(Q_in_reg),
        .Phase_out(Phase_out_raw) // Connected to wire declared above
    );

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // --- Input Generation (Rotating Vector) ---
    real angle;
    real i_val, q_val;
    
    // Fixed-point scaling factor (Assuming signed 16-bit, max value is 32767)
    localparam real SCALE = 32767.0; 

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
            
            // Display values
            $display("Time: %t | Angle: %d deg | Cos: %d | Sin: %d", 
                     $time, i, $rtoi(i_val), $rtoi(q_val));
        end
        
        #100;
        $finish;
    end

    // --- Output Registration ---
    always @(posedge clk) begin
        Phase_out_reg <= Phase_out_raw;
        $display("Time: %t | Phase Out (Raw): %d", $time, Phase_out_raw);
    end

endmodule
