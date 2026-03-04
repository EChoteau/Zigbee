module tb_derive();
    parameter WIDTH = 16;
    parameter real PI = 3.14159265358979323846;

    logic clk;
    logic rst_n;
    logic signed [WIDTH-1:0] phase_in;
    logic signed [WIDTH-1:0] phase_deriv;

    derivative #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .phase_in(phase_in),
        .phase_deriv(phase_deriv)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        real theta;
        real sin_val;
        // Initialize signals
        rst_n = 0;
        phase_in = 0;

        // Reset the system
        #18;
        rst_n = 1;
        #2;

        // Generate Sine Wave
        for (int i = 0; i < 100; i++) begin
            theta = 2.0 * PI * i / 50.0;
            sin_val = $sin(theta);
            
            @(posedge clk);
            phase_in <= $rtoi(sin_val * ((1 << (WIDTH-1)) - 1));
        end
        $finish;
    end
endmodule
