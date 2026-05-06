`timescale 1ns / 1ps

module top_cordic_tb();

    parameter int WIDTH = 6;
    parameter int WIDTH_PHASE = WIDTH + 2;
    parameter int BUS_A_WIDTH = 12;
    parameter int BUS_B_WIDTH = 10;
    parameter int BUS_C_WIDTH = 12;
    parameter int BUS_D_WIDTH = 2;
    parameter int CFG_WIDTH = 3;
    parameter real PI = 3.141592653589793;
 
    // DUT signals
    logic i_clk;
    logic i_rst_n;
    logic [2:0] i_top_cfg;
    logic [2:0] i_wrapper_cfg;
    logic [BUS_A_WIDTH-1:0] i_bus_a;
    logic [BUS_B_WIDTH-1:0] i_bus_b;
    logic [BUS_C_WIDTH-1:0] o_bus_c;
    logic [1:0] o_bus_d;

    // (output observation done directly from `o_bus_c` LSBs)

    // ------------------------------------------------------------------
    // Configuration modes
    // ------------------------------------------------------------------
    localparam logic [2:0] MODE_0 = 3'b000; // Input=Cordic, Output=Filter (default)
    localparam logic [2:0] MODE_1 = 3'b001; // Input=Cordic, Output=Cordic
    localparam logic [2:0] MODE_2 = 3'b010; // Input=Derivate, Output=Derivate
    localparam logic [2:0] MODE_3 = 3'b011; // Input=Filter, Output=Filter
    localparam logic [2:0] MODE_4 = 3'b100; // Input=Cordic, Output=Derivate
    localparam logic [2:0] MODE_5 = 3'b101; // Input=Cordic, Output=Filter
    localparam logic [2:0] MODE_6 = 3'b110; // Input=Derivate, Output=Filter
    localparam logic [2:0] MODE_7 = 3'b111; // Input=Filter, Output=Filter

    localparam real SCALE = 2**(WIDTH-1)-1; 

    // Clock generator
    initial begin
        i_clk = 1'b0;
        forever #50 i_clk = ~i_clk;
    end

    // DUT instantiation
    cordic_wrapper  #(
        .WIDTH_IN(WIDTH),
        .WIDTH_PHASE(WIDTH_PHASE),
        .BUS_A_WIDTH(BUS_A_WIDTH),
        .BUS_B_WIDTH(BUS_B_WIDTH),
        .BUS_C_WIDTH(BUS_C_WIDTH),
        .BUS_D_WIDTH(BUS_D_WIDTH),
        .CFG_WIDTH(CFG_WIDTH),
        .INSIDE_WRAPPER(1) // Set inside wrapper flag to 1 to enable internal muxing for testing
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(i_wrapper_cfg),
        .i_bus_a(i_bus_a),
        .i_bus_b(i_bus_b),
        .o_bus_c(o_bus_c),
        .o_bus_d(o_bus_d)
    );

    // Reset and init
    initial begin
        i_rst_n = 1'b0;
        i_top_cfg = 3'b010;    // fixed: select Cordic wrapper in top
        i_wrapper_cfg = 3'b000; // select test sequence in wrapper (will be overridden by run_cfg)
        i_bus_a = '0;
        i_bus_b = '0;
        repeat (4) @(posedge i_clk);
        i_rst_n = 1'b1;
    end

/*------------------------Sequence tasks--------------------------------*/
    task automatic cordic_spin();
        real s_angle;
        real s_i_val;
        real s_q_val;
        logic signed [WIDTH-1:0] i_cordic_i;
        logic signed [WIDTH-1:0] i_cordic_q;
        for (int i = 0; i < 40; i = i + 1) begin
            @(posedge i_clk);

            // Calculate cos/sin in simulation
            s_angle = (i * 2.0 * PI) / 40.0;
            s_i_val = $cos(s_angle);
            s_q_val = $sin(s_angle);

            // Drive bus A directly from local variables
            i_cordic_i = $rtoi(s_i_val * SCALE);
            i_cordic_q = $rtoi(s_q_val * SCALE);
            i_bus_a = {i_cordic_q, i_cordic_i};
        end
        repeat (2) @(posedge i_clk);
    endtask

    task automatic derivate_triangle_step();
        logic signed [WIDTH_PHASE-1:0] phase_val;
        for (int i = 0; i < 40; i = i + 1) begin
            phase_val = (i < 20) ? i : 39 - i;
            @(posedge i_clk);
            i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, phase_val };
        end
        repeat (2) @(posedge i_clk);
    endtask

    task automatic filter_step();
        logic signed [WIDTH_PHASE-1:0] phase_step;
        phase_step = '0;
        @(posedge i_clk);
        i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, phase_step };
        repeat (4) @(posedge i_clk);
        phase_step = {{(WIDTH_PHASE-WIDTH){1'b0}}, {1'b0, {(WIDTH-1){1'b1}}}};
        @(posedge i_clk);
        i_bus_a = { {(BUS_A_WIDTH-WIDTH_PHASE){1'b0}}, phase_step };
        repeat (8) @(posedge i_clk);
    endtask

/*------------Run configuration and apply corresponding stimulus------------------------*/
    task automatic run_cfg(input logic [2:0] cfg);
        i_wrapper_cfg = cfg;
        repeat (2) @(posedge i_clk);
        case (cfg)
            MODE_0, MODE_5: begin i_wrapper_cfg = MODE_0; cordic_spin(); end
            MODE_1:         begin cordic_spin(); end
            MODE_2:         begin derivate_triangle_step(); end
            MODE_3, MODE_7: begin i_wrapper_cfg = MODE_3; filter_step(); end
            MODE_4:         begin $display("TODO: config 4 not yet implemented"); cordic_spin(); end
            MODE_6:         begin $display("TODO: config 6 not yet implemented"); derivate_triangle_step(); end
            default:        begin $display("TODO: unsupported config %b", cfg); end
        endcase
    endtask

/*---------------- Test sequence control----------------*/

    initial begin
        @(posedge i_rst_n);
        $display("--- top_cordic_tb: starting wrapper_cfg sweep ---");

        run_cfg(MODE_0);    // default path: cordic -> filter
        run_cfg(MODE_1);    // cordic -> cordic
        run_cfg(MODE_2);    // derivate -> derivate
        run_cfg(MODE_3);    // filter -> filter
        run_cfg(MODE_4);    // cordic -> derivate
        run_cfg(MODE_5);    // cordic -> filter (same as default, retest to check for consistency)
        run_cfg(MODE_6);    // derivate -> filter
        run_cfg(MODE_7);    // filter -> filter (same as MODE_3, retest to check for consistency)

        $display("--- top_cordic_tb: finished ---");
        $finish;
    end

endmodule
