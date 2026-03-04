module tb_complete();
    parameter WIDTH = 8;
    parameter WIDTH_PHASE = WIDTH + 2;
    parameter FILTER_N = 8;
    parameter real PI = 3.14159265359;
    parameter int OUT_WIDTH = WIDTH + $clog2(FILTER_N);

    logic clk;
    logic rst_n;
    logic signed [WIDTH-1:0] I_in, Q_in;
    logic signed [WIDTH_PHASE-1:0] phase_cordic;
    logic signed [WIDTH_PHASE-1:0] phase_deriv;
    logic signed [OUT_WIDTH-1:0] phase_filter;
    

    cordic_top #(
        .WIDTH_IN(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE)
    ) cordic_top_inst (
        .I_in(I_in), .Q_in(Q_in),
        .Phase_out(phase_cordic)
    );

    derivative #(.WIDTH(WIDTH_PHASE)) derivative_inst (
        .clk(clk),
        .rst_n(rst_n),
        .phase_in(phase_cordic),
        .phase_deriv(phase_deriv)
    );

    boxcar_filter #(
        .WIDTH(WIDTH_PHASE), 
        .N(FILTER_N)
    ) boxcar_filter_inst (
        .clk(clk), .rst_n(rst_n),
        .data_in(phase_deriv), .data_out(phase_filter)
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
        i_val = 0;
        q_val = 0;
        angle = 0.0;
        rst_n = 0;
        I_in <= 0;
        Q_in <= 0;
        @(posedge clk);
        @(posedge clk);
        rst_n = 1;
        
        for (int i = 0; i < 10; i = i + 1) begin
            // Calculate cos/sin in simulation
            angle = (i * 2.0 * PI) / 40.0;
            i_val = $cos(angle);
            q_val = $sin(angle);
            
            // Assign to registered inputs
            I_in <= $rtoi(i_val * SCALE);
            Q_in <= $rtoi(q_val * SCALE);
            @(posedge clk);
        end
        for (int i = 0; i < 10; i = i + 1) begin
            // Calculate cos/sin in simulation
            angle = PI * (10 - i) / 20.0;
            i_val = $cos(angle);
            q_val = $sin(angle);
            
            // Assign to registered inputs
            I_in <= $rtoi(i_val * SCALE);
            Q_in <= $rtoi(q_val * SCALE);
            @(posedge clk);
        end
        // Generate a full rotation
        for (int i = 0; i < 40; i = i + 1) begin
            // Calculate cos/sin in simulation
            angle = (i * 2.0 * PI) / 40.0;
            i_val = $cos(angle);
            q_val = $sin(angle);
            
            // Assign to registered inputs
            I_in <= $rtoi(i_val * SCALE);
            Q_in <= $rtoi(q_val * SCALE);
            @(posedge clk);
        end
        for (int i = 0; i < 40; i = i + 1) begin
            // Calculate cos/sin in simulation
            angle = -(i * 2.0 * PI) / 40.0;
            i_val = $cos(angle);
            q_val = $sin(angle);
            
            // Assign to registered inputs
            I_in <= $rtoi(i_val * SCALE);
            Q_in <= $rtoi(q_val * SCALE);
            @(posedge clk);
        end
        #100;
        $finish;
    end
endmodule

