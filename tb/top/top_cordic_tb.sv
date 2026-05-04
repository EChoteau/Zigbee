`timescale 1ns / 1ps

module top_cordic_tb();
    parameter int WIDTH = 6;
    parameter int WIDTH_PHASE = WIDTH + 2;
    parameter int BUS_A_WIDTH = 12;
    parameter int BUS_B_WIDTH = 10;
    parameter int BUS_C_WIDTH = 12;
    parameter real PI = 3.141592653589793;

    // DUT ports
    logic i_clk;
    logic i_rst_n;
    logic [2:0] i_top_cfg;
    logic [2:0] i_wrapper_cfg;
    logic [BUS_A_WIDTH-1:0] i_bus_a;
    logic [BUS_B_WIDTH-1:0] i_bus_b;
    logic [BUS_C_WIDTH-1:0] o_bus_c;
    logic [1:0] o_bus_d;

    // Clock generator
    initial begin
        i_clk = 1'b0;
        forever #5 i_clk = ~i_clk;
    end

    // Instantiate top
    top dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_top_cfg(i_top_cfg),
        .i_wrapper_cfg(i_wrapper_cfg),
        .i_bus_a(i_bus_a),
        .i_bus_b(i_bus_b),
        .o_bus_c(o_bus_c),
        .o_bus_d(o_bus_d)
    );

    // Reset and configuration
    initial begin
        i_rst_n = 1'b0;
        // Select Cordic wrapper in `top` and request Cordic output from wrapper
        i_top_cfg = 3'b010;    // selects cordic wrapper
        i_wrapper_cfg = 3'b001; // cordic_wrapper MODE_1 -> o_bus_c = w_phase_cordic
        i_bus_a = '0;
        i_bus_b = '0;
        repeat (4) @(posedge i_clk);
        i_rst_n = 1'b1;
    end

    // Rotating-vector stimulus (reuse pattern from tb/cordic/complete_tb.sv)
    real angle;
    real r_i, r_q;
    localparam real SCALE = 2**(WIDTH-1)-1; // fixed-point scale for I/Q
    logic signed [WIDTH-1:0] si, sq;

    initial begin
        // Wait until reset is released
        @(posedge i_rst_n);
        $display("--- top Cordic-only TB: sending rotating vector to i_bus_a ---");

        int steps = 32;
        for (int k = 0; k < steps; k = k + 1) begin
            angle = (k * 2.0 * PI) / steps;
            r_i = $cos(angle);
            r_q = $sin(angle);
            si = $rtoi(r_i * SCALE);
            sq = $rtoi(r_q * SCALE);
            // cordic_wrapper expects LSBs = I, next bits = Q (w_cordic_i = i_bus_a[WIDTH-1:0])
            i_bus_a = {sq, si};
            @(negedge i_clk);
            // allow one more cycle for propagation
            @(negedge i_clk);
            $display("step %0d angle=%0f I=%0d Q=%0d phase_out=%0h", k, angle, si, sq, o_bus_c[WIDTH_PHASE-1:0]);
        end

        $display("--- Finished top Cordic-only TB ---");
        $finish;
    end

endmodule
