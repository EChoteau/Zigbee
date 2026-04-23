`timescale 1ns / 1ps

module cordic_top_sine_tb;

    // Parameters
    parameter WIDTH = 6;
    parameter WIDTH_PHASE = WIDTH + 2;
    parameter NUM_STEPS = WIDTH + 2;
    parameter real PI = 3.14159265359;

    // Clock
    logic i_clk;
    logic i_rst_n;

    // DUT Inputs (Registered)
    logic signed [WIDTH-1:0] i_i_in_reg;
    logic signed [WIDTH-1:0] i_q_in_reg;

    // DUT Output (Registered)
    logic signed [WIDTH_PHASE-1:0] o_phase_out_reg;
    
    // --- Fix: Declare raw output wire here ---
    wire signed [WIDTH_PHASE-1:0] w_phase_out_raw;
    assign o_phase_out_reg = w_phase_out_raw;

    // --- Instantiate the Device Under Test (DUT) ---
    cordic_top #(
        .WIDTH_IN(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE),
        .NUM_STEPS(NUM_STEPS)
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_i(i_i_in_reg),
        .i_q(i_q_in_reg),
        .o_phase(w_phase_out_raw) // Connected to wire declared above
    );

    // --- Clock Generation ---
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    // --- Input Generation (Rotating Vector) ---
    real s_angle;
    real s_i_val, s_q_val;
    
    // Fixed-point scaling factor
    localparam real SCALE = 2**(WIDTH-1)-1; 

    initial begin
        // Initialize
        i_i_in_reg = 0;
        i_q_in_reg = 0;
        s_angle = 0.0;
	    i_rst_n = 1;
        
        @(posedge i_clk);
        
        // Generate a full rotation
        for (int i = 0; i < 720; i = i + 1) begin
            @(posedge i_clk);
            
            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 360.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i_in_reg <= $rtoi(s_i_val * SCALE);
            i_q_in_reg <= $rtoi(s_q_val * SCALE);
        end
        #100;
        $finish;
    end
endmodule
