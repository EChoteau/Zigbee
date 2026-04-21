module derive_tb();
    parameter WIDTH = 16;
    parameter real PI = 3.14159265358979323846;
    parameter int DERIV_TOL = 2;

    logic i_clk;
    logic i_rst_n;
    logic signed [WIDTH-1:0] i_phase;
    logic signed [WIDTH-1:0] o_phase_deriv;

    derivative #(.WIDTH(WIDTH)) uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_phase(i_phase),
        .o_phase_deriv(o_phase_deriv)
    );

    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    task automatic check_derivative(
        input int idx,
        input logic signed [WIDTH-1:0] i_expected
    );
        assert ((o_phase_deriv >= (i_expected - DERIV_TOL)) &&
                (o_phase_deriv <= (i_expected + DERIV_TOL)))
        else begin
            $error("ERROR: idx=%0d expected=%0d got=%0d", idx, i_expected, o_phase_deriv);
        end
    endtask

    initial begin
        real theta;
        real sin_val;
        real delta;
        real deriv_real;
        logic signed [WIDTH-1:0] s_next_input;
        logic signed [WIDTH-1:0] s_expected_deriv;

        // Initialize signals
        i_rst_n = 0;
        i_phase = 0;
        delta = 2.0 * PI / 50.0;

        // Reset the system
        #18;
        i_rst_n = 1;
        #2;

        // Generate Sine Wave
        for (int i = 0; i < 100; i++) begin
            theta = 2.0 * PI * i / 50.0;
            sin_val = $sin(theta);
            s_next_input = $rtoi(sin_val * ((1 << (WIDTH-1)) - 1));
            
            // Drive input away from the sampling edge to avoid race conditions.
            @(negedge i_clk);
            i_phase <= s_next_input;

            // Check derivative right after DUT registers update.
            @(posedge i_clk);
            #1;

            // Discrete derivative of sampled sine: x[n]-x[n-1]
            // = 2*A*sin(delta/2)*cos(theta - delta/2)
            deriv_real = ((1 << (WIDTH-1)) - 1) *
                         (2.0 * $sin(delta / 2.0)) *
                         $cos(theta - (delta / 2.0));
            s_expected_deriv = $rtoi(deriv_real);
            check_derivative(i, s_expected_deriv);
        end
        $finish;
    end
endmodule
