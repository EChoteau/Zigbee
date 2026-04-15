`timescale 1ns / 1ps

module complete_tb();
    parameter WIDTH = 8;
    parameter FILTER_N = 8;
    parameter real PI = 3.14159265359;
    parameter int OUT_WIDTH = WIDTH + $clog2(FILTER_N)+2;

    logic i_clk;
    logic i_rst_n;
    logic signed [WIDTH-1:0] i_i_in, i_q_in;

    logic signed [OUT_WIDTH-1:0] o_phase_out;
    

    cordic_system_complete dut (
	    .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_i_in(i_i_in), .i_q_in(i_q_in),
        .o_phase_out(o_phase_out)
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
        i_i_in <= SCALE;
        i_q_in <= 0;
        @(posedge i_clk);
        @(posedge i_clk);
        #2 i_rst_n <= 1; #2;
        
        for (int i = 0; i < 10; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 40.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i_in <= $rtoi(s_i_val * SCALE);
            i_q_in <= $rtoi(s_q_val * SCALE);
            @(posedge i_clk); #1;
        end
        for (int i = 0; i < 10; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = PI * (10 - i) / 20.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i_in <= $rtoi(s_i_val * SCALE);
            i_q_in <= $rtoi(s_q_val * SCALE);
            @(posedge i_clk); #1;
        end
        // Generate a full rotation
        for (int i = 0; i < 40; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 40.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i_in <= $rtoi(s_i_val * SCALE);
            i_q_in <= $rtoi(s_q_val * SCALE);
            @(posedge i_clk); #1;
        end
        for (int i = 0; i < 40; i = i + 1) begin
            // Calculate cos/sin in simulation
            s_angle = -(i * 2.0 * PI) / 40.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);
            
            // Assign to registered inputs
            i_i_in <= $rtoi(s_i_val * SCALE);
            i_q_in <= $rtoi(s_q_val * SCALE);
            @(posedge i_clk); #1;
        end
        #100;
        $finish;
    end
endmodule
