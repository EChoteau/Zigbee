`timescale 1ns / 1ps

module complete_tb();
    parameter WIDTH = 6;
    parameter FILTER_N = 5;
    parameter real PI = 3.14159265359;
    parameter int OUT_WIDTH = WIDTH + 2; // matches cordic_system WIDTH_PHASE

    logic i_clk;
    logic i_rst_n;
    logic signed [WIDTH-1:0] i_i, i_q;

    logic signed [OUT_WIDTH-1:0] o_phase;
    

    cordic_system dut (
	    .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_i(i_i), .i_q(i_q),
        .o_phase(o_phase),
        .i_wrapper_flag(1'b0) // Set wrapper flag to 0 for direct testing of cordic system
    );

    // --- Clock Generation ---
    initial begin
        i_clk = 0;
        forever #50 i_clk = ~i_clk;
    end

    // --- Input Generation (Rotating Vector) ---
    real s_angle;
    real s_i_val, s_q_val;
    
    // Fixed-point scaling factor
    localparam real SCALE = 2**(WIDTH-1)-1; 

    initial begin
        // Initialize
        s_i_val = 0;
        s_q_val = 0;
        s_angle = 0.0;
        i_rst_n = 0;
        i_i <= SCALE;
        i_q <= 0;
        @(negedge i_clk);
        @(negedge i_clk);
        #2 i_rst_n <= 1; #2;
        
        for (int i = 0; i < 5; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 20.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(negedge i_clk); #1;
        end
        for (int i = 0; i < 5; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = PI * (5 - i) / 10.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(negedge i_clk); #1;
        end
        // Generate a full rotation
        for (int i = 0; i < 20; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 20.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(negedge i_clk); #1;
        end
        for (int i = 0; i < 20; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = -(i * 2.0 * PI) / 20.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(negedge i_clk); #1;
        end
        #100;
        i_rst_n = 0;
        i_i <= SCALE;
        i_q <= 0;
        @(negedge i_clk);
        @(negedge i_clk);
        #2 i_rst_n <= 1; #2;
                
        // Generate a full rotation
        for (int i = 0; i < 20; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 20.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(negedge i_clk); #1;
        end
        // Generate a few rapid rotation
        for (int i = 0; i < 12; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 4.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(negedge i_clk); #1;
        end
        $finish;
    end
endmodule
