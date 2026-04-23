`timescale 1ns / 1ps

module complete_tb();
    parameter WIDTH = 6;
    parameter FILTER_N = 5;
    parameter real PI = 3.14159265359;
    parameter int OUT_WIDTH = WIDTH + $clog2(FILTER_N)+2;

    logic i_clk;
    logic i_rst_n;
    logic signed [WIDTH-1:0] i_i, i_q;

    logic signed [OUT_WIDTH-1:0] o_phase;
    

    cordic_system_complete dut (
	    .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_i(i_i), .i_q(i_q),
        .o_phase(o_phase)
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
        @(posedge i_clk);
        @(posedge i_clk);
        #2 i_rst_n <= 1; #2;
        
        for (int i = 0; i < 10; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 40.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(posedge i_clk); #1;
        end
        for (int i = 0; i < 10; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = PI * (10 - i) / 20.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(posedge i_clk); #1;
        end
        // Generate a full rotation
        for (int i = 0; i < 40; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 40.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(posedge i_clk); #1;
        end
        for (int i = 0; i < 40; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = -(i * 2.0 * PI) / 40.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i <= $rtoi(s_i_val * SCALE);
            i_q <= $rtoi(s_q_val * SCALE);
            @(posedge i_clk); #1;
        end
        #100;
        $finish;
    end
endmodule
